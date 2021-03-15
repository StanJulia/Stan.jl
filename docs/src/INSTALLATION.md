# Cmdstan installation

## Minimal requirement

Note: Stan.jl refers to this Julia package. Stan's executable C++ program is 'cmdstan'.

To install Stan.jl e.g. in the Julia REPL: `] add Stan`.

To run this version of the Stan.jl package on your local machine, it assumes that the [cmdstan](http://mc-stan.org/interfaces/cmdstan) executable is properly installed.

In order for Stan.jl to find the cmdstan you need to set the environment variable `JULIA_CMDSTAN_HOME` to point to the cmdstan directory, e.g. add

```
export JULIA_CMDSTAN_HOME=/Users/rob/Projects/Stan/cmdstan
launchctl setenv JULIA_CMDSTAN_HOME /Users/rob/Projects/Stan/cmdstan # Mac specific
```

to your `~/.zshrc` or `~/.bash_profile` or simply add

```
ENV["JULIA_CMDSTAN_HOME"]="_your absolute path to cmdstan_"
```

to `./julia/config/startup.jl`. Remember to use `expanduser()` if you use `~` in above "path to cmdstan" if it is not absolute.

I typically prefer cmdstan not to include the cmdstan version number in the above path to cmdstan (no update needed when the cmdstan version is updated).

Currently tested with cmdstan 2.26.1
