using StatisticalRethinking
using DiffEqBayes, DynamicHMC, DataFrames
using BenchmarkTools
using OrdinaryDiffEq, RecursiveArrayTools, ParameterizedFunctions
using StatsPlots
gr(size=(600,900))

ProjDir = @__DIR__
cd(ProjDir)
isdir(ProjDir*"/tmp") && rm(ProjDir*"/tmp", recursive=true)

f = @ode_def LotkaVolterraTest begin
    dx = a*x - b*x*y
    dy = -c*y + d*x*y
end a b c d

u0 = [30.0, 4.0]
tspan = (0.0, 21.0)
p = [0.55, 0.028, 0.84, 0.026]

prob = ODEProblem(f,u0,tspan,p)
sol = solve(prob,Tsit5())

t = collect(range(1,stop=20,length=20))

sig = 0.49
data = convert(Array, VectorOfArray([(sol(t[i]) + sig*randn(2)) for i in 1:length(t)]))
df = DataFrame(
  :Lynx => vcat(u0[2], data[2, :]),
  :Hare => vcat(u0[1], data[1, :])
)

scatter(t, data[1,:], lab="#prey (data)")
scatter!(t, data[2,:], lab="#predator (data)")
plot!(sol)
savefig("$(ProjDir)/fig_01.png")

#=
priors = [
  truncated(Normal(1,0.5),0.1,3),
  truncated(Normal(0.05,0.05),0,2),
  truncated(Normal(1,0.5),0.1,4),
  truncated(Normal(0.05,0.05),0,2)
]
=#

lv = "
  functions {
    real[] dz_dt(real t,       // time
                 real[] z,     // system state {prey, predator}
                 real[] theta, // parameters
                 real[] x_r,   // unused data
                 int[] x_i) {
      real u = z[1];
      real v = z[2];

      real alpha = theta[1];
      real beta = theta[2];
      real gamma = theta[3];
      real delta = theta[4];

      real du_dt = (alpha - beta * v) * u;
      real dv_dt = (-gamma + delta * u) * v;

      return { du_dt, dv_dt };
    }
  }
  data {
    int<lower = 0> N;          // number of measurement times
    real ts[N];                // measurement times > 0
    real y_init[2];            // initial measured populations
    real<lower = 0> y[N, 2];   // measured populations
  }
  parameters {
    real<lower = 0> theta[4];   // { alpha, beta, gamma, delta }
    real<lower = 0> z_init[2];  // initial population
    real<lower = 0> sigma[2];   // measurement errors
  }
  transformed parameters {
    real z[N, 2]
      = integrate_ode_rk45(dz_dt, z_init, 0, ts, theta,
                           rep_array(0.0, 0), rep_array(0, 0),
                           1e-3, 1e-6, 1e5);
  }
  model {
    theta[1] ~ normal(1, 0.5) T[0.1, 3.0];
    theta[2] ~ normal(0.05, 0.1) T[0, 3];
    theta[3] ~ normal(1, 0.5) T[0.1, 4.0];
    theta[4] ~ normal(0.05, 0.1) T[0, 3];
    sigma ~ inv_gamma(2, 2);
    z_init ~ lognormal(10, 1);
    for (k in 1:2) {
      y_init[k] ~ lognormal(log(z_init[k]), sigma[k]);
      y[ , k] ~ lognormal(log(z[, k]), sigma[k]);
    }
  }
  generated quantities {
    real y_init_rep[2];
    real y_rep[N, 2];
    for (k in 1:2) {
      y_init_rep[k] = lognormal_rng(log(z_init[k]), sigma[k]);
      for (n in 1:N)
        y_rep[n, k] = lognormal_rng(log(z[n, k]), sigma[k]);
    }
  }
";

tmpdir = ProjDir*"/tmp"
sm = SampleModel("lynx_hare", lv; tmpdir=tmpdir)

N = size(df, 1) - 1
lv_data = Dict(
  "N" => N,
  "ts" => collect(1:N),
  "y_init" => Array(df[1, [:Hare, :Lynx]]),
  "y" => Array(df[2:end, [:Hare, :Lynx]])
)

@time rc = stan_sample(sm, data=lv_data)

if success(rc)

  dfa = read_samples(sm, output_format=:dataframe)
  p = Particles(dfa)
  p[Symbol("theta.1")] |> display
  p[Symbol("theta.2")] |> display
  p[Symbol("theta.3")] |> display
  p[Symbol("theta.4")] |> display
  p[Symbol("sigma.1")] |> display
  p[Symbol("sigma.2")] |> display

  println()
  sdf = StanSample.read_summary(sm)
  sdf[8:15, [1, 2, 4, 5, 7, 8, 9]] |> display

  original_stan_results ="
                mean se_mean    sd    10%    50%    90% n_eff Rhat
    theta[1]   0.549   0.002 0.065  0.469  0.545  0.636  1163    1
    theta[2]   0.028   0.000 0.004  0.023  0.028  0.034  1281    1
    theta[3]   0.797   0.003 0.091  0.684  0.791  0.918  1125    1
    theta[4]   0.024   0.000 0.004  0.020  0.024  0.029  1170    1
    sigma[1]   0.248   0.001 0.045  0.198  0.241  0.306  2625    1
    sigma[2]   0.252   0.001 0.044  0.201  0.246  0.310  2808    1
    z_init[1] 33.960   0.056 2.909 30.363 33.871 37.649  2684    1
    z_init[2]  5.949   0.011 0.533  5.294  5.926  6.644  2235    1
  ";
  
  p1 = plot()
  scatter!(vcat(0, t), df[:, :Hare], lab="Obs hare")
  scatter!(vcat(0, t), vcat(30, [mean(dfa[:, Symbol("y_rep.$i.1")]) for i in 1:20]),
    lab="Pred hare")
  hares = transpose(convert(Array, VectorOfArray(vcat(
    [hpdi(dfa[:, Symbol("z_init.1")])],
    [hpdi(dfa[:, Symbol("y_rep.$i.1")]) for i in 1:20]
  ))))
  mu = vcat(
    mean(dfa[:, Symbol("z_init.1")]),
    [mean(dfa[:, Symbol("y_rep.$i.1")]) for i in 1:20]
  )
  plot!(vcat(0, t), mu; ribbon=hares, alpha=0.4, lab="89% hpd", color=:lightgrey)
  plot!(sol)

  p2 = plot()
  scatter!(vcat(0, t), df[:, :Lynx], lab="Obs Lynx")
  scatter!(vcat(0, t), vcat(4, [mean(dfa[:, Symbol("y_rep.$i.2")]) for i in 1:20]), 
    lab="Pred lynx")
  lynxs = transpose(convert(Array, VectorOfArray(vcat(
    [hpdi(dfa[:, Symbol("z_init.2")])],
    [hpdi(dfa[:, Symbol("y_rep.$i.2")]) for i in 1:20]
  ))))
  mu = vcat(
    mean(dfa[:, Symbol("z_init.2")]),
    [mean(dfa[:, Symbol("y_rep.$i.2")]) for i in 1:20]
  )
  plot!(vcat(0, t), mu; ribbon=lynxs, alpha=0.4, lab="89% hpd", color=:lightgrey)
  plot!(sol)

  plot(p1, p2, layout=(2,1))
  savefig("$(ProjDir)/fig_02.png")

end