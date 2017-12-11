using OrdinaryDiffEq, ParameterizedFunctions, RecursiveArrayTools
#using DiffEqBayes
using Stan, Mamba
using Base.Test

include(joinpath(Pkg.dir("Stan"), "Examples", "OtherExamples", "DiffEqBayes",
  "bayesian_inference.jl"))

#=
Experimental link to DiffEqBayes examples

Possible issues to investigate:

1. Sampling results vary too much. chains often get stuck
2. @ode_def_nohes needs to be kept outside local scope block
3. Minimize string replacements in Stan language model to prevent recompilations

=#

f1 = @ode_def_nohes LotkaVolterraTest1 begin
  dx = a*x - b*x*y
  dy = -c*y + d*x*y
end a=>1.5 b=1.0 c=3.0 d=1.0

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  #isdir("tmp") && rm("tmp", recursive=true)
  isfile("LotkaVolterraTest1-summaryplot-1.pdf") &&
    rm("LotkaVolterraTest1-summaryplot-1.pdf")
    
  println("One parameter LotkaVolterra")
  u0 = [1.0,1.0]
  tspan = (0.0,10.0)
  prob1 = ODEProblem(f1,u0,tspan)
  sol = solve(prob1,Tsit5())
  t = collect(linspace(1,10,10))
  randomized = VectorOfArray([(sol(t[i]) + .01randn(2)) for i in 1:length(t)])
  data = convert(Array,randomized)
  priors = [Normal(1.5,1)]

  bayesian_result = bayesian_inference(prob1,t,data,priors;
    num_samples=500,num_warmup=1500)
  theta1 = bayesian_result.chain_results[:,["theta.1"],:]

  global sim1 = bayesian_result.chain_results[1:end,
    ["sigma.1", "sigma.2", "theta.1"], :]
  ## Plotting
  p = plot(sim1, [:trace, :mean, :density, :autocor], legend=true);
  draw(p, ncol=4, filename="LotkaVolterra-summaryplot", fmt=:pdf)

  @test mean(theta1.value[:,:,1]) ≈ 1.5 atol=1e-1
end