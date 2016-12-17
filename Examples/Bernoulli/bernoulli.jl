######### Stan program example  ###########

using Mamba, Stan

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

bernoullidata_1 = [
  Dict("N" => 1, "y" => [0]),
  Dict("N" => 1, "y" => [0]),
  Dict("N" => 1, "y" => [0]),
  Dict("N" => 1, "y" => [0]),
]

bernoullidata_10 = [
  Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
  Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]),
  Dict("N" => 10, "y" => [0, 0, 0, 0, 0, 0, 1, 0, 1, 1]),
  Dict("N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1])
]

monitor = ["theta", "lp__", "accept_stat__"]

stanmodel = Stanmodel(update=1200, thin=2, name="bernoulli", model=bernoullimodel);

## Test with single datapoint
println("\nStanmodel that will be used:")
stanmodel |> display
println()
println("Input observed data dictionary:")
bernoullidata_1 |> display
println()

sim1 = stan(stanmodel, bernoullidata_1, ProjDir, diagnostics=false, CmdStanDir=CMDSTAN_HOME);
isa(sim1, Void) && error("Stan run failed")

## Test with 10 datapoints
println("\nStanmodel that will be used:")
stanmodel |> display
println()
println("Input observed data dictionary:")
bernoullidata_10 |> display
println()

sim10 = stan(stanmodel, bernoullidata_10, ProjDir, diagnostics=false, CmdStanDir=CMDSTAN_HOME);
isa(sim10, Void) && error("Stan run failed")

## Subset Sampler Output to variables suitable for describe().
sim = sim10[1:size(sim10, 1), monitor, 1:size(sim10, 3)]
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

# Below will only work on OSX, please adjust for your environment.
# JULIA_SVG_BROWSER is set from environment variable JULIA_SVG_BROWSER
@static is_apple() ? if isdefined(Main, :JULIA_SVG_BROWSER) && length(JULIA_SVG_BROWSER) > 0
        for i in 1:4
          isfile("$(stanmodel.name)-summaryplot-$(i).svg") &&
            run(`open -a $(JULIA_SVG_BROWSER) "$(stanmodel.name)-summaryplot-$(i).svg"`)
        end
      end : println()

if Pkg.installed("Mamba") > v"0.7.1"
	# Pairwise contour plots
	simmod = ModelChains(sim,Mamba.Model())
	p = plot(simmod, :contour)
	draw(p, nrow=2, ncol=2, filename="$(stanmodel.name)-contourplot.svg")
	draw(p, nrow=2, ncol=2, filename="$(stanmodel.name)-contourplot.pdf", fmt=:pdf)

	# Below will only work on OSX, please adjust for your environment.
	# JULIA_SVG_BROWSER is set from environment variable JULIA_SVG_BROWSER
	@static is_apple() ? if isdefined(Main, :JULIA_SVG_BROWSER) && length(JULIA_SVG_BROWSER) > 0
	        isfile("$(stanmodel.name)-contourplot.svg") &&
	          run(`open -a $(JULIA_SVG_BROWSER) "$(stanmodel.name)-contourplot.svg"`)
	      end : println()
end

end # cd
