using Mamba,Stan,Distributions,Gadfly,DataFrames,Compat

ProjDir = dirname(@__FILE__)
cd(ProjDir) #do

  #############################
  #    Load Stan Model        #
  #############################

  include("ModelFunctions.jl")
  
  Nchains = 2
  subjParm = ["theta"]
  hyperParm = ["kappa", "omega"]
  subjVal = Any[[.5,3]]
  hyperVal = [.5,3]

  Nsubj = 10
  Ntrials = 10
  Nobs = Nsubj*Ntrials
  kappa = .7
  omega = 5
  
  y,SubjIdx = GenerateData(kappa, omega, Nsubj, Ntrials)

  init = InitializeChain(Nsubj, Nchains, subjParm, hyperParm, subjVal, hyperVal)
  
  SimData = [
      Dict(
        "Nobs" => Nobs,
        "Nsubj" => Nsubj,
        "SubjIdx"=>SubjIdx,
        "y" => y),
  ]
  
  ###########################
  #     Run Chains          #
  ###########################

  f = open("model.stan","r")
  TestModel = readstring(f)
  close(f)

  stanmodel = Stanmodel(
    Sample(num_samples = 1000, num_warmup = 200, adapt = Adapt(delta=0.88)),
    nchains=Nchains, update=1000, thin=1, name="TestModel", model=TestModel,
    init=Stan.Init(init=init)
  )

  @time sim = stan(stanmodel, SimData, ProjDir, diagnostics=false)

  #describe(sim)

#end