######### CmdStan batch program example  ###########

using CmdStan, StatsPlots

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  eightschools ="
  data {
    int<lower=0> J; // number of schools
    real y[J]; // estimated treatment effects
    real<lower=0> sigma[J]; // s.e. of effect estimates
  }
  parameters {
    real mu;
    real<lower=0> tau;
    real eta[J];
  }
  transformed parameters {
    real theta[J];
    for (j in 1:J)
      theta[j] <- mu + tau * eta[j];
  }
  model {
    eta ~ normal(0, 1);
    y ~ normal(theta, sigma);
  }
  "

  schools8data = Dict("J" => 8,
      "y" => [28,  8, -3,  7, -1,  1, 18, 12],
      "sigma" => [15, 10, 16, 11,  9, 11, 10, 18],
      "tau" => 25
    )

  global stanmodel, rc, chns, cnames
  stanmodel = Stanmodel(name="schools8", model=eightschools,
    output_format=:mcmcchains);
  rc, chn, cnames = stan(stanmodel, schools8data, ProjDir, CmdStanDir=CMDSTAN_HOME)

  if rc == 0
    
    chns = set_section(chn, Dict(
      :parameters => ["mu", "tau"],
      :thetas => ["theta.$i" for i in 1:8],
      :etas => ["eta.$i" for i in 1:8],
      :internals => ["lp__", "accept_stat__", "stepsize__", "treedepth__", "n_leapfrog__",
        "divergent__", "energy__"]
      )
    )
    
    if isdefined(Main, :StatsPlots)
      p1 = plot(chns)
      savefig(p1, "traceplot.pdf")
      #p2 = plot(chns, [:thetas])
      #savefig(p2, "thetas.pdf")
    end
    
    show(chns)
    println("\n")
    summarize(chns, sections=[:thetas])
    
  end
end # cd
