######### Stan program example  ###########

using Compat, Stan, Test, Statistics

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

  bernoullidata = Dict{String, Any}[
    Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
    Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]),
    Dict("N" => 10, "y" => [0, 0, 0, 0, 0, 0, 1, 0, 1, 1]),
    Dict("N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1])
  ]

  inittheta = Dict{String, Any}[
    Dict("theta" => 0.31),
    Dict("theta" => 0.32),
    Dict("theta" => 0.33),
    Dict("theta" => 0.34),
  ]

  global stanmodel
  stanmodel = Stanmodel(name="bernoulli", model=bernoullimodel,
    num_warmup=1, useMamba=false);

  global rc, sim
  rc, sim = stan(stanmodel, bernoullidata, ProjDir, 
    init=inittheta, CmdStanDir=CMDSTAN_HOME)
  
  if rc == 0
    println()
    println("Test 0.2 <= mean(theta[1]) <= 0.5)")
    @test 0.2 <= round(mean(sim[:,8,:]), digits=1) <= 0.5
  end

end # cd
