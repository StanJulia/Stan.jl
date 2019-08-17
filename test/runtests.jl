# Test Stan.jl examples.

using Test

examples = [

  "Examples/ARM/Ch03/Kid/kidscore.jl",
  "Examples/Bernoulli/bernoulli.jl",
  "Examples/Binomial/binomial.jl",
  "Examples/Binormal/binormal.jl",
  "Examples/Dyes/dyes.jl",
  "Examples/EightSchools/schools8.jl",
  
  "Examples_Stan_Methods/Diagnose/diagnose.jl",
  "Examples_Stan_Methods/Generate_Quantities/generate_quantities.jl",
  "Examples_Stan_Methods/Optimize/optimize.jl",
  "Examples_Stan_Methods/Parse_and_Interpolate/parse.jl",
  "Examples_Stan_Methods/Variational/variational.jl",
  
  "Examples_Test_Cases/Diagnostics/diagnostics.jl",
  "Examples_Test_Cases/InitThetaDict/init_dict.jl",
  "Examples_Test_Cases/InitThetaDictArray/init_dict_array.jl",
  "Examples_Test_Cases/InitThetaFile/init_file.jl",
  "Examples_Test_Cases/NamedArray/namedarray.jl",
  "Examples_Test_Cases/ScalarObs/scalar.jl",
  "Examples_Test_Cases/ZeroLengthArray/zerolengtharray.jl",
 
]

@testset "Stan.jl v6.0" begin

  for example in examples
      #println("\n  * $(example) *")
      @testset "$(example)" begin
        include(example)
      end
      #println("\n * $(example) done! *")
  end

end