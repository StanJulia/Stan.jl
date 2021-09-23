######### StanSample Bernoulli example  ###########

using MonteCarloMeasurements
using StanSample

bernoulli_model = "
data {
  int<lower=1> N;
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

bernoulli_data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

sm = SampleModel("bernoulli", bernoulli_model);

rc = stan_sample(sm; data=bernoulli_data);

if success(rc)
  part_sm = read_samples(sm, :particles)	  # Return Particles NamedTuple
  part_sm |> display

  # Fetch cmdstan summary df
  sdf = read_summary(sm, true)

end
