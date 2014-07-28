######### Stan program example  ###########

using Stan

old = pwd()
ProjDir = homedir()*"/.julia/v0.3/Stan/Examples/Binormal"
cd(ProjDir)

binormalmodel = Stanmodel(name="binormal");
chains = stan(binormalmodel)

chains[1][:samples] |> display
println()

cd(old)
