######### StanSample Bernoulli example  ###########

using DataFrames
using StanSample

bernoulli_model = "
data {
  int<lower=1> N;
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

bernoulli_data = [
  Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 0, 0, 0, 0]),
  Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
  Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 1, 1, 0, 0, 1]),
  Dict("N" => 10, "y" => [1, 1, 1, 1, 1, 1, 1, 1, 0, 1])
]

# Keep tmpdir across multiple runs to prevent re-compilation

sm = SampleModel("bernoulli", bernoulli_model);
rc = stan_sample(sm; data=bernoulli_data);

if success(rc)
  dfa = read_samples(sm, :dataframes;
    include_internals=true
  )

  for i in 1:size(dfa, 1)
    mean(Array(dfa[i]), dims=1) |> display
  end
end
