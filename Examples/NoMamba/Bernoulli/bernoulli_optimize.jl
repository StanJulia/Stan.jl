######### Stan program example  ###########

using Compat, Stan, Test

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  bernoulli = "
  data { 
    int<lower=0> N; 
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

  global stanmodel, rc, optim
  stanmodel = Stanmodel(Optimize(), name="bernoulli",
    model=bernoulli, useMamba=false);

  rc, optim = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME);

  if rc == 0
    optim[1] |> display
    println()

    println()
    println("Test round(optim[1][\"optimize\"][\"theta\"][1], digits=1) ≈ 0.3")
    @test round(optim[1]["optimize"]["theta"][1], digits=1) ≈ 0.3
  end
end # cd
