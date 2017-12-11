export StanModel, bayesian_inference

struct StanModel{R,C}
  return_code::R
  chain_results::C
end

function generate_differential_equation(f)
  prob_parts = split(string(f.pfuncs[1]),"\n")
  differential_equation = ""
  for i in 2:length(prob_parts)-2
    differential_equation = string(differential_equation,prob_parts[i], ";")
  end
  params = f.params
  for i in 1:length(params)
    differential_equation = replace(differential_equation,string(params[i]),"theta[$i]")
  end
  return differential_equation
end

function generate_priors(f,priors)
  priors_string = ""
  params = f.params
  if priors==nothing
    for i in 1:length(params)
      priors_string = string(priors_string,"theta[$i] ~ normal(0, 1)", " ; ")
    end
  else
    for i in 1:length(params)
      μ = priors[i].μ
      σ = priors[i].σ
      priors_string = string(priors_string,"theta[$i] ~ normal($μ, $σ)", " ; ")
    end
  end
  priors_string
end

function bayesian_inference(prob::DEProblem,t,data,priors = nothing;
    alg=:rk45,num_samples=1000, num_warmup=1000, 
    reltol=1e-3, abstol=1e-6, maxiter=100000, kwargs...)
    length_of_y = string(length(prob.u0)
    )
  f = prob.f
  length_of_parameter = string(length(f.params))
  if alg ==:rk45
    algorithm = "integrate_ode_rk45"
  else
    algorithm = "integrate_ode_bdf"
  end

  differential_equation = generate_differential_equation(f)
  priors_string = generate_priors(f,priors)

  const parameter_estimation_model = "
  functions {
    real[] sho(real t,real[] u,real[] theta,real[] x_r,int[] x_i) {
      real du[$length_of_y];
      $differential_equation
      return du;
      }
    }
  data {
    real u0[$length_of_y];
    int<lower=1> T;
    real u[T,$length_of_y];
    real t0;
    real ts[T];
    real reltol;
    real abstol;
    int maxiter;
  }
  transformed data {
    real x_r[0];
    int x_i[0];
  }
  parameters {
    vector<lower=0>[$length_of_y] sigma;
    real theta[$length_of_parameter];
  }
  model{
    real u_hat[T,$length_of_y];
    sigma ~ inv_gamma(2, 3);
    $priors_string
    u_hat = $algorithm(sho, u0, t0, ts, theta, x_r, x_i, reltol, abstol, maxiter);
    for (t in 1:T){
      u[t] ~ normal(u_hat[t], sigma);
      }
  }
  "

  stanmodel = Stanmodel(num_samples=num_samples, num_warmup=num_warmup,
   name="parameter_estimation_model", model=parameter_estimation_model);
  const parameter_estimation_data = Dict("u0"=>prob.u0, "T" => size(t)[1],
   "u" => data', "t0" => prob.tspan[1], "ts" => t,
   "reltol" => reltol, "abstol" => abstol, "maxiter" => maxiter)
  display(parameter_estimation_data)
  return_code, chain_results = stan(stanmodel, [parameter_estimation_data];
    CmdStanDir=CMDSTAN_HOME)
  return StanModel(return_code,chain_results)
end
