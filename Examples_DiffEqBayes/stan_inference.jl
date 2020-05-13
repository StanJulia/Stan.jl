struct StanModel{M,R,C,N}
  model::M
  return_code::R
  chains::C
  cnames::N
end

struct StanODEData
end

function generate_priors(n,priors)
  priors_string = ""
  if priors==nothing
    for i in 1:n
      priors_string = string(priors_string,"theta[$i] ~ normal(0, 1)", " ; ")
    end
  else
    for i in 1:n
      priors_string = string(priors_string,"theta[$i] ~",stan_string(priors[i]),";")
    end
  end
  priors_string
end

function generate_theta(n,priors)
  theta = ""
  for i in 1:n
    upper_bound = ""
    lower_bound = ""
    if !isnothing(priors) && maximum(priors[i]) != Inf
      upper_bound = string("upper=",maximum(priors[i]))
    end
    if !isnothing(priors) && minimum(priors[i]) != -Inf
      lower_bound = string("lower=",minimum(priors[i]))
    end
    if lower_bound != "" && upper_bound != ""
      theta = string(theta,"real","<$lower_bound",",","$upper_bound>"," theta$i",";")
    elseif lower_bound != ""
      theta = string(theta,"real","<$lower_bound",">"," theta$i",";")
    elseif upper_bound != ""
      theta = string(theta,"real","<","$upper_bound>"," theta$i",";")
    else
      theta = string(theta,"real"," theta$i",";")
    end
  end
  return theta
end

function stan_inference(prob::DiffEqBase.DEProblem, t, data, 
  priors=nothing, 
  stanmodel=nothing;
  alg=:rk45, num_samples=1000, num_warmup=1000, reltol=1e-3,
  abstol=1e-6, maxiter=Int(1e5),likelihood=Normal,
  vars=(StanODEData(),InverseGamma(3,3)),nchains=1,
  sample_u0 = false, save_idxs = nothing, diffeq_string = nothing,
  printsummary = true)

  tmpdir = "$(pwd())/tmp"

  save_idxs !== nothing && length(save_idxs) == 1 ? save_idxs = save_idxs[1] : save_idxs = save_idxs
  length_of_y = length(prob.u0)
  save_idxs = something(save_idxs, 1:length_of_y)
  length_of_params = length(vars)
  if isnothing(diffeq_string)
    sys = first(ModelingToolkit.modelingtoolkitize(prob))
    length_of_parameter = length(sys.ps) + sample_u0 * length(save_idxs)
  else
    length_of_parameter = length(prob.p) + sample_u0 * length(save_idxs)
  end
  if alg ==:rk45
    algorithm = "integrate_ode_rk45"
  elseif alg == :bdf
    algorithm = "integrate_ode_bdf"
  else
    error("The choices for alg are :rk45 or :bdf")
  end
  hyper_params = ""
  tuple_hyper_params = ""
  setup_params = ""
  thetas = ""
  theta_string = generate_theta(length_of_parameter,priors)
  for i in 1:length_of_parameter
    thetas = string(thetas,"theta[$i] = theta$i",";")
  end
  for i in 1:length_of_params
    if isa(vars[i], StanODEData)
      tuple_hyper_params = string(tuple_hyper_params,"u_hat[t,$save_idxs]",",")
    else
      dist = stan_string(vars[i])
      hyper_params = string(hyper_params,"sigma$(i-1) ~ $dist;")
      tuple_hyper_params = string(tuple_hyper_params,"sigma$(i-1)",",")
      setup_params = string(setup_params,"row_vector<lower=0>[$(length(save_idxs))] sigma$(i-1);")
    end
  end
  tuple_hyper_params = tuple_hyper_params[1:length(tuple_hyper_params)-1]
  priors_string = string(generate_priors(length_of_parameter,priors))
  stan_likelihood = stan_string(likelihood)
  if sample_u0
    nu = length(save_idxs)
    if nu < length(prob.u0)
      u0 = "{"
      for u_ in prob.u0[nu+1:length(prob.u0)]
        u0 = u0*string(u_)
      end
      u0 = u0*"}"
      integral_string = "u_hat = $algorithm(sho, append_array(theta[1:$nu],$u0), t0, ts, theta[$(nu+1):$length_of_parameter], x_r, x_i, $reltol, $abstol, $maxiter);"
    else 
      integral_string = "u_hat = $algorithm(sho, theta[1:$nu], t0, ts, theta[$(nu+1):$length_of_parameter], x_r, x_i, $reltol, $abstol, $maxiter);"
    end
  else
    integral_string = "u_hat = $algorithm(sho, u0, t0, ts, theta, x_r, x_i, $reltol, $abstol, $maxiter);"
  end
  binsearch_string = """
    int bin_search(real x, int min_val, int max_val){
      int range = (max_val - min_val + 1) / 2;
      int mid_pt = min_val + range;
      int out;
      while (range > 0) {
          if (x == mid_pt) {
              out = mid_pt;
              range = 0;
          } else {
              range = (range + 1) / 2; 
              mid_pt = x > mid_pt ? mid_pt + range: mid_pt - range; 
          }
      }
      return out;
  }
  """
  if isnothing(diffeq_string)
    diffeq_string = ModelingToolkit.build_function(
        sys.eqs,sys.states,
        sys.ps,sys.iv,
        fname = :sho,
        target = ModelingToolkit.StanTarget()
    )
  end
  parameter_estimation_model = "
  functions {
    $binsearch_string
    $diffeq_string
  }
  data {
    real u0[$length_of_y];
    int<lower=1> T;
    real internal_var___u[T,$(length(save_idxs))];
    real t0;
    real ts[T];
  }
  transformed data {
    real x_r[0];
    int x_i[0];
  }
  parameters {
    $setup_params
    $theta_string
  }
  transformed parameters{
    real theta[$length_of_parameter];
    $thetas
  }
  model{
    real u_hat[T,$length_of_y];
    $hyper_params
    $priors_string
    $integral_string
    for (t in 1:T){
      internal_var___u[t,:] ~ $stan_likelihood($tuple_hyper_params);
      }
  }
  generated quantities{
    real u_hat[T,2];
    u_hat = integrate_ode_rk45(sho, u0, t0, ts, theta, x_r, x_i, 0.001, 1.0e-6, 100000);
  }
  ";
  
  if isnothing(stanmodel)
    stanmodel = StanSample.SampleModel(
      "pem", parameter_estimation_model, [nchains],
      tmpdir=tmpdir)
      #method=StanSample.Sample(num_samples=num_samples, num_warmup=num_warmup)) 
      #printsummary = printsummary)
  end

  parameter_estimation_data = Dict("u0"=>prob.u0, "T" => length(t), "internal_var___u" => view(data, :, 1:length(t))', "t0" => prob.tspan[1], "ts" => t)
  return_code = StanSample.stan_sample(stanmodel, 
    data= parameter_estimation_data)
  if success(return_code)
    df = read_samples(stanmodel, output_format=:dataframe)
    return StanModel(stanmodel, return_code, df, names(df))
  else
    Println("\nSimulation failed.\n")
  end

end
