######### Stan program example  ###########

using Compat, Stan, Base.Test

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  const binorm = "
  transformed data {
      matrix[2,2] Sigma;
      vector[2] mu;

      mu[1] <- 0.0;
      mu[2] <- 0.0;
      Sigma[1,1] <- 1.0;
      Sigma[2,2] <- 1.0;
      Sigma[1,2] <- 0.10;
      Sigma[2,1] <- 0.10;
  }
  parameters {
      vector[2] y;
  }
  model {
        y ~ multi_normal(mu,Sigma);
  }
  "

  stanmodel = Stanmodel(name="binormal", model=binorm, Sample(save_warmup=true),
   useMamba=false);

  sim = stan(stanmodel, CmdStanDir=CMDSTAN_HOME)

  println()
  println("Test round(mean(y[1]), 0) ≈ 0.0")
  @test round(mean(sim[:,8,:]), 0) ≈ 0.0

end # cd
