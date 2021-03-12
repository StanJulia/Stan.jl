using CSV, DataFrames, StanQuap

ProjDir = @__DIR__

df = CSV.read(joinpath(ProjDir,  "..", "..", "data", "Howell1.csv"), DataFrame)
df = filter(row -> row[:age] >= 18, df);

stan4_1 = "
// Inferring the mean and std
data {
  int N;
  real<lower=0> h[N];
}
parameters {
  real<lower=0.1> sigma;
  real<lower=100,upper=180> mu;
}
model {
  // Priors for mu and sigma
  mu ~ normal(178, 20);
  sigma ~ exponential(1);

  // Observed heights
  h ~ normal(mu, sigma);
}
";

data = (N = size(df, 1), h = df.height)
init = (mu = 160.0, sigma = 10.0)

qm, sm, om = stan_quap("s4.1s", stan4_1; data, init)

println()
qm |> display
println()

println()
om.optim |> display
println()
