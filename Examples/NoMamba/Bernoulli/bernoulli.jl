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

  observeddata = [
    Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
    Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]),
    Dict("N" => 10, "y" => [0, 0, 0, 0, 0, 0, 1, 0, 1, 1]),
    Dict("N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1])
  ]

  global stanmodel, rc, sim
  stanmodel = Stanmodel(num_samples=1200, thin=2, name="bernoulli", 
    model=bernoullimodel, useMamba=false);

  rc, sim = stan(stanmodel, observeddata, ProjDir, diagnostics=false,
    CmdStanDir=CMDSTAN_HOME);

  if rc == 0
    println()
    println("Test round(mean(theta), digits=1) ≈ 0.3")
    @test round(mean(sim[:,8,:]), digits=1) ≈ 0.3
  end
end # cd
