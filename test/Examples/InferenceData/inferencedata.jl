using CSV, DataFrames, NamedTupleTools
using StanSample
using InferenceObjects

stan_schools = """
data {
    int<lower=0> J;
    real y[J];
    real<lower=0> sigma[J];
}

parameters {
    real mu;
    real<lower=0> tau;
    real theta_tilde[J];
}

transformed parameters {
    real theta[J];
    for (j in 1:J)
        theta[j] = mu + tau * theta_tilde[j];
}

model {
    mu ~ normal(0, 5);
    tau ~ cauchy(0, 5);
    theta_tilde ~ normal(0, 1);
    y ~ normal(theta, sigma);
}

generated quantities {
    vector[J] log_lik;
    vector[J] y_hat;
    for (j in 1:J) {
        log_lik[j] = normal_lpdf(y[j] | theta[j], sigma[j]);
        y_hat[j] = normal_rng(theta[j], sigma[j]);
    }
}
""";

data = Dict(
    "J" => 8,
    "y" => [28.0, 8.0, -3.0, 7.0, -1.0, 1.0, 18.0, 12.0],
    "sigma" => [15.0, 10.0, 16.0, 11.0, 9.0, 11.0, 10.0, 18.0]
)

m_schools = SampleModel("eight_schools", stan_schools)
rc = stan_sample(m_schools; data, save_warmup=true)

if success(rc)

    idata = inferencedata(m_schools)

    nt = namedtuple(data)

    # Until InferenceObjects issue #36 is merged
    ntu=(sigma=nt.sigma, J=[4], y=nt.y)
    
    idata = merge(idata, from_namedtuple(; observed_data = ntu))

else
    @warn "Sampling failed."
end

if :observed_data in propertynames(idata)
    idata.observed_data
end

DataFrame(idata.observed_data)

keys(idata.posterior)

post_schools = read_samples(m_schools, :dataframe)

posterior_schools = DataFrame(idata.posterior)

idata |> display

