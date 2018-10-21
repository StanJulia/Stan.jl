# This is a test for CmdStan issue #510 (thanks to jonalm)

using Mamba, Stan, Cairo

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  simplecode = "
  data {real sigma;}
  parameters {real y;}
  model {y ~ normal(0,sigma);}
  "

  global stanmodel1, rc1, sim1
  stanmodel1 = Stanmodel(Sample(save_warmup=false, thin=5), name="simple", model=simplecode);
  rc1, sim1 = stan(stanmodel1, [Dict("sigma" => 1.)], CmdStanDir=CMDSTAN_HOME);
  describe(sim1)
  
  global stanmodel2, rc2, sim2
  stanmodel2 = Stanmodel(Sample(save_warmup=true, thin=1), name="simple", 
    thin=5, model=simplecode);
  rc2, sim2 = stan(stanmodel2, [Dict("sigma" => 1.)], CmdStanDir=CMDSTAN_HOME);
  describe(sim2)
  
  global stanmodel3, rc3, sim3
  stanmodel3 = Stanmodel(Sample(save_warmup=true, thin=5), name="simple", model=simplecode);
  rc3, sim3 = stan(stanmodel3, [Dict("sigma" => 1.)], CmdStanDir=CMDSTAN_HOME);
  describe(sim3)
  
end

# stanmodel3 should not fail.