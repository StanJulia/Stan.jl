using Stan

ProjDir = dirname(@__FILE__)
cd(ProjDir) #do

  const simplecode = "
  data {real sigma;}
  parameters {real y;}
  model {y ~ normal(0,sigma);}
  "

  #stanmodel = Stanmodel(Sample(thin=5), name="simple", model=simplecode);
  stanmodel = Stanmodel(thin=5, name="simple", model=simplecode);
  sim = stan(stanmodel, [Dict("sigma" => 1.)], CmdStanDir=CMDSTAN_HOME);

  #end