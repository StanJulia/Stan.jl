# Test Stan.jl examples.

using DataFrames, Test

TestDir = @__DIR__
ExampleDir = joinpath(TestDir, "..")

examples = [

  "Examples/Bernoulli/bernoulli.jl",
  "Examples/Binomial/binomial.jl",
  "Examples/Binormal/binormal.jl",
  "Examples/Dyes/dyes.jl",
  "Examples/EightSchools/schools8.jl",
  "Examples/ARM/Ch03/Kid/kidscore.jl",
  
  "Examples_Stan_Methods/Diagnose/diagnose.jl",
  "Examples_Stan_Methods/Optimize/optimize.jl",
  "Examples_Stan_Methods/Variational/variational.jl",
  "Examples_Stan_Methods/StanQuap/howell1.jl",

  "Examples_Test_Cases/Diagnostics/diagnostics.jl",
  "Examples_Test_Cases/InitThetaDict/init_dict.jl",
  "Examples_Test_Cases/InitThetaDictArray/init_dict_array.jl",
  "Examples_Test_Cases/InitThetaFile/init_file.jl",
  "Examples_Test_Cases/ScalarObs/scalar.jl",
  "Examples_Test_Cases/ZeroLengthArray/zerolengtharray.jl",

  "Examples_Stan_Methods/Generate_Quantities/generate_quantities.jl",
  "Examples_Stan_Methods/Parse_and_Interpolate/parse.jl"
]

if haskey(ENV, "JULIA_CMDSTAN_HOME")
  println("\nRunning Stan.jl v6.x test examples")

  for example in examples
      println("\n* $(joinpath(TestDir, example)) *\n")

      cd(TestDir) do
        include(joinpath(TestDir, example))
      end

  end
else
  println("\nJULIA_CMDSTAN_HOME not set. Skipping tests")
end
