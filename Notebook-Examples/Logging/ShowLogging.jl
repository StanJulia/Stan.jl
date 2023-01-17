### A Pluto.jl notebook ###
# v0.19.18

using Markdown
using InteractiveUtils

# ╔═╡ 3a1b3129-e17b-48c5-b7c2-a8caaa55a442
using Pkg

# ╔═╡ a92b66bc-4869-4bd1-8a5a-c519df844fcf
begin
	using CSV, DataFrames, NamedTupleTools
	using InferenceObjects
	using StanSample
end

# ╔═╡ cecf32d4-6047-11ed-31d9-9514b3067c9c
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(160px, 10%);
    	padding-right: max(160px, 10%);
	}
</style>
"""

# ╔═╡ 8579afa5-4b67-4b64-9f4a-5de9add5fec4
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

# ╔═╡ b7291faa-3487-4ed5-ae41-501f83f0bf3c
data = Dict(
    "J" => 8,
    "y" => [28.0, 8.0, -3.0, 7.0, -1.0, 1.0, 18.0, 12.0],
    "sigma" => [15.0, 10.0, 16.0, 11.0, 9.0, 11.0, 10.0, 18.0]
);

# ╔═╡ a1e486d9-ad7f-48ae-8d51-9ae446e6c030
# Sample using cmdstan
begin
	m_schools = SampleModel("eight_schools", stan_schools)
	rc = stan_sample(m_schools; data)
end;

# ╔═╡ 9a15cd96-2863-4b87-b3eb-3d14fb128b6d
post_schools = read_samples(m_schools, :dataframe)

# ╔═╡ ee1a3352-fd5c-4a11-a430-1825d0b57a92
Array(DataFrame(post_schools, :theta_tilde))

# ╔═╡ 46d18428-b5ef-4c70-986d-fef0fa5c6862
let
	m_schools = SampleModel("eight_schools", stan_schools)
	rc = stan_sample(m_schools; data, num_chains=5, use_cpp_chains=true, show_logging=true)
end;

# ╔═╡ Cell order:
# ╠═cecf32d4-6047-11ed-31d9-9514b3067c9c
# ╠═3a1b3129-e17b-48c5-b7c2-a8caaa55a442
# ╠═a92b66bc-4869-4bd1-8a5a-c519df844fcf
# ╠═8579afa5-4b67-4b64-9f4a-5de9add5fec4
# ╠═b7291faa-3487-4ed5-ae41-501f83f0bf3c
# ╠═a1e486d9-ad7f-48ae-8d51-9ae446e6c030
# ╠═9a15cd96-2863-4b87-b3eb-3d14fb128b6d
# ╠═ee1a3352-fd5c-4a11-a430-1825d0b57a92
# ╠═46d18428-b5ef-4c70-986d-fef0fa5c6862
