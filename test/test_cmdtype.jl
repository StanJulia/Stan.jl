using Stan
using Base.Test

m = Stanmodel(name="8schools")
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
@assert d1.diagnostic.error == 1e-6 && d1.id == 1
d2 = Diagnose(Gradient(error=1e-7))
@assert d2.diagnostic.error == 1e-7
d3 = Diagnose(id=3)
@assert d3.diagnostic.error == 1e-6 && d3.id == 3
d4 = Diagnose(Gradient(epsilon=1e-7), 4)
@assert d4.diagnostic.epsilon == 1e-7 && d4.id == 4

println()
showcompact(d4)
println()
show(d4)

println()
m.command