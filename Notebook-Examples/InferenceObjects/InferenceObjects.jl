### A Pluto.jl notebook ###
# v0.19.19

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
begin
	m_schools = SampleModel("eight_schools", stan_schools)
	rc = stan_sample(m_schools; data, save_warmup=true)
end;

# ╔═╡ 91e75953-130e-471e-9869-4164c90295f7
df = read_samples(m_schools, :dataframe; include_internals=true)

# ╔═╡ d572fb32-4ccf-4ba9-a995-48877e90f232
if success(rc)
    idata = inferencedata(m_schools; log_likelihood_var=:log_lik, posterior_predictive_var=:y_hat)
    idata = merge(idata, from_namedtuple(; observed_data = namedtuple(data)))
else
    @warn "Sampling failed."
end

# ╔═╡ 150f9cea-91da-4648-8469-dfb4c852227a
md" ##### To see more details, click on any of the triangles above or specify group as shown below."

# ╔═╡ 3b2eee33-a2f2-4dc8-a4a1-89fa036a1385
idata.posterior

# ╔═╡ 4d703d31-d03e-4c37-b4b9-c29f29b5cc62
if :observed_data in propertynames(idata)
	idata.observed_data
end

# ╔═╡ 8a6367b7-92f9-498e-874d-868b0a402d3e
DataFrame(idata.observed_data)

# ╔═╡ 5bf5c448-5b76-4c77-9529-9106f94bc1ef
keys(idata.posterior)

# ╔═╡ 9a15cd96-2863-4b87-b3eb-3d14fb128b6d
post_schools = read_samples(m_schools, :dataframe; start=1001)

# ╔═╡ 4da97b66-2c45-4c19-aa32-487a95fb23e9
posterior_schools = DataFrame(idata.posterior)

# ╔═╡ 8f52ef47-46e2-4028-83f1-c9cd183bc799
DataFrame(inferencedata(m_schools).posterior) |> size

# ╔═╡ 2e19a32a-4a26-4b53-8173-ea3d74eb19f4
DataFrame(inferencedata(m_schools; dims=(theta=[:school], theta_tilde=[:school])).posterior)

# ╔═╡ 30b9724d-73f4-4888-9698-b01f0ed1c720
DataFrame(inferencedata(m_schools; dims=(theta=[:school], theta_tilde=[:school])).posterior) |> size

# ╔═╡ 912457a9-1438-4dd1-840b-b620d5d7ccaa
DataFrame(idata.sample_stats)

# ╔═╡ Cell order:
# ╠═cecf32d4-6047-11ed-31d9-9514b3067c9c
# ╠═3a1b3129-e17b-48c5-b7c2-a8caaa55a442
# ╠═a92b66bc-4869-4bd1-8a5a-c519df844fcf
# ╠═8579afa5-4b67-4b64-9f4a-5de9add5fec4
# ╠═b7291faa-3487-4ed5-ae41-501f83f0bf3c
# ╠═a1e486d9-ad7f-48ae-8d51-9ae446e6c030
# ╠═91e75953-130e-471e-9869-4164c90295f7
# ╠═d572fb32-4ccf-4ba9-a995-48877e90f232
# ╟─150f9cea-91da-4648-8469-dfb4c852227a
# ╠═3b2eee33-a2f2-4dc8-a4a1-89fa036a1385
# ╠═4d703d31-d03e-4c37-b4b9-c29f29b5cc62
# ╠═8a6367b7-92f9-498e-874d-868b0a402d3e
# ╠═5bf5c448-5b76-4c77-9529-9106f94bc1ef
# ╠═9a15cd96-2863-4b87-b3eb-3d14fb128b6d
# ╠═4da97b66-2c45-4c19-aa32-487a95fb23e9
# ╠═8f52ef47-46e2-4028-83f1-c9cd183bc799
# ╠═2e19a32a-4a26-4b53-8173-ea3d74eb19f4
# ╠═30b9724d-73f4-4888-9698-b01f0ed1c720
# ╠═912457a9-1438-4dd1-840b-b620d5d7ccaa
