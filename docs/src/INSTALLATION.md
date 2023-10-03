# Stan.jl installation

## Minimal requirement

Note: Stan.jl refers to this Julia package. Stan's executable C++ program is 'cmdstan'.

To install Stan.jl e.g. in the Julia REPL: `] add Stan`.

To run this version of the Stan.jl package on your local machine, it assumes that the [cmdstan](http://mc-stan.org/interfaces/cmdstan) executable is properly installed.

In order for Stan.jl to find the cmdstan you need to set the environment variable `CMDSTAN` (or `JULIA_CMDSTAN_HOME`) to point to the cmdstan directory, e.g. add

```
export CMDSTAN=/Users/rob/Projects/Stan/cmdstan
launchctl setenv CMDSTAN /Users/rob/Projects/Stan/cmdstan # Mac specific
```

to your `~/.zshrc` or `~/.bash_profile` or simply add
```
ENV["CMDSTAN"]="_your absolute path to cmdstan_"
```

to `./julia/config/startup.jl`. Remember to use `expanduser()` if you use `~` in above "path to cmdstan" if it is not absolute.

I typically prefer cmdstan not to include the cmdstan version number in the above path to cmdstan (no update needed when the cmdstan version is updated).

Currently tested with cmdstan 2.33.1.

Note: StanSample.jl v6, supports multithreading in the `cmdstan` binary and requires cmdstan v2.28.2 and up. To activate multithreading in `cmdstan` this needs to be specified during the build process of `cmdstan`. 

### Conda based installation walkthrough for running Stan from Julia on Windows

Note: The conda way of installing also works on other platforms. See [also](https://mc-stan.org/docs/cmdstan-guide/index.html).

Make sure you have conda installed on your system and available from the command line (you can use the conda version that comes with Conda.jl or install your own).

Activate the conda environment into which you want to install cmdstan (e.g. run `conda activate stan-env` from the command line) or create a new environment (`conda create --name stan-env`) and then activate it.

Install cmdstan into the active conda environment by running `conda install -c conda-forge cmdstan`.

You can check that cmdstan, g++, and mingw32-make are installed properly by running `conda list cmdstan, g++ --version` and `mingw32-make --version`, respectively, from the activated conda environment.

Start a Julia session from the conda environment in which cmdstan has been installed (this is necessary for the cmdstan installation and the tools to be found).

Add the StanSample.jl package by running ] add StanSample from the REPL.

Set the CMDSTAN environment variable so that Julia can find the cmdstan installation, e.g. from the Julia REPL do: ENV["CMDSTAN"] = "C:/Users/Jakob/.julia/conda/3/envs/stan-env/Library/bin/cmdstan" This needs to be set before you load the StanSample package by e.g. using it. You can add this line to your startup.jl file so that you don't have to run it again in every fresh Julia session.
