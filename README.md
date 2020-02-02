# Stan

[![Travis Build Status](https://travis-ci.org/StanJulia/Stan.jl.svg?branch=master)](https://travis-ci.org/StanJulia/Stan.jl)
[![Coverage Status](https://coveralls.io/repos/StanJulia/Stan.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/StanJulia/Stan.jl?branch=master)
[![codecov](https://codecov.io/gh/StanJulia/Stan.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/StanJulia/Stan.jl?branch=master)

## Important note

V6.0.0 is a (mildly) breaking release primarily because StanSample now by default returns an array.
If e.g. an MCMCChains.Chains object is needed MCMCChains.jl must have been loaded and use:
```
chns = read_samples(sm; output_format=:mcmcchains)
```

See `?read_samples` for other optional arguments. 

Further work will happen on this package over the next few months, i.e. until at least April 2020 as the underlying StanJulia packages are being fine-tuned. Documentation - to be part of Stan.jl v6 - is also far from done. WORK IN PROGRESS!!!!

## Documentation

- [**STABLE**][docs-stable-url] &mdash; **documentation of the most recently tagged version.**
- [**DEVEL**][docs-dev-url] &mdash; *documentation of the in-development version.*

## Background info

Stan.jl v4.x and earlier versions were the first generation of Julia tools to use Stan's [cmdstan executable](https://mc-stan.org/users/interfaces/cmdstan.html). CmdStan.jl v5.x and v6.x updated these for Julia v1.x and added features based on user feedback. Most of cmdstan's features are covered (but not all).

Stan.jl v6.x constitutes the third generation and extends Tamas Papp's approach taken in StanRun, StanDump and StanSamples. It covers all of cmdstan's features in separate modules. i.e. StanVariational, StanSample, etc., including an option to run `generate_quantities`.

Stan.jl v6.x will contain examples using the features available in [StanJulia](https://github.com/StanJulia). 

My intention is to continue maintenance of CmdStan.jl for at least another two years. 

## Purpose

A collection of documented examples to use Stan (as an external program) from Julia. 

Stan's cmdstan executable needs to be installed separatedly. Please see [cmdstan installation](https://stanjulia.github.io/Stan.jl/latest/INSTALLATION/). 

For more info on Stan, please go to <http://mc-stan.org>.


[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://stanjulia.github.io/Stan.jl/latest

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://stanjulia.github.io/Stan.jl/stable

