# A walk-through example

## Bernoulli example

[`Stan.cmdline`](@ref)

In this walk-through, it is assumed that 'ProjDir' holds a path to where transient files will be created (in a subdirectory /tmp of ProjDir).

Make Stan.jl and Mamba diagnostics and graphics available:
```
using Mamba, Stan
```

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

The next step is to create a Stanmodel object. The most common way to create such an object is by giving the model a name while the Stan model is passed in, both through keyword (hence optional) arguments:
```
stanmodel = Stanmodel(name="bernoulli", model=bernoullistanmodel);
stanmodel |> display
```

Above Stanmodel() call creates a default model for sampling. See the other examples for methods optimize, diagnose and variational in the Bernoulli example directory and below for some more possible Stanmodel() arguments.

The input data is defined below.
```
const bernoullidata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])
```

Run the simulation by calling stan(), passing in the data and the intended working directory. 
```
sim1 = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME)
```

To get a summary description of the results, describe() is called (describe() is a Mamba.jl function):
```
sim1 = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME)
describe(sim1)
```

The first time (or when updates to the model or data have been made) stan() will compile the model and create the executable.

On Windows, the CmdStanDir argument appears needed (this is still being investigated). On OSX/Unix CmdStanDir is obtained from either ~/.juliarc.jl or an environment variable (see the Requirements section).

By default it will run 4 chains, optionally display a combined summary and returns a Mamba Chains object for a sampler. Some other Stan methods, e.g. optimize, return a dictionary.

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
  gelmandiag(sim, mpsrf=true, transform=true) |> display
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

