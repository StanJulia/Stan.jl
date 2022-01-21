######### Stan program example  ###########

using StanSample

ProjDir = @__DIR__

bernoullimodel = "
data { 
  int<lower=0> N; 
  array[N] int<lower=0,upper=1> y;
} 
parameters {
  real<lower=0,upper=1> theta;
} 
model {
  theta ~ beta(1,1);
  y ~ bernoulli(theta);
}
";

observed_data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

# Default for tmpdir is to create a new tmpdir location
# To prevent recompilation of a Stan progam, choose a fixed location,
tmpdir= ProjDir * "/tmp"

sm = SampleModel("bernoulli2", bernoullimodel, tmpdir);

rc = stan_sample(sm; data=observed_data,
  save_warmup=true, num_warmups=1000,
  num_samples=1000, thin=1, delta=0.85
);

if success(rc)
  df = read_summary(sm, true)
  df |> display
end
