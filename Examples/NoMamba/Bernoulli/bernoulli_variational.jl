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

stanmodel = Stanmodel(Variational(), name="bernoulli", 
  model=bernoulli, useMamba=false)

sim = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME)

#sim[1:10,:,1] |> display
#println()

println()
println("Test round(mean(theta), 1) ≈ 0.3")
@test round(mean(sim[:,2,:]), 1) ≈ 0.3

end # cd
