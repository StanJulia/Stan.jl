# Stan

[![Travis Build Status](https://travis-ci.org/StanJulia/Stan.jl.svg?branch=master)](https://travis-ci.org/StanJulia/Stan.jl)
[![Coverage Status](https://coveralls.io/repos/StanJulia/Stan.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/StanJulia/Stan.jl?branch=master)
[![codecov](https://codecov.io/gh/StanJulia/Stan.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/StanJulia/Stan.jl?branch=master)

Documentation:
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://StanJulia.github.io/Stan.jl/latest)


## Purpose

A package to use Stan (as an external program) from Julia. 

Documentation can be found [here](http://StanJulia.github.io/Stan.jl/latest/INTRO.html)

CmdStan needs to be installed separatedly. Please see [CmdStan installation](http://StanJulia.github.io/Stan.jl/latest/INSTALLATION.html). 

For more info on Stan, please go to <http://mc-stan.org>.

For more info on Mamba, please go to <http://mambajl.readthedocs.org/en/latest/>.

For more info on Gadfly, please go to <https://github.com/GiovineItalia/Gadfly.jl>

## Important note

For Julia 1.0.0 and up, the intention is to split out the functionality currently in Stan.jl. For more info see [StanJulia][(https://github.com/StanJulia) and the currently available package CmdStan.jl in that Github organization.

The intention is to make Stan.jl v5.1.0 into a shell using the features available in above StanJulia packages. Stan.jl v5.0.0 is an updated version of Stan.jl v3.5.0 based on Pkg3.