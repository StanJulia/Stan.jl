######### Stan ODE example  ###########
#
# This is very experimental.
#
# Running this example with a single chain often returns a completed simulation.
# As more chains are added, you will find the ODE solver and/or Stan HMC might not finish,
# If this happens, in the REPL, ^C will terminate the run. Trying it a few more time
# will typically lead to a successful simulation. On my system completion takes < 1 minute.
#
# Bob Carpenter suggested to lower the stepsize and increase acceptance rate. This can
# be done as shown below (commented out lines 97 and 97). Limited testing has not shown
# guaranteed improvements in successful completion of the simulation.
#

using Stan, Distributions

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  odemodel = "
  functions {
         real[] sho(real t,
                    real[] y,
                    real[] theta,
                    real[] x_r,
                    int[] x_i) {
           real dydt[2];
           dydt[1] <- y[2];
           dydt[2] <- -y[1] - theta[1] * y[2];
           return dydt;
          }
  }

  data {
    int<lower=1> T;
    int<lower=1> M;
    real t0;
    #real y0[M];
    real ts[T];
    real y[T,M];
  }

  transformed data {
    real x_r[0];
    int x_i[0];
  }

  parameters {
    real y0[2];
    vector<lower=0>[2] sigma;
    real theta[1];
  }

  model {
    real y_hat[T,2];
    sigma ~ cauchy(0,2.5);
    theta ~ normal(0,1);
    y0 ~ normal(0,1);
    y_hat <- integrate_ode(sho, y0, t0, ts, theta, x_r, x_i);
    for (t in 1:T)
     y[t] ~ normal(y_hat[t], sigma);
  }
  "

  #Just store date in ho.csv, drop the header
  ho_data = readcsv("ho.csv.data", header=true)[1];

  #Extract initial values in row 1 of ho_data
  t0 = ho_data[1, 1]
  y0 = reshape(ho_data[1, 2:3], 2)

  # Now we can drop the first row of ho_data
  ts = ho_data[2:end, 1]
  ho_data = ho_data[2:end, 2:3]

  #Get the proper sizes to pass to CmdStan
  T = size(ho_data, 1)
  M = size(ho_data, 2)

  #Prepare to add the noise
  sigma = 0.15
  noise = [rand(Normal(0, sigma)) for i in 1:T, j in 1:M]
  y = ho_data + noise

  odedict =
    Dict(
      "T" => T, 
      "M" => M,
      "t0" => t0,
      "y0" => y0,
      "ts" => ts,
      "y" => y)

  global stanmodel, rc, sim1
  stanmodel = Stanmodel(name="ode", model=odemodel, nchains=2);
  #stanmodel.method.algorithm.stepsize = 0.7 # default stepsize=1.0
  #stanmodel.method.adapt.delta = 0.9 # default delta=0.8

  println("\nStanmodel that will be used:")
  stanmodel |> display
  println()

  rc, sim1 = stan(stanmodel, [odedict], ProjDir, diagnostics=false,
    CmdStanDir=CMDSTAN_HOME);

end # cd
