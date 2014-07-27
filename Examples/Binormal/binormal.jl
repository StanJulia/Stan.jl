######### Stan program example  ###########

using Stan

old = pwd()
ProjDir = homedir()*"/.julia/v0.3/Stan/Examples/Binormal"
cd(ProjDir)

binormalmodel = Stanmodel(name="binormal");
samples_df = stan(binormalmodel)

show(samples_df[1:5, :], true)
println()

cd(old)
