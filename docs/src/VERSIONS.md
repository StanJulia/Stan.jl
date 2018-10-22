# Version approach and history

## Approach

A version of a Julia package is labeled (tagged) as v"major.minor.patch".

My intention is to update the patch level whenever I make updates which are not visible to any of the existing examples.

New functionality will be introduced in minor level updates. This includes adding new examples, tests and the introduction of new arguments if they default to previous behavior, e.g. in v"1.1.0" the useMamba and init arguments to Stanmodel().

Changes that require updates to some examples bump the major level.

Updates for new releases of Julia and CmdStan bump the appropriate level.

## Testing

This version of the package has primarily been tested on Mac OSX 10.14, Julia 1.0, CmdStan 2.18.0, Mamba 0.12.0 and Gadfly 1.0.0.

A limited amount of testing has taken place on other platforms by other users of the package.

## Version 4.0.0

1. Julia 1.0 release
2. Moved to [StanJulia](https://github.com/StanJulia)
3. Further development will be done in CmdStan.jl

## Version 3.0.1 

1. Added ODE examples from DiffEqBayes.jl

## Version 3.0.0 

1. Julia 0.7- compatible

## Version 2.0.2

1. Julia 0.6 only
2. Added ODE examples from DiffEqBayes.jl

## Version 2.0.1

1. Mainly package updates

## Version 2.0.0

1. Compatible with Julia 0.6.
1. Added optional keyward argument useMamba to stanmodel().
1. All test now set useMamba=false and do not depend on either Mamba or Gadfly.
1. Tamas Papp figured out how to install CmdStan on Travis! This allows proper testing of Stan.jl on various unix/linux versions. Currently Travis tests Julia 0.5 and 0.6 on linux. The master branch typically tests on nightlies and osx as well.
1. Complete documentation (initial version, will no doubt take additional work).
2. Streamline R file creation for observed data and initialization values.
3. Improve error catching.

### Breaking changes:

1. Parameter initialization values (for parameters in the parameter block) are now passed in as an optional keyword argument to `stan()`. In v1.1.0 this was a keyword argument of Stanmodel(). See BernoulliInitTheta for an example.
1. The main execution method, `stan()`, now returns a tuple consisting of a return code and the simulation results.
1. The simulation results can either be in the form of Mamba.Chains or as a Array of values (the latter if the argument `useMamba=false` is added to `Stanmodel()`).
1. The `update` argument to Stanmodel() has been renamed `num_samples`.

## Version 1.1.0

Please see the "Future of Stan.jl" [issue](https://github.com/StanJulia/Stan.jl/issues/40).
 
1. Thanks to Jon Alm Eriksen the performance of update_R_file() has been improved tremendously. 
1. A further suggestion by Michael Prange to directly write to the R file also prevents a Julia segmentation trap for very large arrays (N > 10^6).
1. Thanks to Maxime Rischard it is now possible for parameter values to be passed to a Stanmodel as an array of data dictionaries.
1. Bumped REQUIRE for Julia to v"0.5.0".
1. Fix for Stan 2.13.1 (for runs without a data file).
1. Added Marco Cox' fix for scalar data elements.
1. Updates to README suggested by Frederik Beaujean.
1. Further work on initialization with Chris Fisher. Added keyword init to Stanmodel(). This needs further work, see below under outstanding issues.
1. Added 2 tests to track outstanding CmdStan issues (#510 and #547). Slated for Stan 3.0
1. Fix to not depend on Homebrew on non OSX patforms
1. Initiated the "Future of Stan.jl" discussion (Stan.jl issue #40).

## Version 1.0.2

1. Bumped REQUIRE for Julia to v"0.5.0-rc3"
2. Updated Homebrew section as CmdStan 2.11.0 is now available from Homebrew
3. Updated .travis.yml to just test on Julia 0.5

## Version 1.0.0

1. Tested with Stan 2.11.0 (fixed a change in the diagnose .csv file format)
2. Updated how CMDSTAN_HOME is retrieved from ENV (see also REQUIREMENTS section below)
3. Requires Julia 0.5
4. Requires Mamba 0.10.0
5. Mamba needs updates to Graphs.jl (will produce warnings otherwise)

## Version 0.3.2

1. Cleaned up message in Pkg.test("Stan")
2. Added experimental use of Mamba.contour() to bernoulli.jl (this requires Mamba 0.7.1+)
3. Introduce the use of Homebrew to install CmdStan on OSX
4. Pkg.test("Stan") will give an error on variational bayes
5. Last version update for Julia 0.4



