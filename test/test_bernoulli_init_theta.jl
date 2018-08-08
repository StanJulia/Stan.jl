
using Test


ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "NoMamba", "BernoulliInitTheta")
cd(ProjDir) do

  isdir("tmp") &&
    rm("tmp", recursive=true);

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
    
    theta_init = [0.1, 0.4, 0.5, 0.9]
    bernoulliinit = Dict{String, Any}[
      Dict("theta" => theta_init[1]),
      Dict("theta" => theta_init[2]),
      Dict("theta" => theta_init[3]),
      Dict("theta" => theta_init[4]),
    ]

    monitor = ["theta", "lp__", "accept_stat__"]

    stanmodel = Stanmodel(name="bernoulli",
      model=bernoullimodel,
      init=Stan.Init(init=bernoulliinit),
      adapt=1);

      sim1 = stan(stanmodel, bernoullidata, CmdStanDir=CMDSTAN_HOME)
      global sim1_values = round(sim1.value[1, end, :], digits=1)

  isdir("tmp") &&
    rm("tmp", recursive=true);

  sim1_values |> display
  
  @assert sim1_values == theta_init "Not close to theta input values."
end # cd
