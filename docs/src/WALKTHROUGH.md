# A walk-through example

Make StanSample.jl available:
```
using StanSample
```

Define a variable 'model' to hold the [Stan language]() model definition:

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
"
```

Create a SampleModel object:

```
sm = SampleModel("bernoulli", model)
```

Above SampleModel() call creates a default model for sampling. See `?SampleModel` for details.

The observed input data:

```
data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])
```

Run a simulation by calling stan_sample(), passing in the model and data: 
```
(sample_file, log_file) = stan_sample(sm, data)
```

If sample_file is defined the sampling completed and can (and should!) be inspected:
```
if !(sample_file == Nothing)
  chns = read_samples(sm)
  describe(chns)
  plot(chns)
end
```
