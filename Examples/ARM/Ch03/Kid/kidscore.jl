######### ARM Ch03: kid score example  ###########

using Stan

old=pwd()
ProjDir = Pkg.dir("Stan")*"/Examples/ARM/Ch03/Kid"
DataDir = Pkg.dir("Stan")*"/Examples/ARM/Data/"
cd(ProjDir)

stanmodel = Stanmodel(name="kid");
data_file = "kid.data.R"

println()
chains = stan(stanmodel, data_file, ProjDir)
chains[1][:samples] |> display

cd(old)
