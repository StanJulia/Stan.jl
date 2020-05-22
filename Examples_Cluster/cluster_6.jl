using CmdStan, Distributions, Distributed, MCMCChains

ProjDir = @__DIR__


@everywhere mutable struct Job
  name::AbstractString
  model::AbstractString
  data::Dict
  output_format::Symbol
  tmpdir::AbstractString
  nchains::Int
  num_samples::Int
  num_warmup::Int
  save_warmup::Bool
  delta::Float64
  sm::Union{Nothing, Stanmodel}
end
function Job(
    name::AbstractString, 
    model::AbstractString, 
    data::Dict; 
    output_format=:particles,
    tmpdir=pwd()
  )
  
  nchains=4
  num_samples=1000
  num_warmup=1000
  save_warmup=false
  delta=0.85

  sm = Stanmodel(
    CmdStan.Sample(
      num_samples=num_samples,
      num_warmup=num_warmup,
      save_warmup=save_warmup,
      adapt=CmdStan.Adapt(delta=delta)
    ),
    name=name, model=model, nchains=nchains,
    tmpdir=tmpdir, output_format=:mcmcchains,
    printsummary=false
  )

  Job(name, model, data, output_format,
    tmpdir, nchains, num_samples, num_warmup, 
    save_warmup, delta, sm)
end

@everywhere M = 3            # No of models
@everywhere D = 10           # No of data sets
@everywhere N = 100          # No of Bernoulli trials
isdir("$(ProjDir)/tmp") && rm("$(ProjDir)/tmp", recursive=true)

# Assume we have M models
model_template = "
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

m = repeat([model_template], M)

# Assume we have D sets of data 
d = Vector{Dict}(undef, D)
p = range(0.1, stop=0.9, length=D)
for i in 1:D
  d[i] = Dict("N" => N, "y" => [Int(rand(Bernoulli(p[i]), 1)[1]) for j in 1:N])
end

tmpdir = "$(ProjDir)/tmp"
@everywhere jobs = Vector{Job}(undef, M*D)
jobid = 0
for i in 1:M
  for j in 1:D
    global jobid += 1
    jobs[jobid] = Job("m$(jobid)", m[i], d[j]; output_format=:mcmcchains, 
      tmpdir=tmpdir)
  end
end

@everywhere function runjob(i, jobs)
  p = []
  rc, chns, _ = stan(jobs[i].sm, jobs[i].data)
  if rc == 0
    push!(p, (i, chns, jobs[i].sm))
    println("Job $i completed")
  else
    println("Job $i failed.")
  end
  p
end

println("\nNo of jobs = $(length(jobs))\n")

@time res = pmap(i -> runjob(i, jobs), 1:length(jobs));

for i in 1:length(jobs)
  display(mean(res[i][1][2]))
end
