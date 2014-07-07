using Stan

cmd1 = `echo`
cmd2 = `2`
sa = ["3", "4"]
s = "5"

r1 = cmd1 * cmd2; println(r1)
r2 = cmd1 * sa; println(r2)
r3 = cmd1 * s; println(r3)

cs = Base.AbstractCmd[] 

for i in 1:5
  push!(cs, `echo $i`)
end

println()
r = Stan.par(cs)
run(r)

println()
r = Stan.par(`echo hello`, 6)
run(r)
