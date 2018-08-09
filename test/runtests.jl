# Top level test script for Stan.jl
using Stan, Test

println("Running tests for Stan-j0.7-v3.5.0:")

code_tests = ["test_env.jl",              
              "test_utilities.jl",
              "test_cmdtype.jl"]

# Run execution_tests only if CmdStan is installed and CMDSTAN_HOME is set correctly.
execution_tests = [
  "test_bernoulli.jl",
  "test_bernoulli_optimize.jl",
  "test_bernoulli_diagnose.jl",
  #"test_bernoulli_variational.jl",
  "test_bernoulliinittheta.jl",
  "test_bernoulliscalar.jl",
  "test_binomial.jl",
  "test_binormal.jl",
  "test_schools8.jl",
  "test_dyes.jl",
  "test_kidscore.jl"
]

if CMDSTAN_HOME != ""
  println("CMDSTAN_HOME set. Try to run tests.")
  @testset "Stan.jl" begin
    for my_test in code_tests
        println("\n\n\n  * $(my_test) *")
        include(my_test)
    end
    
    for my_test in execution_tests
        println("\n\n  * $(my_test) *\n")
        include(my_test)
    end
    
    println("\n")
  end 
else
  println("\n\nCMDSTAN_HOME not set or found.")
  println("Skipping all tests that depend on CmdStan!\n")
end

println("\n")
