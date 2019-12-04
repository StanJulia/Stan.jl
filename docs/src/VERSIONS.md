# Version approach and history

## Approach

A version of a Julia package is labeled (tagged) as v"major.minor.patch".

My intention is to update the patch level whenever I make updates which are not visible to any of the existing examples.

New functionality will be introduced in minor level updates. This includes adding new examples, tests and the introduction of new arguments if they default to previous behavior.

Changes that require updates to some examples bump the major level.

Updates for new releases of Julia and cmdstan bump the appropriate level.

## Testing

This version of the package has primarily been tested on Travis and Mac OSX 10.15, Julia 1.3 and cmdstan 2.21.0.

## Versions

### Version 5.0.2

1. Tracking updates of dependencies.
2. Minor docs updates (far from complete!)

### Version 5.0.1

1. Tracking updates of dependencies.

### Version 5.0.0

1. Initial release of Stan.jl based on StanJulia organization packages.
2. A key package that will test the new setup is StatisticalRethinking.jl. This likely will drive further fine tuning.
3. See the TODO for outstanding work items.