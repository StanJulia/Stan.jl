using Mamba, Stan

ProjDir = dirname(@__FILE__)
cd(ProjDir) #do

  const simplecode = "
  data {real sigma;}
  parameters {real y;}
  model {y ~ normal(0,sigma);}
  "

  stanmodel1 = Stanmodel(Sample(save_warmup=false, thin=5), name="simple", model=simplecode);
  sim1 = stan(stanmodel1, [Dict("sigma" => 1.)], CmdStanDir=CMDSTAN_HOME);
  describe(sim1)
  
  stanmodel2 = Stanmodel(Sample(save_warmup=true, thin=1), name="simple", 
    thin=5, model=simplecode);
  sim2 = stan(stanmodel2, [Dict("sigma" => 1.)], CmdStanDir=CMDSTAN_HOME);
  describe(sim2)
  
  stanmodel3 = Stanmodel(Sample(save_warmup=true, thin=5), name="simple", model=simplecode);
  sim3 = stan(stanmodel3, [Dict("sigma" => 1.)], CmdStanDir=CMDSTAN_HOME);
  describe(sim3)
  
#end