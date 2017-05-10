######### Stan program example  ###########

using Compat, Stan, Base.Test

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

  bernoullidata = [
    Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
    Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]),
    Dict("N" => 10, "y" => [0, 0, 0, 0, 0, 0, 1, 0, 1, 1]),
    Dict("N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1])
  ]

  bernoulliinit = Dict{String, Any}[
    Dict("theta" => 0.1),
    Dict("theta" => 0.4),
    Dict("theta" => 0.5),
    Dict("theta" => 0.9),
  ]

  stanmodel = Stanmodel(name="bernoulli",
    model=bernoullimodel,
    init=Stan.Init(init=bernoulliinit),
    num_warmup=1, useMamba=false);

  sim = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME)

  println()
  println("Test 0.2 < mean(theta[1]) < 0.7)")
  @test 0.2 < round(mean(sim[:,8,:]), 1) < 0.7

end # cd
