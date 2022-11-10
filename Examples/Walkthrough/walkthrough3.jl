# StanSample & GLMakie must be available from your environment.

using StanSample, GLMakie

model = "
data { 
  int<lower=0> N; 
  int<lower=0,upper=1> y[N];
} 
parameters {
  real<lower=0,upper=1> theta;
} 
model {
  theta ~ beta(1,1);
    y ~ bernoulli(theta);
}
";

sm = SampleModel("bernoulli", model);

data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]);

rc = stan_sample(sm; data);

if success(rc)
  df = read_samples(sm, :dataframe);
  df |> display
end

density(df.theta) |> display
