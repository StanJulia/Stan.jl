######### Stan program example  ###########

using Mamba, Stan

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

stanmodel = Stanmodel(Variational(), name="bernoulli", model=bernoulli);

sim1 = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME);
monitor = ["theta"]
sim = sim1[1:size(sim1, 1), monitor, 1:size(sim1, 3)]
Mamba.describe(sim)
println()

## Plotting
p = plot(sim, [:trace, :mean, :density, :autocor], legend=true);
draw(p, ncol=1, nrow=4, filename="$(stanmodel.name)-variationalplot", fmt=:svg)
draw(p, ncol=1, nrow=4, filename="$(stanmodel.name)-variationalplot", fmt=:pdf)

# Below will only work on OSX, please adjust for your environment.
# JULIA_SVG_BROWSER is set from environment variable JULIA_SVG_BROWSER
@osx ? if isdefined(Main, :JULIA_SVG_BROWSER) && length(JULIA_SVG_BROWSER) > 0
        for i in 1:4
          isfile("$(stanmodel.name)-variationalplot-$(i).svg") &&
            run(`open -a $(JULIA_SVG_BROWSER) "$(stanmodel.name)-variationalplot-$(i).svg"`)
        end
      end : println()

end # cd
