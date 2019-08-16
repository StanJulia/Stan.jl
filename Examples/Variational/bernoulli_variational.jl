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

# Keep tmpdir across multiple runs to prevent re-compilation
tmpdir = joinpath(@__DIR__, "tmp")

stanmodel = VariationalModel(
  "bernoulli", bernoulli_model; tmpdir = tmpdir)

(sample_file, log_file) = stan_variational(stanmodel; data=bernoulli_data)

if sample_file !== Nothing

  (chns, cnames) = read_variational(stanmodel)

  # Show the same output in DataFrame format
  sdf = read_summary(stanmodel)
  display(sdf)
  println()

  # Retrieve mean value of theta from the summary
  sdf[:theta, :mean]

end