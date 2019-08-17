# Run Stan.jl examples.

examples = [

  "Examples/ARM/Ch03/Kid/kidscore.jl",
  "Examples/Bernoulli/bernoulli.jl",
  "Examples/Binomial/binomial.jl",
  "Examples/Binormal/binormal.jl",
  "Examples/Dyes/dyes.jl",
  "Examples/EightSchools/schools8.jl",
  
  "Examples_Stan_Methods/Diagnose/bernoulli_diagnose.jl",
  "Examples_Stan_Methods/Generate_Quantities/generate_quantities.jl",
  "Examples_Stan_Methods/Optimize/bernoulli_optimize.jl",
  "Examples_Stan_Methods/Parse_and_Interpolate/example.jl",
  "Examples_Stan_Methods/Variational/bernoulli_variational.jl",
  
  "Examples_Test_Cases/Diagnostics/bernoulli_diagnostics.jl",
  "Examples_Test_Cases/InitThetaDict/bernoulliinittheta.jl",
  #"Examples_Test_Cases/InitThetaDictArray/bernoulliinittheta.jl",
  #"Examples_Test_Cases/InitThetaFile/bernoulliinittheta.jl",
  "Examples_Test_Cases/NamedArray/bernoulli_namedarray.jl",
  "Examples_Test_Cases/ScalarObs/bernoulliscalar.jl",
  "Examples_Test_Cases/ZeroLengthArray/zerolengtharray.jl",
  
]

for example in examples
    println("\n\n  * $(example) *")
    include(example)
    println("\n$(example) done!\n")
end
