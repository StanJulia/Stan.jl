# Stan V7

| **Project Status**                                                               |  **Documentation**                                                               | **Build Status**                                                                                |
|:-------------------------------------------------------------------------------:|:-------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------:|
|![][project-status-img] | [![][docs-stable-img]][docs-stable-url] [![][docs-dev-img]][docs-dev-url] | ![][CI-build] |

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://stanjulia.github.io/Stan.jl/latest

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://stanjulia.github.io/Stan.jl/stable

[CI-build]: https://github.com/stanjulia/Stan.jl/workflows/CI/badge.svg?branch=master

[issues-url]: https://github.com/stanjulia/Stan.jl/issues

[project-status-img]: https://img.shields.io/badge/lifecycle-wip-orange.svg

## Purpose

A collection of examples demonstrating the use Stan's cmdstan (as an external program) from Julia. 

## Background info

The first 2 generations of Stan.jl took a similar approach as the recently released [CmdStanR](https://mc-stan.org/cmdstanr/) and [CmdStanPy](https://github.com/stan-dev/cmdstanpy) options to use Stan's [cmdstan executable](https://mc-stan.org/users/interfaces/cmdstan.html).

Stan.jl v7.x constitutes the third generation and covers all of cmdstan's methods in separate modules, i.e. StanVariational, StanSample, etc., including an option to run `generate_quantities`. In a sense, it extends Tamas Papp's approach taken in StanRun, StanDump and StanSamples. 

Stan.jl v7.x will contain examples using the features available in [StanJulia](https://github.com/StanJulia) method packages. 

My intention is to continue maintenance of CmdStan.jl at least until late 2021.

## Requirements

Stan's cmdstan executable needs to be installed separatedly. Please see [cmdstan installation](https://stanjulia.github.io/Stan.jl/latest/INSTALLATION/). 

For more info on Stan, please go to <http://mc-stan.org>.

## Versions

### Version 8.0.0



### Version 7.1.1

1. Doc fixes by Jeremiah P S Lewis.
2. Switch default output_format for read_samples() to :table.
3. Add block extract for DataFrames, e.g. DataFrame(m1_1s, :log_lik)

### Version 7.1.0

1. Doc fixes. Prepare for switching default output_format for read_samples() to :table.

### Version 7.0

**This is a breaking update!**

1. Use KeyedArray chains as default output format returned by read_samples.
2. Drop the output_format keyword argument in favor of a regulare argument.
3. Removed mostly outdated cluster and thread based examples.
4. Added a new package DiffEqBayesStan.jl.
