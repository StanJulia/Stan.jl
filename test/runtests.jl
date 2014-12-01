# Run these tests if CmdStan is installed and CMDSTAN_HOME is set correctly.

using Base.Test

code_tests = [
  "test_utilities.jl",
  "test_cmdtype.jl"
]

execution_tests = [
  "test_bernoulli.jl",
  "test_binormal.jl",
  "test_schools8.jl",
  "test_dyes.jl",
  "test_kidscore.jl"  
]

println("Running tests:")

for my_test in code_tests
    println("\n  * $(my_test) *")
    include(my_test)
end

if CMDSTAN_HOME != ""
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
  println("CMDSTAN_HOME not found!")  
end

println("\n")