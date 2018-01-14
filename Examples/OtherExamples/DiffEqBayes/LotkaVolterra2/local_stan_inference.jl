function local_stan_inference(prob::DEProblem,t,data,priors = nothing;alg=:rk45,
                            num_samples=1000, num_warmup=1000, reltol=1e-3,
                            abstol=1e-6, maxiter=Int(1e5),likelihood=Normal,vars=("StanODEData",InverseGamma(2,3)))
  length_of_y = string(length(prob.u0))
  length_of_params = string(length(vars))
  f = prob.f
  length_of_parameter = string(length(f.params))
  if alg ==:rk45
    algorithm = "integrate_ode_rk45"
  elseif alg == :bdf
    algorithm = "integrate_ode_bdf"
  else
    error("The choices for alg are :rk45 or :bdf")
  end
  hyper_params = ""
  tuple_hyper_params = ""
  for i in 1:length(vars)
    if vars[i] == "StanODEData"
      tuple_hyper_params = string(tuple_hyper_params,"u_hat[t]",",")
    else
      dist = stan_string(vars[i])
      hyper_params = string(hyper_params,"params[$i] ~ $dist",";")
      tuple_hyper_params = string(tuple_hyper_params,"params[$i]",",")
    end
  end
  tuple_hyper_params = tuple_hyper_params[1:endof(tuple_hyper_params)-1] 
  differential_equation = DiffEqBayes.generate_differential_equation(f)
  priors_string = string(DiffEqBayes.generate_priors(f,priors),";")
  stan_likelihood = stan_string(likelihood)
  const parameter_estimation_model = "
  functions {
    real[] sho(real t,real[] internal_var___u,real[] theta,real[] x_r,int[] x_i) {
      real internal_var___du[$length_of_y];
      $differential_equation
      return internal_var___du;
      }
    }
    data {
      real u0[2];
      int<lower=1> T;
      real internal_var___u[T,2];
      real t0;
      real ts[T];
    }
    transformed data {
      real x_r[0];
      int x_i[0];
    }
    parameters {
      row_vector<lower=0.1, upper=3.0>[2] sigma1;
      real theta[4];
    }
    model{
      real u_hat[T,2];
      sigma1 ~ inv_gamma(4.0, 1.0);
      theta[1] ~normal(1.5, 0.01);
      theta[2] ~normal(1.0, 0.01);
      theta[3] ~normal(3.0, 0.01);
      theta[4] ~normal(1.0, 0.01);
      u_hat = integrate_ode_rk45(sho, u0, t0, ts, theta, x_r, x_i, 0.001, 1.0e-6, 100000);
      for (t in 1:T){
        internal_var___u[t,:] ~ normal(u_hat[t,:],sigma1);
        }
    }
  "

  stanmodel = Stanmodel(num_samples=num_samples, num_warmup=num_warmup, name="parameter_estimation_model", model=parameter_estimation_model);
  const parameter_estimation_data = Dict("u0"=>prob.u0, "T" => size(t)[1], "internal_var___u" => data', "t0" => prob.tspan[1], "ts" => t)
  return_code, chain_results = stan(stanmodel, [parameter_estimation_data]; CmdStanDir=CMDSTAN_HOME)
  return StanModel(return_code,chain_results)
end
