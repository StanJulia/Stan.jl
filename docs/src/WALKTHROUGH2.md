# A walk-through example (using StanSample.jl)

Make StanSample.jl available:
```
using StanSample, Distributions
```

Include also Distributions.jl as we'll be using that package to create an example model. This example is derived from an example in [StatisticalRethinking.jl](https://xcelab.net/rm/statistical-rethinking/).

It shows a few more features than the Bernoulli example in WALKTHROUGH.md.

```
N = 100
df = DataFrame(
    height = rand(Normal(10, 2), N),
    leg_prop = rand(Uniform(0.4, 0.5), N),
)
df.leg_left = df.leg_prop .* df.height + rand(Normal(0, 0.02), N)
df.leg_right = df.leg_prop .* df.height + rand(Normal(0, 0.03), N)
```

Define a variable `stan6_1` to hold the [Stan language](https://mc-stan.org/docs/2_21/reference-manual/index.html) model definition:

```
stan6_1 = "
data {
  int <lower=1> N;
  vector[N] H;
  vector[N] LL;
  vector[N] LR;
}
parameters {
  real a;
  vector[2] b;
  real <lower=0> sigma;
}
model {
  vector[N] mu;
  mu = a + b[1] * LL + b[2] * LR;
  a ~ normal(10, 100);
  b ~ normal(2, 10);
  sigma ~ exponential(1);
  H ~ normal(mu, sigma);
}
";
```

Create and compile a SampleModel object. By "compile" here is meant that `SampleModel()` will take care of compiling the Stan language program first to a C++ program and subsequantly compile that C++ program to an executable which will be executed in `stan_sample()`.

```
sm = SampleModel("m6.1s", stan6_1);
```

Above `SampleModel()` call creates a default model for sampling. See `?SampleModel` for details.

The observed input data is defined below. Note here we use a NamedTuple for input:

```
data = (H = df.height, LL = df.leg_left, LR = df.leg_right, N = size(df, 1))
```

Generate posterior draws by calling `stan_sample()`, passing in the model and optionally data and sometimes initial settings: 
```
rc6_1s = stan_sample(m6_1s; data);


if success(rc6_1s)
    chns = read_samples(m6_1s)

    # Display the chns

    chns |> display
    println()

    # Display the keys

    axiskeys(chns) |> display
    println()

    mean(chns_a, dims=1) |> display
    println()

    chns(chain=1) |> display
    println()

    chns[:, 1, 8] |> display
    println()

    chns(chain=1, param=:bp) |> display
    println()

    chns(chain=[1, 3], param=[:bp, :bpC]) |> display
    println()

    # Select all elements starting with 'a'

    # Use `matrix(...)` - with a twist - from the Tables.jl interface.
    # `matrix(...) is overloaded to extract a block of parameters:

    chns_a = matrix(chns, :a)
    chns_a |> display
    println()

    typeof(chns_a.data) |> display
    println()

    ndraws_a, nchains_a, nparams_a = size(chns_a)
    chn_a = reshape(chns_a, ndraws_a*nchains_a, nparams_a)
    println()

    for row in eachrow(chn_a)
        # ...
    end

    # Or use read_samples to only use chains 2 and 4 using the chains kwarg.

    chns2 = read_samples(m10_4s; chains=[2, 4])
    chns2_a = matrix(chns2, :a)
    ndraws2_a, nchains2_a, nparams2_a = size(chns2_a)
    chn2_a = reshape(chns2_a, ndraws2_a*nchains2_a, nparams2_a)
    mean(chns2_a, dims=1) |> display

end

init = (a = 2.0, b = [1.0, 2.0], sigma = 1.0)
rc6_2s = stan_sample(m6_1s; data, init);

if success(rc6_2s)

    # Retrieve the summary created by the stansummary executable:

    read_summary(m6_1s, true)
    println()

    # For simple models often a DataFrame is attractive to work with:

    post6_1s_df = read_samples(m6_1s, :dataframe)
    post6_1s_df |> display
    println()

    part6_1s = read_samples(m6_1s, :particles)
    part6_1s |> display
    println()

    # Use a NamedTuple:
    
    nt6_1s = read_samples(m6_1s, :namedtuple)
    nt6_1s |> display
    println()

    nt6_1s.b |> display

    # Compute the mean for vector b:

    mean(nt6_1s.b, dims=2)

end

```

Many more examples are provided in the Example subdirectories.

A new member of the StanJulia family is DiffEqBayesStan.jl.

Additional examples can be found in [StanSample.jl](https://github.com/StanJulia/StanSample.jl) and [StatisticalRethinking.jl](https://github.com/StatisticalRethinkingJulia/StatisticalRethinking.jl).

StatisticalRethinking.jl add features to compare models and coefficients, plotting (including `trankplots()` for chains) and summarizing results (`precis()`).

MCMCChains.jl, part of the Turing ecosystem, provides additional tools to evaluate the chains.