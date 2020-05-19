@everywhere using StanSample, Distributions, Distributed

@everywhere ProjDir = @__DIR__

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
  sm::Union{Nothing, SampleModel}
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

  sm = SampleModel("name", model, [nchains],
    tmpdir=tmpdir, 
    method=StanSample.Sample(
      num_samples=num_samples,
      num_warmup=num_warmup,
      save_warmup=save_warmup,
      adapt=StanSample.Adapt(delta=delta)
    )
  )

  Job(name, model, data, output_format,
    tmpdir, nchains, num_samples, num_warmup, 
    save_warmup, delta, sm)
end

# Assume we have 2 models, m1 & m2
m1 = "
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

m2 = "
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

# Assume we have 4 sets of data 
d = Vector{Dict}(undef, 4)
d[1] = Dict(:N => 10, :y => [0, 1, 0, 0, 0, 0, 0, 0, 0, 1])
d[2] = Dict(:N => 10, :y => [0, 1, 0, 0, 0, 1, 1, 1, 0, 1])
d[3] = Dict(:N => 10, :y => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])
d[4] = Dict(:N => 10, :y => [0, 1, 1, 1, 0, 1, 1, 1, 0, 1])

tmpdir = "$(ProjDir)/tmp"
@everywhere jobs = Vector{Job}(undef, 4)
jobs[1] = Job("m1.1", m1, d[1]; output_format=:particles, tmpdir=tmpdir*"1")
jobs[2] = Job("m1.2", m1, d[2]; output_format=:particles, tmpdir=tmpdir*"2")
jobs[3] = Job("m2.1", m2, d[3]; output_format=:particles, tmpdir=tmpdir*"3")
jobs[4] = Job("m2.2", m2, d[4]; output_format=:particles, tmpdir=tmpdir*"4")

@everywhere function runjob(i, jobs)
  p = []
  rc = stan_sample(jobs[i].sm; data=jobs[i].data)
  if success(rc)
    res = read_samples(jobs[i].sm, output_format=:particles)
    push!(p, (res, jobs[i].sm))
    println("Job $i completed")
  else
    println("Job[i] failed, adjust p indeces accordingly.")
  end
  p
end

@time res = pmap(i -> runjob(i, jobs), 1:length(jobs));
for i in 1:length(jobs)
  display(res[i][1][1])
end

