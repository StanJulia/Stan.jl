######## Stan diagnose example  ###########

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

stanmodel = Stanmodel(Diagnose(Gradient(epsilon=1e-6)), name="bernoulli",
  model=bernoulli, useMamba=false);

diags = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME);

diags[1]["diagnose"] |> display
println()

tmp = diags[1]["diagnose"][:value]
println("diags[1][diagnose][:value]: $(tmp)")

@test tmp ≈ [1.7] atol=0.3

end # cd
