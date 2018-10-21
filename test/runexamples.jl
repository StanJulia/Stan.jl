# Run most Stan.jl examples, remove all tmp dirs.

println("Running Stan.jl examples:")

function rmtmpdirs()
  dirs = [
    "Examples/Mamba/Bernoulli",
    "Examples/Mamba/BernoulliDiagnose",
    "Examples/Mamba/BernoulliOptimize",
    "Examples/Mamba/BernoulliVariational",
    "Examples/Mamba/BernoulliInitTheta",
    "Examples/Mamba/BernoulliScalar",
    "Examples/Mamba/Binomial",
    "Examples/Mamba/Binormal",
    "Examples/Mamba/EightSchools",
    "Examples/Mamba/Dyes",
    "Examples/Mamba/ARM/Ch03/Kid"
  ]

  for dir in dirs
    println(joinpath(dirname(pathof(Stan)), "..", dir))
    cd(joinpath(dirname(pathof(Stan)), "..", dir)) do
      isdir("tmp") && rm("tmp", recursive=true)
    end
  end
end

examples = [
  "../Examples/Mamba/Bernoulli/bernoulli.jl",
  "../Examples/Mamba/BernoulliOptimize/bernoulli_optimize.jl",
  "../Examples/Mamba/BernoulliDiagnose/bernoulli_diagnose.jl",
  "../Examples/Mamba/BernoulliVariational/bernoulli_variational.jl",
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
    println("\n$(example) done!\n")
end

rmtmpdirs()
