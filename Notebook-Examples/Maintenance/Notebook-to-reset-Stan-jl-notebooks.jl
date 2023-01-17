### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ 28f7bd2f-3208-4c61-ad19-63b11dd56d30
using Pkg

# ╔═╡ 2846bc48-7972-49bc-8233-80c7ea3326e6
begin
	using DataFrames
    using RegressionAndOtherStories: reset_selected_notebooks_in_notebooks_df!
end

# ╔═╡ 970efecf-9ae7-4771-bff0-089202b1ff1e
html"""
<style>
	main {
		margin: 0 auto;
		max-width: 2000px;
    	padding-left: max(160px, 0%);
    	padding-right: max(160px, 30%);
	}
</style>
"""

# ╔═╡ d98a3a0a-947e-11ed-13a2-61b5b69b4df5
notebook_files = [
    "~/.julia/dev/Stan/Notebook-Examples/ARM/Radon/radon.jl",
    "~/.julia/dev/Stan/Notebook-Examples/BridgeStan/BridgeStan.jl",
    "~/.julia/dev/Stan/Notebook-Examples/DataFrames/Dataframes.jl",
    "~/.julia/dev/Stan/Notebook-Examples/DataFrames/Nested-DataFrame.jl",
    "~/.julia/dev/Stan/Notebook-Examples/DimensionalData/dimensionaldata.jl",
    "~/.julia/dev/Stan/Notebook-Examples/InferenceObjects/InferenceObjects.jl",
    "~/.julia/dev/Stan/Notebook-Examples/Logging/ShowLogging.jl",
    "~/.julia/dev/Stan/Notebook-Examples/PosteriorDB/PosteriorDB.jl",
    "~/.julia/dev/Stan/Notebook-Examples/Stan-introductory-notebooks/intro-stan-00s.jl",
    "~/.julia/dev/Stan/Notebook-Examples/Stan-introductory-notebooks/intro-stan-01s.jl",
    "~/.julia/dev/Stan/Notebook-Examples/Stan-introductory-notebooks/intro-stan-02s.jl",
    "~/.julia/dev/Stan/Notebook-Examples/Stan-introductory-notebooks/intro-stan-chains.jl",
    "~/.julia/dev/Stan/Notebook-Examples/Stan-introductory-notebooks/intro-stan-logpdf.jl",
    "~/.julia/dev/Stan/Notebook-Examples/Stan-introductory-notebooks/intro-stan-optimize.jl",
    "~/.julia/dev/Stan/Notebook-Examples/Stan-introductory-notebooks/intro-stan-priors.jl",
	"~/.julia/dev/Stan/Notebook-Examples/Maintenance/Notebook-to-reset-Stan-jl-notebooks.jl"
];

# ╔═╡ 0f10a758-e442-4cd8-88bc-d82d8de97ede
notebooks_df = DataFrame(
    file = notebook_files,
    reset = repeat([false], length(notebook_files)),
	done = repeat([false], length(notebook_files))
)

# ╔═╡ a4207232-61eb-4da7-8629-1bcc670ab524
notebooks_df.reset .= true;

# ╔═╡ 722d4847-2458-4b23-b6a0-d1c321710a2a
notebooks_df

# ╔═╡ 9d94bebb-fc41-482f-8759-cdf224ec71fb
reset_selected_notebooks_in_notebooks_df!(notebooks_df)

# ╔═╡ 88720478-7f64-4852-8683-6be50793666a
notebooks_df

# ╔═╡ Cell order:
# ╠═28f7bd2f-3208-4c61-ad19-63b11dd56d30
# ╠═2846bc48-7972-49bc-8233-80c7ea3326e6
# ╠═970efecf-9ae7-4771-bff0-089202b1ff1e
# ╠═d98a3a0a-947e-11ed-13a2-61b5b69b4df5
# ╠═0f10a758-e442-4cd8-88bc-d82d8de97ede
# ╠═a4207232-61eb-4da7-8629-1bcc670ab524
# ╠═722d4847-2458-4b23-b6a0-d1c321710a2a
# ╠═9d94bebb-fc41-482f-8759-cdf224ec71fb
# ╠═88720478-7f64-4852-8683-6be50793666a
