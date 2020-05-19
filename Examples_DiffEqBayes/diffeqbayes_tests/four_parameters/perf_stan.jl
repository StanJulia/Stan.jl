using StanSample, DiffEqBayes, OrdinaryDiffEq, ParameterizedFunctions,
      ModelingToolkit, RecursiveArrayTools, Distributions, Random, Test
using MCMCChains

# Uncomment for local testing only, make sure MCMCChains and StatsPlots are available
using MCMCChains, StatsPlots

#Random.seed!(123)
cd(@__DIR__)
isdir("tmp") && rm("tmp", recursive=true)

include("../../stan_string.jl")
include("../../stan_inference.jl")

println("\nFour parameter case\n")
f1 = @ode_def begin
  dx = a*x - b*x*y
  dy = -c*y + d*x*y
end a b c d
u0 = [1.0,1.0]
tspan = (0.0,10.0)
p = [1.5,1.0,3.0,1.0]
prob1 = ODEProblem(f1,u0,tspan,p)
sol = solve(prob1,Tsit5())
t = collect(range(1,stop=10,length=10))
randomized = VectorOfArray([(sol(t[i]) + .5randn(2)) for i in 1:length(t)])
data = convert(Array,randomized)

priors = [truncated(Normal(1.5,0.5),0.5,2.5),truncated(Normal(1.2,0.5),0,2.0),
          truncated(Normal(1.0,0.5),1.0,4),truncated(Normal(1.0,0.5),0,2)]

@time bayesian_result = stan_inference(prob1,t,data,priors;
  num_samples=9000, nchains=1,
  num_warmup=1000,vars =(StanODEData(),InverseGamma(3,3)))

stanmodel = bayesian_result.model

@time bayesian_result = stan_inference(prob1,t,data,priors, stanmodel;
  num_samples=9000, nchains=1,
  num_warmup=1000,vars =(StanODEData(),InverseGamma(3,3)))

if success(bayesian_result.return_code)
  chns  = read_samples(bayesian_result.model, output_format=:mcmcchains)
  describe(chns) |> display

  read_summary(stanmodel) |> display

end
