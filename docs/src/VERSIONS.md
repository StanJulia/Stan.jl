# Version approach and history

## Approach

A version of a Julia package is labeled (tagged) as v"major.minor.patch".

My intention is to update the patch level whenever I make updates to programs which are not
visible to the then existing examples. This also includes adding new chapters and examples.

Changes that require updates to some examples bump the minor level.

Updates for new releases of Julia bump the major level.

## Testing

This version of the package has primarily been tested on Mac OSX 10.12, Julia 0.5 and 0.6, CmdStan 2.15.0, Mamba 0.10.0 and Gadfly 0.6.1

A limited amount of testing has taken place on other platforms by other users of the package (see note 1 in the 'To Do' section below).

## Version 2.0.0 (Currently slated for late 2017 and possibly Julia 1.0)

Please see the "Future of Stan.jl" [issue](https://github.com/goedman/Stan.jl/issues/40)

## Version 1.1.0 (next)
 
1. Thanks to Jon Alm Eriksen the performance of update_R_file() has been improved tremendously. 
1. A further suggestion by Michael Prange to directly write to the R file also prevents a Julia segmentation trap for very large arrays (N > 10^6).
1. Thanks to Maxime Rischard it is now possible for parameter values to be passed to a Stanmodel as an array of data dictionaries.
1. Bumped REQUIRE for Julia to v"0.5.0".
1. Fix for Stan 2.13.1 (for runs without a data file).
1. Added Marco Cox' fix for scalar data elements.
1. Updates to README suggested by Frederik Beaujean.
1. Further work on initialization with Chris Fisher
1. Added 2 tests to track outstanding CmdStan issues (#510 and #547). Slated for Stan 3.0
1. Fix to not depend on Homebrew on non OSX patforms
1. Initiated the "Future of Stan.jl" discussion (Stan.jl issue #40).
1. Compatible with Julia 0.6
1. Added optional keyward argument useMamba to stanmodel()
1. All test now set useMamba=false and do not depend on either Mamba or Gadfly

## Version 1.0.2 (currently tagged version)

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



