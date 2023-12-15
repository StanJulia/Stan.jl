# A walk-through example (using StanSample.jl)

using StanSample
using Distributions
using DataFrames
using MonteCarloMeasurements
using Tables

N = 100
df = DataFrame(
    height = rand(Normal(10, 2), N),
    leg_prop = rand(Uniform(0.4, 0.5), N),
)
df.leg_left = df.leg_prop .* df.height + rand(Normal(0, 0.02), N)
df.leg_right = df.leg_prop .* df.height + rand(Normal(0, 0.03), N)

stan6_1 = "
data {
  int <lower=1> N;
  vector[N] H;
  vector[N] LL;
  vector[N] LR;
}
parameters {
  real a;
  vector[2] b;
  real <lower=0> sigma;
}
model {
  vector[N] mu;
  mu = a + b[1] * LL + b[2] * LR;
  a ~ normal(10, 100);
  b ~ normal(2, 10);
  sigma ~ exponential(1);
  H ~ normal(mu, sigma);
}
";

m6_1s = SampleModel("m6.1s", stan6_1);
data = (H = df.height, LL = df.leg_left, LR = df.leg_right, N = size(df, 1))
rc6_1s = stan_sample(m6_1s; data);

if success(rc6_1s)
    chns = read_samples(m6_1s, :nesteddataframe)
    chns[1:10, :] |> display

    # Or use read_samples to only use chains 2 and 4 using the chains kwarg.

    chns2 = read_samples(m6_1s, :dataframe; chains=[2, 4])
    mean.(eachcol(chns2)) |> display

end

# Some more options:

init = (a = 2.0, b = [1.0, 2.0], sigma = 1.0)
#rc6_2s = stan_sample(m6_1s; data, init);
rc6_2s = stan_sample(m6_1s; data);

if success(rc6_2s)

    read_summary(m6_1s, true)
    println()

    post6_1s_df = read_samples(m6_1s, :dataframe)

    part6_1s = read_samples(m6_1s, :particles)
    part6_1s |> display
    println()

    nt6_1s = read_samples(m6_1s, :namedtuple)
    mean(nt6_1s.b, dims=2)
end
