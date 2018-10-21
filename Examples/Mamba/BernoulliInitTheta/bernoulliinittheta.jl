######### Stan program example  ###########

using Mamba, Stan, Cairo

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  bernoullimodel = "
  data { 
    int<lower=1> N; 
    int<lower=0,upper=1> y[N];
  } 
  parameters {
    real<lower=0,upper=1> theta;
  } 
  model {
    theta ~ beta(1,1);
    y ~ bernoulli(theta);
  }
  "

  observeddata = [
    Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
    Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]),
    Dict("N" => 10, "y" => [0, 0, 0, 0, 0, 0, 1, 0, 1, 1]),
    Dict("N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1])
  ]

  initparms = Dict{String, Any}[
    Dict("theta" => 0.1),
    Dict("theta" => 0.4),
    Dict("theta" => 0.5),
    Dict("theta" => 0.9),
  ]

  monitor = ["theta", "lp__", "accept_stat__"]

  global stanmodel, rc, sim1
  stanmodel = Stanmodel(name="bernoulli", model=bernoullimodel, num_warmup=1);
  rc, sim1 = stan(stanmodel, observeddata, init=initparms, CmdStanDir=CMDSTAN_HOME)
  
  rc == 0 && sim1.value[1, end, :] |> display
end # cd
