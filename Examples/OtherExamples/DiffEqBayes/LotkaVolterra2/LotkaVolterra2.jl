using DiffEqBayes
using OrdinaryDiffEq, ParameterizedFunctions, RecursiveArrayTools
using Stan, Mamba, Base.Test

ProjDir = dirname(@__FILE__)
include(ProjDir*"/stan_inference.jl")

f2 = @ode_def_nohes LotkaVolterraTest2 begin
  dx = a*x - b*x*y
  dy = -c*y + d*x*y
end a=>1.5 b=>1.0 c=>3.0 d=>1.0

cd(ProjDir) do

  isdir("tmp") && rm("tmp", recursive=true)
  isfile("LotkaVolterra2-1.pdf") &&
  rm("LotkaVolterra2-1.pdf")
  
  println("Four parameter case")
  u0 = [1.0,1.0]
  tspan = (0.0,10.0)
  prob2 = ODEProblem(f2,u0,tspan)
  sol = solve(prob2,Tsit5())
  t = collect(linspace(1,10,10))
  randomized = VectorOfArray([(sol(t[i]) + .01randn(2)) for i in 1:length(t)])
  data = convert(Array,randomized)
  priors = [Truncated(Normal(1.5,1),0,2),Truncated(Normal(1.0,1),0,2),
    Normal(3.0,1),Truncated(Normal(1.0,1),0,2)]

  bayesian_result = local_stan_inference(prob2,t,data,priors;num_samples=1000,
    num_warmup=1000,vars =("StanODEData",InverseGamma(2,3)))

  global sim2 = bayesian_result.chain_results[1:end,
    ["theta.1", "params.1", "params.2"], :]
  ## Plotting
  p = plot(sim2, [:trace, :mean, :density, :autocor], legend=true);
  draw(p, ncol=4, filename="LotkaVolterra2", fmt=:pdf)

  theta1 = bayesian_result.chain_results[:,["theta.1"],:]
  @test mean(theta1.value[:,:,1]) ≈ 1.5 atol=1e-1
end
