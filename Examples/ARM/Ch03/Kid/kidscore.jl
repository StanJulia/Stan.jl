######### ARM Ch03: kid score example  ###########

using DataFrames, Stan

old=pwd()
ProjDir = Pkg.dir("Stan")*"/Examples/ARM/Ch03/Kid"
DataDir = Pkg.dir("Stan")*"/Examples/ARM/Data/"
cd(ProjDir)

stanmodel = Model(name="kid");
data_file = "kid.data.R"

println()
df = stan(stanmodel, data_file, ProjDir)

cd(old)
