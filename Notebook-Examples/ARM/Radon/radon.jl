### A Pluto.jl notebook ###
# v0.19.18

using Markdown
using InteractiveUtils

# ╔═╡ 5084b8f0-65ac-4704-b1fc-2a9008132bd7
using Pkg

# ╔═╡ 550371ad-d411-4e66-9d63-7329322c6ea1
begin
    # Specific to ROSStanPluto
    using StanSample
	using DataFramesMeta
	
	# Graphics related
    using GLMakie
		
	# Include basic packages
	using RegressionAndOtherStories
end

# ╔═╡ cf39df58-3371-4535-88e4-f3f6c0404500
md" ##### Widen the cells."

# ╔═╡ 0616ece8-ccf8-4281-bfed-9c1192edf88e
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(160px, 10%);
    	padding-right: max(160px, 30%);
	}
</style>
"""

# ╔═╡ 4755dab0-d228-41d3-934a-56f2863a5652
md"###### A typical set of Julia packages to include in notebooks."

# ╔═╡ 64b4a0ff-57ab-40e0-846c-607ba56f87c0
pwd()

# ╔═╡ f41a688c-dd21-499b-a8fd-e04479d65833
begin
	mn_radon = CSV.read(joinpath(pwd(), "data", "mn_radon.csv"), DataFrame)
	mn_radon.county = rstrip.(String.(mn_radon.county))
	mn_radon
end

# ╔═╡ eaf0cef7-49c0-407f-8490-56df84a87c30
begin
	mn_uranium = CSV.read(joinpath(pwd(), "data", "mn_uranium.csv"), DataFrame)
	mn_uranium.county = rstrip.(String.(mn_uranium.county))
	mn_uranium
end

# ╔═╡ cb6e55ba-1423-49d8-b84e-f7a7766e5ebb
begin
	mn_not_sorted = leftjoin(mn_radon, mn_uranium[:, [:county, :homes]]; on=:county)
	mn_basement = mn_not_sorted[mn_not_sorted.floor .== 0, :]
	mn_floor = mn_not_sorted[mn_not_sorted.floor .== 1, :]
	mn_basement_length = nrow(mn_basement)
	mn_floor_length = nrow(mn_floor)
	# Sort according no of homes with measurements
	mn_sorted = sort(mn_not_sorted, [order(:homes, rev=false), order(:county_id, rev=true)])
	mn_basement_sorted = mn_sorted[mn_sorted.floor .== 0, :]
	mn_floor_sorted = mn_sorted[mn_sorted.floor .== 1, :]
	# Sort mn_uranium the same way
	mn_uranium_sorted = sort(mn_uranium, [order(:homes, rev=false), order(:county_id, rev=true)])
	mn_sorted
end

# ╔═╡ 534496cf-d97c-4584-b220-a7b642447c6a
begin
	df_by = @by(mn_not_sorted,:county, :mean_log_radon = mean(:log_radon))
	df_by.log_uranium = mn_uranium.log_uranium
	df_by.homes = mn_uranium.homes
	df_by.county_id = mn_uranium.county_id
	df_by
end

# ╔═╡ 6e4893d8-e11b-4bda-8f65-d14476b1b4f8
sort(df_by, [order(:homes), order(:county_id, rev=true)])

# ╔═╡ a78cf2d0-0c7e-470c-9f31-d1140416f31f
mn_sorted

# ╔═╡ d73b3781-4c42-420f-ad0b-5d7ed5629049
mn_uranium_sorted

# ╔═╡ 1b78d487-9072-4e3a-9a9d-eaaec00d2a4e
let
	f = Figure()
	ax = Axis(f[1, 1], xlabel="log_radon", ylabel="count")
	h1 = hist!(mn_basement.log_radon; bins = LinRange(-3, 4, 30), normalization = :none, color=:blue, strokewidth = 1,
		strokecolor = :black)
	h2 = hist!(mn_floor.log_radon; bins = LinRange(-3, 4, 30), normalization = :none, color=:red, strokewidth = 1,
		strokecolor = :black)
	Legend(f[1, 2], [h1, h2], ["Basenent", "First floor"])
	f
end

# ╔═╡ 68b5b903-15e8-4b6e-a5c9-e9ff68eb9393
let
	f = Figure()
	ax = Axis(f[1, 1], xlabel="log_radon", ylabel="count")
	h1 = density!(mn_basement.log_radon; color=(:blue, 0.2), strokecolor = :blue, strokewidth = 3, strokearound = true)
	h2 = density!(mn_floor.log_radon; color=(:red, 0.2), strokecolor = :red, strokewidth = 3, strokearound = true)
	Legend(f[1, 2], [h1, h2], ["Basenent", "First floor"])
	f
end

# ╔═╡ 66b541cd-303e-410d-8969-39c22ca92cc0
let
	cat_labels = [x == 0 ? "Basement" : "First floor" for x in mn_radon.floor]
	colors = [x == 0 ? :blue : :red for x in mn_radon.floor]
	f = Figure()
	ax = Axis(f[1, 1])
	rainclouds!(ax, cat_labels, mn_radon.log_radon; plot_boxplots=true, plot_clouds=true, color=colors)
	f
end

# ╔═╡ 531f6333-19ad-4850-9773-d0fa4c46a4c7
length(unique(mn_not_sorted.county))

# ╔═╡ e472968a-47d9-4091-8518-e1bbd4947602
length(unique(mn_basement.county))

# ╔═╡ 49eefcd1-14f5-496a-8724-19ac3fa5fee1
length(unique(mn_floor.county))

# ╔═╡ 9467a274-4a6f-43e0-a4f8-23d43d17ff7e
let
	f = Figure()
	ax = Axis(f[1, 1])
	hist!(mn_uranium.homes; bins=LinRange(-10, 120, 60))
	f
end

# ╔═╡ e1ac6e9d-46a8-4794-ae0f-c246e73c03a7
let
	labs = unique(mn_sorted.county)
	counties = [findfirst(==(i), labs) for i in mn_sorted.county]
	boxplot(counties, mn_sorted.log_radon; axis = (xticks = (1:85, labs), xticklabelrotation = pi/2, xticklabelsize=8))
end

# ╔═╡ 80c03d27-a44e-4967-812f-0d4523d86249
let
	f = Figure()
	ax = Axis(f[1, 1]; xlabel="Observations per county", ylabel="County soil log_uranium")
	scatter!(mn_not_sorted.homes, mn_not_sorted.log_uranium)
	for r in eachrow(mn_not_sorted)
		if r.homes > 25
			annotations!(r.county; position=(r.homes - 4, r.log_uranium + 0.02), fontsize=10)
		end
	end
	f
end

# ╔═╡ df07541f-13ec-4192-acde-82c02ab6bcf6
md" #### Complete pooling regression log_radon on floor."

# ╔═╡ f11b4bdc-3ad4-467d-b75c-37da5e9dcb2c
stan_cp = "
/* simple linear regression model */
data {
  int<lower=0> N;
  vector[N] x;
  vector[N] y;
}
parameters {
  real alpha;
  real beta;
  real<lower=0> sigma;
}
model {
  y ~ normal(alpha + beta * x, sigma);
}";

# ╔═╡ d2585fa2-0d5e-480f-863a-c7c515404057
tmpdir = mktempdir()

# ╔═╡ db6a5dab-a738-42d3-a97a-4ca60894b9ca
begin
	m_cp = SampleModel("cp", stan_cp, tmpdir)
	rc_cp = stan_sample(m_cp; data=(N=length(mn_not_sorted.floor), x=mn_not_sorted.floor, y=mn_not_sorted.log_radon))
	success(rc_cp) && describe(m_cp, [:alpha, :beta, :sigma]; digits=2)
end

# ╔═╡ 9e471ad3-6c48-4f8a-b204-4ee864837898
begin
	post_cp = read_samples(m_cp, :dataframe)
	ms_cp = model_summary(post_cp, [:alpha, :beta, :sigma]; digits=2)
end

# ╔═╡ 10395123-f9c9-441d-a497-cb7be9fa7b18
let
	fig = Figure()
	xlabel = "floor"
	ylabel="log_radon"
	ax = Axis(fig[1, 1]; title="Regression log_radon on floor, all counties.", 
		xlabel, ylabel, xticks=([0, 1], ["Basement", "First floor"]))
	scatter!(mn_basement.floor .+ rand(Normal(0, 0.01), mn_basement_length), mn_basement.log_radon, markersize=2, color=:blue)
	scatter!(mn_floor.floor .+ rand(Normal(0, 0.01), mn_floor_length), mn_floor.log_radon, markersize=2, color=:red)
	xrange = LinRange(0, 1, 30)
	lines!(xrange, mean(post_cp.alpha) .+ mean(post_cp.beta) .* xrange, color = :darkgrey)
	fig
end

# ╔═╡ fbe0ea14-69be-4cc6-9d38-4e114b2e2562
let
	f = Figure()
	ax = Axis(f[1, 1], xlabel="county-level log_uranium", ylabel="home log_radon", title="Home log_radon basement")
	scatter!(mn_basement.log_uranium, mn_basement.log_radon; markersize=6)
	ax = Axis(f[1, 2], xlabel="county-level log_uranium", title="Home log_radon first floor")
	scatter!(mn_floor.log_uranium, mn_floor.log_radon; color=:red, markersize=6)
	f
end

# ╔═╡ 8fd8ec26-7c0c-43a2-ae4c-af6e89b185fd
md" #### No pooling regression log_radon on floor."

# ╔═╡ 6618c5b5-be74-40db-9488-f65581102556
stan_np ="
data {
  int<lower=1> N;  // observations
  int<lower=1> J;  // counties
  array[N] int<lower=1, upper=J> county;
  vector[N] x;     // floor
  vector[N] y;     // radon
}
parameters {
  vector[J] alpha;
  real beta;
  real<lower=0> sigma;
}
model {
  y ~ normal(alpha[county] + beta * x, sigma);  
  alpha ~ normal(0, 10);
  beta ~ normal(0, 10);
  sigma ~ normal(0, 10);
}
generated quantities {
  array[N] real y_rep = normal_rng(alpha[county] + beta * x, sigma);
}";

# ╔═╡ 78a27a91-ed1d-4123-8c5c-db16937e38f1
begin
	m_np = SampleModel("m_np", stan_np, tmpdir)
	rc_np = stan_sample(m_np; data=(N=length(mn_not_sorted.floor), J=85, county=mn_not_sorted.county_id, x=mn_not_sorted.floor,
		y=mn_not_sorted.log_radon))
	sum_np = success(rc_np) && read_summary(m_np)
	sum_np[1:12, :]
end

# ╔═╡ 3c34799c-86bb-4e30-b0de-fda416ac26d5
np_post = read_samples(m_np, :dataframe)

# ╔═╡ af7d7105-ba33-42d5-8e82-98fcff8d3d37
function mlu(data, PI = (0.055, 0.945))
    m = mean.(eachcol(data))
    lower = quantile.(eachcol(data), PI[1])
    upper = quantile.(eachcol(data), PI[2])
    return (mean = m,
            lower = lower,
            upper = upper)
end

# ╔═╡ bfe787fa-9512-47d9-af60-e71c4f43646b
let
	m, l, u = mlu(DataFrame(np_post, :alpha), (0.16, 0.84))
	labs = unique(mn_not_sorted.county)
	homes = [mn_not_sorted[mn_not_sorted.county .==  l, :homes][1] for l in labs]
	global np_alpha = DataFrame(county=labs, county_id=mn_uranium.county_id, homes=homes, mean=m, lower=l, upper=u)
end

# ╔═╡ 14cfd6e9-0d8a-4e1e-b601-c924380bff27
let
	f = Figure()
	ax = Axis(f[1, 1]; xticks = (1:85, np_alpha.county), xticklabelrotation = pi/2, xticklabelsize=8,
		title="No-pooling estimates of alpha values in each county.", ylabel="alpha", xlabel="counties")
	hlines!(ms_cp[:alpha, :mean]; color=:orange)
	indx = 1
	for r in eachrow(np_alpha)
		lines!([indx, indx], [np_alpha.lower[indx], np_alpha.upper[indx]]; color=:grey)
		scatter!(np_alpha.mean)
		indx += 1
	end
	f
end

# ╔═╡ bcc93793-f264-4070-aca0-b166fb16c91d
let
	np_alpha = sort(np_alpha, [order(:homes), order(:county_id, rev=true)])
	f = Figure()
	ax = Axis(f[1, 1]; xticks = (1:85, np_alpha.county), xticklabelrotation = pi/2, xticklabelsize=8,
		title="No-pooling estimates of alpha values in each county, sorted by homes.", ylabel="alpha", xlabel="counties")
	hlines!(ms_cp[:alpha, :mean]; color=:orange)
	indx = 1
	for r in eachrow(np_alpha)
		lines!([indx, indx], [np_alpha.lower[indx], np_alpha.upper[indx]]; color=:grey)
		scatter!(np_alpha.mean)
		indx += 1
	end
	f
end

# ╔═╡ 2ffeb590-d367-468c-aa2b-87fc462c6870
md" #### Predictive values."

# ╔═╡ 54cf46fb-fdef-493f-9d2c-89ff0675994a
begin
	m_np_bsmt = SampleModel("m_np", stan_np, tmpdir)
	rc_np_bsmt = stan_sample(m_np_bsmt; data=(N=length(mn_basement_sorted.floor), J=85, county=mn_basement_sorted.county_id,
		x=mn_basement_sorted.floor, y=mn_basement_sorted.log_radon))
	sum_np_bsmt = success(rc_np_bsmt) && read_summary(m_np_bsmt)
	sum_np_bsmt
end

# ╔═╡ 0df0c8ad-0499-4b89-9987-e01284f1fe5e
function mslu(data, PI = (0.055, 0.945))
    m = mean.(eachcol(data))
	s = std.(eachcol(data))
    lower = quantile.(eachcol(data), PI[1])
    upper = quantile.(eachcol(data), PI[2])
    return (mean = m,
			std = s,
            lower = lower,
            upper = upper)
end

# ╔═╡ fc03f276-2e2b-46a3-8059-5df0ae5eec6a
let
	global np_post_bsmt = read_samples(m_np_bsmt, :dataframe)
	m, s, l, u = mslu(DataFrame(np_post_bsmt, :y_rep), (0.16, 0.84))
	global np_y_rep_bsmt = DataFrame(county=mn_basement_sorted.county, mean=m, std=s,lower=l, upper=u)
end

# ╔═╡ c3d9fe98-003b-446c-a058-79b120309b83
let
	labs = unique(mn_basement_sorted.county)
	counties = [findfirst(==(i), labs) for i in mn_basement_sorted.county]
	
	f = Figure()
	ax = Axis(f[1, 1]; xticks = (1:85, labs), xticklabelrotation = pi/2, xticklabelsize=8,
		xlabel="Counties (sorted by no of measurements)", ylabel="Predicted log_radon value", title="No pooling predictions")
	scatter!(counties, np_y_rep_bsmt.mean)
	hlines!(mean(Array(DataFrame(np_post_bsmt, :y_rep))); color=:orange)
	for (indx, county) in enumerate(counties)
		lines!([county, county], 
			[
				np_y_rep_bsmt.mean[indx] - np_y_rep_bsmt.std[indx]/sqrt(mn_basement_sorted.homes[indx]), 
				np_y_rep_bsmt.mean[indx] + np_y_rep_bsmt.std[indx]/sqrt(mn_basement_sorted.homes[indx])
			], color=:grey)
	end
	f
end

# ╔═╡ 5fc3ef9b-c41c-4b7f-b1ac-1a60cc5d36d1
DataFrame(np_post_bsmt, :y_rep)

# ╔═╡ dd1492d2-e994-4371-9dcd-246ae498035d
mean(Array(DataFrame(np_post_bsmt, :y_rep)))

# ╔═╡ 52a15ff6-d705-4b62-bf45-dd6693f4f9d9
md" #### Partial pooling regression log_radon on floor."

# ╔═╡ d2087caa-d168-4a75-b8df-8d00e393bcfd
stan_pp = "
data {
  int<lower=1> N;  // observations
  int<lower=1> J;  // counties
  array[N] int<lower=1, upper=J> county;
  vector[N] x;
  vector[N] y;
}
parameters {
  real beta;
  real<lower=0> sigma;
  real mu_alpha;
  real<lower=0> sigma_alpha;
  vector<offset=mu_alpha, multiplier=sigma_alpha>[J] alpha;  // non-centered parameterization
}
model {
  y ~ normal(alpha[county] + beta * x, sigma);  
  alpha ~ normal(mu_alpha, sigma_alpha); // partial-pooling
  beta ~ normal(0, 10);
  sigma ~ normal(0, 10);
  mu_alpha ~ normal(0, 10);
  sigma_alpha ~ normal(0, 10);
}
generated quantities {
  array[N] real y_rep = normal_rng(alpha[county] + beta * x, sigma);
}";

# ╔═╡ 8ed5bbeb-96cb-42e4-8617-bab46b1dbcdd
begin
	m_pp = SampleModel("m_pp", stan_pp, tmpdir)
	rc_pp = stan_sample(m_pp; data=(N=length(mn_radon.floor), J=85, county=mn_radon.county_id, x=mn_radon.floor, y=mn_radon.log_radon))
	success(rc_pp) && describe(m_pp, [:beta, :mu_alpha, :sigma_alpha, :sigma]; digits=2)
end

# ╔═╡ d176a5b2-1e33-4b81-998a-6f336a19b57f
begin
	post_pp = read_samples(m_pp, :dataframe)
	ms_pp = model_summary(post_pp, [:beta, :mu_alpha, :sigma_alpha, :sigma], digits=2)
end

# ╔═╡ 9e27130e-e397-4014-a2ca-fbf4972651ad
pp_post = read_samples(m_pp, :dataframe)

# ╔═╡ db722a37-3044-4ab2-8a0d-a3a8565a5ccd
let
	m, l, u = mlu(DataFrame(pp_post, :alpha), (0.16, 0.84))
	labs = unique(mn_not_sorted.county)
	homes = [mn_not_sorted[mn_not_sorted.county .==  l, :homes][1] for l in labs]
	global pp_alpha = DataFrame(county=labs, county_id=mn_uranium.county_id, homes=homes, mean=m, lower=l, upper=u)
end

# ╔═╡ c725ed6c-607d-4f09-93dd-70f8c39d7127
let
	pp_alpha = sort(np_alpha, [order(:homes), order(:county_id, rev=true)])
	f = Figure()
	ax = Axis(f[1, 1]; xticks = (1:85, pp_alpha.county), xticklabelrotation = pi/2, xticklabelsize=8,
		title="Partial-pooling estimates of alpha values in each county, sorted by homes.", ylabel="alpha", xlabel="counties")
	hlines!(ms_cp[:alpha, :mean]; color=:orange)
	indx = 1
	for r in eachrow(pp_alpha)
		lines!([indx, indx], [pp_alpha.lower[indx], pp_alpha.upper[indx]]; color=:grey)
		scatter!(pp_alpha.mean)
		indx += 1
	end
	f
end

# ╔═╡ e5d7c810-35ff-4875-ba6b-485411b99640
let
	np_alpha = sort(np_alpha, [order(:homes), order(:county_id, rev=true)])
	f = Figure()
	ax = Axis(f[1, 1]; title="No-pooling", ylabel="alpha", xlabel="counties")
	ylims!(ax, [0, 3.5])
	hlines!(ms_cp[:alpha, :mean]; color=:orange)
	indx = 1
	for r in eachrow(np_alpha)
		lines!([indx, indx], [np_alpha.lower[indx], np_alpha.upper[indx]]; color=:grey)
		scatter!(np_alpha.mean; color=:darkblue, markersize=12, marker='+')
		indx += 1
	end
	
	pp_alpha = sort(pp_alpha, [order(:homes), order(:county_id, rev=true)])
	ax = Axis(f[1, 2]; title="Partial-pooling", ylabel="alpha", xlabel="counties")
	ylims!(ax, [0, 3.5])
	hlines!(ms_cp[:alpha, :mean]; color=:orange)
	indx = 1
	for r in eachrow(pp_alpha)
		lines!([indx, indx], [pp_alpha.lower[indx], pp_alpha.upper[indx]]; color=:grey)
		scatter!(pp_alpha.mean; color=:darkred, markersize=12, marker='o')
		indx += 1
	end
	f
end

# ╔═╡ Cell order:
# ╟─cf39df58-3371-4535-88e4-f3f6c0404500
# ╠═0616ece8-ccf8-4281-bfed-9c1192edf88e
# ╟─4755dab0-d228-41d3-934a-56f2863a5652
# ╠═5084b8f0-65ac-4704-b1fc-2a9008132bd7
# ╠═550371ad-d411-4e66-9d63-7329322c6ea1
# ╠═64b4a0ff-57ab-40e0-846c-607ba56f87c0
# ╠═f41a688c-dd21-499b-a8fd-e04479d65833
# ╠═eaf0cef7-49c0-407f-8490-56df84a87c30
# ╠═cb6e55ba-1423-49d8-b84e-f7a7766e5ebb
# ╠═534496cf-d97c-4584-b220-a7b642447c6a
# ╠═6e4893d8-e11b-4bda-8f65-d14476b1b4f8
# ╠═a78cf2d0-0c7e-470c-9f31-d1140416f31f
# ╠═d73b3781-4c42-420f-ad0b-5d7ed5629049
# ╠═1b78d487-9072-4e3a-9a9d-eaaec00d2a4e
# ╠═68b5b903-15e8-4b6e-a5c9-e9ff68eb9393
# ╠═66b541cd-303e-410d-8969-39c22ca92cc0
# ╠═531f6333-19ad-4850-9773-d0fa4c46a4c7
# ╠═e472968a-47d9-4091-8518-e1bbd4947602
# ╠═49eefcd1-14f5-496a-8724-19ac3fa5fee1
# ╠═9467a274-4a6f-43e0-a4f8-23d43d17ff7e
# ╠═e1ac6e9d-46a8-4794-ae0f-c246e73c03a7
# ╠═80c03d27-a44e-4967-812f-0d4523d86249
# ╟─df07541f-13ec-4192-acde-82c02ab6bcf6
# ╠═f11b4bdc-3ad4-467d-b75c-37da5e9dcb2c
# ╠═d2585fa2-0d5e-480f-863a-c7c515404057
# ╠═db6a5dab-a738-42d3-a97a-4ca60894b9ca
# ╠═9e471ad3-6c48-4f8a-b204-4ee864837898
# ╠═10395123-f9c9-441d-a497-cb7be9fa7b18
# ╠═fbe0ea14-69be-4cc6-9d38-4e114b2e2562
# ╟─8fd8ec26-7c0c-43a2-ae4c-af6e89b185fd
# ╠═6618c5b5-be74-40db-9488-f65581102556
# ╠═78a27a91-ed1d-4123-8c5c-db16937e38f1
# ╠═3c34799c-86bb-4e30-b0de-fda416ac26d5
# ╠═af7d7105-ba33-42d5-8e82-98fcff8d3d37
# ╠═bfe787fa-9512-47d9-af60-e71c4f43646b
# ╠═14cfd6e9-0d8a-4e1e-b601-c924380bff27
# ╠═bcc93793-f264-4070-aca0-b166fb16c91d
# ╟─2ffeb590-d367-468c-aa2b-87fc462c6870
# ╠═54cf46fb-fdef-493f-9d2c-89ff0675994a
# ╠═0df0c8ad-0499-4b89-9987-e01284f1fe5e
# ╠═fc03f276-2e2b-46a3-8059-5df0ae5eec6a
# ╠═c3d9fe98-003b-446c-a058-79b120309b83
# ╠═5fc3ef9b-c41c-4b7f-b1ac-1a60cc5d36d1
# ╠═dd1492d2-e994-4371-9dcd-246ae498035d
# ╟─52a15ff6-d705-4b62-bf45-dd6693f4f9d9
# ╠═d2087caa-d168-4a75-b8df-8d00e393bcfd
# ╠═8ed5bbeb-96cb-42e4-8617-bab46b1dbcdd
# ╠═d176a5b2-1e33-4b81-998a-6f336a19b57f
# ╠═9e27130e-e397-4014-a2ca-fbf4972651ad
# ╠═db722a37-3044-4ab2-8a0d-a3a8565a5ccd
# ╠═c725ed6c-607d-4f09-93dd-70f8c39d7127
# ╠═e5d7c810-35ff-4875-ba6b-485411b99640
