######### StanSample Gaussian example  ###########

using StanSample, Distributions

gaussian_model = "
data {
  int<lower=0> N;
  vector[N] y;
}
parameters {
  real mu;
  real<lower=0> sigma;
}
model {
  mu ~ normal(0,1);
  sigma ~ cauchy(0,5);
  y ~ normal(mu,sigma);
}
"

simulateGaussian(; μ=0, σ=1, Nd, kwargs...) = (y=rand(Normal(μ, σ), Nd), N=Nd)

count = 0;
iter = 0

while iter < 3
  (y, N) = simulateGaussian(; Nd=5000)
  gaussian_data = Dict("N" => N, "y" => y)

  # Keep tmpdir across multiple runs to prevent re-compilation
  stanmodel = SampleModel("gaussian", gaussian_model)

  rc = stan_sample(stanmodel; data=gaussian_data)

  if success(rc)
    global iter += 1
    samples = read_samples(stanmodel, :dimarray)

    # Show the cmdstan summary output in DataFrame format
    sdf = StanSample.read_summary(stanmodel)
    if sdf[sdf.parameters .== :mu, :ess][1] >= 3999.0 ||
        sdf[sdf.parameters .== :sigma, :ess][1] >= 3999.0
      global count += 1
      println("$(iter), $(count) : mu_ess=$(sdf[sdf.parameters .== :mu, :ess][1]),
          sigma_ess=$(sdf[sdf.parameters .== :sigma, :ess][1])")
    end
  end
end