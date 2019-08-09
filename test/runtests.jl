# Run most Stan.jl examples, remove all tmp dirs.

println("Running Stan.jl examples:")

examples = [
#=
  "../Examples/Bernoulli/bernoulli.jl",
  "../Examples/BernoulliOptimize/bernoulli_optimize.jl",
  "../Examples/BernoulliDiagnose/bernoulli_diagnose.jl",
  "../Examples/BernoulliVariational/bernoulli_variational.jl",
  "../Examples/BernoulliInitTheta/bernoulliinittheta.jl",
  "../Examples/BernoulliScalar/bernoulliscalar.jl",
  "../Examples/Binomial/binomial.jl",
  "../Examples/Binormal/binormal.jl",
  "../Examples/EightSchools/schools8.jl",
  "../Examples/Dyes/dyes.jl",
  "../Examples/ARM/Ch03/Kid/kidscore.jl"
=#
]

for example in examples
    println("\n\n\n  * $(example) *")
    include(example)
    println("\n$(example) done!\n")
end
