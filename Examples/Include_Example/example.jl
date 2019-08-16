# Another way to include functions.
# See Parse_and_Iterate_Example for the Stan way.

using CmdStan, Distributions, Random

ProjDir = @__DIR__
cd(ProjDir)

function full_model(base_model, functions)
  initial_model = open(f->read(f, String), base_model)
  funcs = open(f->read(f, String), functions)
  "functions{\n$(funcs)}\n"*initial_model
end

function full_model(base_model, shared_functions, local_functions)
  initial_model = open(f->read(f, String), base_model)
  shared_funcs = open(f->read(f, String), shared_functions)
  local_funcs = open(f->read(f, String), local_functions)
  "functions{\n$(shared_funcs)\n$(local_funcs)}\n"*initial_model
end

model = full_model("bernoulli.stan", "shared_funcs.stan")

stanmodel = Stanmodel(Sample(save_warmup=true, num_warmup=1000,
  num_samples=2000, thin=1), name="bernoulli", model=model,
  printsummary=false)

observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

rc, chn, cnames = stan(stanmodel, observeddata, ProjDir)

if rc == 0
  show(chn)
end

println("\nOn to model2\n")

model2 = full_model("bernoulli2.stan", "shared_funcs.stan", "local_funcs.stan")

stanmodel = Stanmodel(Sample(save_warmup=true, num_warmup=1000,
  num_samples=2000, thin=1), name="bernoulli2", model=model2,
  printsummary=false)

observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

rc, chn, cnames = stan(stanmodel, observeddata, ProjDir)

if rc == 0
  read_summary(stanmodel)
end