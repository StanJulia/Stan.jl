######### Stan program example  ###########

using StanSample

ProjDir = @__DIR__

bernoullimodel = "
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

observed_data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

# Default for tmpdir is to create a new tmpdir location
# To prevent recompilation of a Stan progam, choose a fixed location,
tmpdir= ProjDir * "/tmp"

sm = SampleModel("bernoulli2", bernoullimodel,
  method=StanSample.Sample(save_warmup=true, num_warmup=1000,
  num_samples=1000, thin=1, adapt=StanSample.Adapt(delta=0.85)),
  tmpdir=tmpdir
);

rc = stan_sample(sm, data=observed_data);

if success(rc)
  df = read_summary(sm, true)
  df |> display
end
