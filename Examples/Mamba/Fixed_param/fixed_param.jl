using Mamba, Stan

ProjDir = dirname(@__FILE__);
cd(ProjDir) do

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

  if rc == 0
    
    ## Subset Sampler Output to variables suitable for describe().
    monitor = ["yhat.2",  "yhat.3",  "yhat.4",  "yhat.5",  "yhat.6",  "yhat.7"]
    sim = sim1[1:size(sim1, 1), monitor, 1:size(sim1, 3)]
    describe(sim)

    ## Plotting
    p = plot(sim, [:trace, :mean, :density, :autocor], legend=true);
    draw(p, ncol=4, filename="$(stanmodel.name)-summaryplot", fmt=:svg)
    draw(p, ncol=4, filename="$(stanmodel.name)-summaryplot", fmt=:pdf)
    
  end # rc == 0
  
end # cd
