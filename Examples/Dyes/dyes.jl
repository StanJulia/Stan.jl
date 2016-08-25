######### Stan batch program example  ###########

using Stan, Mamba

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

const dyes ="
data {
  int BATCHES; 
  int SAMPLES; 
  real y[BATCHES, SAMPLES]; 
  // vector[SAMPLES] y[BATCHES]; 
} 

parameters {
  real<lower=0> tau_between;
  real<lower=0> tau_within; 
  real theta;
  real mu[BATCHES]; 
} 

transformed parameters {
  real sigma_between; 
  real sigma_within;
  sigma_between <- 1/sqrt(tau_between); 
  sigma_within <- 1/sqrt(tau_within); 
} 

model {
  theta ~ normal(0.0, 1E5); 
  tau_between ~ gamma(.001, .001); 
  tau_within ~ gamma(.001, .001); 

  mu ~ normal(theta, sigma_between);
  for (n in 1:BATCHES)  
    y[n] ~ normal(mu[n], sigma_within);
}

generated quantities {
  real sigmasq_between;
  real sigmasq_within;
  
  sigmasq_between <- 1 / tau_between;
  sigmasq_within <- 1 / tau_within;
}
"

const dyesdata = [
  Dict("BATCHES" => 6,
    "SAMPLES" => 5,
    "y" => reshape([
      [1545, 1540, 1595, 1445, 1595]; 
      [1520, 1440, 1555, 1550, 1440]; 
      [1630, 1455, 1440, 1490, 1605]; 
      [1595, 1515, 1450, 1520, 1560]; 
      [1510, 1465, 1635, 1480, 1580]; 
      [1495, 1560, 1545, 1625, 1445]
    ], 6, 5)
  )
]

stanmodel = Stanmodel(name="dyes", model=dyes);
@time sim1 = stan(stanmodel, dyesdata, ProjDir, CmdStanDir=CMDSTAN_HOME)

nodesubset = ["theta", "mu.1", "mu.2", "mu.3", "mu.4", "mu.5", "mu.6", "sigma_between", "sigma_within"]
## Subset Sampler Output
sim = sim1[1:size(sim1, 1), nodesubset, 1:size(sim1, 3)]

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

end # cd
