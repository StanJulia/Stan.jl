# Stan

[![Stan](http://pkg.julialang.org/badges/Stan_0.3.svg)](http://pkg.julialang.org/?pkg=Stan&ver=0.3)
[![Stan](http://pkg.julialang.org/badges/Stan_0.4.svg)](http://pkg.julialang.org/?pkg=Stan&ver=0.4)

## Purpose

A package to use Stan 2.9.0 (as an external program) from Julia (v0.4.2). CmdStan needs to be installed separatedly. Please see the 'Requirements' section below.

For more info on Stan, please go to <http://mc-stan.org>.

For more info on Mamba, please go to <http://mambajl.readthedocs.org/en/latest/>.

This version, once tagged/published in METADATA, will be kept as the Github branch Stan-j0.4-v0.3.2

This version of the package has primarily been tested on Mac OSX 10.11, Julia 0.4.2, CmdStan 2.9.0 and Mamba 0.7+. A limited amount of testing has taken place on other platforms by other users of the package (see note 2 in the 'To Do' section below).

## A walk-through example

To run the Bernoulli example, start by concatenating the home directory and project directory:
```
using Mamba, Stan

old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Bernoulli")
cd(ProjDir)
```
'ProjDir' is the path where permanent and transient files will be created.

Next define the variable 'bernoullistanmodel' to hold the Stan model definition:
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
The next step is to create a Stanmodel object. The most common way to create such an object is
by giving the model a name while the Stan model is passed in, both through keyword (hence optional) arguments:
```
stanmodel = Stanmodel(name="bernoulli", model=bernoullistanmodel);
stanmodel |> display
```
Above Stanmodel() call creates a default model for sampling. See other examples for methods optimize and diagnose in the Bernoulli example directory and below for some more possible Stanmodel() arguments.

The input data is defined below (using the future Julia 0.4 dictionary syntax). Package Compat.jl provides the Dict macro to support this on Julia 0.3. By default 4 chains will be simulated. Below initialization of 'bernoullidata' creates an array of 4 dictionaries, a dictionary for each chain. If the array length is not equal to the number of chains, only the first elemnt of the array will be used as initialization for all chains.
```
const bernoullidata = [
  Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
  Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]),
  Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 0, 0, 1, 1]),
  Dict("N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1])
]
println("Input observed data, an array of dictionaries:")
bernoullidata |> display
println()
```
Run the simulation by calling stan(), passing in the data and the intended working directory (where output files created by Stan will be stored). To get a summary describtion of the results, describe() is called (describe() is a Mamba.jl function):
```
sim1 = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME)
describe(sim1)
```
The first time (or when updates to the model or data have been made) stan() will compile the model and create the executable.

On Windows, the CmdStanDir argument appears needed (this is still being investigated). On OSX/Unix CmdStanDir is obtained from either ~/.juliarc.jl or an environment variable (see the Requirements section).

As stated above, by default it will run 4 chains, optionally display a combined summary and returns a Mamba Chains object for a sampler. Other methods return a dictionary.

In this case 'sim1' is a Mamba Chains object. We can inspect sim1 as follows:
```
typeof(sim1) |> display
fieldnames(sim1) |> display
sim1.names |> display
```
To inspect the simulation results we can't use all monitored variables by Stan. In this example a good subset is selected as follows and stored in 'sim':
```
println("Subset Sampler Output")
sim = sim1[1:1000, ["lp__", "theta", "accept_stat__"], :]
describe(sim)
println()
```
Notice that in this example 7 variables are read in but only 3 are used for diagnostics and posterior inference. In some cases Stan can monitor 100s or even 1000s of variables in which case it might be better to use the monitors keyword argument to stan(), see the next section for more details.

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
On OSX, if e.g. JULIA_SVG_BROWSER="Google's Chrome.app" is exported as an environment variable, the .svg files can be displayed as follows:
```
if length(JULIA_SVG_BROWSER) > 0
  @osx ? for i in 1:3
    isfile("summaryplot-$(i).svg") &&
      run(`open -a $(JULIA_SVG_BROWSER) "summaryplot-$(i).svg"`)
  end : println()
end

cd(old)
```


## Running a Stan script, some details

Stan.jl really only consists of 2 functions, Stanmodel() and stan().

Stanmodel() is used to define basic attributes for a model:
```
monitor = ["theta", "lp__", "accept_stat__"]
stanmodel = Stanmodel(name="bernoulli", model=bernoulli, monitors=monitor);
stanmodel
````
Shows all parameters in the model, in this case (by default) a sample model.

Compared to the call to Stanmodel() above, the keyword argument monitors has been added. This means that after the simulation is complete, only the monitored variables will be read in from the .csv file produced by Stan. This can be useful if many, e.g. 100s, nodes are being observed.
```
stanmodel2 = Stanmodel(Sample(adapt=Adapt(delta=0.9)), name="bernoulli2", nchains=6)
```
An example of updating default model values when creating a model. The format is slightly different from CmdStan, but the parameters are as described in the CmdStan Interface User's Guide (v2.5.0, October 20th 2014). This is also the case for the Stanmodel() optional arguments random, init and output (refresh only).

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
  thin=1,
  model="",
  model_file::ASCIIString="", 
  monitors=ASCIIString[],
  data=Dict{ASCIIString, Any}[], 
  random=Random(),
  init=Init(),
  output=Output())
```
All arguments have default values, although usually at least the name and model arguments will be provided.

An external stan model file can be specified by leaving model="" (the default value) and specifying a model_file name.

Notice that 'thin' as an argument to Stanmodel() works slightly different from passing it through the Sample() argument to Stanmodel. In the first case the thinning is applied after Stan has finished, the second case asks Stan to handle the thinning. For Mamba post-processing of the results, the thin argument to Jagsmodel() is the preferred option.

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
  StanDir=CMDSTAN_HOME)
```
All parameters to compile and run the Stan script are implicitly passed in through the model argument. 


## What's new

### Version 0.3.2

1. Cleaned up message in Pkg.test("Stan")
2. Added experimental use of Mamba.contour() to bernoulli.jl (this requires Mamba 0.7.1+)

### Version 0.3.1

1. Cleaned up shown badges in README (both Travis and ReadTheDocs)
2. Removed 0.3 testing in the new Julia format .travis.yml file

### Version 0.3.0

1. Version 0.3.0 is Julia 0.4 only.
2. Julia 0.4 fixes have been tested up the Julia 0.4-rc4.
3. Added support for variational-bayes in Stan 2.8.0.
4. Added the ODE example from the Stan manual to Examples. Please read the comments on ode.jl.

### Version 0.2.0

1. Added travis & documentation badges
2. Fixes to CMDSTAN_HOME handling in Stan.jl

### Version 0.1.7

1. Updated .travis.yml

### Version 0.1.6

1. Two more notebooks have been added in the Examples/Notebooks directory, StanBernoulliJB includes notebook cells with explanations and some introductory notes.
2. Removed an earlier addition to runtests.jl needed for testing on JuliaBox. Caused problems in tests on pkg.julialang.org.
3. The runtests.jl script now reports which version is being tested.

### Version 0.1.5

1. Demonstrate running Stan on JuliaBox. A notebook example has been added in the Examples/Notebook directory.

### Version 0.1.4

1. Fix for the case where CmdStan is not installed (e.g. in tests on pkg.julialang.org)

### Version 0.1.3

1. Fix for several additional issues on Windows, e.g. CRLF.
2. Handling of obtaining and passing CMDSTAN_HOME is still being studied.
3. For now the Julia upper bound 0.4- has been removed, although several dependencies are not yet available on Julia 0.4.

I would like to thank Kentarou Matsuura for helping out with the Windows issues. Hopefully most aspects have been tested, any remaining issues are of course my responsibility.

### Version 0.1.2

Bug fix:

1. Fix for access to environment variables on Windows.

### Version 0.1.1

Minor updates:

1. Stores Stan's input & output files in a subdirectory of the working directory.
2. Fixed handling of adapt, update and thin when passed in through Stanmodel().

### Version 0.1.0

The two most important features introduced in version 0.1.0 are:

1. Using Mamba to display and diagnose simulation results. The call to stan() to sample now returns a Mamba Chains object (previously it returned a dictionary). 
2. The ability to select which variables to extract form Stan's output .csv file(s).

### Version 0.0.3

1. Inline definition of model and data in the .jl file

### Versions 0.0.2 and earlier

1. Parsing structure for input arguments to Stan.
2. Parallel execution of Stan simulations.
3. Read created .csv file by Stan back into Julia.


## Requirements

To run this version of the Stan.jl package on your local machine, it assumes that:

1. CmdStan (see <http://mc-stan.org>) is properly installed.

2. Mamba (see <https://github.com/brian-j-smith/Mamba.jl>) is installed. It can be installed using Pkg.add("Mamba")

3. On OSX, all Stan-j03-v0.2.1 examples check the environment variable JULIA_SVG_BROWSER to automatically display (in a browser) the simulation results (after creating .svg files), e.g. on my system I have exported JULIA_SVG_BROWSER="Google Chrome.app". For other platforms the final lines in the Examples/xxxx.jl files may need to be adjusted (or removed). In any case, on all platforms, both a .svg and a .pdf file will be created and left behind in the working directory.

In order for Stan.jl to find the CmdStan executable you can either

1.1) set the environment variable CMDSTAN_HOME to point to the CmdStan directory, e.g. add lines like
```
export CMDSTAN_HOME=/Users/rob/Projects/Stan/cmdstan
launchctl setenv CMDSTAN_HOME /Users/rob/Projects/Stan/cmdstan
export JULIA_SVG_BROWSER="Google Chrome.app"
launchctl setenv JULIA_SVG_BROWSER "Google Chrome.app"
```
to ~/.bash_profile (the launchctl lines are OSX specific and only needed for shells started from a GUI application).

Or, alternatively,

1.2) define CMDSTAN_HOME in ~/.juliarc.jl, e.g. append lines like 
```
CMDSTAN_HOME = "/Users/rob/Projects/Stan/cmdstan"
JULIA_SVG_BROWSER = "Google Chrome.app"
```
to ~/.juliarc.jl.

On Windows this could look like:

```
CMDSTAN_HOME = "C:\\cmdstan"
```

To test and run the examples:

**julia >** ``Pkg.test("Stan")``

CmdStan has been installed on JuliaBox (see https://www.juliabox.org ). If you have a JuliaBox account, you should be able to run the StanBernoulliJB.ipynb notebook in the Examples/Notebooks directory, e.g. do 
```
cd(Pkg.dir("Stan", "Examples", "Notebooks"))
```
to see a list of included notebooks.

The two additional notebooks provided test all examples on JuliaBox (or in iJulia) and a notebook that shows how to run the examples included in Stan.jl.


## To do

More features will be added as requested by users and as time permits. Please file an issue on github.

**Note 1:** Few problems related to installing CmdStan have been reported on the Stan mailing list (but maybe most folks use RStan or Pystan).

**Note 2:** In order to support platforms other than OS X, help is needed to test on such platforms.
