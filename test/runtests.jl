# Test Stan.jl examples.

using DataFrames, Test

TestDir = @__DIR__
ExampleDir = joinpath(TestDir, "..")

import CompatHelperLocal as CHL
CHL.@check()

examples = [

  "../Examples/ARM/Ch03/Kid/kidscore.jl",
  "../Examples/Bernoulli/bernoulli.jl",
  "../Examples/Bernoulli/bernoulli2.jl",
  "../Examples/Binomial/binomial.jl",
  "../Examples/Binormal/binormal.jl",
  
  "../Examples/Chimpanzees/chimpanzees.jl",
  #"../Examples/Chimpanzees/chimpanzees_keyedarray.jl",

  "../Examples/Diagnose/diagnose.jl",
  "../Examples/Dyes/dyes.jl",
  "../Examples/Dyes/dyes_2.jl",
  "../Examples/EightSchools/schools8.jl",

  #"../Examples/RedCardsStudy/redcardstudy.jl",

  "../Examples/WaffleDivorce/waffle_divorce.jl",

  "../Examples/Walkthrough/walkthrough2.jl",
  "../Examples-Stan-Methods/Diagnose/diagnose.jl",
  "../Examples-Stan-Methods/Optimize/optimize.jl",
  "../Examples-Stan-Methods/Generate_Quantities/generate_quantities.jl",
  "../Examples-Stan-Methods/Parse_and_Interpolate/parse.jl",

  #"../Examples-Stan-Methods/Variational/variational.jl",
  "../Examples-Stan-Methods/StanQuap/howell1.jl",
  "../Examples-Test-Cases/Diagnostics/diagnostics.jl",
  "../Examples-Test-Cases/InitThetaDict/init_theta.jl",
  "../Examples-Test-Cases/InitThetaDictArray/init_dict_array.jl",
  "../Examples-Test-Cases/InitThetaFile/init_file.jl",
  "../Examples-Test-Cases/ScalarObs/scalar.jl",
  "../Examples-Test-Cases/ZeroLengthArray/zerolengtharray.jl",

  # Test the examples in the test directory
  
  "Examples/ARM/Ch03/Kid/kidscore.jl",
  "Examples/Bernoulli/bernoulli.jl",
  "Examples/Binomial/binomial.jl",
  "Examples/Binormal/binormal.jl",
  "Examples/Dyes/dyes.jl",
  "Examples/EightSchools/schools8.jl",
  "Examples/InferenceData/inferencedata.jl",
  "Examples/PosteriorDB/posteriordb.jl",

  "Examples-Stan-Methods/Diagnose/diagnose.jl",
  "Examples-Stan-Methods/Optimize/optimize.jl",
  #"Examples-Stan-Methods/Variational/variational.jl",
  "Examples-Stan-Methods/StanQuap/howell1.jl",

  "Examples-Test-Cases/Diagnostics/diagnostics.jl",
  "Examples-Test-Cases/InitThetaDict/init_dict.jl",
  "Examples-Test-Cases/InitThetaDictArray/init_dict_array.jl",
  "Examples-Test-Cases/InitThetaFile/init_file.jl",
  "Examples-Test-Cases/ScalarObs/scalar.jl",
  "Examples-Test-Cases/ZeroLengthArray/zerolengtharray.jl",
  "Examples-Test-Cases/MatrixInput/input_array.jl",
  "Examples-Test-Cases/MatrixInput/input_dict_symbol.jl",
  "Examples-Test-Cases/MatrixInput/input_dict_string.jl",
  "Examples-Test-Cases/MatrixInput/input_nt.jl",

  "Examples-Stan-Methods/Generate_Quantities/generate_quantities.jl",
  "Examples-Stan-Methods/Parse_and_Interpolate/parse.jl",
]

if Int(VERSION.minor) > 8
  push!(examples, "Examples/BridgeStan/bridgestan.jl")
end

if haskey(ENV, "JULIA_CMDSTAN_HOME") || haskey(ENV, "CMDSTAN")
  println("\nRunning Stan.jl v9.x test examples")

  for example in examples
      println("\n* $(joinpath(TestDir, example)) *\n")

      cd(TestDir) do
        include(joinpath(TestDir, example))
      end

  end

  println("Tests completed.")
else
  println("\nCMDSTAN or JULIA_CMDSTAN_HOME not set. Skipping tests")
end
