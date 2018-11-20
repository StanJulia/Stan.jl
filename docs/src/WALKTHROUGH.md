# A walk-through example

## Bernoulli example

In this walk-through, it is assumed that 'ProjDir' holds a path to where transient files will be created (in a subdirectory /tmp of ProjDir).

Make Stan.jl and Mamba diagnostics and graphics available:
```
using Mamba, Stan, Cairo
```

Next define the variable 'bernoullistanmodel' to hold the Stan model definition:
```
bernoullistanmodel = "
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
stanmodel
```

Above Stanmodel() call creates a default model for sampling. Other arguments to Stanmodel() can be found in [`Stanmodel`](@ref)

The observed input data is defined below.
```
bernoullidata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])
```

Run the simulation by calling stan(), passing in the data and the intended working directory. 
```
rc, sim1 = stan(stanmodel, [bernoullidata], ProjDir, CmdStanDir=CMDSTAN_HOME)
```
More documentation on stan() can be found in [`stan`](@ref)

If the return code rc indicated success (rc == 0), Mamba.jl provides the describe() function. We can't use all monitored variables by Stan. In this example a good subset is selected as below and stored in 'sim'
```
if rc == 0
  println("Subset Sampler Output")
  sim = sim1[1:1000, ["lp__", "theta", "accept_stat__"], :]
  describe(sim)
end
```
The first time (or when updates to the model have been made) stan() will compile the model and create the executable.

On Windows, the CmdStanDir argument appears needed (this is still being investigated). On OSX/Unix CmdStanDir is obtained from either ~/.juliarc.jl or an environment variable (see the Requirements section).

By default stan() will run 4 chains, optionally display a combined summary and returns a Mamba Chains object for a sampler. Some other Stan methods, e.g. optimize, return a dictionary.

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

## Running a Stan script, some details

Stan.jl really only consists of 2 functions, Stanmodel() and stan().

### [`Stanmodel`](@ref)

Stanmodel() is used to define the basic attributes for a model:
```
monitor = ["theta", "lp__", "accept_stat__"]
stanmodel = Stanmodel(name="bernoulli", model=bernoulli, monitors=monitor);
stanmodel
```
Above script, in the Julia REPL, shows all parameters in the model, in this case (by default) a sample model.

Compared to the call to Stanmodel() above, the keyword argument monitors has been added. This means that after the simulation is complete, only the monitored variables will be read in from the .csv file produced by Stan. This can be useful if many, e.g. 100s, nodes are being observed.
```
stanmodel2 = Stanmodel(Sample(adapt=Adapt(delta=0.9)), name="bernoulli2", nchains=6)
```
An example of updating default model values when creating a model. The format is slightly different from CmdStan, but the parameters are as described in the CmdStan Interface User's Guide. This is also the case for the Stanmodel() optional arguments random, init and output (refresh only).

Now, in the REPL, the stanmodel2 can be shown by:
```
stanmodel2
```
After the Stanmodel object has been created fields can be updated, e.g.
```
stanmodel2.method.adapt.delta=0.85
```

### [`stan`](@ref)
 
After a Stanmodel has been created, the workhorse function stan() is called to run the simulation. Note that some fields in the Stanmodel are updated by stan().

After the stan() call, the stanmodel.command contains an array of Cmd fields that contain the actual run commands for each chain. These are executed in parallel if that is possible. The call to stan() might update other info in the StanModel, e.g. the names of diagnostics files.

The stan() call uses 'make' to create (or update when needed) an executable with the given model.name, e.g. bernoulli in the above example. If no model String (or of zero length) is found, a message will be shown.
