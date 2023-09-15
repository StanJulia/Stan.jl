######### StanOptimize example  ###########

using StanOptimize

bernoulli_model = "
data { 
  int<lower=1> N; 
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

bernoulli_data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

stanmodel = OptimizeModel("bernoulli",  bernoulli_model);
rc = stan_optimize(stanmodel; data=bernoulli_data);

if success(rc)
  optim1, cnames = read_optimize(stanmodel)
  println()
  display(optim1)
  println()
end

# Same with saved iterations
stanmodel = OptimizeModel("bernoulli", bernoulli_model, joinpath(@__DIR__, "tmp"));
rc2  = stan_optimize(stanmodel, data=bernoulli_data);

if success(rc2)
  optim2, cnames = read_optimize(stanmodel)
  println()
  display(optim2)
  println()
end
