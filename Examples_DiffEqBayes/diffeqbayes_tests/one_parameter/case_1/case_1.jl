using StanSample, DiffEqBayes, OrdinaryDiffEq, ParameterizedFunctions,
      ModelingToolkit, RecursiveArrayTools, Distributions, Random, Test

# Uncomment for local testing only, make sure MCMCChains and StatsPlots are available
using MCMCChains, StatsPlots

#Random.seed!(123)
cd(@__DIR__)
isdir("tmp") && rm("tmp", recursive=true)

include("../../../stan_string.jl")
include("../../../stan_inference.jl")

println("\nOne parameter case 1\n")
f1 = @ode_def begin
  dx = a*x - x*y
  dy = -3y + x*y
end a

u0 = [1.0,1.0]
tspan = (0.0,10.0)
pars = [1.5]

prob1 = ODEProblem(f1,u0,tspan,pars)
sol = solve(prob1,Tsit5())
t = collect(range(1,stop=10,length=10))
randomized = VectorOfArray([(sol(t[i]) + .5randn(2)) for i in 1:length(t)])
data = convert(Array,randomized)
priors = [truncated(Normal(0.7,1),0.1,2)]

bayesian_result = stan_inference(prob1,t,data,priors;num_samples=2000, nchains=4,
  num_warmup=1000,likelihood=Normal)

if success(bayesian_result.return_code)
  sdf = read_summary(bayesian_result.model)
  sdf |> display

  p  = read_samples(bayesian_result.model, output_format=:particles)
  @test mean(p.theta1) ≈ 1.5 atol=5e-1

  # Uncomment for local chain inspection
  p1 = Vector{Plots.Plot{Plots.GRBackend}}(undef, length(pars))
  p2 = Vector{Plots.Plot{Plots.GRBackend}}(undef, length(pars))
  for i in 1:length(pars)
    p1[i] = plot(title="theta.$i")
    plot!(p1[i], p[Symbol("theta.$i")].particles)
    p2[i] = plot(title="theta.$i")
    density!(p2[i], p[Symbol("theta.$i")].particles)
  end
  plot(p1..., p2..., layout=(length(pars),2))
  savefig("$(@__DIR__)/case_1_chains.png")

  v1 = [mean(p[Symbol("u_hat.$i.1")]) for i in 1:10]
  v2 = [mean(p[Symbol("u_hat.$i.2")]) for i in 1:10]
  qa_prey = zeros(10, 3);
  qa_pred = zeros(10, 3);

  df = read_samples(bayesian_result.model, output_format=:dataframe)
  achn = Array(df);
  for i in 1:10
    qa_prey[i, :] = quantile(achn[:, 4+i], [0.055, 0.5, 0.945])
    qa_pred[i, :] = quantile(achn[:, 14+i], [0.055, 0.5, 0.945])
  end
  p1 = plot(1:10, v1; ribbon=(qa_prey[:, 1], qa_prey[:, 3]), color=:lightgrey, leg=false)
  title!("Prey u_hat 89% quantiles")
  plot!(v1, lab="prey", xlab="time", ylab="prey", color=:darkred)

  p2 = plot(1:10, v2; ribbon=(qa_pred[:, 1], qa_pred[:, 3]), color=:lightgrey, leg=false)
  title!("Preditors u_hat 89% quantiles")
  plot!(v2, lab="pred", xlab="time", ylab="preditors", color=:darkblue)

  plot(p1, p2, layout=(2,1))
  savefig("$(@__DIR__)/case_1_pred_prey.png")
end
