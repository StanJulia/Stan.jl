######### Stan program example  ###########

using Mamba, Stan, Cairo

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  bernoullimodel = "
  data { 
    int<lower=1> N; 
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

  global stanmodel, rc, sim
  stanmodel = Stanmodel(num_samples=1200, thin=2, name="bernoulli", 
    model=bernoullimodel, useMamba=true);

  println("\nStanmodel that will be used:")
  stanmodel |> display
  println()
  println("Input observed data dictionary:")
  bernoullidata |> display
  println()

  rc, sim1 = stan(stanmodel, bernoullidata, ProjDir, diagnostics=false, CmdStanDir=CMDSTAN_HOME);

  if rc == 0
    ## Subset Sampler Output to variables suitable for describe().
    monitor = ["theta", "lp__", "accept_stat__"]
    sim = sim1[1:size(sim1, 1), monitor, 1:size(sim1, 3)]
    describe(sim)
    println()

    ## Brooks, Gelman and Rubin Convergence Diagnostic
    try
      gelmandiag(sim, mpsrf=true, transform=true) |> display
    catch e
      #println(e)
      gelmandiag(sim, mpsrf=false, transform=true) |> display
    end
    println()

    ## Geweke Convergence Diagnostic
    gewekediag(sim) |> display

    ## Highest Posterior Density Intervals
    hpd(sim) |> display

    ## Cross-Correlations
    cor(sim) |> display

    ## Lag-Autocorrelations
    autocor(sim) |> display

    ## Deviance Information Criterion
    #dic(sim) |> display

    ## Plotting
    p = plot(sim, [:trace, :mean, :density, :autocor], legend=true);
    draw(p, ncol=4, filename="$(stanmodel.name)-summaryplot", fmt=:svg)
    draw(p, ncol=4, filename="$(stanmodel.name)-summaryplot", fmt=:pdf)
  end # rc == 0
end # cd
