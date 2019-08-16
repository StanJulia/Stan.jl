######## CmdStan diagnose example  ###########

using CmdStan, Test, Statistics

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

  bernoullidata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])
  global stanmode, rc, diags, cnames
  stanmodel = Stanmodel(Diagnose(CmdStan.Gradient(epsilon=1e-6)),
    output_format=:array, name="bernoulli", model=bernoulli);

  rc, diags, cnames = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME);

  if rc == 0
    println()
    display(diags)
    println()
    tmp = diags[:error][1]
    println("Test round.(diags[:error], digits=6) ≈ 0.0")
    @test round.(tmp, digits=6) ≈ 0.0
  end
end # cd
