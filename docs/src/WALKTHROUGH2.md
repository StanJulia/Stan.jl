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

if success(rc)
  samples_nt = read_samples(sm);
end
```

Samples_nt now contains a NamedTuple:
```
nt6_1s.b
```

Compute the mean for vector b:
```
mean(nt6_1s.b, dims=2)
```

Some more options:
```
init = (a = 2.0, b = [1.0, 2.0], sigma = 1.0)
rc6_2s = stan_sample(m6_1s; data, init);
if success(rc6_1s)
    nt6_2s = read_samples(m6_1s)
end

nt6_2s.b
println()
mean(nt6_2s.b, dims=2)
println()

read_summary(m6_1s)
println()

post6_1s_df = read_samples(m6_1s; output_format=:dataframe)
println()

part6_1s = read_samples(m6_1s; output_format=:particles)
```

Walkthrough2.jl is also available as a script in the `examples/Walkthrough2` directory.

Many more examples are provided in the six Example subdirectories. 

Additional examples can be found in [StanSample.jl](https://github.com/StanJulia/StanSample.jl) and [StatisticalRethinking.jl](https://github.com/StatisticalRethinkingJulia/StatisticalRethinking.jl).

StatisticalRethinking.jl add features to compare models and coefficients, plotting (including `trankplots()` for chains) and summarizing results (`precis()`). MCMCChains.jl, part of the Turing ecosystem, provides additional tools to evaluate the chains.

StatsModelComparisons.jl add WAIC, PSIS and a few other model comparison methods.
