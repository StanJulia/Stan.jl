# Usually identical to stan_inference in DiffEqBayes. Included here for testing.

struct StanModel{R,C}
  return_code::R
  chain_results::C
end

function generate_differential_equation(f)
  theta_ex = MacroTools.postwalk(f.pfuncs[1]) do x
    i = findfirst(f.params,x)
    i != 0 ? Symbol("theta[$i]") : x
  end
  differential_equation = ""
  for i in 1:length(theta_ex.args)-1
    differential_equation = string(differential_equation,theta_ex.args[i], ";\n")
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

function stan_inference(prob::DEProblem,t,data,priors = nothing;alg=:rk45,
                            num_samples=1000, num_warmup=1000, reltol=1e-3,
                            abstol=1e-6, maxiter=Int(1e5),kwargs...)
  length_of_y = string(length(prob.u0))
  f = prob.f
  length_of_parameter = string(length(f.params))
  if alg ==:rk45
    algorithm = "integrate_ode_rk45"
  elseif alg == :bdf
    algorithm = "integrate_ode_bdf"
  else
    error("The choices for alg are :rk45 or :bdf")
  end

  differential_equation = generate_differential_equation(f)
  priors_string = generate_priors(f,priors)

  parameter_estimation_model = "
  functions {
    real[] sho(real t,real[] internal_var___u,real[] theta,real[] x_r,int[] x_i) {
      real internal_var___du[$length_of_y];
      $differential_equation
      return internal_var___du;
      }
    }
  data {
    real u0[$length_of_y];
    int<lower=1> T;
    real internal_var___u[T,$length_of_y];
    real t0;
    real ts[T];
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
    u_hat = $algorithm(sho, u0, t0, ts, theta, x_r, x_i, $reltol, $abstol, $maxiter);
    for (t in 1:T){
      internal_var___u[t] ~ normal(u_hat[t], sigma);
      }
  }
  "

  stanmodel = Stanmodel(num_samples=num_samples, num_warmup=num_warmup, name="parameter_estimation_model", model=parameter_estimation_model);
  parameter_estimation_data = Dict("u0"=>prob.u0, "T" => size(t)[1], "internal_var___u" => data', "t0" => prob.tspan[1], "ts" => t)
  return_code, chain_results = stan(stanmodel, [parameter_estimation_data]; CmdStanDir=CMDSTAN_HOME)
  return StanModel(return_code,chain_results)
end
