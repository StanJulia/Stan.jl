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

(sample_file, log_file) = stan_variational(sm; data=bernoulli_data)

if sample_file !== Nothing

  (chns, cnames) = read_variational(sm)

  # Show the same output in DataFrame format
  sdf = read_summary(sm)

  # Retrieve mean value of theta from the summary
  sdf[:theta, :mean]
  @test sdf[:theta, :mean][1] ≈ 0.33 atol=0.1

end