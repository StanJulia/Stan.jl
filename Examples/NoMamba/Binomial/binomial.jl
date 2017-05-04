## Binomial Example ####
## Note: Adapted from the Rate_4 example in Bayesian Cognitive Modeling
##  https://github.com/stan-dev/example-models/tree/master/Bayesian_Cognitive_Modeling

using Mamba, Stan

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

const binomialstanmodel = "
// Inferring a Rate
data {
  int<lower=1> n;
  int<lower=0> k;
}
parameters {
  real<lower=0,upper=1> theta;
  real<lower=0,upper=1> thetaprior;
}
model {
  // Prior Distribution for Rate Theta
  theta ~ beta(1, 1);
  thetaprior ~ beta(1, 1);

  // Observed Counts
  k ~ binomial(n, theta);
}
generated quantities {
  int<lower=0> postpredk;
  int<lower=0> priorpredk;

  postpredk <- binomial_rng(n, theta);
  priorpredk <- binomial_rng(n, thetaprior);
}
"

stanmodel = Stanmodel(name="binomial", model=binomialstanmodel, useMamba=false)

const binomialdata = [
  Dict("n" => 10, "k" => 5)
]

sim = stan(stanmodel, binomialdata, ProjDir, diagnostics=false,
            CmdStanDir=CMDSTAN_HOME)

println("Mean of theta[1]: $(mean(sim[:,8,:]))")
@test round(mean(sim[:,8,:]), 1) ≈ 0.5

end # cd
