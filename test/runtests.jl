# Run these tests if CmdStan is installed and STAN_HOME is set correctly.

using Base.Test

my_tests = [
  "test_bernoulli.jl",
  "test_binormal.jl",
  "test_kidscore.jl",
  "test_schools8.jl",
  "test_utilities.jl",
  "test_cmdtype.jl"
]

println("Running tests:")

for my_test in my_tests
    println("\n  * $(my_test) *")
    include(my_test)
end

