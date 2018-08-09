# Stan

[![Travis Build Status](https://travis-ci.org/goedman/Stan.jl.svg?branch=master)](https://travis-ci.org/goedman/Stan.jl)
[![Coverage Status](https://coveralls.io/repos/goedman/Stan.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/goedman/Stan.jl?branch=master)
[![codecov](https://codecov.io/gh/goedman/Stan.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/goedman/Stan.jl?branch=master)

[![Stan](http://pkg.julialang.org/badges/Stan_0.7.svg)](http://pkg.julialang.org/?pkg=Stan&ver=0.7)
[![Stan](http://pkg.julialang.org/badges/Stan_1.0.svg)](http://pkg.julialang.org/?pkg=Stan&ver=1.0)

Documentation:
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://goedman.github.io/Stan.jl/latest)

## Purpose

A package to use Stan (as an external program) from Julia. 

Documentation can be found [here](http://goedman.github.io/Stan.jl/latest/INTRO.html)

CmdStan needs to be installed separatedly. Please see [CmdStan installation](http://goedman.github.io/Stan.jl/latest/INSTALLATION.html). 

For more info on Stan, please go to <http://mc-stan.org>.

For more info on Mamba, please go to <http://mambajl.readthedocs.org/en/latest/>.

For more info on Gadfly, please go to <https://github.com/GiovineItalia/Gadfly.jl>


## Important note

The latest (and maybe last) Stan.jl release is v3.5.0. Stan.jl v3.5.0 has been tested on Julia v0.7.0 and Julia v1.0.0.

For Julia 1.0.0 and up, the intention is to split out the functionality currently in Stan.jl. For more info see [StanJulia][(https://github.com/StanJulia) and the currently available package CmdStan.jl in that Github organization.

The intention is to make Stan.jl v4.x.x into a shell using the features available in StanJulia packages.