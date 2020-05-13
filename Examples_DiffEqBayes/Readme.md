# LotkaVolterra example in Stan and DiffEqBayes formulations.

This subdirectory contains 6 examples.

1. lv_benchmark is basically the benchmark as in DiffEqBayes
2. lv_benchmark_1 identified the lynx-hare coefficients using the lynx-hare data
3. lv_benchmark_2 uses the DiffEqBayes generated data
4. lv_benchmark_3 also runs a DynamicHMC example
5. diffeqbayes four parameter case
6. diffeqbayes one parameter case

All simulations usually produce results close to the expected solution.
All formulations occasionally have chains that do not converge.

All simulations use a slightly updated stan_inference method (imported from DiffEqBayes). It records the u_hat estimates (in a generated_quantities section) and enables pre-compiling by stanc. Note that current benchmarking tools currently don't work well for CmdStan due to the forced compilation of the Stan language program.

Notice that several additional (not normally required for CmdStan.jl) packages are needed in these scripts.
