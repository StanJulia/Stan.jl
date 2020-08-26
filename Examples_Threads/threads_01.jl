# Experimental threads example. WIP!

using StanSample
using Statistics
using Distributions

ProjDir = @__DIR__
cd(ProjDir) #do

bernoullimodel = "
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
n = 100;
p1 = 12 # p1 is the number of models to fit
p = range(0, stop=1, length=p1)
observeddata = [Dict("N" => n, "y" => rand(Bernoulli(p[i]), n)) for i in 1:p1]

#isdir(ProjDir * "/tmp") && rm(ProjDir * "/tmp", recursive=true)
tmpdir = ProjDir * "/tmp"

sm = [SampleModel("bernoulli_m$i", bernoullimodel; tmpdir=tmpdir) for i in 1:p1];

println("\nThreads loop\n")

estimates = Vector(undef, p1)
Threads.@threads for i in 1:p1
     rc = stan_sample(sm[i]; data=observeddata[i]);
    if success(rc)
      samples = read_samples(sm[i]; output_format=:namedtuple)

      estimates[i] = [mean(reshape(samples.theta, 4000)), std(reshape(samples.theta, 4000))]
    end
end

estimates |> display

#end
