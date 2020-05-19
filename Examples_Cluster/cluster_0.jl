using StanSample

ProjDir = @__DIR__

themodel = "
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

# Default for tmpdir is to create a new tmpdir location
# To prevent recompilation of a Stan progam, choose a fixed location,
# and to initally hav access to run logs etc.
tmpdir = "$(ProjDir)/tmp"

all_models = Vector{SampleModel}(undef, 2)
for i in 1:length(all_models)
  all_models[i] = SampleModel("sm_$i", themodel,
    tmpdir=tmpdir,
    method=StanSample.Sample(save_warmup=true, num_warmup=1000, 
      num_samples=1000, adapt=StanSample.Adapt(delta=0.85))
  );
end

# This could be any Vector type (or Dict with Int keys)
observed_data = Dict(:N => 10, :y => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

rc = stan_sample.(all_models; data=observed_data);

p = []
if all(success.(rc))
  for m in all_models
    push!(p, read_samples(m, output_format=:particles))
  end
  display(p)
end
