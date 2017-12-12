######### Stan program example  ###########

using Stan, Mamba

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

  global stanmodel, rc, sim1, sim
  stanmodel = Stanmodel(name="binormal", model=binorm, Sample(save_warmup=true));

  rc, sim1 = stan(stanmodel, CmdStanDir=CMDSTAN_HOME)

  if rc == 0
    ## Subset Sampler Output
    sim = sim1[1:size(sim1, 1), ["lp__", "y.1", "y.2"], 1:size(sim1, 3)]

    describe(sim)
    println()

    ## Brooks, Gelman and Rubin Convergence Diagnostic
    try
      gelmandiag(sim1, mpsrf=true, transform=true) |> display
    catch e
      #println(e)
      gelmandiag(sim, mpsrf=false, transform=true) |> display
    end

    ## Geweke Convergence Diagnostic
    gewekediag(sim) |> display

    ## Highest Posterior Density Intervals
    hpd(sim) |> display

    ## Cross-Correlations
    cor(sim) |> display

    ## Lag-Autocorrelations
    autocor(sim) |> display

    ## Plotting
    p = plot(sim, [:trace, :mean, :density, :autocor], legend=true);
    draw(p, ncol=4, filename="$(stanmodel.name)-summaryplot", fmt=:svg)
    draw(p, ncol=4, filename="$(stanmodel.name)-summaryplot", fmt=:pdf)
  end # rc == 0
end # cd
