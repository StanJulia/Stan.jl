using Mamba,Stan,Distributions,Gadfly,DataFrames,Compat

# Note: This example, due to Chris Fisher, only runs on the latest development
#       version of CmdStan & Stan, i.e. the version post (Cmd)Stan 2.14.0.
#       Daniel (Lee, from the Stan team) has confirmed this.

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  #############################
  #    Load Stan Model        #
  #############################

  include("ModelFunctions.jl")
  
  Nchains = 4
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

  global init, stanmodel, rc, sim
  initpars = InitializeChain(Nsubj, Nchains, subjParm, hyperParm, subjVal, hyperVal)
  
  observeddata = [
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
  TestModel = read(f, String)
  close(f)

  stanmodel = Stanmodel(
    Sample(num_samples = 1000, num_warmup = 200, adapt = Stan.Adapt(delta=0.88)),
    nchains=Nchains, num_samples=1000, thin=1, name="TestModel", model=TestModel
  )

  @time rc, sim = stan(stanmodel, observeddata, ProjDir, init=initpars,
    diagnostics=false)
  rc == 0 && describe(sim)
end