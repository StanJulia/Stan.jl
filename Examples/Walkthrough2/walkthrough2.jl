using StanSample, Distributions

N = 100;
df = DataFrame(
    height = rand(Normal(10, 2), N),
    leg_prop = rand(Uniform(0.4, 0.5), N),
);
df.leg_left = df.leg_prop .* df.height + rand(Normal(0, 0.02), N);
df.leg_right = df.leg_prop .* df.height + rand(Normal(0, 0.03), N);

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
data = (H = df.height, LL = df.leg_left, LR = df.leg_right, N = size(df, 1));

rc6_1s = stan_sample(m6_1s; data);
if success(rc6_1s)
    nt6_1s = read_samples(m6_1s)
end

nt6_1s.b |> display
println()
mean(nt6_1s.b, dims=2) |> display

init = (a = 2.0, b = [1.0, 2.0], sigma = 1.0)
rc6_2s = stan_sample(m6_1s; data, init);
if success(rc6_1s)
    nt6_2s = read_samples(m6_1s)
end

nt6_2s.b |> display
println()
mean(nt6_2s.b, dims=2) |> display
println()

read_summary(m6_1s) |> display
println()

post6_1s_df = read_samples(m6_1s; output_format=:dataframe) |> display
println()

part6_1s = read_samples(m6_1s; output_format=:particles) |> display
