# Stan V9

| **Project Status**                                                               |  **Documentation**                                                               | **Build Status**                                                                                |
|:-------------------------------------------------------------------------------:|:-------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------:|
|![][project-status-img] | [![][docs-stable-img]][docs-stable-url] [![][docs-dev-img]][docs-dev-url] | ![][CI-build] |

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://stanjulia.github.io/Stan.jl/latest

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://stanjulia.github.io/Stan.jl/stable

[CI-build]: https://github.com/stanjulia/Stan.jl/workflows/CI/badge.svg?branch=master

[issues-url]: https://github.com/stanjulia/Stan.jl/issues

[project-status-img]: https://img.shields.io/badge/lifecycle-stable-green.svg

## Purpose

A collection of example Stan Language programs demonstrating all methods available in Stan's cmdstan executable (as an external program) from Julia.

For most applications one of the method packages is a better choice for day to day use and for executing a Stan Language program use the most important method (sample) in StanSample.jl.

## Background info

Early on (2012) Stan.jl took a similar approach as the recently released [CmdStanR](https://mc-stan.org/cmdstanr/) and [CmdStanPy](https://github.com/stan-dev/cmdstanpy) options to use Stan's [cmdstan executable](https://mc-stan.org/users/interfaces/cmdstan.html).

Stan.jl v7 covers all of cmdstan's methods in separate packages, i.e. StanSample.jl, StanOptimize.jl, StanVariational.jl and StanDiagnose.jl, including an option to run `generate_quantities` as part of StanSample.jl. 

Stan.jl v9 uses StanSample.jl v6, StanOptimize.jl v4, StanQuap.jl v4, StanDiagnose.jl v4 and StanVariational v4 and supports multithreading on C++ level. Stan.jl v9 also uses JSON.jl to generate data and init input files for cmdstan.

The StanJulia ecosystem includes 2 additional packages, StanQuap.jl (to compute [MAP](https://en.wikipedia.org/wiki/Maximum_a_posteriori_estimation) estimates) and DiffEqBayesStan.jl.

## Requirements

**Stan's cmdstan executable needs to be installed separatedly.** Please see [cmdstan installation](https://stanjulia.github.io/Stan.jl/latest/INSTALLATION/). If you plan to use C++ level threads, please read the `make/local-example` instructions and below section and [this file](https://github.com/StanJulia/StanSample.jl/blob/master/INSTALLING_CMDSTAN.md).


## Options for multi-threading and multi-chaining

Stan.jl v9 is intended to use Stan's `cmdstan` v2.28.2+ and StanSample.jl v6.

StanSample.jl v6 enables the use of c++ multithreading in the `cmdstan` binary. To activate multithreading in `cmdstan` this needs to be specified during the build process of `cmdstan`. I typically create a `path_to_cmdstan_directory/make/local` file (before running `make -j9 build`) containing `STAN_THREADS=true`. For an example, see the `.github/CI.yml` script

This means StanSample supports 2 mechanisms for in parallel drawing samples for chains, i.e. on C++ level (using C++ threads) and on Julia level (by spawing a Julia process for each chain). 

The `use_cpp_chains` keyword argument for `stan_sample()` determines if chains are executed on C++ level or on Julia level. By default, `use_cpp_chains=false`.

By default in ether case `num_chains=4`. See `??stan_sample`. Internally, `num_chains` will be copied to either `num_cpp_chains` or `num_julia_chains'.`

**Note:** Currently I do not suggest to use both C++ level chains and Julia level chains. Based on  `use_cpp_chains` the `stan_sample()` method will set either `num_cpp_chains=num_chains; num_julia_chains=1` or `num_julia_chains=num_chains;num_cpp_chain=1` (the default of `use_cpp_chains` is false).

Set the `check_num_chains` keyword argument in the call to `stan_sample()` to `false` to prevent above default behavior. See the example in the `Examples/RedCardsStudy` directory for more details and an example.

Threads on C++ level can be used in multiple ways, e.g. to run separate chains and to speed up certain Stan Language operations.

StanSample.jl's SampleModel sets the C++ `num_threads` to 4 but for compatibility with previous versions of StanJulia this is by default (`use_cpp_chains=false`) not included in the generated command line, e.g. see `sm.cmds` where `sm` is your SampleModel. 

An example of the possible performance trade-offs between `use_cpp_threads`, `num_cpp_chains` and `num_julia_chains` can be found in the [this](https://github.com/StanJulia/Stan.jl/tree/master/Examples/RedCardsStudy/graphs) directory.

### Conda based installation walkthrough for running Stan from Julia on Windows

**Note 1:** The conda way of installing also works on other platforms. See [also](https://mc-stan.org/docs/2_28/cmdstan-guide/index.html). 

**Note 2:** I believe if you have used CmdstanR (or CmdstanPy) to install cmdstan you can use that cmdstan version in Julia.

Make sure you have conda installed on your system and available from the command line (you can use the conda version that comes with Conda.jl or install your own).

Activate the conda environment into which you want to install cmdstan (e.g. run `conda activate stan-env` from the command line) or create a new environment (`conda create --name stan-env`) and then activate it.

Install cmdstan into the active conda environment by running `conda install -c conda-forge cmdstan`.

You can check that cmdstan, g++, and mingw32-make are installed properly by running `conda list cmdstan, g++ --version` and `mingw32-make --version`, respectively, from the activated conda environment.

Start a Julia session from the conda environment in which cmdstan has been installed (this is necessary for the cmdstan installation and the tools to be found).

Add the StanSample.jl package by running ] add StanSample from the REPL.

Set the CMDSTAN environment variable so that Julia can find the cmdstan installation, e.g. from the Julia REPL do: ENV["CMDSTAN"] = "C:/Users/Jakob/.julia/conda/3/envs/stan-env/Library/bin/cmdstan" This needs to be set before you load the StanSample package by e.g. using it. You can add this line to your startup.jl file so that you don't have to run it again in every fresh Julia session.

## Versions

### Version 9.5.0

1. Fix for matrix input files using JSON.

### Version 9.4.0

1. Updated redcardsstudy results for cmdstan-2.29.0.
2. Added a README to the `Examples/RedCardsStudy` directory

### Version 9.2.3

1. Switch to cmdstan-2.29.0

### Version 9.2.0 - 9.2.2

1. Switched from JSON3.jl to JSON.jl (JSON.jl supports 2D arrays)
2. Switched back to by default using Julia level chains.

### Version 9.1.1

1. Documentation improvement.

### version 9.1.0

1. Modified (simplified?) use of `num_chains` to define either number of chains on C++ or Julia level based on `use_cpp_chains` keyword argument to `stan_sample()`.

### Version 9.0.0

1. Use C++ multithreading features by default (4 `num_threads`, 4 `num_cpp_chains`).
2. By default use JSON3.jl to create data.json and init.json input files.

### Version 8.1.0

1. Support StanSample.jl v5.3 multithreading in cmdstan

### Version 8.0.0

1. Supports both CMDSTAN and JULIA_CMDSTAN_HOME environment variables to point to the cmdstan installation.
2. Thanks to @jfb-h completed testing with using conda to install cmdstan
3. Refactored code between StanBase.jl and the other StanJulia packages.

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
