### A Pluto.jl notebook ###
# v0.19.18

using Markdown
using InteractiveUtils

# ╔═╡ d89204c4-7ee5-11ed-3356-1581fcf877fa
using Pkg

# ╔═╡ bcfd62c6-dbd3-41af-b329-9fddb22b18c2
begin
	using CSV, DataFrames
	using Statistics, Test
	using DimensionalData
	using StanSample
end

# ╔═╡ d4b95015-b202-475b-bc70-9389fcb90b70
include(joinpath(pkgdir(StanSample), "src", "utils", "dimarray.jl"))

# ╔═╡ 567821e6-18a9-43ba-a35f-c75cc3146d98
md" #### Example of the use of :dimarray and :dimarrays in read_samples()."

# ╔═╡ 9be99d72-d78e-494a-8d4b-8cafeb9f2f4c
md" ###### Unfortunately this conflict with InferenceObjects.jl, hence it is currently not directly provided by StanSample."

# ╔═╡ a0f056fc-f537-4778-8433-ffd53cb75db3
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


# ╔═╡ 05d79a9b-8506-40a4-8a5f-16bf9956f7f5
pkgdir(StanSample)

# ╔═╡ d6ab26aa-fe54-49a0-97ae-90f626337fc7
df = CSV.read(joinpath(pkgdir(StanSample), "data", "chimpanzees.csv"), DataFrame);

# ╔═╡ 0dbe88e2-14e2-43c1-8f49-754547a369e9
# Define the Stan language model

stan10_4 = "
data{
    int N;
    int N_actors;
    int pulled_left[N];
    int prosoc_left[N];
    int condition[N];
    int actor[N];
}
parameters{
    vector[N_actors] a;
    real bp;
    real bpC;
}
model{
    vector[N] p;
    bpC ~ normal( 0 , 10 );
    bp ~ normal( 0 , 10 );
    a ~ normal( 0 , 10 );
    for ( i in 1:504 ) {
        p[i] = a[actor[i]] + (bp + bpC * condition[i]) * prosoc_left[i];
        p[i] = inv_logit(p[i]);
    }
    pulled_left ~ binomial( 1 , p );
}
";

# ╔═╡ 63aad88a-a263-40d3-bb78-d643b9b66d82
data10_4 = (N = size(df, 1), N_actors = length(unique(df.actor)), 
    actor = df.actor, pulled_left = df.pulled_left,
    prosoc_left = df.prosoc_left, condition = df.condition);

# ╔═╡ 32bdb60f-b347-453a-8384-4c3fe0f465e6
# Sample using cmdstan

begin
	m10_4s = SampleModel("m10.4s", stan10_4)
	rc10_4s = stan_sample(m10_4s; data=data10_4);
end;

# ╔═╡ 55ac1b70-dcd4-49a8-8fb1-5164370f7ade
if success(rc10_4s)
	read_samples(m10_4s, :dimarray)
end

# ╔═╡ eb31f80c-7b81-458c-a217-2374bd83962d
if success(rc10_4s)
	da = read_samples(m10_4s, :dimarrays)
	da1 = da[param=At(Symbol("a.1"))]
end

# ╔═╡ ad36dba7-5934-4510-8ec7-7b9ed8498d1c
if success(rc10_4s)
	# Other manipulations
	
	@test Tables.istable(da) == true

	# All of parameters
	dar = reshape(Array(da), 4000, 9);
	@test size(dar) == (4000, 9)

	# Check :param axis names
	@test dims(da, :param).val == vcat([Symbol("a.$i") for i in 1:7], :bp, :bpC)  

	# Test combining vector param 'a'
	ma = matrix(da, "a");
	rma = reshape(ma, 4000, size(ma, 3))
	@test mean(rma, dims=1) ≈ [-0.7 10.9 -1 -1 -0.7 0.2 1.8] atol=0.7
end

# ╔═╡ 02d42039-9510-4dfd-bbe7-7bbaba18445f
if success(rc10_4s)
	da2 = read_samples(m10_4s, :dimarray)
	da2
end

# ╔═╡ 81671185-b8e7-4b61-8109-450374d9b348
if success(rc10_4s)
	da3= da2[param=At(Symbol("a.1"))]

	# Other manipulations
	
	@test Tables.istable(da3) == true

	# Check :param axis names
	@test dims(da2, :param).val == vcat([Symbol("a.$i") for i in 1:7], :bp, :bpC)  

	# Test combining vector param 'a'
	ma3 = matrix(da2, "a");
	@test mean(ma3, dims=1) ≈ [-0.7 10.9 -1 -1 -0.7 0.2 1.8] atol=0.7
end

# ╔═╡ Cell order:
# ╟─567821e6-18a9-43ba-a35f-c75cc3146d98
# ╟─9be99d72-d78e-494a-8d4b-8cafeb9f2f4c
# ╠═a0f056fc-f537-4778-8433-ffd53cb75db3
# ╠═d89204c4-7ee5-11ed-3356-1581fcf877fa
# ╠═bcfd62c6-dbd3-41af-b329-9fddb22b18c2
# ╠═05d79a9b-8506-40a4-8a5f-16bf9956f7f5
# ╠═d4b95015-b202-475b-bc70-9389fcb90b70
# ╠═d6ab26aa-fe54-49a0-97ae-90f626337fc7
# ╠═0dbe88e2-14e2-43c1-8f49-754547a369e9
# ╠═63aad88a-a263-40d3-bb78-d643b9b66d82
# ╠═32bdb60f-b347-453a-8384-4c3fe0f465e6
# ╠═55ac1b70-dcd4-49a8-8fb1-5164370f7ade
# ╠═eb31f80c-7b81-458c-a217-2374bd83962d
# ╠═ad36dba7-5934-4510-8ec7-7b9ed8498d1c
# ╠═02d42039-9510-4dfd-bbe7-7bbaba18445f
# ╠═81671185-b8e7-4b61-8109-450374d9b348
