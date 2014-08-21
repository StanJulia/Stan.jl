# Stan

[![Stan](http://pkg.julialang.org/badges/Stan_0.3.svg)](http://pkg.julialang.org/?pkg=Stan&ver=0.3)
## Purpose

A package to use Stan (as an external program) from Julia. 

Right now the package has been tested on Mac OSX 10.9.3+, Julia 0.3 and CmStan 2.4.0.

For more info on Stan, please go to <http://mc-stan.org>.

This version will be kept as the Github branch Stan-j0.3-v0.0.3

## Requirements

This version of the Stan.jl package assumes that CmdStan (see <http://mc-stan.org>) is installed and the environment variables STAN_HOME and CMDSTAN_HOME are set accordingly (pointing to the Stan and CmdStan directories, e.g. /Users/rob/Projects/Stan/cmdstan/stan and /Users/rob/Projects/Stan/cmdstan on my system).

To test and run the examples:

**julia >** ``Pkg.test("Stan")``

## Caveats

Version 0.0.3 does not handle NaN in the input data. 

## A walk-through example

To run the Bernoulli example:

```
using Stan

old = pwd()
path = @windows ? "\\Examples\\Bernoulli" : "/Examples/Bernoulli"
ProjDir = Pkg.dir("Stan")*path
cd(ProjDir)
```
Concatenate home directory and project directory. For Windows, backslashes need to be reversed.

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
```

Create a default model for sampling. See other examples for methods optimize and diagnose in the Bernoulli example directory. Show the results from the first chain:

```
chains = stan(stanmodel, data_file, ProjDir, diagnostics=true)

chains[1]["samples"] |> display

```

'stan()' is the work horse, the first time it will compile the model and create the executable. 

By default it will run 4 chains, display a combined summary and returns a array of dictionaries (one dictionary for each chain) with all samples.

In this example the diagnostics_file, which can optionally be produced by Stan, is used below and hence the argument 'diagnostics=true' has been added. By default diagnostics is set to false.

```
chains[1]["diagnostics"] |> display
println()

logistic(x::FloatingPoint) = one(x) / (one(x) + exp(-x))
logistic(x::Real) = logistic(float(x))
@vectorize_1arg Real logistic

println()
[logistic(chains[1]["diagnostics"]["diagnostics"]) chains[1]["samples"]["diagnostics"]][1:5,:] |> display

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