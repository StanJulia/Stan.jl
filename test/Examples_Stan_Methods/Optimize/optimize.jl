######### Stan optimize example  ###########

using StanOptimize, Test

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

stanmodel = OptimizeModel("optimize_1",  bernoulli_model);

(sample_path, log_path) = stan_sample(stanmodel, data=bernoulli_data);

if sample_path !== Nothing
  optim1, cnames = read_optimize(stanmodel)
  
  @test optim1["theta"][end] ≈ 0.3 atol=0.001
end

# Same with saved iterations
sm = OptimizeModel("optimize_2", bernoulli_model;
  method = StanOptimize.Optimize(save_iterations = true));

(sample_path, log_path)  = stan_optimize(sm, data=bernoulli_data);

if sample_path !== Nothing
  optim2, cnames = read_optimize(sm)
  @test optim2["theta"][end] ≈ 0.3 atol=0.001
end
