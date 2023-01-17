### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ 8101d726-f20f-11ea-0bc2-17fa288e23b5
using Pkg

# ╔═╡ 81020e56-f20f-11ea-362b-27053dc41cdb
begin
	using Optim
	using MonteCarloMeasurements
	using StanQuap
	using StatisticalRethinking
	using StatisticalRethinkingPlots

end

# ╔═╡ bf795c3e-f20c-11ea-3be2-f53326c31bcf
md"## Intro-stan-02s.jl"

# ╔═╡ 93792909-2ae1-4ce4-93ca-ab68b0b3793e
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

# ╔═╡ ba7b3448-f211-11ea-2ba3-eda3b6c0a146
	stan1_1 = "
	// Inferring a rate
	data {
	  int N;
	  int<lower=1> n;
	  int<lower=0> k[N];
	}
	parameters {
	  real<lower=0,upper=1> theta;
	}
	model {
	  // Prior distribution for θ
	  theta ~ uniform(0, 1);

	  // Observed Counts
	  k ~ binomial(n, theta);
	}";

# ╔═╡ 8103503a-f20f-11ea-0039-3df29edd62f2
begin
	N = 25                              	# 25 experiments
	d = Binomial(9, 0.66)               	# 9 tosses (simulate 2/3 is water)
	k = rand(d, N)                      	# Simulate 15 trial results
	n = 9                               	# Each experiment has 9 tosses
	data = Dict("N" => N, "n" => n, "k" => k)
	init = Dict(:theta => 0.5)
end

# ╔═╡ 4ff9f050-3e36-11eb-0e80-2b7e791d4ba5
begin
	q1_1s, m1_1s, om = stan_quap("m1.1s", stan1_1; data, init)
	if !isnothing(m1_1s)
		post1_1s_df = read_samples(m1_1s, :dataframe)
	end
	PRECIS(post1_1s_df)
end

# ╔═╡ 818da9a4-f20f-11ea-22f7-5d860f5d4302
begin
	quap1_1s_df = sample(q1_1s)
	PRECIS(quap1_1s_df)
end

# ╔═╡ 8113d7ac-f20f-11ea-3c23-55e1cc5b3833
md"##### This scripts shows a number of different ways to estimate a quadratic approximation."

# ╔═╡ 8114dca4-f20f-11ea-01b6-655c44daa6ce
md"##### Compare with MLE."

# ╔═╡ 8122e934-f20f-11ea-3aa9-95546337d293
part1_1s = Particles(post1_1s_df)

# ╔═╡ 21543902-f216-11ea-076c-bf301cca4890
md"###### MLE estimate"

# ╔═╡ 9d8329f8-f215-11ea-05fb-73d13c3e9d3a
mle_fit = fit_mle(Normal, post1_1s_df.theta)

# ╔═╡ 819831c6-f20f-11ea-3a18-b97920d8dea0
md"###### Using optim (compare with quap() result above)."

# ╔═╡ 81abd456-f20f-11ea-1f23-7d0391bd1088
function loglik(x)
  ll = 0.0
  ll += log.(pdf.(Beta(1, 1), x[1]))
  ll += sum(log.(pdf.(Binomial(9, x[1]), k)))
  -ll
end

# ╔═╡ 81b591ee-f20f-11ea-282d-49247a597eb3
begin
	res = optimize(loglik, 0.0, 1.0)
	mu_optim = Optim.minimizer(res)[1]
	sigma_optim = std(post1_1s_df[:, :theta], mean=mu_optim)
	[mu_optim, sigma_optim]
end

# ╔═╡ 81c0aeb2-f20f-11ea-2c2e-61392085a1d3
md"###### Show the hpd region"

# ╔═╡ 81cb464c-f20f-11ea-18be-a9e06beb1201
bnds_hpd = hpdi(post1_1s_df.theta, alpha=0.11)

# ╔═╡ 81ed14ac-f20f-11ea-22b2-e9ed65f3f14a
begin
	x = 0.5:0.001:0.8
	plot( x, pdf.(Normal( mean(mle_fit) , std(mle_fit)) , x ),
		xlim=(0.5, 0.8), lab="MLE approximation",
		legend=:topleft, line=:dash)
	plot!( x, pdf.(Normal( pmean(part1_1s.theta), pstd(part1_1s.theta)), x ),
		lab="Particle approximation", line=:dash)
	plot!( x, pdf.(Normal( q1_1s.coef.theta, √q1_1s.vcov[1]), x ),
		lab="quap approximation")
	density!(post1_1s_df.theta, lab="StanSample chain")
	vline!([bnds_hpd[1]], line=:dash, lab="hpd lower bound")
	vline!([bnds_hpd[2]], line=:dash, lab="hpd upper bound")
end

# ╔═╡ 823b6f1c-f20f-11ea-25fc-41aaa9ddbf48
md"In this example usually most approximations are similar. Other examples, definitely when theta is not `Normal()`, are less clear."

# ╔═╡ 90032db0-f217-11ea-33a9-8fa3202cd2f8
md"## End of intro-stan/Intro-stan-02s.jl"

# ╔═╡ Cell order:
# ╟─bf795c3e-f20c-11ea-3be2-f53326c31bcf
# ╠═93792909-2ae1-4ce4-93ca-ab68b0b3793e
# ╠═8101d726-f20f-11ea-0bc2-17fa288e23b5
# ╠═81020e56-f20f-11ea-362b-27053dc41cdb
# ╠═ba7b3448-f211-11ea-2ba3-eda3b6c0a146
# ╠═8103503a-f20f-11ea-0039-3df29edd62f2
# ╠═4ff9f050-3e36-11eb-0e80-2b7e791d4ba5
# ╠═818da9a4-f20f-11ea-22f7-5d860f5d4302
# ╟─8113d7ac-f20f-11ea-3c23-55e1cc5b3833
# ╟─8114dca4-f20f-11ea-01b6-655c44daa6ce
# ╠═8122e934-f20f-11ea-3aa9-95546337d293
# ╟─21543902-f216-11ea-076c-bf301cca4890
# ╠═9d8329f8-f215-11ea-05fb-73d13c3e9d3a
# ╟─819831c6-f20f-11ea-3a18-b97920d8dea0
# ╠═81abd456-f20f-11ea-1f23-7d0391bd1088
# ╠═81b591ee-f20f-11ea-282d-49247a597eb3
# ╟─81c0aeb2-f20f-11ea-2c2e-61392085a1d3
# ╠═81cb464c-f20f-11ea-18be-a9e06beb1201
# ╠═81ed14ac-f20f-11ea-22b2-e9ed65f3f14a
# ╟─823b6f1c-f20f-11ea-25fc-41aaa9ddbf48
# ╟─90032db0-f217-11ea-33a9-8fa3202cd2f8
