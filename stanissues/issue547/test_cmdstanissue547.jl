# This is a test for CmdStan issue #547 (thanks to chris fisher & bob)

using Mamba, Stan, Cairo

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  simplecode = "
  parameters {
    real y;
  }
  model {
    y ~ normal(0, 1);
  }  "

  global stanmodel, rc, sim
  stanmodel = Stanmodel(Sample(save_warmup=true, thin=1), name="simple", model=simplecode);
  rc, sim = stan(stanmodel, [Dict("y" => 0.)], CmdStanDir=CMDSTAN_HOME);
  rc == 0 && describe(sim)
  
end

# The first sample for y (in e.g. tmp/simple_samples_1.csv, ~line 39) should be 0.