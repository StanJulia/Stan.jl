######### Stan program example  ###########

using StanSample, MCMCChains

  binorm_model = "
  transformed data {
      matrix[2,2] Sigma;
      vector[2] mu;

      mu[1] = 0.0;
      mu[2] = 0.0;
      Sigma[1,1] = 1.0;
      Sigma[2,2] = 1.0;
      Sigma[1,2] = 0.10;
      Sigma[2,1] = 0.10;
  }
  parameters {
      vector[2] y;
  }
  model {
        y ~ multi_normal(mu, Sigma);
  }
  "

sm = SampleModel("binormal", binorm_model);

rc = stan_sample(sm)

if success(rc)
  chn = read_samples(sm, :mcmcchains)
  chn |> display
end
