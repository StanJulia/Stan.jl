######### Stan program example  ###########

#using Cairo, Mamba, Stan
using Stan

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

stanmodel = Stanmodel(name="bernoulli", model=bernoulli, data=data);

println("\nStanmodel that will be used:")
stanmodel |> display
println("Input observed data dictionary:")
data |> display
println()

#chains = stan(stanmodel, data, ProjDir, diagnostics=true)


cd(old)
