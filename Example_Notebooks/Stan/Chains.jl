### A Pluto.jl notebook ###
# v0.19.10

using Markdown
using InteractiveUtils

# ╔═╡ a20974be-c658-11ec-3a53-a185aa9085cb
using Pkg

# ╔═╡ 3626cf55-ee2b-4363-95ee-75f2444a1542
begin
    # Specific to ROSStanPluto
    using StanSample
	
	# Graphics related
    using GLMakie
		
	# Include basic packages
	using RegressionAndOtherStories
end

# ╔═╡ 364446a2-2ff2-4477-aa71-37d44a93dc44
md" ### This notebook is based on chapter 9 in [Statistical Rethinking](https://github.com/StatisticalRethinkingJulia)."

# ╔═╡ 4a6f12f9-3b83-42b5-9fed-0296a5a603c6
md" #### Care and feeding of Markov chains"

# ╔═╡ 2409c72b-cbcc-467f-9e81-23d83d2b703a
html"""
<style>
    main {
        margin: 0 auto;
        max-width: 2000px;
        padding-left: max(160px, 10%);
        padding-right: max(100px, 10%);
    }
</style>
"""

# ╔═╡ d84f1487-7eec-4a09-94d5-811449380cf5
stan9_2 = "
data {
    int n;
    vector[n] y;
}
parameters {
    real alpha;
    real<lower=0> sigma;
}
model {
    real mu;
    alpha ~ normal(0, 1000);
    sigma ~ exponential(0.0001);
    mu = alpha;
    y ~ normal(mu, sigma);
}";

# ╔═╡ eece4795-f36f-4f16-8132-e1fc672ebb8e
let
    Random.seed!(123)
    data = (n=2, y=[-1, 1])
    global m9_2s = SampleModel("m9_2s", stan9_2)
    global rc9_2s = stan_sample(m9_2s; data)
	success(rc9_2s) && describe(m9_2s)
end

# ╔═╡ 9c2175a4-2174-4258-8125-aadc0989f5af
if success(rc9_2s)
	post9_2s = read_samples(m9_2s, :dataframe)
	ms9_2s = model_summary(post9_2s, [:alpha, :sigma])
end

# ╔═╡ 1853b58c-5fc6-4b9c-9500-efb8ea5cff0f
plot_chains(post9_2s, [:alpha])

# ╔═╡ f2194a71-f2b7-4b9c-acc0-ebbb05205f6e
trankplot(post9_2s, "alpha")

# ╔═╡ db7bede1-41d7-4e62-baf2-6449b3cbd45e
stan9_3 = "
data {
    int n;
    vector[n] y;
}
parameters {
    real alpha;
    real<lower=0> sigma;
}
model {
    real mu;
    alpha ~ normal(0, 1);
    sigma ~ exponential(1);
    mu = alpha;
    y ~ normal(mu, sigma);
}";

# ╔═╡ ba6d8640-b472-4ab3-8700-c80fdd59d82b
let
    Random.seed!(123)
    data = (n=2, y=[-1, 1])
    global m9_3s = SampleModel("m9.3s", stan9_3)
    global rc9_3s = stan_sample(m9_3s; data)
	success(rc9_3s) && describe(m9_3s)
end

# ╔═╡ ed087dec-c69e-49b2-bc66-a02449aafa6d
if success(rc9_3s)
	post9_3s = read_samples(m9_3s, :dataframe)
end

# ╔═╡ 3a51c780-9cdd-4f81-96fa-85fa81bb37f5
ms9_3s = model_summary(post9_3s, [:alpha, :sigma])

# ╔═╡ 739831b7-27d4-4450-a3ed-8db96870e105
plot_chains(post9_3s, [:alpha, :sigma])

# ╔═╡ 2e06ce86-9431-4d94-94f5-eedca0d7b4b5
trankplot(post9_3s, "alpha")

# ╔═╡ 9eab4cb7-a30a-440c-a86a-7938df599285
stan9_4 = "
data {
    int n;
    vector[n] y;
}
parameters {
    real alpha;
    real beta;
    real<lower=0> sigma;
}
model {
    real mu;
    alpha ~ normal(0, 100);
    beta ~ normal(0, 1000);
    sigma ~ exponential(1);
    mu = alpha + beta;
    y ~ normal(mu, sigma);
}";

# ╔═╡ d75515b0-de24-4874-8edf-df2a86f24536
begin
	Random.seed!(1)
    data9_4s = (n = 100, y = rand(Normal(0, 1), 100))
    m9_4s = SampleModel("m9.4s", stan9_4)
    rc9_4s = stan_sample(m9_4s; data=data9_4s)
	success(rc9_4s) && describe(m9_4s)
end

# ╔═╡ 213c8348-3c3e-4f27-affe-156f852c078e
if success(rc9_4s)
	post9_4s = read_samples(m9_4s, :dataframe)
end

# ╔═╡ 0162ead7-e9d7-4ddf-a453-9a9f1285fc31
model_summary(post9_4s, [:alpha, :beta, :sigma])

# ╔═╡ cc947268-ef10-46f6-8bdf-6d2b42a70e10
plot_chains(post9_4s, [:alpha, :beta, :sigma])

# ╔═╡ 2dda23d9-d1b5-428e-b2e6-30692624d537
trankplot(post9_4s, "alpha")

# ╔═╡ 3206f276-877c-4f87-961b-3e7f22f351c9
trankplot(post9_4s, "beta")

# ╔═╡ 46ab44f5-26ae-4b2c-865e-0f0860e52a17
stan9_5 = "
data {
    int n;
    vector[n] y;
}
parameters {
    real alpha;
    real beta;
    real<lower=0> sigma;
}
model {
    real mu;
    alpha ~ normal(0, 10);
    beta ~ normal(0, 10);
    sigma ~ exponential(1);
    mu = alpha + beta;
    y ~ normal(mu, sigma);
}";

# ╔═╡ b9abe548-82fd-4e6e-aede-a91d19ce04d3
begin
    # Re-use data from m9_4s
    m9_5s = SampleModel("m9.5s", stan9_5)
    rc9_5s = stan_sample(m9_5s; data=data9_4s)
	success(rc9_5s) && describe(m9_5s)
end

# ╔═╡ 0499bc36-922f-4d89-983e-070eb69ba8d8
if success(rc9_5s)
	sdf9_5s = read_summary(m9_5s)
	post9_5s = read_samples(m9_5s, :dataframe)
end

# ╔═╡ 14b8e07c-a427-4ed5-93a2-22ea6b9a6d47
sdf9_5s

# ╔═╡ 213010f0-aaa7-423a-bcff-4dfe6bbc34cd
plot_chains(post9_5s, [:alpha, :beta, :sigma])

# ╔═╡ e4b85093-d7ca-4323-959a-0a4e12769a65
trankplot(post9_5s, "alpha")

# ╔═╡ 419bd2a1-141f-4106-9bf9-00f07e37359d
begin
	df = CSV.read(ros_datadir("SR2", "rugged.csv"), DataFrame)
	dropmissing!(df, :rgdppc_2000)
	dropmissing!(df, :rugged)
	df.log_gdp = log.(df[:, :rgdppc_2000])
	df.log_gdp_s = df.log_gdp / mean(df.log_gdp)
	df.rugged_s = df.rugged / maximum(df.rugged)
	df.cid = [df.cont_africa[i] == 1 ? 1 : 2 for i in 1:size(df, 1)]
	r̄ = mean(df.rugged_s)
	describe(df[:, [:rgdppc_2000, :log_gdp, :log_gdp_s, :rugged, :rugged_s, :cid]])
end

# ╔═╡ 7bae7603-2785-447c-922f-f1dd856208c0
data8_3s = (N = size(df, 1), K = length(unique(df.cid)), G = df.log_gdp_s, R = df.rugged_s, cid=df.cid);

# ╔═╡ 25f73c43-ed90-43b4-98fd-860c9bdb35b3
stan8_3 = "
data {
	int N;
	int K;
	vector[N] G;
	vector[N] R;
	int cid[N];
}

parameters {
	vector[K] a;
	vector[K] b;
	real<lower=0> sigma;
}

transformed parameters {
	vector[N] mu;
	for (i in 1:N)
		mu[i] = a[cid[i]] + b[cid[i]] * (R[i] - $(r̄));
}

model {
	a ~ normal(1, 0.1);
	b ~ normal(0, 0.3);
	sigma ~ exponential(1);
	G ~ normal(mu, sigma);
}
";

# ╔═╡ 86d9fc80-3b3a-46f0-849e-674071f6d880
begin
	m8_3s = SampleModel("m8.3s", stan8_3)
	rc8_3s = stan_sample(m8_3s; data=data8_3s)
	success(rc8_3s) && describe(m8_3s)
end

# ╔═╡ c78c289a-3112-48a6-83c2-625ef52ff5a3
if success(rc8_3s)
	post8_3s = read_samples(m8_3s, :dataframe)
	nd8_3s = read_samples(m8_3s, :nesteddataframe)
end

# ╔═╡ 428fd578-e58a-44fb-9797-fb3c575b4a3e
array(nd8_3s, :mu)

# ╔═╡ 1952c376-b5ef-4164-8aaa-d016371de227
plot_chains(post8_3s, [Symbol("a.1"), Symbol("a.2")])

# ╔═╡ a67ca73d-015c-415f-b57a-0239bd289369
trankplot(post8_3s, "a.1")

# ╔═╡ 1646dd2f-8087-4aa3-ac0e-6701e913a3b7
plot_chains(post8_3s, [Symbol("b.1"), Symbol("b.2")])

# ╔═╡ c0e5bfda-7cd7-4bd3-808f-79f8a5c623be
plot_chains(post8_3s, [:sigma])

# ╔═╡ Cell order:
# ╟─364446a2-2ff2-4477-aa71-37d44a93dc44
# ╟─4a6f12f9-3b83-42b5-9fed-0296a5a603c6
# ╠═2409c72b-cbcc-467f-9e81-23d83d2b703a
# ╠═a20974be-c658-11ec-3a53-a185aa9085cb
# ╠═3626cf55-ee2b-4363-95ee-75f2444a1542
# ╠═d84f1487-7eec-4a09-94d5-811449380cf5
# ╠═eece4795-f36f-4f16-8132-e1fc672ebb8e
# ╠═9c2175a4-2174-4258-8125-aadc0989f5af
# ╠═1853b58c-5fc6-4b9c-9500-efb8ea5cff0f
# ╠═f2194a71-f2b7-4b9c-acc0-ebbb05205f6e
# ╠═db7bede1-41d7-4e62-baf2-6449b3cbd45e
# ╠═ba6d8640-b472-4ab3-8700-c80fdd59d82b
# ╠═ed087dec-c69e-49b2-bc66-a02449aafa6d
# ╠═3a51c780-9cdd-4f81-96fa-85fa81bb37f5
# ╠═739831b7-27d4-4450-a3ed-8db96870e105
# ╠═2e06ce86-9431-4d94-94f5-eedca0d7b4b5
# ╠═9eab4cb7-a30a-440c-a86a-7938df599285
# ╠═d75515b0-de24-4874-8edf-df2a86f24536
# ╠═213c8348-3c3e-4f27-affe-156f852c078e
# ╠═0162ead7-e9d7-4ddf-a453-9a9f1285fc31
# ╠═cc947268-ef10-46f6-8bdf-6d2b42a70e10
# ╠═2dda23d9-d1b5-428e-b2e6-30692624d537
# ╠═3206f276-877c-4f87-961b-3e7f22f351c9
# ╠═46ab44f5-26ae-4b2c-865e-0f0860e52a17
# ╠═b9abe548-82fd-4e6e-aede-a91d19ce04d3
# ╠═0499bc36-922f-4d89-983e-070eb69ba8d8
# ╠═14b8e07c-a427-4ed5-93a2-22ea6b9a6d47
# ╠═213010f0-aaa7-423a-bcff-4dfe6bbc34cd
# ╠═e4b85093-d7ca-4323-959a-0a4e12769a65
# ╠═419bd2a1-141f-4106-9bf9-00f07e37359d
# ╠═7bae7603-2785-447c-922f-f1dd856208c0
# ╠═25f73c43-ed90-43b4-98fd-860c9bdb35b3
# ╠═86d9fc80-3b3a-46f0-849e-674071f6d880
# ╠═c78c289a-3112-48a6-83c2-625ef52ff5a3
# ╠═428fd578-e58a-44fb-9797-fb3c575b4a3e
# ╠═1952c376-b5ef-4164-8aaa-d016371de227
# ╠═a67ca73d-015c-415f-b57a-0239bd289369
# ╠═1646dd2f-8087-4aa3-ac0e-6701e913a3b7
# ╠═c0e5bfda-7cd7-4bd3-808f-79f8a5c623be
