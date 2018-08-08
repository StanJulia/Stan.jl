######### Stan batch program example  ###########

using Stan, Compat, Test

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  dyes ="
  data {
    int BATCHES; 
    int SAMPLES; 
    real y[BATCHES, SAMPLES]; 
    // vector[SAMPLES] y[BATCHES]; 
  } 

  parameters {
    real<lower=0> tau_between;
    real<lower=0> tau_within; 
    real theta;
    real mu[BATCHES]; 
  } 

  transformed parameters {
    real sigma_between; 
    real sigma_within;
    sigma_between <- 1/sqrt(tau_between); 
    sigma_within <- 1/sqrt(tau_within); 
  } 

  model {
    theta ~ normal(0.0, 1E5); 
    tau_between ~ gamma(.001, .001); 
    tau_within ~ gamma(.001, .001); 

    mu ~ normal(theta, sigma_between);
    for (n in 1:BATCHES)  
      y[n] ~ normal(mu[n], sigma_within);
  }

  generated quantities {
    real sigmasq_between;
    real sigmasq_within;
  
    sigmasq_between <- 1 / tau_between;
    sigmasq_within <- 1 / tau_within;
  }
  "

  dyesdata = [
    Dict("BATCHES" => 6,
      "SAMPLES" => 5,
      "y" => reshape([
        [1545, 1540, 1595, 1445, 1595]; 
        [1520, 1440, 1555, 1550, 1440]; 
        [1630, 1455, 1440, 1490, 1605]; 
        [1595, 1515, 1450, 1520, 1560]; 
        [1510, 1465, 1635, 1480, 1580]; 
        [1495, 1560, 1545, 1625, 1445]
      ], 6, 5)
    )
  ]

  global stanmodel, rc, sim
  stanmodel = Stanmodel(name="dyes", model=dyes, useMamba=false);
  @time rc, sim = stan(stanmodel, dyesdata, ProjDir, CmdStanDir=CMDSTAN_HOME)

  if rc == 0
    println()
    println("Test round(mean(theta)/100.0, digits=0) ≈ 15.0")
    @test round(mean(sim[:,10,:])/100.0, digits=0) ≈ 15.0
  end
end # cd
