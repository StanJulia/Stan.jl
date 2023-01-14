### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ b88059f0-f793-11ea-0031-23a60382d51a
using Pkg

# ╔═╡ b8809a8c-f793-11ea-382c-5763b1d11ca5
begin
	using Optim
	using StatisticalRethinking
end

# ╔═╡ fdf51ec0-f794-11ea-327a-33958a9cd52a
md"## Intro-logpdf.jl"

# ╔═╡ b0e613ba-f554-4390-a737-0db4863d9608
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

# ╔═╡ 3330c924-f793-11ea-28b7-6d61030db6f9
md"##### This script shows clip-04-26-29s.jl using Optim and a loglik function."

# ╔═╡ b8812010-f793-11ea-19d0-61be51252ae5
md"## snippet 4.26"

# ╔═╡ 5d5852d4-34cf-11eb-2618-4b83ea072b1e
begin
	df = DataFrame(CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim=';'))
	df2 = filter(row -> row[:age] >= 18, df)
end;

# ╔═╡ b88ee9c0-f793-11ea-08c9-e9b05a6e3990
md"## snippet 4.27"

# ╔═╡ 4433d922-34cf-11eb-379a-cfe1dbd939cb
# Our first model:

stan4_1 = "
  μ ~ Normal(178,20) # prior
  σ ~ Uniform(0, 50) # prior
  height ~ Normal(μ, σ) # likelihood
";

# ╔═╡ b898fb18-f793-11ea-202f-672f3b026e96
md"## snippet 4.28"

# ╔═╡ b8998394-f793-11ea-021c-bf822c791396
function loglik(x)
  ll = 0.0
  ll += log(pdf(Normal(178, 20), x[1]))
  ll += log(pdf(Uniform(0, 50), x[2]))
  ll += sum(logpdf.(Normal(x[1], x[2]), df2.height))
  -ll
end

# ╔═╡ b8a3c502-f793-11ea-34f8-eddc53070e3b
md"## snippet 4.29"

# ╔═╡ 9e16251c-34cf-11eb-2af5-21ac06afd361
# Start values

begin
	lower = [0.0, 0.0]
	upper = [250.0, 50.0]
	x0 = [170.0, 10.0]
end

# ╔═╡ b8bcaa18-f793-11ea-3e04-0fa9333a1435
res = optimize(loglik, lower, upper, x0)

# ╔═╡ b8bd8988-f793-11ea-0f93-4bf863950fe3
Optim.minimizer(res)

# ╔═╡ b8cab216-f793-11ea-1880-9dc5d6a84e79
# Our second model:

stan4_2 = "
  μ ~ Normal(178, 0.1) # prior
  σ ~ Uniform(0, 50) # prior
  height ~ Normal(μ, σ) # likelihood
";

# ╔═╡ 9c55acca-f794-11ea-26ae-c505f54777f2
function loglik2(x)
  ll = 0.0
  ll += log(pdf(Normal(178, 0.1), x[1]))
  ll += log(pdf(Uniform(0, 50), x[2]))
  ll += sum(logpdf.(Normal(x[1], x[2]), df2.height))
  -ll
end

# ╔═╡ b8dd1d66-f793-11ea-1210-99abfb4919c9
x1 = [178.0, 40.0] # Initial values can't be outside the the box.

# ╔═╡ b8ecbb40-f793-11ea-219a-4d4d89afbede
res2 = optimize(loglik2, lower, upper, x1)

# ╔═╡ d9e99bd8-34ce-11eb-1779-231c74d97cd1
Optim.minimizer(res2)

# ╔═╡ b8f4b8ec-f793-11ea-1f5e-6d1225f2da1a
md"##### Notice the increase of σ."

# ╔═╡ b8fc6e14-f793-11ea-275c-35a406bdaefc
md"## End of intro-logpdf.jl"

# ╔═╡ Cell order:
# ╠═fdf51ec0-f794-11ea-327a-33958a9cd52a
# ╠═b0e613ba-f554-4390-a737-0db4863d9608
# ╟─3330c924-f793-11ea-28b7-6d61030db6f9
# ╠═b88059f0-f793-11ea-0031-23a60382d51a
# ╠═b8809a8c-f793-11ea-382c-5763b1d11ca5
# ╟─b8812010-f793-11ea-19d0-61be51252ae5
# ╠═5d5852d4-34cf-11eb-2618-4b83ea072b1e
# ╠═b88ee9c0-f793-11ea-08c9-e9b05a6e3990
# ╠═4433d922-34cf-11eb-379a-cfe1dbd939cb
# ╟─b898fb18-f793-11ea-202f-672f3b026e96
# ╠═b8998394-f793-11ea-021c-bf822c791396
# ╟─b8a3c502-f793-11ea-34f8-eddc53070e3b
# ╠═9e16251c-34cf-11eb-2af5-21ac06afd361
# ╠═b8bcaa18-f793-11ea-3e04-0fa9333a1435
# ╠═b8bd8988-f793-11ea-0f93-4bf863950fe3
# ╠═b8cab216-f793-11ea-1880-9dc5d6a84e79
# ╠═9c55acca-f794-11ea-26ae-c505f54777f2
# ╠═b8dd1d66-f793-11ea-1210-99abfb4919c9
# ╠═b8ecbb40-f793-11ea-219a-4d4d89afbede
# ╠═d9e99bd8-34ce-11eb-1779-231c74d97cd1
# ╟─b8f4b8ec-f793-11ea-1f5e-6d1225f2da1a
# ╟─b8fc6e14-f793-11ea-275c-35a406bdaefc
