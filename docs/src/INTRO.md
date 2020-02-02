# A Julia interface to Stan's cmdstan executable

## Stan.jl

[Stan](https://github.com/stan-dev/stan) is a system for statistical modeling, data analysis, and prediction. It is extensively used in social, biological, and physical sciences, engineering, and business. The Stan program language and interfaces are documented [here](http://mc-stan.org/documentation/).

[cmdstan](http://mc-stan.org/interfaces/cmdstan.html) is the shell/command line interface to run Stan language programs. 

[Stan.jl](https://github.com/StanJulia/Stan.jl) wraps cmdstan and captures the samples for further processing.

## StanJulia overview

Stan.jl is part of the [StanJulia Github organization](https://github.com/StanJulia) set of packages. CmdStan.jl is one of two options in StanJulia to capture draws from a Stan language program. The other option is *under development* and is illustrated in Stan.jl and [StatisticalRethinking.jl](https://github.com/StatisticalRethinkingJulia/StatisticalRethinking.jl).

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

if rc == 0
  # Cmdstan summary of result
  sdf = read_summary(sm)

  # Display the summary as a DataFrame
  sdf |> display

  # Show the draws
  samples = read_samples(sm, output_format=:array)

end
```
This workflow creates an array of draws, the default value for the `output_format` argument in read_samples().

If at this point a vector of DataFrames (a DataFrame for each chain) is preferred:
```
df = read_samples(sm; output_format=:dataframes)
```
Other options are `:dataframe, :dataframes`, `:mcmcchains` and `:particles`. See
```
?read_samples
```
for more details.

Version 5 of Stan.jl used `:mcmcchains` by default but the dependencies of MCMCChains.jl, including access to plotting features, lead to long compile times. In version 6 the default is :array again. In order to use the other options glue code is needed which is handled by Requires.jl.

## References

There is no shortage of good books on Bayesian statistics. A few of my favorites are:

1. [Bolstad: Introduction to Bayesian statistics](http://www.wiley.com/WileyCDA/WileyTitle/productCd-1118593227.html)

2. [Bolstad: Understanding Computational Bayesian Statistics](http://www.wiley.com/WileyCDA/WileyTitle/productCd-0470046090.html)

3. [Gelman, Hill: Data Analysis using regression and multileve,/hierachical models](http://www.stat.columbia.edu/~gelman/arm/)

4. [McElreath: Statistical Rethinking](http://xcelab.net/rm/statistical-rethinking/)

5. [Gelman, Carlin, and others: Bayesian Data Analysis](http://www.stat.columbia.edu/~gelman/book/)

and a great read (and implementation in DynamicHMC.jl):

5. [Betancourt: A Conceptual Introduction to Hamiltonian Monte Carlo](https://arxiv.org/abs/1701.02434)
