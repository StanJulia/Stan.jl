using StanSample, MCMCChains

bernoullimodel = "
data { 
  int<lower=1> N; 
  int<lower=0,upper=1> y[N];
  real empty[0];
} 
parameters {
  real<lower=0,upper=1> theta;
} 
model {
  theta ~ beta(1,1);
  y ~ bernoulli(theta);
}
"

observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1],"empty"=>Float64[])


sm = SampleModel("bernoulli", bernoullimodel);

rc = stan_sample(sm, data=observeddata);

if success(rc)
  df = read_samples(sm; output_format=:dataframe)
  display(df)
end
