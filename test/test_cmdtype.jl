using Stan
using Base.Test

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

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

m = Stanmodel(Optimize(), name="bernoulli", model=bernoulli, data=data);
m.command[1] = cmdline(m)

println()
showcompact(m)
println()
show(m)

@assert m.output.refresh == 100

s1 = Sample()

println()
showcompact(s1)
println()
show(s1)

n1 = Lbfgs()
n2 = Lbfgs(history_size=15)
@assert 3*n1.history_size == n2.history_size

b1 = Bfgs()
b2 = Bfgs(tol_obj=1//100000000)
@assert b1.tol_obj == b2.tol_obj
o1 = Optimize()
o2 = Optimize(Newton())
o3 = Optimize(Lbfgs(history_size=10))
o4 = Optimize(Bfgs(tol_obj=1e-9))
o5 = Optimize(method=Bfgs(tol_obj=1e-9), save_iterations=true)
@assert o5.method.tol_obj == o1.method.tol_obj/10

println()
showcompact(o5)
println()
show(o5)

d1 = Diagnose()
@assert d1.diagnostic.error == 1e-6
d2 = Diagnose(Gradient(error=1e-7))
@assert d2.diagnostic.error == 1e-7

println()
showcompact(d2)
println()
show(d2)

println()
m.command

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

end # cd
