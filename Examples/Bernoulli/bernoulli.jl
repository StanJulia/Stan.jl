######### Stan program example  ###########

using Stan

old = pwd()
path = @windows ? "\\Examples\\Bernoulli" : "/Examples/Bernoulli"
ProjDir = Pkg.dir("Stan")*path
cd(ProjDir)

bernoulli = "
data { 
  int<lower=0> N; 
  int<lower=0,upper=1> y[N];
} 
parameters {
  real<lower=0,upper=1> theta;
} 
model {
  theta ~ beta(1,1);
    y ~ bernoulli(theta);
}
"

data = [
  (ASCIIString => Any)["N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]],
  (ASCIIString => Any)["N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]],
  (ASCIIString => Any)["N" => 10, "y" => [0, 0, 0, 0, 0, 0, 1, 0, 1, 1]],
  (ASCIIString => Any)["N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1]]
]


stanmodel = Stanmodel(name="bernoulli", model=bernoulli);

println("\nStanmodel that will be used:")
stanmodel |> display
println("Input observed data dictionary:")
data |> display
println()

chains = stan(stanmodel, data, ProjDir, diagnostics=true)

chains[1]["samples"] |> display

chains[1]["diagnostics"] |> display
println()

logistic(x::FloatingPoint) = one(x) / (one(x) + exp(-x))
logistic(x::Real) = logistic(float(x))
@vectorize_1arg Real logistic

println()
[logistic(chains[1]["diagnostics"]["theta"]) chains[1]["samples"]["theta"]][1:5,:] |> display

cd(old)
