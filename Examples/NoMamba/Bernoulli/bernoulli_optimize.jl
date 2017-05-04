######### Stan program example  ###########

using Stan, Base.Test

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

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

bernoullidata = [
  Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
  Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]),
  Dict("N" => 10, "y" => [0, 0, 0, 0, 0, 0, 1, 0, 1, 1]),
  Dict("N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1])
]

stanmodel = Stanmodel(Optimize(), name="bernoulli",
  model=bernoulli, useMamba=false);

optim = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME);

optim[1] |> display
println()

@test optim[1]["optimize"]["thet"] ≈ [0.3] atol=1.0e-1

end # cd
