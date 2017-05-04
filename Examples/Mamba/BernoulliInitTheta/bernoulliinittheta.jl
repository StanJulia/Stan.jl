######### Stan program example  ###########

using Mamba, Stan

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

  monitor = ["theta", "lp__", "accept_stat__"]

  stanmodel = Stanmodel(name="bernoulli",
    model=bernoullimodel,
    init=Stan.Init(init=bernoulliinit),
    adapt=1);

    sim1 = stan(stanmodel, bernoullidata, CmdStanDir=CMDSTAN_HOME)
    sim1.value[1, end, :] |> display
end # cd
