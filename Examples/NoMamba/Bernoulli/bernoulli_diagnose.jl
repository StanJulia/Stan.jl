######## Stan diagnose example  ###########

using Compat, Stan, Test

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

  global stanmode, rc, diags
  stanmodel = Stanmodel(Diagnose(Stan.Gradient(epsilon=1e-6)), name="bernoulli",
    model=bernoulli, useMamba=false);

  rc, diags = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME);

  if rc == 0
    diags[1]["diagnose"] |> display
    println()

    println()
    tmp = diags[1]["diagnose"][:error][1]
    println("Test round(diags[1][diagnose][:error], digits=6) ≈ 0.0")
    @test round(tmp, digits=6) ≈ 0.0
  end
end # cd
