# Top level test script for Stan.jl
using Base.Test

println("Running tests for Stan-j0.3-v0.2.0:")

code_tests = [
  "test_utilities.jl",
  "test_cmdtype.jl"
]

# Run execution_tests only if CmdStan is installed and CMDSTAN_HOME is set correctly.
execution_tests = [
  "test_bernoulli.jl",
  "test_binormal.jl",
  "test_schools8.jl",
  "test_dyes.jl",
  "test_kidscore.jl"  
]

for my_test in code_tests
    println("\n  * $(my_test) *")
    include(my_test)
end

if isdefined(Main, :CMDSTAN_HOME) && length(CMDSTAN_HOME) > 0
  println("CMDSTAN_HOME found! Try to run bernoulli.")
  try
    for my_test in execution_tests
        println("\n  * $(my_test) *")
        include(my_test)
    end
  catch e
     println("CMDSTAN_HOME found, but CmdStan not installed properly.")
     println(e)
     println("No simulation runs have been performed.")
  end 
else
  println("\n\nCMDSTAN_HOME not found. Skipping all tests that depend on CmdStan!\n")  
end

println("\n")