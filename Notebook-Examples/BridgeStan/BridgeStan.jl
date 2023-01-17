### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ eedbb8c6-2e87-4712-a9ce-cad9382d06a1
begin
	using StanSample
	using DataFrames
	import StanSample: BS
end

# ╔═╡ 6a5a6122-08d1-44da-8881-48b23450dc83
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

# ╔═╡ 3e8be11d-40a3-465b-8941-6c7f4ce24745
pwd()

# ╔═╡ 8f2ed639-a384-4fd2-bed6-2d9571ef3457
md" ##### Setup BridgeStan if necessary."

# ╔═╡ fa746109-80dd-4d68-88ba-a38eca97c206
md" ###### If `bridgestan` is installed in the same directory as `cmdstan`, StanSample includes setup. See INSTALLING_CMDSTAN.md in StanSample.jl"

# ╔═╡ abe21911-c908-4a35-88b0-b4646a74c63e
md" ##### Run the Stan Language program"

# ╔═╡ 0fc6fa0d-268a-4b0e-b1eb-4b228761c96b
bernoulli = "
data { 
  int<lower=1> N; 
  int<lower=0,upper=1> y[N];
} 
parameters {
  real<lower=0,upper=1> theta;
} 
model {
  theta ~ beta(1,1);
  y ~ bernoulli(theta);
}
";

# ╔═╡ a976cf4b-6f49-4141-a56a-132f358fb4c4
data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

# ╔═╡ 7c2c46d0-b61e-41ca-8ba4-8fe31640d41e
begin
	sm = SampleModel("bernoulli", bernoulli)
	rc = stan_sample(sm; data, save_warmup=true)
end;

# ╔═╡ 77321ebd-fe28-4e97-a81f-c59d9906f096
md" ##### Creade the BridgeStan model library"

# ╔═╡ acccac71-e62d-4a1d-8fb4-ebb379ee572d
available_chains(sm)

# ╔═╡ b3d88396-fcb9-44ed-8e6a-16030c9d4f36
begin
	chain_id = 2
	smb = BS.StanModel(stan_file = sm.output_base * ".stan", data = sm.output_base * "_data_$(chain_id).json")
end;

# ╔═╡ 0f43e4c5-6c4b-4a2b-bcf3-fee8862b28fd
md" ###### Model name:"

# ╔═╡ 4023e439-8af1-46e7-b484-24544c7dda8f
BS.name(smb)

# ╔═╡ 04f05b74-9b3e-4c49-b752-e6260eac1096
md" ###### Number of model parameters:"

# ╔═╡ 76dc6325-54a6-4fbd-bf67-80b738f49d4f
BS.param_num(smb)

# ╔═╡ 924c7420-9bef-4a30-b36c-e647e90c5a56
md" ###### Compute log_density and gradient at a random observation"

# ╔═╡ 6d31bc0d-321a-42d1-b851-dc6aed4aa6eb
let
	x = rand(BS.param_unc_num(smb))
	q = @. log(x / (1 - x)); # unconstrained scale
	ld, grad = BS.log_density_gradient(smb, q, jacobian = false)
	(log_density=ld, gradient=grad)
end

# ╔═╡ b24643c0-262d-4c96-b07a-b5196ce5c60a
md" ###### Or a range of densities"

# ╔═╡ ce23ee24-d13b-4e79-9dfb-9dcdd6b8f599
if typeof(smb) == BS.StanModel
    x = rand(BS.param_unc_num(smb))
    q = @. log(x / (1 - x))        # unconstrained scale

    function sim(smb::BS.StanModel, x=LinRange(0.1, 0.9, 100))
        q = zeros(length(x))
        ld = zeros(length(x))
        g = Vector{Vector{Float64}}(undef, length(x))
        for (i, p) in enumerate(x)
            q[i] = @. log(p / (1 - p)) # unconstrained scale
            ld[i], g[i] = BS.log_density_gradient(smb, q[i:i],
                jacobian = 0)
        end
        return DataFrame(x=x, q=q, log_density=ld, gradient=g)
    end

  sim(smb)
end

# ╔═╡ e5fd63fd-f08e-46a8-94dc-9edf59ed9929
md" ###### Check the BridgeStan model library has been created in the tmpdir"

# ╔═╡ 0554224d-f04c-4cfb-825f-38974792f7c8
readdir(sm.tmpdir)

# ╔═╡ Cell order:
# ╠═6a5a6122-08d1-44da-8881-48b23450dc83
# ╠═eedbb8c6-2e87-4712-a9ce-cad9382d06a1
# ╠═3e8be11d-40a3-465b-8941-6c7f4ce24745
# ╟─8f2ed639-a384-4fd2-bed6-2d9571ef3457
# ╟─fa746109-80dd-4d68-88ba-a38eca97c206
# ╟─abe21911-c908-4a35-88b0-b4646a74c63e
# ╠═0fc6fa0d-268a-4b0e-b1eb-4b228761c96b
# ╠═a976cf4b-6f49-4141-a56a-132f358fb4c4
# ╠═7c2c46d0-b61e-41ca-8ba4-8fe31640d41e
# ╟─77321ebd-fe28-4e97-a81f-c59d9906f096
# ╠═acccac71-e62d-4a1d-8fb4-ebb379ee572d
# ╠═b3d88396-fcb9-44ed-8e6a-16030c9d4f36
# ╟─0f43e4c5-6c4b-4a2b-bcf3-fee8862b28fd
# ╠═4023e439-8af1-46e7-b484-24544c7dda8f
# ╟─04f05b74-9b3e-4c49-b752-e6260eac1096
# ╠═76dc6325-54a6-4fbd-bf67-80b738f49d4f
# ╟─924c7420-9bef-4a30-b36c-e647e90c5a56
# ╠═6d31bc0d-321a-42d1-b851-dc6aed4aa6eb
# ╟─b24643c0-262d-4c96-b07a-b5196ce5c60a
# ╠═ce23ee24-d13b-4e79-9dfb-9dcdd6b8f599
# ╟─e5fd63fd-f08e-46a8-94dc-9edf59ed9929
# ╠═0554224d-f04c-4cfb-825f-38974792f7c8
