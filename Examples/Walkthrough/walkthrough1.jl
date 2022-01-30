using StanSample, DataFrames

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

rc = stan_sample(sm; num_chains=4, data);

if success(rc)
  df = read_samples(sm, :dataframe);
  df |> display
end
