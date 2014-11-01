# Stan

[![Stan](http://pkg.julialang.org/badges/Stan_release.svg)](http://pkg.julialang.org/?pkg=Stan&ver=release)

## Purpose

A package to use Stan (as an external program) from Julia. 

For more info on Stan, please go to <http://mc-stan.org>.

For more info on Mamba, please go to <http://mambajl.readthedocs.org/en/latest/>.

This version will be kept as the Github branch Stan-j0.3-v0.1.0

## What's new

### Version 0.1.0

The two most important features introduced in version 0.1.0 are:

1. Using Mamba to display and diagnose simulation results.
2. The ability to select which variables to extract form Stan's output .csv file(s).

### Version 0.0.3

The main feature introduced is inline definition of model and data in the .jl file

## Requirements

This version of the Stan.jl package assumes that:

1. CmdStan (see <http://mc-stan.org>) is installed and the environment variables STAN_HOME and CMDSTAN_HOME are set accordingly (pointing to the Stan and CmdStan directories, e.g. /Users/rob/Projects/Stan/cmdstan/stan and /Users/rob/Projects/Stan/cmdstan on my system).

2. Mamba (see <https://github.com/brian-j-smith/Mamba.jl>) is installed. At this moment Mamba has not been registered on METADATA.jl yet. It can be installed using Pkg.clone("git://github.com/brian-j-smith/Mamba.jl.git")

3. Only on OSX Stan-j03-v0.1.0 examples use the environment variable JULIA_SVG_BROWSER to automatically display simulation results after creating .svg files in a browser. For other systems the final lines in the Examples/xxxx.jl files may need to be adjusted or removed. Both an .svg and a .pdf file will be created. If the environment variable JULIA_SVG_BROWSER is not found, "Google Chrome.app" is assumed.

The package has been tested on Mac OSX 10.10, Julia 0.3.2 and CmStan 2.5.0.

To test and run the examples:

**julia >** ``Pkg.test("Stan")``

## A walk-through example

To run the Bernoulli example:

```
using Compat, Mamba, Stan

old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Bernoulli")
cd(ProjDir)
```
Concatenate home directory and project directory.

Variable 'bernoullistanmodel' holds the Stan model definition:
```
const bernoullistanmodel = "
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
```
The model is given a name while the Stan model is passed in using the model keyword argument:
```
stanmodel = Stanmodel(name="bernoulli", model=bernoullistanmodel);
stanmodel |> display
```
The Stanmodel() call creates a default model for sampling. See other examples for methods optimize and diagnose in the Bernoulli example directory and below for some more details.

The input data is defined below (using the future Julia 0.4 dictionary syntax). Package Compat.jl provides the @Compat.Dict macro to support this on Julia 0.3. By default 4 chains will be simulated. Below initialization of 'data' is an array of 4 dictionaries, a dictionary for each chain. If the array length is not equal to the number of chains, only the first elemnt of the array will be used for all chains.
```
const bernoullidata = [
  @Compat.Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
  @Compat.Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]),
  @Compat.Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 0, 0, 1, 1]),
  @Compat.Dict("N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1])
]
println("Input observed data, an array of dictionaries:")
bernoullidata |> display
println()
```
Run the simulation by calling stan(), passing in the data and the intended working directory (where output files created by Stan will be stored). Describe the results (describe() is a Mamba.jl function):
```
sim1 = stan(stanmodel, bernoullidata, ProjDir)
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
The following diagnostics and Gadfly based plot functions from Mamba.jl are available:
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
On OSX, with e.g. Google's Chrome installed:
```
@osx ? for i in 1:4
  isfile("summaryplot-$(i).svg") &&
    run(`open -a "Google Chrome.app" "summaryplot-$(i).svg"`)
end : println()

cd(old)
```


## Running a Stan script, some details

Stan.jl really only consists of 2 functions, StanModel() and stan().

Stanmodel() is used to define basic attributes for a model:
```
monitor = ["theta", "lp__", "accept_stat__"]
stanmodel = Stanmodel(name="bernoulli", model=bernoulli, monitors=monitor);
stanmodel
````
Shows all parameters in the model, in this case (by default) a sample model.

Notice that compared to the call to Stanmodel() above, the keyword argument monitors has been added. This means that after the simulation is complete, only the monitored variables will be read in from the .csv file produced by Stan. This can be useful if many nodes are being observed.
```
stanmodel2 = Stanmodel(Sample(adapt=Adapt(delta=0.9)), name="bernoulli2", nchains=6)
```
An example of updating default model values when creating a model. The format is slightly different from CmdStan, but the parameters are as described in the CmdStan Interface User's Guide (v2.5.0, October 20th 2014). 

Now stanmodel2 will look like:
```
stanmodel2
````
After the Stanmodel object has been created fields can be updated, e.g.

```
stanmodel2.method.adapt.delta=0.85
```
After the stan() call, the stanmodel.command contains an array of Cmd fields that contain the actual run commands for each chain. These are executed in parallel. The call to stan() might update other info in the StanModel, e.g. the names of diagnostics files.

The full signature of Stanmodel() is:
```
function Stanmodel(
  method=Sample();
  name="noname", 
  nchains=4,
  adapt=1000, 
  update=1000,
  model="",
  monitors=ASCIIString[],
  data=Dict{ASCIIString, Any}[], 
  random=Random(),
  init=Init(),
  output=Output())
```
All arguments have default values, although usually at least the name and model arguments will be provided.

After a Stanmodel has been created, the workhorse function stan() is called to run the simulation.

The stan() call uses 'make' to create (or update when needed) an executable with the given model.name, e.g. bernoulli in the above example. If no model String (or of zero length) is found, a message will be shown.

If the Julia REPL is started in the correct directory, stan(model) is sufficient for a model that does not require a data file. See the Binormal example.


The full signature of stan() is:
```
function stan(
  model::Stanmodel, 
  data=Nothing, 
  ProjDir=pwd();
  summary=true, 
  diagnostics=false, 
  StanDir=CMDSTANDIR)
```
All parameters to compile and run the Stan script are implicitly passed in through the model argument. 


## To do

More features will be added as requested by users and as time permits. Please file an issue on github.

**Note 1:** Few problems related to installing CmdStan have been reported on the Stan mailing list (but maybe most folks use RStan or Pystan).

**Note 2:** In order to support platforms other than OS X, help is needed to test on such platforms.
