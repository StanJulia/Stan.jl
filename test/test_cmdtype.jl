using Stan
using Test

ProjDir = dirname(@__FILE__)
cd(ProjDir) #do

bernoulli = "
data { 
  int<lower=0> N; 
  int<lower=0,upper=1> y[N];
} 
parameters {
  real<lower=0,upper=1> theta;
} 
model {
  theta ~ beta(1,1);
    y ~ bernoulli(theta);
}
"

data = [
  Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
  Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]),
  Dict("N" => 10, "y" => [0, 0, 0, 0, 0, 0, 1, 0, 1, 1]),
  Dict("N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1])
]

m = Stanmodel(Optimize(), name="bernoulli", model=bernoulli, 
  data=data, useMamba=false);
m.command[1] = Stan.cmdline(m)

println()
show(IOContext(stdout, :compact => true), m)
println()
show(m)

@assert m.output.refresh == 100

s1 = Sample()

println()
show(IOContext(stdout, :compact => true), s1)
println()
show(s1)

n1 = Stan.Lbfgs()
n2 = Stan.Lbfgs(history_size=15)
@assert 3*n1.history_size == n2.history_size

b1 = Stan.Bfgs()
b2 = Stan.Bfgs(tol_obj=1//100000000)
@assert b1.tol_obj == b2.tol_obj
o1 = Optimize()
o2 = Optimize(Stan.Newton())
o3 = Optimize(Stan.Lbfgs(history_size=10))
o4 = Optimize(Stan.Bfgs(tol_obj=1e-9))
o5 = Optimize(method=Stan.Bfgs(tol_obj=1e-9), save_iterations=true)
@assert o5.method.tol_obj == o1.method.tol_obj/10

println()
show(IOContext(stdout, :compact => true), o5)
println()
show(o5)

d1 = Diagnose()
@assert d1.diagnostic.error == 1e-6
d2 = Diagnose(Stan.Gradient(error=1e-7))
@assert d2.diagnostic.error == 1e-7

println()
show(IOContext(stdout, :compact => true), d2)
println()
show(d2)

println()
m.command

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

  #end # cd
