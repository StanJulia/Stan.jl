### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ b850b5ba-0e8b-11eb-1e8f-ff7e2b29163e
using Pkg

# ╔═╡ b878f13a-0e8b-11eb-3a3d-3df3931f026e
begin
 	using NamedArrays
	using StanQuap
	using StatisticalRethinking
	using PlutoUI
end

# ╔═╡ 766ea8e6-0e8b-11eb-15fa-477197ab5a31
md"## Intro-stan-optimize.jl"

# ╔═╡ ca399c32-3a2e-11eb-3f73-d51f5baf0250
md"##### This notebook uses a SampleModel and OptimizeModel to demonstrate the quadratic approximation. See `stan-optimize-02s.jl` for a more streamlined approach for the relatively simple models in chapters 4 to 8 of StatisticalRethinking."

# ╔═╡ 84995629-9993-4dd2-91d4-b805275d7d0b
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

# ╔═╡ b88588d8-0e8b-11eb-096f-f152abbd3d1e
begin
	df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';')
	df = filter(row -> row[:age] >= 18, df);
end;

# ╔═╡ b89107b4-0e8b-11eb-0c7f-437f9e4a9d19
stan4_2 = "
// Inferring the mean and std
data {
  int N;
  real<lower=0> h[N];
}
parameters {
  real<lower=0> sigma;
  real<lower=0,upper=250> mu;
}
model {
  // Priors for mu and sigma
  mu ~ normal(178, 20);
  sigma ~ uniform( 0 , 50 );

  // Observed heights
  h ~ normal(mu, sigma);
}
";

# ╔═╡ b89c414e-0e8b-11eb-2056-bd70c5d493ee
begin
  data = Dict(:N => length(df.height), :h => df.height)
  init = Dict(:mu => 174.0, :sigma => 5.0)
end;

# ╔═╡ ddbc3e62-3a2f-11eb-06d0-e7a7abf38861
md"##### Create a SampleModel:"

# ╔═╡ cb914d40-3345-11eb-1f96-81c4902b8193
begin
  m4_2_sample_s = SampleModel("m4.2_sample_s", stan4_2)
  rc4_2_sample_s = stan_sample(m4_2_sample_s; data)
end;

# ╔═╡ 847d6bee-3347-11eb-0b71-312d18c967df
begin
  if success(rc4_2_sample_s)
    m4_2_sample_s_df = read_samples(m4_2_sample_s, :dataframe)
    PRECIS(m4_2_sample_s_df)
  end
end

# ╔═╡ cb766002-3a2f-11eb-25d6-d9aef3e9d398
md"##### Create an OptimizeModel and obtain map estimates:"

# ╔═╡ a87dc40a-3345-11eb-191b-7f02f5ff8ee7
begin
	m4_2_opt_s = OptimizeModel("m4_2_opt_s", stan4_2)
	rc4_2_opt_s = stan_optimize(m4_2_opt_s; data, init)
end;

# ╔═╡ b8b1e70e-0e8b-11eb-0f10-7d74079e68f8
if success(rc4_2_opt_s)
  optim_stan, cnames = read_optimize(m4_2_opt_s)
  optim_stan
end

# ╔═╡ 36c1d07c-805c-11eb-3401-b1be978eb42a
md"##### Combine SampleModel and OptimizeModel in StanQuap.jl."

# ╔═╡ cf29cb5a-33e8-11eb-142c-319fcce6609b
begin
	q4_2s, m4_2s, om = stan_quap("m4.2s", stan4_2; data, init)
 	quap4_2s_df = sample(q4_2s)
  	PRECIS(quap4_2s_df)
end

# ╔═╡ c06df784-bd6e-4fc3-9495-d9a237c84b49
q4_2s

# ╔═╡ 314b3234-3348-11eb-0d37-c5aa7e3f6c94
md"##### Turing quap results:
```
julia> opt = optimize(model, MAP())
ModeResult with maximized lp of -1227.92
2-element Named Array{Float64,1}
A  │ 
───┼────────
:μ │ 154.607
:σ │ 7.73133

julia> coef = opt.values.array
2-element Array{Float64,1}:
 154.60702358192225
   7.731333062764486

julia> var_cov_matrix = informationmatrix(opt)
2×2 Named Array{Float64,2}
A ╲ B │          :μ           :σ
──────┼─────────────────────────
:μ    │     0.16974  0.000218032
:σ    │ 0.000218032    0.0849058
```"

# ╔═╡ 92734668-805b-11eb-0a16-51e77a8d2af6
NamedArray(q4_2s.vcov, ( q4_2s.params, q4_2s.params ), ("Rows", "Cols"))

# ╔═╡ b8bdd370-0e8b-11eb-0d2e-1174a6d67c88
md"## End of Intro-stan-optimize.jl"

# ╔═╡ Cell order:
# ╟─766ea8e6-0e8b-11eb-15fa-477197ab5a31
# ╟─ca399c32-3a2e-11eb-3f73-d51f5baf0250
# ╠═84995629-9993-4dd2-91d4-b805275d7d0b
# ╠═b850b5ba-0e8b-11eb-1e8f-ff7e2b29163e
# ╠═b878f13a-0e8b-11eb-3a3d-3df3931f026e
# ╠═b88588d8-0e8b-11eb-096f-f152abbd3d1e
# ╠═b89107b4-0e8b-11eb-0c7f-437f9e4a9d19
# ╠═b89c414e-0e8b-11eb-2056-bd70c5d493ee
# ╟─ddbc3e62-3a2f-11eb-06d0-e7a7abf38861
# ╠═cb914d40-3345-11eb-1f96-81c4902b8193
# ╠═847d6bee-3347-11eb-0b71-312d18c967df
# ╟─cb766002-3a2f-11eb-25d6-d9aef3e9d398
# ╠═a87dc40a-3345-11eb-191b-7f02f5ff8ee7
# ╠═b8b1e70e-0e8b-11eb-0f10-7d74079e68f8
# ╟─36c1d07c-805c-11eb-3401-b1be978eb42a
# ╠═cf29cb5a-33e8-11eb-142c-319fcce6609b
# ╠═c06df784-bd6e-4fc3-9495-d9a237c84b49
# ╟─314b3234-3348-11eb-0d37-c5aa7e3f6c94
# ╠═92734668-805b-11eb-0a16-51e77a8d2af6
# ╟─b8bdd370-0e8b-11eb-0d2e-1174a6d67c88
