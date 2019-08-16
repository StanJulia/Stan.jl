######### CmdStan program example  ###########

using CmdStan, Test, Statistics

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

  observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])
  global stanmodel, rc, sim
  stanmodel = Stanmodel(num_samples=1200, thin=2, name="bernoulli", 
    output_format=:array, model=bernoullimodel);

  rc, sim, cnames = stan(stanmodel, observeddata, ProjDir, diagnostics=true,
    CmdStanDir=CMDSTAN_HOME);

  if rc == 0
    @test -0.9 < round.(mean(sim[:, 8, :]), digits=2) < -0.7
  end

end # cd
