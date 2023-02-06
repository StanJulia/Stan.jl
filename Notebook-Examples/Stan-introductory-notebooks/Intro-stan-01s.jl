### A Pluto.jl notebook ###
# v0.19.20

using Markdown
using InteractiveUtils

# ╔═╡ 38677642-f1dd-11ea-2537-59511c140dab
using Pkg

# ╔═╡ 5d9316ec-f1dd-11ea-1c0d-0d8566ab3a90
begin
	using MonteCarloMeasurements
	using CategoricalArrays
	using StanSample, StanQuap
	using StatisticalRethinking
	using StatisticalRethinkingPlots
	using PlutoUI
end

# ╔═╡ accc5535-2e9e-4a20-bd83-048477649d4b
md" ## Another introduction to Stan, as used in StatisticalRethinking.jl."

# ╔═╡ 6908ab8d-41be-4bca-9111-91cda8ea06b7
md"
!!! note

Currently I prefer the notebook style used in Regression And Other Stories and given time SR2StanPluto.jl will be updated accordingly.

"

# ╔═╡ 2a0a2339-1c8b-42d0-93cb-a97c461e2dd9
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

# ╔═╡ 45929f5a-f759-11ea-1955-67ba740778e6
md"### Rethinking vs. StatisticalRethinking.jl"

# ╔═╡ e27ece36-f756-11ea-250c-99d909d390f9
md"In the book and associated R package `rethinking`, statistical models are defined as illustrated below:

```
flist <- alist(
  height ~ dnorm( mu , sigma ) ,
  mu <- a + b*weight ,
  a ~ dnorm( 156 , 100 ) ,
  b ~ dnorm( 0 , 10 ) ,
  sigma ~ dunif( 0 , 50 )
)
```
"

# ╔═╡ 8819279a-f757-11ea-37ee-f7b0a267d351
md"The author of the book states: *If that (the statistical model) doesn't make much sense, good. ... you're holding the right textbook, since this book teaches you how to read and write these mathematical descriptions* (page 77).

The Pluto notebooks in [SR2StanPluto](https://github.com/StatisticalRethinkingJulia/SR2StanPluto.jl) are intended to allow experimenting with this learning process using [Stan](https://github.com/StanJulia) and [Julia](https://julialang.org).

In the R package `rethinking`, posterior values can be approximated by
 
```
# Simulate quadratic approximation (for simpler models)
m4.31 <- quap(flist, data=d2)
```
"

# ╔═╡ 46c64c28-803e-11eb-1b95-83fab3e00932
md"
or, in the second half of the book, generated using Stan by:

```
# Generate a Stan model and run a simulation
m4.32 <- ulam(flist, data=d2)
```

In SR2StanPluto, R's ulam() has been replaced by StanSample.jl and occasionally used much earlier on than in the book."

# ╔═╡ 55ed2bde-f756-11ea-1f1d-7fbdf76c1b76
md"To help out with this, in this notebook and a few additional notebooks in the subdirectory `notebooks/intros/intro-stan` the Stan language is introduced and the execution of Stan language programs illustrated.

Chapter 9 of the book contains a nice introduction to translating the `alist` R models to the Stan language (just before section 9.5).
"

# ╔═╡ 04330a22-8020-11eb-38f3-15f03a13f217
md"
!!! note
	In general SR2StanPluto relies on and shows more details (and capabilities!) of the full Stan Language than the above mentioned `alist`s in the book. In the Julia setting, if your preference is to use something closer to the `alist`s, Turing.jl is a better alternative, e.g. see [SR2TuringPluto](https://github.com/StatisticalRethinkingJulia/SR2TuringPluto.jl).
"

# ╔═╡ 2e4c633e-f75a-11ea-2bcb-fb9800e518af
md"A few ways to provide similar fuctionality to the R function `quap()` are illustrated in SR2StanPluto, i.e. using Optim.jl, using StanOptimize.jl and using StanQuap.jl.

The use of Optim.jl is shown in `Intro-stan-logpdf`. This is probably the best way of obtaining MAP estimates but requires rewriting the models in `logpdf` format.

The use of StanOptimize.jl is shown in `Intro-stan-optimize.jl`.
"

# ╔═╡ f2cd269c-801e-11eb-1e56-bfbb77a13ac9
md"
In the code clips I have opted for a less efficient way of computing the quadratic approximation to the posterior distribution by using StanQuap.jl which uses both StanOptimize.jl and StanSample.jl. The advantage is that this way, as in the StanOptimize.jl approach, the same Stan Language model can be used and it returns both the quapdratic approximation and a full SampleModel which makes comparing the two results easier.
"

# ╔═╡ d12eb360-f1ea-11ea-1a2f-fd69805cb4b4
md"##### This model represents N experiments each tossing a globe n times and recording the number of times the globe lands on water (`W`) in an array `k`."

# ╔═╡ c265df40-f1de-11ea-3eaf-795a1560b5af
md"##### R's `rethinking` model is defined as:
```
flist <- alist(
  theta ~ Uniform(0, 1)
  k ~ Binomial(n, theta)
)
```"

# ╔═╡ 0bf971c6-f1df-11ea-1f57-41937efd2e21
md"##### This model in Stan language could be written as:"

# ╔═╡ 5da2632c-f1dd-11ea-2d50-9d80cda7b1ed
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

# ╔═╡ 5da326d6-f1dd-11ea-17f5-e9341ab2118c
md"###### For this model three Stan language blocks are used: data, parameters and the model block."

# ╔═╡ 1a1a5292-f1e0-11ea-14db-4989e6acb15a
md"###### The first two blocks define the data and the parameter definitions for the model and at the same time can be used to define constraints. As explained in section 2.3 of the book (*'Components of the model'*), variables can be observable or unobservable. Variables known (chosen or observed) are defined in the data block, parameters are not observed but need to be inferred and are defined in the parameter block."

# ╔═╡ d12f1c4c-f1ea-11ea-1c5f-ab52ceca9c68
md"###### We know that k can't be negative (k[i] == 0 indicates the globe never landed on `W` in the n tosses). We also assume at least 1 toss is performed, hence n >= 1. In this example we use N=10 experiments of 9 tosses, thus n = 9 in all trials. k[i] is the number of times the globe lands on water in each experiment."

# ╔═╡ d13a6034-f1ea-11ea-101e-c13a5918086f
md"###### N, n and the vector k[N] and are all integers."

# ╔═╡ d1441b68-f1ea-11ea-38f4-6bddd7e002b1
md"###### In this golem, theta, the fraction of water on the globe surface, is assumed to generate the probability a toss lands on `W`. Theta cannot be observed and is the parameter of interest. We know this probability is between 0 an 1. Thus theta is also constrained in the parameters block. Theta is a real number."

# ╔═╡ d156ce40-f1ea-11ea-09ee-65173a8eaa15
md"###### The third block is the actual model and is pretty much identical to R's alist."

# ╔═╡ d1639a94-f1ea-11ea-1df0-e11a07650af5
md"###### Note that unfortunately the names of distributions such as Normal and Binomial are not identical between Stan, R and Julia. The Stan language uses the Stan convention (starts with lower case). Also, each Stan language statement ends with a `;`"

# ╔═╡ 1a30c9b4-f1ea-11ea-0fef-cfcb7bc6a6af
md"##### Running a Stan language program in Julia."

# ╔═╡ 459f3540-f1ea-11ea-21da-9bf2ec949773
md"###### Once the Stan language model is defined, in this case stored in the Julia variable stan1_1, below steps execute the program:"

# ╔═╡ 4b81f25e-f1ea-11ea-0f34-99192ddea9ad
md"##### 1. Create a Stanmodel object:"

# ╔═╡ a9af402c-f1de-11ea-2ad7-39922b622327
m1_1s = SampleModel("m1.1s", stan1_1);

# ╔═╡ ffdf3090-f1ea-11ea-084a-dda8c4d1a68c
md"##### 2. Simulate the results of N repetitions of 9 tosses."

# ╔═╡ 5daf1ed2-f1dd-11ea-1f3d-1909cc196f7a
begin
	N = 10                        # Number of globe toss experiment
	d = Binomial(9, 0.66)         # 9 tosses (simulate 2/3 is water)
	k = rand(d, N)                # Simulate 15 trial results
	n = 9                         # Each experiment has 9 tosses
end;

# ╔═╡ 5dcb2868-f1dd-11ea-389c-ff32a30fddc2
md"##### 3. Input data in the form of a Dict"

# ╔═╡ 49b87dde-f1eb-11ea-0ee1-67edf7b90b1c
data = (N = N, n = n, k = k);

# ╔═╡ 5dd4b36a-f1dd-11ea-11af-a946fb4ac07a
md"##### 4. Sample using stan_sample (the equivalent of `rethinking`'s ulam()."

# ╔═╡ 6f463898-f1eb-11ea-16f1-0b6de4bd69c4
rc1_1s = stan_sample(m1_1s; data);

# ╔═╡ 5ddf4cf6-f1dd-11ea-388f-77f48ba93c39
md"##### 5. Describe and check the results"

# ╔═╡ 73d0dd98-f1ec-11ea-2499-477a8024ecc6
if success(rc1_1s)
	post1_1s_df = read_samples(m1_1s, :dataframe)
	PRECIS(post1_1s_df)
end

# ╔═╡ 34a8496e-4c4d-4960-8324-68436778e258
md"##### The default output format for `read_samples()` is a StanTable (which supports the Tables API). Converting to a DataFrame produces the same result as above."

# ╔═╡ 60842475-1ac4-40d4-a3a2-fdaa967e2b91
PRECIS(DataFrame(read_samples(m1_1s)))

# ╔═╡ 208e7a70-f1ec-11ea-3ba9-d5e8c8c00553
md"###### Sample `Particles` summary:"

# ╔═╡ cfe9027e-f1ec-11ea-33df-65cd05965437
part1_1s = read_samples(m1_1s, :particles)

# ╔═╡ b82e2e82-f757-11ea-2696-6f294e3070f5
md"The use of Particles to represent quap-like approximations is possible thanks to the package [MonteCarloMeasurements.jl](https://github.com/baggepinnen/MonteCarloMeasurements.jl).

[Soss.jl](https://github.com/cscherrer/Soss.jl) and [related write-ups](https://cscherrer.github.io) introduced me to that option."

# ╔═╡ cfe95fee-f1ec-11ea-32a1-bbf3633ab8e7
md"###### Generate a quadratic approximation of the posterior distribution and show the NamedTuple representation of such a quap estimate. Click on the little triangle to show the full NamedTuple:"

# ╔═╡ a804833c-3a44-11eb-2cbd-997854743a0f
begin
	init = Dict(:theta => 0.5)
	q1_1s, sm, om = stan_quap("m1.1s", stan1_1; data, init)
	q1_1s
end

# ╔═╡ 094310f4-8046-11eb-0073-950f55104695
md" ##### Sample from the quadratic approximation:"

# ╔═╡ a0a04fa8-2b5e-11eb-0a44-4b31c17d9a57
begin
	quap1_1s_df = sample(q1_1s)
	PRECIS(quap1_1s_df)
end

# ╔═╡ c2ef6864-802c-11eb-1a86-858e8db6e45f
√q1_1s.vcov

# ╔═╡ d00c24de-f1ec-11ea-1c83-cb2584421f6f
md"##### Display the stansummary result as a DataFrame."

# ╔═╡ 0e3309b2-f1ed-11ea-0d57-2f0e5b83c8dd
success(rc1_1s) && read_summary(m1_1s)

# ╔═╡ 2c465b0a-f1ed-11ea-35e3-017075244cd8
md"##### Plot the chains."

# ╔═╡ bc8dccca-96a0-4b6a-bdd0-c19e0be4bcfc
let
	nt = (theta = post1_1s_df.theta,)
	res = trankplot(nt, :theta; n_draws=1000)
	plot(res[1])
end

# ╔═╡ 5de8c1c8-f1dd-11ea-1b97-5bbb6c6316ae
md"## End of intros/intro-stan-01s.jl"

# ╔═╡ Cell order:
# ╟─accc5535-2e9e-4a20-bd83-048477649d4b
# ╟─6908ab8d-41be-4bca-9111-91cda8ea06b7
# ╠═2a0a2339-1c8b-42d0-93cb-a97c461e2dd9
# ╟─45929f5a-f759-11ea-1955-67ba740778e6
# ╟─e27ece36-f756-11ea-250c-99d909d390f9
# ╟─8819279a-f757-11ea-37ee-f7b0a267d351
# ╟─46c64c28-803e-11eb-1b95-83fab3e00932
# ╟─55ed2bde-f756-11ea-1f1d-7fbdf76c1b76
# ╟─04330a22-8020-11eb-38f3-15f03a13f217
# ╟─2e4c633e-f75a-11ea-2bcb-fb9800e518af
# ╟─f2cd269c-801e-11eb-1e56-bfbb77a13ac9
# ╠═38677642-f1dd-11ea-2537-59511c140dab
# ╠═5d9316ec-f1dd-11ea-1c0d-0d8566ab3a90
# ╟─d12eb360-f1ea-11ea-1a2f-fd69805cb4b4
# ╟─c265df40-f1de-11ea-3eaf-795a1560b5af
# ╟─0bf971c6-f1df-11ea-1f57-41937efd2e21
# ╠═5da2632c-f1dd-11ea-2d50-9d80cda7b1ed
# ╟─5da326d6-f1dd-11ea-17f5-e9341ab2118c
# ╟─1a1a5292-f1e0-11ea-14db-4989e6acb15a
# ╟─d12f1c4c-f1ea-11ea-1c5f-ab52ceca9c68
# ╟─d13a6034-f1ea-11ea-101e-c13a5918086f
# ╟─d1441b68-f1ea-11ea-38f4-6bddd7e002b1
# ╟─d156ce40-f1ea-11ea-09ee-65173a8eaa15
# ╟─d1639a94-f1ea-11ea-1df0-e11a07650af5
# ╟─1a30c9b4-f1ea-11ea-0fef-cfcb7bc6a6af
# ╟─459f3540-f1ea-11ea-21da-9bf2ec949773
# ╟─4b81f25e-f1ea-11ea-0f34-99192ddea9ad
# ╠═a9af402c-f1de-11ea-2ad7-39922b622327
# ╟─ffdf3090-f1ea-11ea-084a-dda8c4d1a68c
# ╠═5daf1ed2-f1dd-11ea-1f3d-1909cc196f7a
# ╟─5dcb2868-f1dd-11ea-389c-ff32a30fddc2
# ╠═49b87dde-f1eb-11ea-0ee1-67edf7b90b1c
# ╟─5dd4b36a-f1dd-11ea-11af-a946fb4ac07a
# ╠═6f463898-f1eb-11ea-16f1-0b6de4bd69c4
# ╟─5ddf4cf6-f1dd-11ea-388f-77f48ba93c39
# ╠═73d0dd98-f1ec-11ea-2499-477a8024ecc6
# ╟─34a8496e-4c4d-4960-8324-68436778e258
# ╠═60842475-1ac4-40d4-a3a2-fdaa967e2b91
# ╟─208e7a70-f1ec-11ea-3ba9-d5e8c8c00553
# ╠═cfe9027e-f1ec-11ea-33df-65cd05965437
# ╟─b82e2e82-f757-11ea-2696-6f294e3070f5
# ╟─cfe95fee-f1ec-11ea-32a1-bbf3633ab8e7
# ╠═a804833c-3a44-11eb-2cbd-997854743a0f
# ╟─094310f4-8046-11eb-0073-950f55104695
# ╠═a0a04fa8-2b5e-11eb-0a44-4b31c17d9a57
# ╠═c2ef6864-802c-11eb-1a86-858e8db6e45f
# ╟─d00c24de-f1ec-11ea-1c83-cb2584421f6f
# ╠═0e3309b2-f1ed-11ea-0d57-2f0e5b83c8dd
# ╟─2c465b0a-f1ed-11ea-35e3-017075244cd8
# ╠═bc8dccca-96a0-4b6a-bdd0-c19e0be4bcfc
# ╟─5de8c1c8-f1dd-11ea-1b97-5bbb6c6316ae
