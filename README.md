# Stan

[![Stan](http://pkg.julialang.org/badges/Stan_release.svg)](http://pkg.julialang.org/?pkg=Stan&ver=release)

## Purpose

A package to use Stan (as an external program) from Julia. 

The package is tested on Mac OSX 10.10, Julia 0.3.2 and CmStan 2.5.0.

For more info on Stan, please go to <http://mc-stan.org>.

For more info on Mamba, please go to <http://mambajl.readthedocs.org/en/latest/>.

This version will be kept as the Github branch Stan-j0.4-v0.0.4

## Whats new

### Version 0.0.4

The two most important features introduced in version 0.0.4 are using Mamba to display and diagnose simulation results and the handling of NaNs in input data.

### Version 0.0.3

The main feature introduced is inline definition of model and data in the .jl file

## Requirements

This version of the Stan.jl package assumes that:

1. CmdStan (see <http://mc-stan.org>) is installed and the environment variables STAN_HOME and CMDSTAN_HOME are set accordingly (pointing to the Stan and CmdStan directories, e.g. /Users/rob/Projects/Stan/cmdstan/stan and /Users/rob/Projects/Stan/cmdstan on my system).

2. Mamba (see <https://github.com/brian-j-smith/Mamba.jl>) is installed. At this moment Mamba has not been registered on METADATA.jl yet. It can be installed using Pkg.clone():

```
julia> Pkg.clone("git://github.com/brian-j-smith/Mamba.jl.git")
```

3. On unix-like systems is uses Google's Chrome to display simulation results after creating .svg files.

To test and run the examples:

**julia >** ``Pkg.test("Stan")``

## Caveats

Version 0.0.4 does not handle NaN in the input data???

## A walk-through example

To run the Bernoulli example:

```
using Stan

old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Bernoulli")
cd(ProjDir)
```
Concatenate home directory and project directory.

```
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

data = [
  (ASCIIString => Any)["N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]],
  (ASCIIString => Any)["N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]],
  (ASCIIString => Any)["N" => 10, "y" => [0, 1, 0, 0, 0, 0, 0, 0, 1, 1]],
  (ASCIIString => Any)["N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1]]
]

stanmodel = Stanmodel(name="bernoulli", model=bernoulli);
stanmodel |> display
println("Input observed data dictionary:")
data |> display
println()
```

Create a default model for sampling. See other examples for methods optimize and diagnose in the Bernoulli example directory. 

Run the simulation and describe the results:

```
sim1 = stan(stanmodel, data_file, ProjDir, diagnostics=true)
describe(sim1)
```

'stan()' is the work horse, the first time it will compile the model and create the executable. 

By default it will run 4 chains, display a combined summary and returns a Mamba Chain for a sampler. Other methods return a dictionary.

```
println("Subset Sampler Output")
sim = sim1[1:1000, ["lp__", "theta", "accept_stat__"], :]
describe(sim)
println()
```

It is also possible to variables to be monitored in the Stanmodel.

The following diagnostics are als based on the Mamba.jl diagnostics:

```
println("Brooks, Gelman and Rubin Convergence Diagnostic")
try
  gelmandiag(sim1, mpsrf=true, transform=true) |> display
catch e
  #println(e)
  gelmandiag(sim, mpsrf=false, transform=true) |> display
end
println()

println("Geweke Convergence Diagnostic")
gewekediag(sim) |> display
println()

println("Highest Posterior Density Intervals")
hpd(sim) |> display
println()

println("Cross-Correlations")
cor(sim) |> display
println()

println("Lag-Autocorrelations")
autocor(sim) |> display
println()
```

To plot the simulation results:

```
p = plot(sim, [:trace, :mean, :density, :autocor], legend=true);
draw(p, ncol=4, filename="summaryplot", fmt=:svg)
draw(p, ncol=4, filename="summaryplot", fmt=:pdf)
```

On a unix-like platform, with e.g. Google's Chrome installed:

```
for i in 1:4
  isfile("summaryplot-$(i).svg") &&
    run(`open -a "Google Chrome.app" "summaryplot-$(i).svg"`)
end

cd(old)
```


## Running a Stan script, some details

The full signature of stan() is:

```
stan(model::Stanmodel, data=Nothing, ProjDir=pwd(); summary=true, diagnostics=false, StanDir=CMDSTANDIR)
````

All parameters to compile and run the Stan script are implicitly passed in through the model argument. Some more details are given below.

The stan() call uses make to create (or update when needed) an executable with the given model.name, e.g. bernoulli in the above example. If no model String (or of zero length) is found, a message will be shown.

If the Julia REPL is started in the correct directory, stan(model) is sufficient for a model that does not require a data file. See the Binormal example.

Next to stan(), the other important method to run Stan scripts is Stanmodel():

```
stanmodel = Stanmodel(name="bernoulli", model=bernoulli);
stanmodel
````

Shows all parameters in the model, in this case (by default) a sample model. 

```
stanmodel2 = Stanmodel(Sample(adapt=Adapt(delta=0.9)), name="bernoulli2", nchains=6)
```

An example of updating default model values when creating a model. The format is slightly different from CmdStan, but the parameters are as described in the CmdStan Interface User's Guide (v2.4.0, July 20th 2014). 

Now stanmodel2 will look like:

```
stanmodel2
````

After the Stanmodel object has been created fields can be updated, e.g.

```
stanmodel2.method.adapt.delta=0.85
```

After the stan() call, the stanmodel.command contains an array of Cmd fields that contain the actual run commands for each chain. These are executed in parallel.

## To do

More features will be added as requested by users and as time permits. Please file an issue on github.

See the TODO.md file for an initial list of issues I've been working on.

**Note 1:** Few problems related to installing CmdStan have been reported on the Stan mailing list (but maybe most folks use RStan or Pystan).

**Note 2:** In order to support platforms other than OS X, help is needed to test on such platforms.
