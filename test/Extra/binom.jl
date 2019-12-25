using Distributions, StanSample, Test

binom_model = "
data{
    int W;
    int F[W];
    int R[W];
}
parameters{
    real<lower=0,upper=1> a;
    real<lower=0> theta;
}
model{
    vector[W] pbar;
    theta ~ exponential( 3 );
    a ~ beta( 3 , 7 );
    R ~ beta_binomial(F ,  a * theta, (1 - a) * theta );
}
generated quantities{
    vector[W] log_lik;
    vector[W] y_hat;
    for ( i in 1:W ) {
        log_lik[i] = beta_binomial_lpmf( R[i] | F[i] , a * theta, (1 - a) * theta  );
        y_hat[i] = beta_binomial_rng(F[i] , a * theta, (1 - a) * theta );
    }
}
"

sm = SampleModel("binomial", binom_model)

probs = rand(Beta(0.3 * 40, 0.7 * 40), 300)
trials = [450 for i = 1:300]
res = [rand(Binomial(trials[i], probs[i]), 1)[1] for i in 1:300]

#d <- list(W = 300, F = trials, R = res)
binom_data = Dict("W" => 300, "F" => trials, "R" => res)

(sample_file, log_file) = stan_sample(sm, data=binom_data)

if !(sample_file == nothing)
  chn = read_samples(sm)
  show(chn)
  
  # Create a ChainDataFrame
  summary_df = read_summary(sm)
  #@test summary_df[:theta, :mean][1] ≈ 0.24 atol=0.8
  
end
