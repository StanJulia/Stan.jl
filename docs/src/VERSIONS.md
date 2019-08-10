# Version approach and history

## Approach

A version of a Julia package is labeled (tagged) as v"major.minor.patch".

My intention is to update the patch level whenever I make updates which are not visible to any of the existing examples.

New functionality will be introduced in minor level updates. This includes adding new examples, tests and the introduction of new arguments if they default to previous behavior, e.g. in v"1.1.0" the useMamba and init arguments to Stanmodel().

Changes that require updates to some examples bump the major level.

Updates for new releases of Julia and CmdStan bump the appropriate level.

## Testing

This version of the package has primarily been tested on Mac OSX 10.14, Julia 1.3 and CmdStan 2.20.0.

## Version 6.0.0

1. Initial release of Stan.jl based on StanJulia organization packages.