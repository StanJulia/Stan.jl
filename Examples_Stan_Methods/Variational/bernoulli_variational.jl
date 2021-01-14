######### StanVariational Bernoulli example  ###########

using StanVariational

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

stanmodel = VariationalModel("bernoulli", bernoulli_model)

rc = stan_variational(stanmodel; data=bernoulli_data)

if success(rc)

  chns, cnames = read_variational(stanmodel)

end