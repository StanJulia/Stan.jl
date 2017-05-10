# Run most Stan.jl examples, leave tmp dir in place.

println("Running Stan.jl examples:")

examples = [
  "../Examples/Mamba/Bernoulli/bernoulli.jl",
  #"../Examples/Mamba/Bernoulli/bernoulli_optimize.jl",
  #"../Examples/Mamba/Bernoulli/bernoulli_diagnose.jl",
  "../Examples/Mamba/Bernoulli/bernoulli_variational.jl",
  "../Examples/Mamba/BernoulliInitTheta/bernoulliinittheta.jl",
  "../Examples/Mamba/BernoulliScalar/bernoulliscalar.jl",
  "../Examples/Mamba/Binomial/binomial.jl",
  "../Examples/Mamba/Binormal/binormal.jl",
  "../Examples/Mamba/EightSchools/schools8.jl",
  "../Examples/Mamba/Dyes/dyes.jl",
  "../Examples/Mamba/ARM/Ch03/Kid/kidscore.jl"
]

for example in examples
    println("\n\n\n  * $(example) *")
    include(example)
end

println("\n")

dirs = [
  "../Examples/Mamba/Bernoulli",
  "../Examples/Mamba/BernoulliInitTheta",
  "../Examples/Mamba/BernoulliScalar",
  "../Examples/Mamba/Binomial",
  "../Examples/Mamba/Binormal",
  "../Examples/Mamba/EightSchools",
  "../Examples/Mamba/Dyes",
  "../Examples/Mamba/ARM/Ch03/Kid"
]

for dir in dirs
  cd(dir) do
    isdir(tmp) $$ rm(tmp, recursive=true)
  end
end