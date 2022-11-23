using DataFrames
using PosteriorDB

pdb = database()

pdb.path

posterior_names(pdb)

dataset_names(pdb)

post = posterior(pdb, "eight_schools-eight_schools_centered")

mod = model(post)

info(post)

mod_code = implementation(mod, "stan")
mod_code

impl = implementation(mod, "stan")

code = load(impl)
println(code)


info(mod)

data = dataset(post)

info(data)

path(data)

load(data)

ref = reference_posterior(post)

info(ref)

path(ref)

DataFrame(load(ref)) |> display
