using StanSample, DiffEqBayes, OrdinaryDiffEq, ParameterizedFunctions,
      ModelingToolkit, RecursiveArrayTools, Distributions, Random, Test

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
priors = [truncated(Normal(1.0,1),0.1,2),truncated(Normal(1.5,0.5),0.1,1.5),
          truncated(Normal(2.0,1),0.1,4),truncated(Normal(1.3,0.5),0.1,2)]

@time bayesian_result = stan_inference(prob1,t,data,priors;num_samples=2000, nchains=4,
  num_warmup=1000,vars =(StanODEData(),InverseGamma(4,1)))

if success(bayesian_result.return_code)
  p  = read_samples(bayesian_result.model, output_format=:particles)
  @test mean(p.theta1) ≈ 1.5 atol=5e-1
  @test mean(p.theta2) ≈ 1.0 atol=5e-1
  @test mean(p.theta3) ≈ 3.0 atol=5e-1
  @test mean(p.theta4) ≈ 1.0 atol=5e-1

  # Uncomment for local chain inspection
  p1 = Vector{Plots.Plot{Plots.GRBackend}}(undef, length(priors))
  p2 = Vector{Plots.Plot{Plots.GRBackend}}(undef, length(priors))
  for i in 1:length(priors)
    p1[i] = plot(title="theta.$i", leg=false)
    plot!(p1[i], p[Symbol("theta.$i")].particles)
    p2[i] = plot(title="theta.$i", leg=false)
    density!(p2[i], p[Symbol("theta.$i")].particles)
  end
  plot(p1[1], p2[1], p1[2], p2[2], p1[3], p2[3], p1[4], p2[4], layout=(length(priors),2))
  savefig("$(@__DIR__)/four_par_case.png")

  v1 = [mean(p[Symbol("u_hat.$i.1")]) for i in 1:10]
  v2 = [mean(p[Symbol("u_hat.$i.2")]) for i in 1:10]
  qa_prey = zeros(10, 3);
  qa_pred = zeros(10, 3);

  df = read_samples(bayesian_result.model, output_format=:dataframe)
  achn = Array(df);
  for i in 1:10
    qa_prey[i, :] = quantile(achn[:, 10+i], [0.055, 0.5, 0.945])
    qa_pred[i, :] = quantile(achn[:, 20+i], [0.055, 0.5, 0.945])
  end
  p1 = plot(1:10, v1; ribbon=(qa_prey[:, 1], qa_prey[:, 3]), color=:lightgrey, leg=false)
  title!("Prey u_hat 89% quantiles")
  plot!(v1, lab="prey", xlab="time", ylab="prey", color=:darkred)

  p2 = plot(1:10, v2; ribbon=(qa_pred[:, 1], qa_pred[:, 3]), color=:lightgrey, leg=false)
  title!("Preditors u_hat 89% quantiles")
  plot!(v2, lab="pred", xlab="time", ylab="preditors", color=:darkblue)

  plot(p1, p2, layout=(2,1))
  savefig("$(@__DIR__)/four_par_pred_prey.png")
end
