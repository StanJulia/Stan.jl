# Test script to test Stan on Windows

try
  global CMDSTAN_HOME = @static is_windows() ? "C:\\cmdstan" : CMDSTAN_HOME
  Pkg.rm("Stan")
  Pkg.rm("Stan")
  Pkg.clone("Stan")
catch e
  println(e)
end

# Go to the Stan.jl package directory

ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Bernoulli")
cd(ProjDir) do

isdir("tmp") &&
  rm("tmp", recursive=true);

try
  include(joinpath(ProjDir, "bernoulli.jl"))
catch e
  println(e)
end

println("After include('bernoulli.jl'), CMDSTAN_HOME is set to: $(CMDSTAN_HOME)")
cd(stanmodel.tmpdir)
run(`ls`)
println()
println(stanmodel.command)
println()

end # cd

