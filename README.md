# Stan

## Purpose

A package to use Stan (as an external program) from Julia. 

Right now the package has been tested on Mac OSX 10.9.3+, Julia 0.3-prerelease and CmStan 2.3.0.

For more info on Stan, please go to <http://mc-stan.org>.

## Requirements

This version of the Stan.jl package assumes that CmdStan (see <http://mc-stan.org>) is installed and the environment variable STAN_HOME is set accordingly (pointing to the CmdStan directory).

To test and run the examples:

**julia >** ``Pkg.test("Stan")``

## A walk-through example

To run the Bernoulli example:

**julia >** ``using Stan``

The Stan package uses DataFrames, but DataFrames is only required if Stan's results are further processed.

**julia >** ``old = pwd()``
<br>**julia >** ``ProjDir = homedir() * "/.julia/v0.3/Stan/Examples/Bernoulli/"``

Concatenate home directory and project directory. For Windows, backslashes need to be reversed.

**julia >** ``cd(ProjDir)``

Simplifies calling read_stanfit() and/or stan_summary() later.

**julia >** ``stanmodel = Model(name="bernoulli");``

Create a default model for sampling. See other examples for methods optimize and diagnose in the Bernoulli example directory.

**julia >** ``data_file = "bernoulli.data.R"``
<br>**julia >** ``samples_df = stan(stanmodel, data_file, ProjDir, diagnostics=true)``

'stan()' is the work horse, the first time it will compile the model and create the executable.
By default it will run 4 chains, display a combined summary and returns a DataFrame with all samples.

In this example the diagnostics_file, which can optionally be produced by Stan, is used below and hence the argument 'diagnostics=true' has been added. By default diagnostics is set to false. See also the next section.

**julia >** ``stan_summary("$(stanmodel.name)_samples_2.csv")``
<br>**julia >** ``println("First 5 of $(size(samples_df)[1]) rows of sample_df: ")``
<br>**julia >** ``show(samples_df[1:5, :], true)``
<br>**julia >** ``println()``

Notice samples_df has 400 rows and contains all (thinned) samples from the 4 chains.

**julia >** ``samples_2_df = read_stanfit("$(stanmodel.name)_samples_2.csv")``
<br>**julia >** ``diags_2_df = read_stanfit("$(stanmodel.name)_diagnostics_2.csv")``

In this case only bernoulli_samples_2.csv is read in. Or select the appropriate rows:

**julia >** ``println()``
<br>**julia >** ``println([logistic(diags_2_df[1:5, :theta]) samples_df[101:105, :theta]])``
<br>
<br>**julia >** ``cd(old)``

## Running a Stan script, some details

The full signature of stan() is:

``stan(model::Model, data=Nothing, ProjDir=pwd(); summary=true, diagnostics=false, StanDir=STANDIR)``

All parameters to compile and run the Stan script are implicitly passed in through the model argument. Some more details are given below.

The stan() call uses make to create (or update when needed) an executable with the given model.name, e.g. bernoulli in the above example.

If the Julia REPL is started in the correct directory, stan(model) is sufficient for a model that does not require a data file. See the Binormal example.

Next to stan(), the other important method to run Stan scripts is Model():

**julia >** ``stanmodel = Model(name="bernoulli");``
<br>**julia >** ``stanmodel``

Shows all parameters in the model, in this case (by default) a sample model. 

**julia >** ``stanmodel2 = Model(name="bernoulli2", noofchains=6, method=Sample(adapt=Adapt(delta=0.9)))``

An example of updating default model values when creating a model. The format is slightly different from CmdStan, but the parameters are as described in the CmdStan Interface User's Guide (v2.3.0, June 20th 2014). 

Now stanmodel2 will look like:

**julia >** ``stanmodel2``

After the Model object has been created fields can be updated, e.g.

``stanmodel2.method.adapt.delta=0.85``

After the stan() call, the stanmodel.command contains an array of Cmd fields that contain the actual run commands for each chain.

## To do

More features will be added as requested by users and as time permits. Please file an issue on github.

See the TODO.md file for an initial list of issues I've been working on.

**Note 1:** Few problems related to installing CmdStan have been reported on the Stan mailing list (but maybe most folks use RStan or Pystan).

**Note 2:** In order to support platforms other than OS X, help is needed to test on such platforms.