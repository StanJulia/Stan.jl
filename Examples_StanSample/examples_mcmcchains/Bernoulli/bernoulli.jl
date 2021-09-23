######### StanSample Bernoulli example  ###########

# This example expects MCMCChains to be installed

using StanSample, MCMCChains

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

# Keep tmpdir across multiple runs to prevent re-compilation
#tmpdir = joinpath(@__DIR__, "tmp")

sm = SampleModel("bernoulli", bernoulli_model;
  method = StanSample.Sample(save_warmup=true,
    adapt = StanSample.Adapt(delta = 0.85)),
    #tmpdir = tmpdir,
);

rc = stan_sample(sm; data=bernoulli_data);

if success(rc)
  chns = read_samples(sm, :mcmcchains)
  chns |> display
end
