using Mamba, Stan
#using Mamba, Stan, JLD, MAT, Plots
ProjDir = dirname(@__FILE__);
cd(ProjDir);
#
T = 100;
y0 = 1;
phi = 0.95;
sigma = 1;
# make the data dictionary
dat = Dict("T"=>T,"y0"=>y0,"phi"=>phi,"sigma"=>sigma);

# read in the stan program
fid = open("ar1.stan");
ar1 = readstring(fid);|
close(fid)

stanmodel= Stanmodel(name = "ar1", model = ar1, Sample(algorithm=Stan.Fixed_param()));
rc, sim1 = stan(stanmodel, [dat], ProjDir, CmdStanDir=CMDSTAN_HOME);
