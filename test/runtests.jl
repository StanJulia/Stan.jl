# Top level test script for Stan.jl
using Base.Test

println("Running tests for Stan-j0.5-v1.0.2:")

code_tests = ["test_env.jl",              
              "test_utilities.jl",
              "test_cmdtype.jl"]

# Run execution_tests only if CmdStan is installed and CMDSTAN_HOME is set correctly.
execution_tests = [
  "test_bernoulli.jl",
  "test_bernoulli_optimize.jl",
  "test_bernoulli_diagnose.jl",
  "test_bernoulli_variational.jl",
  "test_bernoulliinittheta.jl",
  "test_bernoulliscalar.jl",
  "test_binomial.jl",
  "test_binormal.jl",
  "test_schools8.jl",
  "test_dyes.jl",
  "test_kidscore.jl"  
]

for my_test in code_tests
    println("\n  * $(my_test) *")
    include(my_test)
end

if CMDSTAN_HOME != ""
  println("CMDSTAN_HOME set. Try to run bernoulli.")
  try
    for my_test in execution_tests
        println("\n  * $(my_test) *")
        include(my_test)
    end
  catch e
     println("CMDSTAN_HOME initialized, but CmdStan not installed properly.")
     println(e)
     println("No simulation runs have been performed.")
  end 
else
  println("\n\nCMDSTAN_HOME not initialized. Skipping all tests that depend on CmdStan!\n")
end

println("\n")
