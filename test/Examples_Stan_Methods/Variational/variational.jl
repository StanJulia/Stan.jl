######### StanVariational Bernoulli example  ###########

using StanVariational, Test

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

# Use tmpdir across multiple runs to prevent re-compilation
#tmpdir = joinpath(@__DIR__, "tmp")

sm = VariationalModel("variational", bernoulli_model)

rc = stan_variational(sm; data=bernoulli_data)

if success(rc)

  (samples, cnames) = read_variational(sm)

end