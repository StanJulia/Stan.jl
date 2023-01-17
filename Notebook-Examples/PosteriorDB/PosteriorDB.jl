### A Pluto.jl notebook ###
# v0.19.18

using Markdown
using InteractiveUtils

# ╔═╡ 9339e545-32ee-4304-ba49-d34befb45fe3
using Pkg

# ╔═╡ e4d98ecf-1dd3-414b-ba5c-b6a7d71df3eb
begin
	using DataFrames
	using Statistics
	using PosteriorDB
	using StanSample
end

# ╔═╡ 34a9e246-547e-11ed-2c8e-5d545ad2b268
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

# ╔═╡ 22ffe9ac-a7d7-4066-a6a0-58e0b60d0352
pdb = database()

# ╔═╡ 97fd910a-2972-48f9-a512-e5975b51351f
pdb.path

# ╔═╡ bdf2a2eb-89df-401f-b113-6ea178d67500
posterior_names(pdb)

# ╔═╡ 5cebec86-cb13-4bf2-850a-3c6510e3fb5e
dataset_names(pdb)

# ╔═╡ 54dd2074-76f0-4bd7-9406-94e9720d0daf
posterior_pdb = posterior(pdb, "eight_schools-eight_schools_centered")

# ╔═╡ a0260880-429c-4888-a4be-9b1d6457de53
mod = model(posterior_pdb)

# ╔═╡ 829195fc-adab-4f39-a69c-4c5c8d4916db
info(posterior_pdb)

# ╔═╡ 8feb8740-b286-4877-8587-7fde4419f90d
begin
	mod_code = implementation(mod, "stan")
	mod_code
end

# ╔═╡ 46d29033-58c8-48a0-998e-944ad9d0ee62
impl = implementation(mod, "stan")

# ╔═╡ 438253a2-5b62-46f9-a85e-8a89e42e1c82
begin
	code = load(impl)
	println(code)
end

# ╔═╡ 3068fb12-0c37-466d-9721-99f746006f03
info(mod)

# ╔═╡ 0247e72a-afc8-4072-9fd6-78b4a0e1baf7
post = dataset(posterior_pdb)

# ╔═╡ e18e0655-1785-47e6-a322-d7e2f84e6f6f
info(posterior_pdb)

# ╔═╡ 302ce3e8-e3c0-4111-8065-71a3b622779f
path(post)

# ╔═╡ a9ba650f-76f3-483e-bc3a-c0ff039e08c8
data = load(post)

# ╔═╡ 69c80caa-cc31-4409-9f73-2580e7620fd2
ref = reference_posterior(posterior_pdb)

# ╔═╡ 719112ef-f399-4664-8843-16723289bd1d
info(ref)

# ╔═╡ 9e152cf5-2916-42a5-85cb-2c41e3590c3a
path(ref)

# ╔═╡ 26030da6-920f-47bd-ad55-29444e78c1c8
pdb_df = DataFrame(load(ref))

# ╔═╡ 20738a8e-a50d-4682-884b-a84e33e6146a
pdb_df.mu

# ╔═╡ 4ac7fa99-6ba1-46dd-abae-ed0655a71f6f
begin
	sm = SampleModel("PDB", code)
	rc = stan_sample(sm; data)
end;

# ╔═╡ 1e6593dd-956e-40b1-a715-6223fc7c56d8
if success(rc)
	df = read_samples(sm, :dataframe)
end

# ╔═╡ Cell order:
# ╠═34a9e246-547e-11ed-2c8e-5d545ad2b268
# ╠═9339e545-32ee-4304-ba49-d34befb45fe3
# ╠═e4d98ecf-1dd3-414b-ba5c-b6a7d71df3eb
# ╠═22ffe9ac-a7d7-4066-a6a0-58e0b60d0352
# ╠═97fd910a-2972-48f9-a512-e5975b51351f
# ╠═bdf2a2eb-89df-401f-b113-6ea178d67500
# ╠═5cebec86-cb13-4bf2-850a-3c6510e3fb5e
# ╠═54dd2074-76f0-4bd7-9406-94e9720d0daf
# ╠═a0260880-429c-4888-a4be-9b1d6457de53
# ╠═829195fc-adab-4f39-a69c-4c5c8d4916db
# ╠═8feb8740-b286-4877-8587-7fde4419f90d
# ╠═46d29033-58c8-48a0-998e-944ad9d0ee62
# ╠═438253a2-5b62-46f9-a85e-8a89e42e1c82
# ╠═3068fb12-0c37-466d-9721-99f746006f03
# ╠═0247e72a-afc8-4072-9fd6-78b4a0e1baf7
# ╠═e18e0655-1785-47e6-a322-d7e2f84e6f6f
# ╠═302ce3e8-e3c0-4111-8065-71a3b622779f
# ╠═a9ba650f-76f3-483e-bc3a-c0ff039e08c8
# ╠═69c80caa-cc31-4409-9f73-2580e7620fd2
# ╠═719112ef-f399-4664-8843-16723289bd1d
# ╠═9e152cf5-2916-42a5-85cb-2c41e3590c3a
# ╠═26030da6-920f-47bd-ad55-29444e78c1c8
# ╠═20738a8e-a50d-4682-884b-a84e33e6146a
# ╠═4ac7fa99-6ba1-46dd-abae-ed0655a71f6f
# ╠═1e6593dd-956e-40b1-a715-6223fc7c56d8
