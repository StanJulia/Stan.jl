### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ 5084b8f0-65ac-4704-b1fc-2a9008132bd7
using Pkg

# ╔═╡ 550371ad-d411-4e66-9d63-7329322c6ea1
begin
	# Specific to this notebook
    using GLM

    # Specific to ROSStanPluto
    using StanSample
	
	# Graphics related
    using GLMakie
		
	# Include project support packages
	using RegressionAndOtherStories

	# If data files from StatisticalRethinking are needed, uncomment below line
	#using StatisticalRethinking: sr_datadir
end

# ╔═╡ 703fdfa1-cff7-4643-bf26-0bfb81d17438
md" ### Introduction of Stan."

# ╔═╡ bb45e62b-7957-4b21-8361-fd774502eb7a
md" ###### This notebook is using the Pluto notebook style as used in Regression And Other Stories. It is also using Makie. See Chapter 1.2, Figure 1.1 in Regression and Other Stories for more background."

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

# ╔═╡ 5fdc1b11-ce9b-4f67-8e2e-5ab22cd75b70
md"
!!! note

The data files for Regression And Others Stories are available (as .csv files) in the data subdirectory of package RegressionAndOtherStories.jl and can be retrieved with `ros_datadir`.

Similarly, data files for Statistical Rethinking can be retrieved using `sr_datadir()` if `using StatisticalRethinking: sr_datadir` is included in above cell.
"

# ╔═╡ 100e2ea9-17e5-4eef-b880-823311f5d496
ros_datadir()

# ╔═╡ d830f41c-0fb6-4bff-9fe0-0bd51f444779
hibbs = CSV.read(ros_datadir("ElectionsEconomy", "hibbs.csv"), DataFrame)

# ╔═╡ 35bee056-5cd8-48ee-b9c0-74a8b53229bd
hibbs_lm = lm(@formula(vote~growth), hibbs)

# ╔═╡ 3c4672aa-d17e-4681-9863-9ee026fefee6
residuals(hibbs_lm)

# ╔═╡ a9970ef7-1e0e-4976-b8c9-1db4dd3a222b
mad(residuals(hibbs_lm))

# ╔═╡ f48df50b-5450-4998-8dab-014c8b9d42a2
std(residuals(hibbs_lm))

# ╔═╡ be41c745-c87d-4f3a-ab4e-a8ae3b9ae091
coef(hibbs_lm)

# ╔═╡ 06ab4f30-68cc-4e35-9fa2-b8f8f25d3776
let
	fig = Figure(resolution=default_figure_resolution)
	hibbs.label = string.(hibbs.year)
	xlabel = "Average growth personal income [%]"
	ylabel = "Incumbent's party vote share"
	let
		title = "Forecasting the election from the economy"
		ax = Axis(fig[1, 1]; title, xlabel, ylabel)
		for (ind, yr) in enumerate(hibbs.year)
			annotations!("$(yr)"; position=(hibbs.growth[ind], hibbs.vote[ind]), fontsize=10)
		end
	end
	let
		x = LinRange(-1, 4, 100)
		title = "Data and linear fit"
		ax = Axis(fig[1, 2]; title, xlabel, ylabel)
		scatter!(hibbs.growth, hibbs.vote)
		lines!(x, coef(hibbs_lm)[1] .+ coef(hibbs_lm)[2] .* x; color=:darkred)
		annotations!("vote = 46.2 + 3.0 * growth"; position=(0, 41))
	end
	fig
end

# ╔═╡ df07541f-13ec-4192-acde-82c02ab6bcf6
md" #### Priors used in the Stan model."

# ╔═╡ f11b4bdc-3ad4-467d-b75c-37da5e9dcb2c
stan1_0 = "
parameters {
	real b;              // Coefficient independent variable
	real a;              // Intercept
	real<lower=0> sigma; // dispersion parameter
}
model {
	// priors including constants
	a ~ normal(50, 20);
	b ~ normal(2, 10);
  	sigma ~ exponential(1);
}";

# ╔═╡ d2585fa2-0d5e-480f-863a-c7c515404057
tmpdir = mktempdir()

# ╔═╡ db6a5dab-a738-42d3-a97a-4ca60894b9ca
begin
	m1_0s = SampleModel("m1_0s", stan1_0, tmpdir)
	rc1_0s = stan_sample(m1_0s)
	success(rc1_0s) && describe(m1_0s)
end

# ╔═╡ 9e471ad3-6c48-4f8a-b204-4ee864837898
begin
	post1_0s = read_samples(m1_0s, :dataframe)
	ms1_0s = model_summary(post1_0s, [:a, :b, :sigma])
end

# ╔═╡ f2517a79-a971-4787-8c85-d7ee5ba4d1d1
let
	df = read_samples(m1_0s, :dataframe; include_internals=true)
end

# ╔═╡ 10395123-f9c9-441d-a497-cb7be9fa7b18
let
	fig = Figure(resolution=default_figure_resolution)
	xlabel = "Average growth personal income [%]"
	ylabel="Incumbent's party vote share"
	ax = Axis(fig[1, 1]; title="Lines based on prior samples", 
		xlabel, ylabel)
	ylims!(ax, 40, 65)
	xrange = LinRange(-1, 4, 200)
	for i = 1:100
		lines!(xrange, post1_0s.a[i] .+ post1_0s.b[i] .* xrange, color=:grey)
	end
	fig
end

# ╔═╡ 1786b700-0d99-4541-87d4-b6308a2331bc
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; title="Density :a")
	density!(f[1, 1], post1_0s.a; color=(:blue, 0.2), strokecolor=:blue, strokewidth=2, strokearound=true)
	ax = Axis(f[1, 2]; title="Density :b")
	density!(f[1, 2], post1_0s.b; color=(:blue, 0.2), strokecolor=:blue, strokewidth=2, strokearound=true)
	ax = Axis(f[1, 3]; title="Density :sigma")
	density!(f[1, 3], post1_0s.sigma; color=(:blue, 0.2), strokecolor=:blue, strokewidth=2, strokearound=true)
	f
end

# ╔═╡ 261c1e49-13be-4950-b211-29c35e0da5e8
md" #### Conditioning based on the available data."

# ╔═╡ 274dc84c-b416-4f9e-8ff2-6ca0f08a40cf
stan1_1 = "
functions {
}
data {
	int<lower=1> N;      // total number of observations
	vector[N] growth;    // Independent variable: growth
	vector[N] vote;      // Dependent variable: votes 
}
parameters {
	real b;              // Coefficient independent variable
	real a;              // Intercept
	real<lower=0> sigma; // Dispersion parameter
}
model {
	vector[N] mu;
	mu = a + b * growth;

	// priors including constants
	a ~ normal(50, 20);
	b ~ normal(2, 10);
  	sigma ~ exponential(1);

	// likelihood including constants
	vote ~ normal(mu, sigma);
}";

# ╔═╡ 953eea61-f05f-4233-86aa-d5af3b47b41e
let
	data = (N=16, vote=hibbs.vote, growth=hibbs.growth)
	global m1_1s = SampleModel("m1_1s", stan1_1, tmpdir)
	global rc1_1s = stan_sample(m1_1s; data)
	success(rc1_1s) && describe(m1_1s, [:a, :b, :sigma])
end

# ╔═╡ 9d1a8b9a-2b0c-4b8d-af31-1717e7a5ecd7
if success(rc1_1s)
	post1_1s = read_samples(m1_1s, :dataframe)
	ms1_1s = model_summary(post1_1s, [:a, :b, :sigma])
end

# ╔═╡ 9842ce96-98f9-4a87-9208-d32d16418c15
plot_chains(post1_1s, [:a, :b, :sigma])

# ╔═╡ 3a256571-459c-4346-a511-377a273cbb66
trankplot(post1_1s, "b")

# ╔═╡ 8abccff4-2015-467e-92d6-067bd8db4e10
let
	N = 100
	x = LinRange(-1, 4, N)
	a = rand(Normal(50, 20), N)
	b = rand(Normal(2, 10), N)
	mat1 = zeros(50, 100)
	for i in 1:50
		mat1[i, :] = a[i] .+ b[i] .* x
	end
	ā = ms1_1s[:a, :mean]
	b̄ = ms1_1s[:b, :mean]

	# Maybe could use a `link` function here
	mat2 = zeros(50, 100)
	for i in 1:50
		mat2[i, :] = post1_1s.a[i] .+ post1_1s.b[i] .* x
	end

	fig = Figure(resolution=default_figure_resolution)
	xlabel = "Average growth personal income [%]"
	ylabel="Incumbent's party vote share"
	ax = Axis(fig[1, 1]; title="Lines based on prior samples", 
		xlabel, ylabel)
	ylims!(ax, 40, 65)
	series!(fig[1, 1], x, mat1; solid_color=:lightgrey)
	ax = Axis(fig[1, 2]; title="Lines based on posterior samples", 
		xlabel, ylabel)
	series!(fig[1, 2], x, mat2; solid_color=:lightgrey)
	scatter!(hibbs.growth, hibbs.vote)
	lines!(fig[1, 2], x, ā .+ b̄ * x; color=:red)

	fig
end

# ╔═╡ a872c820-57b6-45d5-a7e9-2ab7349c81e7
let
	f = Figure(resolution=default_figure_resolution)
	ax = Axis(f[1, 1]; title="Density :a")
	xlims!(ax, -10, 125)
	density!(post1_0s.a; color=(:blue, 0.3), strokecolor=:blue, strokewidth=2, strokearound=true)
	ax = Axis(f[1, 2]; title="Density :b")
	xlims!(ax, -40, 45)
	density!(post1_0s.b; color=(:blue, 0.3), strokecolor=:blue, strokewidth=2, strokearound=true)
	ax = Axis(f[1, 3]; title="Density :sigma")
	density!(post1_1s.sigma; color=(:blue, 0.3), strokecolor=:blue, strokewidth=2, strokearound=true)
	
	ax = Axis(f[2, 1]; title="Density :a")
	density!(post1_1s.a; color=(:blue, 0.3), strokecolor=:blue, strokewidth=2, strokearound=true)
	xlims!(ax, -10, 125)
	ax = Axis(f[2, 2]; title="Density :b")
	xlims!(ax, -40, 45)
	density!(post1_1s.b; color=(:blue, 0.3), strokecolor=:blue, strokewidth=2, strokearound=true)
	ax = Axis(f[2, 3]; title="Density :sigma")
	density!(post1_1s.sigma; color=(:blue, 0.3), strokecolor=:blue, strokewidth=2, strokearound=true)
	f
end

# ╔═╡ 99259579-97fa-46f5-93b4-710b3180ded2
begin
	fig = Figure(resolution=default_figure_resolution)
	hibbs.label = string.(hibbs.year)
	xlabel = "Average growth personal income [%]"
	ylabel="Incumbent's party vote share"

	# Same figure as above
	let
		title = "Forecasting the election from the economy"
		ax = Axis(fig[1, 1]; title, xlabel, ylabel)
		xlims!(ax, -0.5, 5)
		for (ind, yr) in enumerate(hibbs.year)
			annotations!("$(yr)"; position=(hibbs.growth[ind], hibbs.vote[ind]), fontsize=12)
		end
	end

	# Superimpose Stan fit
	let
		ā = ms1_1s[:a, :mean]
		b̄ = ms1_1s[:b, :mean]
		title = "Compare GLM and Stan fitted lines"
		axis = (; title, xlabel, ylabel)
		
		x = LinRange(-1, 4.4, 100)
		title = "Data and linear fit"
		ax = Axis(fig[1, 2]; title, xlabel, ylabel)
		xlims!(ax, -0.5, 5)
		scatter!(hibbs.growth, hibbs.vote)
		lines!(x, coef(hibbs_lm)[1] .+ coef(hibbs_lm)[2] .* x)
		lines!(x, ā .+  b̄ .* x; color=:darkred)
		annotations!("vote = $(round(ā, digits=1)) + $(round(b̄, digits=0)) \
			* growth"; position=(0, 41), fontsize=16)
	end
	fig
end

# ╔═╡ 750a66c1-47bc-466c-a7f1-567640e2e2bb
let
	N = 10000
	nt = (
		a = post1_1s.a,
		b = post1_1s.b,
		σ = post1_1s.sigma,
	)

	fig = Figure(resolution=default_figure_resolution)
	for (i, k) in enumerate(keys(nt))
		ax = Axis(fig[1, i]; title = "Density $k")
		den = density!(nt[k]; color=(:blue, 0.3), strokecolor=:blue, strokewidth=2, strokearound=true)
	end
	fig
end

# ╔═╡ 95cdfe9f-a06f-49f3-888f-34e47025c810
md"#### Compute median and mad."

# ╔═╡ 10b925db-5f9c-4603-b49a-bd9b9a2e64d0
md" ##### Alternative computation of mad()."

# ╔═╡ 14cbb5c2-db18-4bc1-a9b9-06ef2ab2ccec
let
	1.483 .* [
		median(abs.(post1_1s.a .- median(post1_1s.a))),
		median(abs.(post1_1s.b .- median(post1_1s.b))),
		median(abs.(post1_1s.sigma .- median(post1_1s.sigma)))]
end

# ╔═╡ e87627bb-1a5a-4209-8519-e0905e5fe2ca
ms1_1 = model_summary(post1_1s, ["a", "b", "sigma"])

# ╔═╡ b51a73a2-3f21-4811-9057-bcce4222e1ec
ms1_1[:b, :mad_sd]

# ╔═╡ 1d9665a6-639e-4ef1-8b5c-151944a8fc33
ss1_1 = describe(m1_1s, ["a", "b", "sigma"]; digits=2)

# ╔═╡ f544db54-86e2-4694-9cac-fc42e2c00e50
ss1_1["a", "ess"]

# ╔═╡ f8e7241f-46a9-4e2b-bdc9-8c63da6bc8ab
md" ##### Quick simulation with median, mad, mean and std of Normal observations."

# ╔═╡ 1f44495d-50cf-4e92-97b2-d19a82c46c78
nt = (x=rand(Normal(5, 2), 10000),)

# ╔═╡ a72ca80f-b42e-4638-8ffd-f23dc70c7bc0
[median(nt.x), mad(nt.x), mean(nt.x), std(nt.x)]

# ╔═╡ 4db28bae-8901-44fe-a479-3272342413c6
sd_mean = round(mad(nt.x)/√10000; digits=2)

# ╔═╡ 0b711521-5b96-429e-8e73-e2d68d94c0ce
median(abs.(nt.x .- median(nt.x)))

# ╔═╡ e193199a-188b-4fa9-ae51-0fce401872e0
1.483 * median(abs.(nt.x .- median(nt.x)))

# ╔═╡ be3898d3-af87-4808-a1a7-4e2e76583ee2
let
	fig = Figure(resolution=default_figure_resolution)
	ax = Axis(fig[1, 1]; title = "Density")
	den = density!(nt.x; color=(:blue, 0.3), strokecolor=:blue, strokewidth=2, strokearound=true)
	fig
end

# ╔═╡ a2be1bd7-6897-438c-928f-787e36134ec7
quantile(nt.x, [0.025, 0.975])

# ╔═╡ 6ce605aa-9504-4ebc-bfdf-c4c54c048647
quantile(nt.x, [0.25, 0.75])

# ╔═╡ 86636b94-f945-4bb1-b7b9-90bc5cc0c836
md" ###### A closer look at Stan's summary. Below the full version:"

# ╔═╡ 45a307ad-4f6a-4cb6-9182-bda870c42679
success(rc1_1s) && describe(m1_1s; showall=true)

# ╔═╡ 8a04158e-a24d-477f-9cf8-30f062ec29bb
md" ###### Usually I use the abbreviated version:"

# ╔═╡ a3277285-5acb-4117-a567-67fdfd2cd4ba
ss1_1s = success(rc1_1s) && describe(m1_1s, names(post1_1s))

# ╔═╡ bd15d29b-552e-4f62-bb55-c57dca312b5b
ms1_1s

# ╔═╡ 29c2e746-a79d-4bef-84d2-2f2172807185
ss1_1s[:a, :ess]

# ╔═╡ a07ce943-1ce7-4961-93e2-c3ed8e78d2e3
ms1_1s[:a, :mad_sd]

# ╔═╡ Cell order:
# ╟─703fdfa1-cff7-4643-bf26-0bfb81d17438
# ╟─bb45e62b-7957-4b21-8361-fd774502eb7a
# ╟─cf39df58-3371-4535-88e4-f3f6c0404500
# ╠═0616ece8-ccf8-4281-bfed-9c1192edf88e
# ╟─4755dab0-d228-41d3-934a-56f2863a5652
# ╠═5084b8f0-65ac-4704-b1fc-2a9008132bd7
# ╠═550371ad-d411-4e66-9d63-7329322c6ea1
# ╟─5fdc1b11-ce9b-4f67-8e2e-5ab22cd75b70
# ╠═100e2ea9-17e5-4eef-b880-823311f5d496
# ╠═d830f41c-0fb6-4bff-9fe0-0bd51f444779
# ╠═35bee056-5cd8-48ee-b9c0-74a8b53229bd
# ╠═3c4672aa-d17e-4681-9863-9ee026fefee6
# ╠═a9970ef7-1e0e-4976-b8c9-1db4dd3a222b
# ╠═f48df50b-5450-4998-8dab-014c8b9d42a2
# ╠═be41c745-c87d-4f3a-ab4e-a8ae3b9ae091
# ╠═06ab4f30-68cc-4e35-9fa2-b8f8f25d3776
# ╟─df07541f-13ec-4192-acde-82c02ab6bcf6
# ╠═f11b4bdc-3ad4-467d-b75c-37da5e9dcb2c
# ╠═d2585fa2-0d5e-480f-863a-c7c515404057
# ╠═db6a5dab-a738-42d3-a97a-4ca60894b9ca
# ╠═9e471ad3-6c48-4f8a-b204-4ee864837898
# ╠═f2517a79-a971-4787-8c85-d7ee5ba4d1d1
# ╠═10395123-f9c9-441d-a497-cb7be9fa7b18
# ╠═1786b700-0d99-4541-87d4-b6308a2331bc
# ╟─261c1e49-13be-4950-b211-29c35e0da5e8
# ╠═274dc84c-b416-4f9e-8ff2-6ca0f08a40cf
# ╠═953eea61-f05f-4233-86aa-d5af3b47b41e
# ╠═9d1a8b9a-2b0c-4b8d-af31-1717e7a5ecd7
# ╠═9842ce96-98f9-4a87-9208-d32d16418c15
# ╠═3a256571-459c-4346-a511-377a273cbb66
# ╠═8abccff4-2015-467e-92d6-067bd8db4e10
# ╠═a872c820-57b6-45d5-a7e9-2ab7349c81e7
# ╠═99259579-97fa-46f5-93b4-710b3180ded2
# ╠═750a66c1-47bc-466c-a7f1-567640e2e2bb
# ╟─95cdfe9f-a06f-49f3-888f-34e47025c810
# ╟─10b925db-5f9c-4603-b49a-bd9b9a2e64d0
# ╠═14cbb5c2-db18-4bc1-a9b9-06ef2ab2ccec
# ╠═e87627bb-1a5a-4209-8519-e0905e5fe2ca
# ╠═b51a73a2-3f21-4811-9057-bcce4222e1ec
# ╠═1d9665a6-639e-4ef1-8b5c-151944a8fc33
# ╠═f544db54-86e2-4694-9cac-fc42e2c00e50
# ╟─f8e7241f-46a9-4e2b-bdc9-8c63da6bc8ab
# ╠═1f44495d-50cf-4e92-97b2-d19a82c46c78
# ╠═a72ca80f-b42e-4638-8ffd-f23dc70c7bc0
# ╠═4db28bae-8901-44fe-a479-3272342413c6
# ╠═0b711521-5b96-429e-8e73-e2d68d94c0ce
# ╠═e193199a-188b-4fa9-ae51-0fce401872e0
# ╠═be3898d3-af87-4808-a1a7-4e2e76583ee2
# ╠═a2be1bd7-6897-438c-928f-787e36134ec7
# ╠═6ce605aa-9504-4ebc-bfdf-c4c54c048647
# ╟─86636b94-f945-4bb1-b7b9-90bc5cc0c836
# ╠═45a307ad-4f6a-4cb6-9182-bda870c42679
# ╟─8a04158e-a24d-477f-9cf8-30f062ec29bb
# ╠═a3277285-5acb-4117-a567-67fdfd2cd4ba
# ╠═bd15d29b-552e-4f62-bb55-c57dca312b5b
# ╠═29c2e746-a79d-4bef-84d2-2f2172807185
# ╠═a07ce943-1ce7-4961-93e2-c3ed8e78d2e3
