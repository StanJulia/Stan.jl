######### Stan program example  ###########

using Cairo, Mamba, Stan

old = pwd()
path = @windows ? "\\Examples\\Bernoulli2" : "/Examples/Bernoulli2"
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

data = Dict{ASCIIString, Any}()
data["N"] = 10
data["y"] = [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]

inits = [
  (ASCIIString => Any)["alpha" => 0,"beta" => 0,"tau" => 1],
  (ASCIIString => Any)["alpha" => 1,"beta" => 2,"tau" => 1],
  (ASCIIString => Any)["alpha" => 3,"beta" => 3,"tau" => 2],
  (ASCIIString => Any)["alpha" => 5,"beta" => 2,"tau" => 5],
]

stanmodel = Stanmodel(name="bernoulli");

println("\nJagsmodel that will be used:")
stanmodel |> display
println("Input observed data dictionary:")
data |> display
println("\nInput initial values dictionary:")
inits |> display
println()

#chains = stan(stanmodel, data, ProjDir, diagnostics=true)


cd(old)
