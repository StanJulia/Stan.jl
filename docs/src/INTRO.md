# A Julia interface to Stan's cmdstan executable

## Stan.jl

[Stan](https://github.com/stan-dev/stan) is a system for statistical modeling, data analysis, and prediction. It is extensively used in social, biological, and physical sciences, engineering, and business. The Stan language and the interfaces to execute a Stan language program are documented [here](http://mc-stan.org/documentation/).

[Cmdstan](http://mc-stan.org/interfaces/cmdstan.html) is the shell/command line interface to run Stan language programs. 

[Stan.jl](https://github.com/StanJulia/Stan.jl) wraps cmdstan and captures the samples for further processing.

## StanJulia overview

Stan.jl is part of the [StanJulia Github organization](https://github.com/StanJulia) set of packages.

Stan.jl is the primary option in StanJulia to capture draws from a Stan language program.  How to use the underlying component packages in StanJulia, e.g. StanSample.jl, StanOptimize.jl and StanVariational.jl, is illustrated in Stan.jl and in a much broader context in [StatisticalRethinking.jl](https://github.com/StatisticalRethinkingJulia).

The other option to capture draws from a Stan language program in StanJulia is *CmdStan*, which is the older approach and is currently in maintenance mode. Thus new features will be added to Stan.jl and the supporting component packages.

These are not the only options to sample using Stan from Julia. Valid other options are PyCall.jl/PyStan and StanRun.jl. In addition, Julia provides other, pure Julia, mcmc options such as DynamicHMC.jl, Turing.jl and Mamba.jl.

On a very high level, a typical workflow for using Stan.jl looks like:

```
using Stan

# Define a Stan language program.
bernoulli = "..."

# Create and compile a SampleModel, an OptimizeModel, etc.:
sm = SampleModel(...)

# Run the compiled Stan languauge program and collect draws:
rc = stan_sample(...)

if success(rc)
  # Retrieve Stan's `stansummary` executable result:
  sdf = read_summary(sm)

  # Display the summary as a DataFrame:
  sdf |> display

  # Extract the draws from the SampleModel:
  named_tuple_of_samples = read_samples(sm)

end
```
This workflow creates an NamedTuple with the draws, the default value for the `output_format` argument in read_samples().

If a DataFrame (with all chains appended) is preferred:
```
df = read_samples(sm; output_format=:dataframe)
```
Other options are `:dataframes`, `:mcmcchains`, `:array` and `:particles`. See
```
?read_samples
```
for more details. Walkthrough and Walkthrough2 show StanSample.jl in action.

## References

There is no shortage of good books on Bayesian statistics. A few of my favorites are:

1. [Bolstad: Introduction to Bayesian statistics](http://www.wiley.com/WileyCDA/WileyTitle/productCd-1118593227.html)

2. [Bolstad: Understanding Computational Bayesian Statistics](http://www.wiley.com/WileyCDA/WileyTitle/productCd-0470046090.html)

3. [Gelman, Hill: Data Analysis using regression and multileve,/hierachical models](http://www.stat.columbia.edu/~gelman/arm/)

4. [McElreath: Statistical Rethinking](http://xcelab.net/rm/statistical-rethinking/)

5. [Kruschke: Doing Bayesian Data Analysis](https://sites.google.com/site/doingbayesiandataanalysis/what-s-new-in-2nd-ed)

6. [Lee, Wagenmakers: Bayesian Cognitive Modeling](https://www.cambridge.org/us/academic/subjects/psychology/psychology-research-methods-and-statistics/bayesian-cognitive-modeling-practical-course?format=PB&isbn=9781107603578)

7. [Gelman, Carlin, and others: Bayesian Data Analysis](http://www.stat.columbia.edu/~gelman/book/)

8. [Causal Inference in Statistics - A Primer](https://www.wiley.com/en-us/Causal+Inference+in+Statistics%3A+A+Primer-p-9781119186847)

9. [Betancourt: A Conceptual Introduction to Hamiltonian Monte Carlo](https://arxiv.org/abs/1701.02434)

10. [Gelman, Carlin, and others: Bayesian Data Analysis](http://www.stat.columbia.edu/~gelman/book/)

11. [Pearl, Judea and MacKenzie, Dana: The Book of Why](https://www.basicbooks.com/titles/judea-pearl/the-book-of-why/9780465097616/)
