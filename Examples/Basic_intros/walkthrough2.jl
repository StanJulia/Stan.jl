using Distributions, DataFrames
using MonteCarloMeasurements, AxisKeys
using StanSample

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
rc6_1s = stan_sample(m6_1s; data, seed=-1, num_chains=2, delta=0.85);


if success(rc6_1s)
    tbl = read_samples(m6_1s) # By default a StanTable object is returned

    # Display the schema of the tbl

    tbl |> display
    println()

    # Display the keys

    dft = DataFrame(tbl)
    dft |> display
    println()

    # Or using a KeyedArray object from AxisKeys.jl
    chns = read_samples(m6_1s, :keyedarray)
    chns |> display
end

init = (a = 2.0, b = [1.0, 2.0], sigma = 1.0)
rc6_2s = stan_sample(m6_1s; data, init);

if success(rc6_2s)

    # Retrieve the summary created by the stansummary executable:

    read_summary(m6_1s, true)
    println()

    # For simple models often a DataFrame is attractive to work with:

    post6_1s_df = read_samples(m6_1s, :dataframe)
    post6_1s_df |> display
    println()

    part6_1s = read_samples(m6_1s, :particles)
    part6_1s |> display
    println()

    # Use a NamedTuple:
    
    nt6_1s = read_samples(m6_1s, :namedtuple)
    nt6_1s |> display
    println()

    nt6_1s.b |> display

    # Compute the mean for vector b:

    mean(nt6_1s.b, dims=2)

end
