# Stan

[![Travis Build Status](https://travis-ci.org/goedman/Stan.jl.svg?branch=master)](https://travis-ci.org/goedman/Stan.jl)

[![Stan](http://pkg.julialang.org/badges/Stan_0.4.svg)](http://pkg.julialang.org/?pkg=Stan&ver=0.4)

[![Stan](http://pkg.julialang.org/badges/Stan_0.5.svg)](http://pkg.julialang.org/?pkg=Stan&ver=0.5)

## Purpose

A package to use Stan (as an external program) from Julia.

CmdStan needs to be installed separatedly. Please see the 'Requirements' section below.

For more info on Stan, please go to <http://mc-stan.org>.

For more info on Mamba, please go to <http://mambajl.readthedocs.org/en/latest/>.

This version of the package has primarily been tested on Mac OSX 10.11&12, Julia 0.5.0, CmdStan 2.12.0 and Mamba 0.10.0.

A limited amount of testing has taken place on other platforms by other users of the package (see note 1 in the 'To Do' section below).

## A walk-through example

To run the Bernoulli example, start by concatenating the home directory and project directory:
```
using Mamba, Stan

old = pwd()
ProjDir = Pkg.dir("Stan", "Examples", "Bernoulli")
cd(ProjDir)
```
'ProjDir' is the path where permanent and transient files will be created (in a subdirectory /tmp of ProjDir).

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
Above Stanmodel() call creates a default model for sampling. See the other examples for methods optimize, diagnose and variational in the Bernoulli example directory and below for some more possible Stanmodel() arguments.

The input data is defined below. By default 4 chains will be simulated. Below initialization of 'bernoullidata' creates an array of 4 dictionaries, a dictionary for each chain. If the array length is not equal to the number of chains, only the first element of the array will be used as initialization for all chains.
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
Run the simulation by calling stan(), passing in the data and the intended working directory. To get a summary description of the results, describe() is called (describe() is a Mamba.jl function):
```
sim1 = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME)
describe(sim1)
```
The first time (or when updates to the model or data have been made) stan() will compile the model and create the executable.

On Windows, the CmdStanDir argument appears needed (this is still being investigated). On OSX/Unix CmdStanDir is obtained from either ~/.juliarc.jl or an environment variable (see the Requirements section).

As stated above, by default it will run 4 chains, optionally display a combined summary and returns a Mamba Chains object for a sampler. Some other Stan methods, e.g. optimize, return a dictionary.

In this case 'sim1' is a Mamba Chains object. We can inspect sim1 as follows:
```
typeof(sim1) |> display
fieldnames(sim1) |> display
sim1.names |> display
```
To inspect the simulation results by Mamba's describe() we can't use all monitored variables by Stan. In this example a good subset is selected as follows and stored in 'sim':
```
println("Subset Sampler Output")
sim = sim1[1:1000, ["lp__", "theta", "accept_stat__"], :]
describe(sim)
println()
```
Notice that in this example 7 variables are read in but only 3 are used for diagnostics and posterior inference. In some cases Stan can monitor 100s or even 1000s of variables in which case it might be better to use the monitors keyword argument to stan(), see the next section for more details.

The following diagnostics and Gadfly based plot functions (all from Mamba.jl) are available:
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
  @static is_apple() ? for i in 1:3
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
An example of updating default model values when creating a model. The format is slightly different from CmdStan, but the parameters are as described in the CmdStan Interface User's Guide. This is also the case for the Stanmodel() optional arguments random, init and output (refresh only).

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
  model_file::String="", 
  monitors=String[],
  data=Dict{String, Any}[], 
  random=Random(),
  init=Init(),
  output=Output())
```
All arguments have default values, although usually at least the name and model arguments will be provided.

An external stan model file can be specified by leaving model="" (the default value) and specifying a model_file name.

Notice that 'thin' as an argument to Stanmodel() works slightly different from passing it through the Sample() argument to Stanmodel. In the first case the thinning is applied after Stan has finished, the second case asks Stan to handle the thinning. For Mamba post-processing of the results, the thin argument to Stanmodel() is the preferred option.

If the method=Sample(save_warmup=true) is used, it is possible to retrieve just the warmup samples by calling
```
read_stanfit_warmup_samples(stanmodel)
```
 
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

In Stan.jl v"1.0.3" an example has been added to show passing in parameter values to Stanmodel (see below version release note 2). The example can be found in directory Examples/BernoulliInitTheta.

## What's new

### Version 1.0 3 (next)
 
1. Thanks to Jon Alm Eriksen the performance of update_R_file() has been improved tremendously. A further suggestion by Michael Prange to directly write to the R file also prevents a Julia segmentation trap for very large arrays (N > 10^6).
2. Thanks to Maxime Rischard it is now possible for parameter values to be passed to a Stanmodel as an array of data dictionaries.
3. Bumped REQUIRE for Julia to v"0.5.0".
4. Fix for Stan 2.13.1 (for runs without a data file).
5. Added Marco Cox' fix for scalar data elements.

### Version 1.0.2 (currently tagged version)

1. Bumped REQUIRE for Julia to v"0.5.0-rc3"
2. Updated Homebrew section as CmdStan 2.11.0 is now available from Homebrew
3. Updated .travis.yml to just test on Julia 0.5

### Version 1.0.0

1. Tested with Stan 2.11.0 (fixed a change in the diagnose .csv file format)
2. Updated how CMDSTAN_HOME is retrieved from ENV (see also REQUIREMENTS section below)
3. Requires Julia 0.5
4. Requires Mamba 0.10.0
5. Mamba needs updates to Graphs.jl (will produce warnings otherwise)

### Version 0.3.2

1. Cleaned up message in Pkg.test("Stan")
2. Added experimental use of Mamba.contour() to bernoulli.jl (this requires Mamba 0.7.1+)
3. Introduce the use of Homebrew to install CmdStan on OSX
4. Pkg.test("Stan") will give an error on variational bayes
5. Last version update for Julia 0.4

## Requirements

To run this version of the Stan.jl package on your local machine, it assumes that:

1. CmdStan (see <http://mc-stan.org>) is properly installed.

2. Mamba (see <https://github.com/brian-j-smith/Mamba.jl>) is installed. It can be installed using Pkg.add("Mamba"). It requires Mamba v"0.10.0"

3. On OSX, all examples check the environment variable JULIA_SVG_BROWSER to automatically display (in a browser) the simulation results (after creating .svg files), e.g. on my system I have exported JULIA_SVG_BROWSER="Google Chrome.app". For other platforms the final lines in the Examples/xxxx.jl files may need to be adjusted (or removed). In any case, on all platforms, both a .svg and a .pdf file will be created and left behind in the working directory.

4. Thanks to Robert Feldt and the brew/Homebrew.jl folks, on OSX, in addition to the user following the steps in Stan's CmdStan User's Guide, CmdStan can also be installed using brew or Julia's Homebrew.

	 Executing in a terminal:
	 ```
	 brew tap homebrew/science
	 brew install cmdstan
	 ```
	 should install the latest available (on Homebrew) cmdstan in /usr/local/Cellar/cmdstan/x.x.x
	 
	 Or, from within the Julia REPL:
	 ```
	 using Homebrew
	 Homebrew.add("homebrew/science/cmdstan")
	 ```
	 will install CmdStan in ~/.julia/v0.x/Homebrew/deps/usr/Cellar/cmdstan/x.x.x.
	 
In order for Stan.jl to find the CmdStan executable you can either

1.1) set the environment variable CMDSTAN_HOME to point to the CmdStan directory, e.g. add lines like

```
export CMDSTAN_HOME=/Users/rob/Projects/Stan/cmdstan
launchctl setenv CMDSTAN_HOME /Users/rob/Projects/Stan/cmdstan
```

or for Homebrew (check for the latest cmdstan available and replace x.x.x accordingly):

```
export CMDSTAN_HOME=~/.julia/v0.x/Homebrew/deps/usr/Cellar/cmdstan/x.x.x
launchctl setenv CMDSTAN_HOME ~/.julia/v0.x/Homebrew/deps/usr/Cellar/cmdstan/x.x.x
export JULIA_SVG_BROWSER="Google Chrome.app"
launchctl setenv JULIA_SVG_BROWSER "Google Chrome.app"
```
to ~/.bash_profile (the launchctl lines are OSX specific and only needed for shells started from a GUI application).

I typically prefer not to include the cmdstan version number in the path so no update is needed when CmdStan is updated.

Or, alternatively,

1.2) define CMDSTAN_HOME in ~/.juliarc.jl, e.g. append lines like 
```
CMDSTAN_HOME = "/Users/rob/Projects/Stan/cmdstan" # Choose the appropriate directory here
JULIA_SVG_BROWSER = "Google Chrome.app"
```
to ~/.juliarc.jl.

On Windows this could look like:
```
CMDSTAN_HOME = "C:\\cmdstan"
```

To test and run the examples:

**julia >** ``Pkg.test("Stan")``

## To do

More features will be added as requested by users and as time permits. Please file an issue on github.

**Note 1:** In order to support platforms other than OS X, help is needed to test on such platforms.
