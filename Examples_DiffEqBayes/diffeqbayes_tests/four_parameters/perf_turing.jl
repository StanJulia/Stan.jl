using DiffEqBayes, OrdinaryDiffEq, ParameterizedFunctions, RecursiveArrayTools
using Test, Distributions, SteadyStateDiffEq
println("Four parameter case")
f2 = @ode_def begin
    dx = a*x - b*x*y
    dy = -c*y + d*x*y
end a b c d
u0 = [1.0,1.0]
tspan = (0.0,10.0)
p = [1.5,1.0,3.0,1.0]
prob2 = ODEProblem(f2,u0,tspan,p)
sol = solve(prob2,Tsit5())
t = collect(range(1,stop=10,length=10))
randomized = VectorOfArray([(sol(t[i]) + .5randn(2)) for i in 1:length(t)])
data = convert(Array,randomized)

priors = [truncated(Normal(1.5,0.5),0.5,2.5),truncated(Normal(1.2,0.5),0,2.0),
          truncated(Normal(1.0,0.5),1.0,4),truncated(Normal(1.0,0.5),0,2)]

@time bayesian_result = turing_inference(prob2,Tsit5(),t,data,priors;num_samples=1000,
                                   syms = [:a,:b,:c,:d])

@show bayesian_result

@test mean(get(bayesian_result,:a)[1]) ≈ 1.5 atol=3e-1
@test mean(get(bayesian_result,:b)[1]) ≈ 1.0 atol=3e-1
@test mean(get(bayesian_result,:c)[1]) ≈ 3.0 atol=3e-1
@test mean(get(bayesian_result,:d)[1]) ≈ 1.0 atol=3e-1



#=

# Ben's settings

parameters {
  real<lower = 0.5, upper = 2.5> alpha;
  real<lower = 0.0, upper = 2.0> beta;
  real<lower = 1.0, upper = 4.0> gamma;
  real<lower = 0.0, upper = 2.0> delta;
  real<lower = 0> sigma;
}
  alpha ~ normal(1.5, 0.5);
  beta ~ normal(1.2, 0.5);
  gamma ~ normal(3.0, 0.5);
  delta ~ normal(1.0, 0.5);

=#