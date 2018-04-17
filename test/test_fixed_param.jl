using Stan

ProjDir = dirname(@__FILE__);
cd(ProjDir)

isdir("tmp") && rm("tmp", recursive=true);

ar1 = "
data {
  int T;
  real y0;
  real phi;
  real sigma;
}
parameters{}
model{}
generated quantities {
  vector[T] yhat;
  yhat[1] = y0;
  for (t in 2:T)
    yhat[t] = normal_rng(phi*yhat[t-1],sigma);
}
"

#
T = 100;
y0 = 1;
phi = 0.95;
sigma = 1;

# make the data dictionary
dat = Dict("T"=>T,"y0"=>y0,"phi"=>phi,"sigma"=>sigma);

stanmodel= Stanmodel(name = "ar1", model = ar1, Sample(algorithm=Stan.Fixed_param()));
rc, sim1 = stan(stanmodel, [dat], ProjDir, CmdStanDir=CMDSTAN_HOME);

#rc == 0 && describe(sim1)

isdir("tmp") && rm("tmp", recursive=true);
