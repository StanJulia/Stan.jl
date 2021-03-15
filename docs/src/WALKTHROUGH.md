# A walk-through example (using StanSample.jl)

This script assumes StanSample has been installed in your environment.

A better approach would be to use projects, e.g. DrWatson.jl, to manage which packages are available.

Make StanSample.jl available:
```
using StanSample
```

Define a variable 'model' to hold the [Stan language](https://mc-stan.org/docs/2_21/reference-manual/index.html) model definition:

```
model = "
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
";
```

Create and compile a SampleModel object:

```
sm = SampleModel("bernoulli", model);
```

Above SampleModel() call creates a default model for sampling. See `?SampleModel` for details.

The observed input data as a Dict:

```
data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]);
```

Run a simulation by calling stan_sample(), passing in the model and data: 
```
rc = stan_sample(sm; data);

if success(rc)
  samples_df = read_samples(sm; output_format=:dataframe);
  samples_df |> display
end
```

Notice that data and init are optional keyword arguments to `stan_sample()`. Julia expands `data` to `data=data` or you can use `data=your_data`.

A further example can be found in WALKTHROUGH2.md.
