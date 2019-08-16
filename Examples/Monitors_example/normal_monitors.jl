# example copied from th0br0 with modifications
using CmdStan

y = collect(1:100);
x = [3:3:300 5:5:500];

model = """
data {
  int<lower = 0> N;
  int<lower = 0> k;
  matrix[N, k] x;
  real<lower=0> y[N];
}
parameters {
  vector[k] beta; 
  real<lower=0> sigma;
}
model {
  y ~ normal(x * beta, sigma);
}
""";

# beta parameters are accessed using beta.[1-9+] syntax
data = Dict("N"=>100, "k" => 2, "x" => x, "y" => y);
stanmodel = Stanmodel(monitors = ["beta.1", "beta.2", "sigma"], model=model,
          output_format=:mcmcchains);

rc, sim, cnames = stan(stanmodel, data; diagnostics = false);

cnames |> display
# 3-element Array{String,1}: "beta.1", "beta.2" ,"sigma" 
println()

describe(sim)
