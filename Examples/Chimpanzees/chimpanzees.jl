# A walk-through example (using StanSample.jl)

using StanSample
using Distributions
using DataFrames
using MonteCarloMeasurements
using AxisKeys
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
    chns = read_samples(m6_1s, :keyedarray)

    # Display the chns

    chns |> display
    println("\n")

    # Display the keys

    axiskeys(chns) |> display
    println("\n")

    chns(chain=1) |> display
    println()

    chns[:, 1, 1] |> display
    println()

    chns(chain=1, param=:a) |> display
    println()

    chns(chain=[1, 3], param=[:a, :sigma]) |> display
    println()

    # Select all elements starting with 'a'

    chns_b = matrix(chns, :b)
    chns_b |> display
    println()

    mean(chns_b, dims=1) |> display
    println()

    typeof(chns_b.data) |> display
    println()

    ndraws_b, nchains_b, nparams_b = size(chns_b)
    chn_b = reshape(chns_b, ndraws_b*nchains_b, nparams_b)
    println()

    for row in eachrow(chn_b)
        # ...
    end

    # Obtain  b.1 , b,2 as a matrix

    chns2 = read_samples(m6_1s, :table)
    chns2_b = matrix(chns2, :b)

    # Or use read_samples to only use chains 2 and 4 using the chains kwarg.

    chns2 = read_samples(m6_1s, :dataframe; chains=[2, 4])
    mean.(eachcol(chns2)) |> display

end

# Some more options:

init = (a = 2.0, b = [1.0, 2.0], sigma = 1.0)
rc6_2s = stan_sample(m6_1s; data, init);

if success(rc6_2s)

    read_summary(m6_1s, true)
    println()

    post6_1s_df = read_samples(m6_1s, :dataframe)
    post6_1s_df |> display
    println()

    part6_1s = read_samples(m6_1s, :particles)
    part6_1s |> display
    println()

    nt6_1s = read_samples(m6_1s, :namedtuple)
    nt6_1s.b |> display
    println()

    mean(nt6_1s.b, dims=2) |> display
    println()

end
