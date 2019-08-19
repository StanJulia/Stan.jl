# Stan

[![Travis Build Status](https://travis-ci.org/StanJulia/Stan.jl.svg?branch=master)](https://travis-ci.org/StanJulia/Stan.jl)
[![Coverage Status](https://coveralls.io/repos/StanJulia/Stan.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/StanJulia/Stan.jl?branch=master)
[![codecov](https://codecov.io/gh/StanJulia/Stan.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/StanJulia/Stan.jl?branch=master)

Documentation:
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://StanJulia.github.io/Stan.jl/latest)


## Important note

Major work will happen on this package over the next few months.

Stan.jl v4.x (and earlier versions) was the first generation of Julia tools to use Stan's [cmdstan executable](). CmdStan.jl v5.x updated these for Julia v1.x and added features based on user feedback. Most of cmdstan's features are covered (but not all).

Stan.jl v6.x constitutes the third generation and extends Tamas Papp's approach taken in StanRun, StanDump and StanSamples. It covers all of cmdstan's features in separate modules. i.e. StanVariational, StanSample, etc., including an option to run `generate_quantities`.

Stan.jl v6.x will contain examples using the features available in [StanJulia](). 

My intention is to continue maintenance of CmdStan.jl for at least another two years. 

## Purpose

A collection of documented examples to use Stan (as an external program) from Julia. 

Stan's cmdstan executable needs to be installed separatedly. Please see [CmdStan installation](http://StanJulia.github.io/Stan.jl/latest/INSTALLATION.html). 

For more info on Stan, please go to <http://mc-stan.org>.
