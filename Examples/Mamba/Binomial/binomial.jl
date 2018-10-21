## Binomial Example ####
## Note: Adapted from the Rate_4 example in Bayesian Cognitive Modeling
##  https://github.com/stan-dev/example-models/tree/master/Bayesian_Cognitive_Modeling

using Mamba, Stan, Cairo

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  binomialstanmodel = "
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

  global stanmodel, rc, sim1
  stanmodel = Stanmodel(name="binomial", model=binomialstanmodel)

  binomialdata = [
    Dict("n" => 10, "k" => 5)
  ]

  rc, sim1 = stan(stanmodel, binomialdata, ProjDir, diagnostics=false,
    CmdStanDir=CMDSTAN_HOME)
  
  if rc == 0   
    theta_sim = sim1[1:size(sim1,1), ["theta", "thetaprior"], :]
    predk_sim = sim1[1:size(sim1,1), ["postpredk", "priorpredk"], :]

    p = plot(theta_sim, [:trace, :mean, :density, :autocor], legend=false);
    draw(p, ncol=4, nrow=2, filename="$(stanmodel.name)-thetas", fmt=:svg)

    p = plot(predk_sim, [:bar], legend=false)
    draw(p, ncol=2, nrow=2, filename="$(stanmodel.name)-predictiv", fmt=:svg)
  end # rc == 0
end # cd
