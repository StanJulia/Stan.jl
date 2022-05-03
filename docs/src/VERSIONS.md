# Version approach and history

## Approach

A version of a Julia package is labeled (tagged) as v"major.minor.patch".

My intention is to update the patch level whenever I make updates which are not visible to any of the existing examples.

New functionality will be introduced in minor level updates. This includes adding new examples, tests and the introduction of new arguments if they default to previous behavior.

Changes that require updates to some examples bump the major level.

Updates for new releases of Julia and cmdstan bump the appropriate level.

## Testing

This version of the package has primarily been tested with GitHub workflows and macOS Big Sur v11.5, Julia 1.6+ and cmdstan-2.28.1.

## Versions

### Version 9.4.1 (Not yet published)

1. Doc updates

### Version 9.4.0

1. Updated redcradsstudy results for cmdstan-2.29.0.
2. Added a README to the `Examples/RedCardsStudy` directory

### Version 9.3.0-1

1. Switch to cmdstan-2.29.0 for CI testing.

### Version 9.2.0

1. Switch back to Julia level chains as default.
2. Replace JSON3.jl by JSON.jl (support for 2D arrays).

### Version 9.1.1

1. Documentation improvement.

### version 9.1.0

1. Modified (simplified?) use of `num_chains` to define either the number of chains on C++ or Julia level based on the value of the `use_cpp_chains` keyword argument to `stan_sample()`.

### Version 9.0.0

1. Use C++ multithreading features by default (`num_threads=5`, `num_cpp_chains=num_chains=4`).
2. By default use JSON3.jl to create data.json and init.json input files.

### Version 8.1.0

1. Support StanSanple.jl v5.3 multithreading in cmdstan

### Version 8.0.0

1. Supports both CMDSTAN and JULIA_CMDSTAN_HOME environment variables to point to the cmdstan installation (for compatibility between cmdstan for R and Python).
2. Thanks to @jfb-h completed testing with using conda to install cmdstan
3. Refactored code between StanBase.jl and the other StanJulia packages.
4. Change the default output format returned by read_samples to :table.
5. Keyword based cmdline modification.
6. Refactored code between StanBase.jl and the other StanJulia packages.
7. Will need cmdstan 2.28.1 (for num_threads).
8. `tmpdir` now positional argument when creating a CmdStanModel.
9. Thanks to @jfb-h completed testing with using conda to install cmdstan

### Version 7.0

**This is a breaking update!**

1. Use KeyedArray chains as default output format returned by read_samples.
2. Drop the output_format keyword argument in favor of a regulare argument.
3. Removed mostly outdated cluster and thread based examples.
4. Added a new package DiffEqBayesStan.jl.

### Version 6.4

1. Default output_format for read_samples() is now :namedtuple.
2. Updates for StanQuap
3. Version bound updates
4. CmdStan is in maintenance mode, new features will be added to StanSample, etc.
5. Additional testing (by users) on Windows 10
6. Doc updates
7. Use of Github workflows

### Version 6.2-3

1. Updates for dependencies
2. Add several experimental examples and tests (DiffEqBayes, Cluster and Threads)
3. Add :namedtuple as an output_format
4. Add RedCardsStudy example

### Version 6.0

This is a breaking release. Instead of by default returning an MCMCChains.Chains object,
Requires.jl is used to:

1. Optional include glue code to support Chains through MCMCChains.jl.
2. Optional include glue code to support DataFrames through DataFrames.jl.
3. Optional include glue code to support Particles through MonteCarloMeasusrements.jl.

By default stan_sample will return an "a3d" and optionally can also return a vector of variable names.

### Version 5.0.2

1. Tracking updates of dependencies.
2. Minor docs updates (far from complete!)

### Version 5.0.1

1. Tracking updates of dependencies.

### Version 5.0.0

1. Initial release of Stan.jl based on StanJulia organization packages.
2. A key package that will test the new setup is StatisticalRethinking.jl. This likely will drive further fine tuning.
3. See the TODO for outstanding work items.