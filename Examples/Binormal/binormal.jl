######### Stan program example  ###########

using Compat, Stan, Test

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  binorm = "
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

  global stanmodel, rc, sim
  stanmodel = Stanmodel(name="binormal", model=binorm, Sample(save_warmup=true),
   useMamba=false);

  rc, sim = stan(stanmodel, CmdStanDir=CMDSTAN_HOME)

  if rc == 0
    println()
    println("Test round(mean(y[1]), digits=0) ≈ 0.0")
    @test round(mean(sim[:,8,:]), digits=0) ≈ 0.0
  end
end # cd
