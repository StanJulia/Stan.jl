# A Julia interface to Stan's cmdstan executable

## Stan.jl

[Stan](https://github.com/stan-dev/stan) is a system for statistical modeling, data analysis, and prediction. It is extensively used in social, biological, and physical sciences, engineering, and business. The Stan program language and interfaces are documented [here](http://mc-stan.org/documentation/).

[cmdstan](http://mc-stan.org/interfaces/cmdstan.html) is the shell/command line interface to run Stan language programs. 

[Stan.jl](https://github.com/StanJulia/Stan.jl) wraps cmdstan and captures the samples for further processing.

## StanJulia

Stan.jl is part of the [StanJulia Github organization](https://github.com/StanJulia) set of packages. It is one of two options in StanJulia to capture draws from a Stan language program. The other option is *under development* and is illustrated in Stan.jl and [StatisticalRethinking.jl](https://github.com/StatisticalRethinkingJulia/StatisticalRethinking.jl).

These are not the only options to sample using Stan from Julia. Valid other options are PyCall.jl/PyStan and StanRun.jl.

On a very high level, a typical workflow for using CmdStan.jl looks like:

```
using CmdStan

# Define a Stan language program.
bernoulli = "..."

# Prepare for calling cmdstan.
sm = SampleModel(...)

# Compile and run Stan program, collect draws.
rc = stan_sample(...)

# Cmdstan summary of result
sdf = read_summary(sm)

# Dsplay the summary
sdf |> display

# Show the draws
samples = read_samples(sm)
```
This workflow creates an array of draws, the default value for the `output_format` argument in Stanmodel(). Other options are `:dataframes` and `:mcmcchains`.

If at this point a vector of DataFrames (a DataFrame for each chain) is preferred:
```
df = StanSample.convert_a3d(samples, cnames, Val(:dataframes))
```
Or, if you know upfront a vector of DataFrames is what you want, you can specify that when creating the Stanmodel:
```
stanmodel = StanModel(..., output_format=:dataframes,...)
```
Version 5 of CmdStan.jl used `:mcmcchains` by default but the dependencies of MCMCChains.jl, including access to plotting features, can lead to long compile times.

## References

There is no shortage of good books on Bayesian statistics. A few of my favorites are:

1. [Bolstad: Introduction to Bayesian statistics](http://www.wiley.com/WileyCDA/WileyTitle/productCd-1118593227.html)

2. [Bolstad: Understanding Computational Bayesian Statistics](http://www.wiley.com/WileyCDA/WileyTitle/productCd-0470046090.html)

3. [Gelman, Hill: Data Analysis using regression and multileve,/hierachical models](http://www.stat.columbia.edu/~gelman/arm/)

4. [McElreath: Statistical Rethinking](http://xcelab.net/rm/statistical-rethinking/)

5. [Gelman, Carlin, and others: Bayesian Data Analysis](http://www.stat.columbia.edu/~gelman/book/)

and a great read (and implementation in DynamicHMC.jl):

5. [Betancourt: A Conceptual Introduction to Hamiltonian Monte Carlo](https://arxiv.org/abs/1701.02434)
