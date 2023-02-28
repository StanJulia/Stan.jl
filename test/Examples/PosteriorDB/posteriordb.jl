using DataFrames
using PosteriorDB

pdb = PosteriorDB.database()

pdb.path

PosteriorDB.posterior_names(pdb)

PosteriorDB.dataset_names(pdb)

post = PosteriorDB.posterior(pdb, "eight_schools-eight_schools_centered")

mod = PosteriorDB.model(post)

PosteriorDB.info(post)

mod_code = PosteriorDB.implementation(mod, "stan")
mod_code

impl = PosteriorDB.implementation(mod, "stan")

code = PosteriorDB.load(impl)
println(code)


PosteriorDB.info(mod)

data = PosteriorDB.dataset(post)

PosteriorDB.info(data)

PosteriorDB.path(data)

PosteriorDB.load(data)

ref = PosteriorDB.reference_posterior(post)

PosteriorDB.info(ref)

PosteriorDB.path(ref)

DataFrame(PosteriorDB.load(ref)) |> display
