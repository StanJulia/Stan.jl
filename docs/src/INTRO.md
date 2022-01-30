# A Julia interface to Stan's cmdstan executable

## Stan.jl v9

[Stan](https://github.com/stan-dev/stan) is a system for statistical modeling, data analysis, and prediction. It is extensively used in social, biological, and physical sciences, engineering, and business. The Stan language and the interfaces to execute a Stan language program are documented [here](http://mc-stan.org/documentation/).

[Stan.jl](https://github.com/StanJulia/Stan.jl) illustrates how the packages available in [StanJulia's ecosystem](https://github.com/StanJulia) wrap the methods available in Stan's **cmdstan** executable.

Stan.jl v9.0.0 uses the latest versions of StanSample.jl (v6), StanOptimize.jl (v4) and StanQuap.jl (v4). Both StanSample.jl (v5+) and StanOptimize.jl (v3+) use keyword arguments in the `stan_sample()` call to update the command line options for running the cmdstan binary, e.g.
```Julia
rc = stan_sample(model; data, init, num_chains=2, seed=123, delta=0.85)
```

Stan.jl v9 (and the updated StanJulia packages) are intended to use Stan's `cmdstan` v2.28.2 which enables StanJulia to take full advantage of the C++ level multi-threading options in cmdstan v2.28.2.

In fact, by default, SampleModels in StanSample.jl now use 4 C++ `num_threads` and 4 C++ `num_cpp_chains` and a single Julia chain (`num_chains=1`). All of this can be tailored using the above 3 keyword arguments to `stan_sample()`

Note: Currently I do not suggest to use both C++ level chains and Julia
level chains. By default, if `num_chains > 1` this method will set
`num_cpp_chains` to 1 and a message will be displayed. Set the
postional `check_num_chains` argument to `false` to prevent this.

An example of the possible trade-offs between `num_threads`, `num_cpp_chains` and `num_chains` can be found in the `Examples/RedCardsStudy` directory.

## StanJulia overview

Stan.jl is part of the [StanJulia Github organization](https://github.com/StanJulia) set of packages.

The use of the underlying method packages in StanJulia, i.e. StanSample.jl (the primary workhorse package), StanOptimize.jl, StanVariational.jl, StanQuap.jl and DiffEqBayesStan.jl are demonstrated in Stan.jl and in a much broader context in [StatisticalRethinking.jl](https://github.com/StatisticalRethinkingJulia).

Stan.jl is not the only Stan mcmc option in Julia. Other options are PyCall.jl/PyStan and StanRun.jl. In addition, Julia provides other, pure Julia, mcmc options such as DynamicHMC.jl, Turing.jl and Mamba.jl.

On a high level, a typical workflow to use Stan.jl looks like:

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

  # Extract the draws from the SampleModel and show the schema:
  tbl = read_samples(sm, :table)
  tbl |> display

  # Or converted to a DataFrame

  DataFrame(tbl) |> display

  # See below for reading in the draws directly into a DataFrame.

end
```
Above workflow returns a StanTable.Table object with all chains appended. 

If e.g. a DataFrame (with all chains appended) is preferred:
```
df = read_samples(sm, :dataframe)
```
Other options are `:namedtuple`, `:particles`, `:keyedarray`, `:dimdata`, `:mcmcchains`, etc. See `?read_samples` for more details. Walkthrough and Walkthrough2 show StanSample.jl in action.

## References

There is no shortage of good books on Bayesian statistics. A few of my favorites are:

1. [Bolstad: Introduction to Bayesian statistics](http://www.wiley.com/WileyCDA/WileyTitle/productCd-1118593227.html)

2. [Bolstad: Understanding Computational Bayesian Statistics](http://www.wiley.com/WileyCDA/WileyTitle/productCd-0470046090.html)

3. [Gelman, Hill: Data Analysis using regression and multileve,/hierachical models](http://www.stat.columbia.edu/~gelman/arm/)

4. [McElreath: Statistical Rethinking](http://xcelab.net/rm/statistical-rethinking/)

5. [Kruschke: Doing Bayesian Data Analysis](https://sites.google.com/site/doingbayesiandataanalysis/what-s-new-in-2nd-ed)

6. [Lee, Wagenmakers: Bayesian Cognitive Modeling](https://www.cambridge.org/us/academic/subjects/psychology/psychology-research-methods-and-statistics/bayesian-cognitive-modeling-practical-course?format=PB&isbn=9781107603578)

7. [Betancourt: A Conceptual Introduction to Hamiltonian Monte Carlo](https://arxiv.org/abs/1701.02434)

8. [Gelman, Carlin, and others: Bayesian Data Analysis](http://www.stat.columbia.edu/~gelman/book/)

9. [Causal Inference in Statistics - A Primer](https://www.wiley.com/en-us/Causal+Inference+in+Statistics%3A+A+Primer-p-9781119186847)

10. [Pearl, Judea and MacKenzie, Dana: The Book of Why](https://www.basicbooks.com/titles/judea-pearl/the-book-of-why/9780465097616/)

Special mention is appropriate for the new book:

11. [Gelman, Hill, Vehtari: Rgression and other stories](https://www.cambridge.org/highereducation/books/regression-and-other-stories/DD20DD6C9057118581076E54E40C372C#overview)

which in a sense is a major update to item 3. above.