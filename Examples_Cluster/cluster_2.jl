@everywhere using StanSample, Distributed

@everywhere ProjDir = @__DIR__

@everywhere struct Job
  model::AbstractString
  data::Dict
  tmpdir::AbstractString
  name::AbstractString
  nchains::Int
  num_samples::Int
  num_warmup::Int
  save_warmup::Bool
  delta::Float64
  output_format::Symbol
end

@everywhere themodel = "
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

@everywhere tmpdir = "$(ProjDir)/tmp"
@everywhere observed_data = Dict(:N => 10, :y => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])
@everywhere N = 8
@everywhere jobs = Vector{Job}(undef, N)

for i in 1:N
  jobs[i] = Job(
    themodel, observed_data, tmpdir,
    "Bernoulli_$i", 4, 1000, 1000, false, 0.85,
    :particles,
  )
end

@everywhere function runjob(i, jobs)
  sm = SampleModel(jobs[i].name, 
    jobs[i].model, 
    tmpdir=jobs[i].tmpdir,
    method=StanSample.Sample(
      save_warmup=jobs[i].save_warmup, 
      num_warmup=jobs[i].num_warmup, 
      num_samples=jobs[i].num_samples, 
      adapt=StanSample.Adapt(delta=jobs[i].delta))
  )
  (rc=stan_sample(sm; data=jobs[i].data), model=sm)
end

@time res = pmap(i -> runjob(i, jobs), 1:N);

p = []
for (ind, r) in enumerate(res)
  if success(r.rc)
    push!(p, read_samples(r.model, output_format=:particles))
  else
    println("Job[ind] failed.")
  end
end
display(p)

