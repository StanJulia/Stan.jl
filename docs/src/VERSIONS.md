# Version approach and history

## Approach

A version of a Julia package is labeled (tagged) as v"major.minor.patch".

My intention is to update the patch level whenever I make updates which are not visible to any of the existing examples.

New functionality will be introduced in minor level updates. This includes adding new examples, tests and the introduction of new arguments if they default to previous behavior.

Changes that require updates to some examples bump the major level.

Updates for new releases of Julia and cmdstan bump the appropriate level.

## Testing

This version of the package has primarily been tested with GitHub workflows and macOS Big Sur v11.3, Julia 1.5+ and cmdstan-2.26.1.

## Versions

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