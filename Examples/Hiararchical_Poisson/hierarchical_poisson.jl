using StanSample, Random

Random.seed!(1)

cd(@__DIR__)
include("simulatePoisson.jl")

HP = "
data {
    int N;
    int y[N];
    int Ns;
    int idx[N];
    real x[N];
  }
  parameters {
    real a0;
    vector[Ns] a0s;
    real a1;
    real<lower=0> a0_sig;
  }
  model {
    vector[N] mu;
    a0 ~ normal(0, 10);
    a1 ~ normal(0, 1);
    a0_sig ~ cauchy(0, 1);
    a0s ~ normal(0, a0_sig);
    for(i in 1:N) mu[i] = exp(a0 + a0s[idx[i]] + a1 * x[i]);
    y ~ poisson(mu);
  }
"

y, x, idx, N, Ns = simulatePoisson(;Nd=1,Ns=10,a0=1.0,a1=.5,a0_sig=.3)

hp_data = Dict(:N =>N, :y => y, :Ns => Ns, :idx => idx, :x => x)

stanmodel = SampleModel("Hierachical_Poisson", HP; 
  method = StanSample.Sample(adapt = StanSample.Adapt(delta = 0.8)));

(sample_file, log_file) = stan_sample(stanmodel; data=hp_data, n_chains=4)

if !(sample_file == Nothing)
  # Convert to an MCMCChains.Chains object
  chns = read_samples(stanmodel)
  
  # Describe the MCMCChains using MCMCChains statistics
  cdf = describe(chns)
  display(cdf)

  # Show the same output in DataFrame format
  sdf = StanSample.read_summary(stanmodel)
  display(sdf)
end
