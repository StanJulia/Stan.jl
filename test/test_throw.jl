immutable Stop <: Exception end

function run_task(f)
   try f()
   catch e
       if isa(e, Stop)
           println("Your program was gracefully terminated.")
       else
           rethrow()
       end
   end
end

function f()
   throw(Stop())
end

function g()
   f()
end

run_task() do
   g()
end
println()

run_task() do
   error("This is bad.")
end
