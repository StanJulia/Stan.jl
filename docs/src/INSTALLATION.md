# CmdStan installation

## Minimal requirement

To run this version of the Stan.jl package on your local machine, it assumes that the  [CmdStan] (http://mc-stan.org/interfaces/cmdstan.html) executable is properly installed.

In order for Stan.jl to find the CmdStan executable you can

1.1) set the environment variable CMDSTAN_HOME to point to the CmdStan directory, e.g. add

```
export CMDSTAN_HOME=/Users/rob/Projects/Stan/cmdstan
launchctl setenv CMDSTAN_HOME /Users/rob/Projects/Stan/cmdstan
```

to .bash_profile. I typically prefer not to include the cmdstan version number in the path so no update is needed when CmdStan is updated.

Currently tested with CmdStan 2.16.0.

## Optional requirements

By default Stan.jl uses Mamba.jl for diagnostics and graphics.

2. [Mamba](https://github.com/brian-j-smith/Mamba.jl)
3. [Gadfly](https://github.com/GiovineItalia/Gadfly.jl)

Both packages can be installed using Pkg.add(), e.g. Pkg.add("Mamba"). It requires Mamba v"0.10.0". Mamba will install Gadfly.jl.

The Stanmodel field `useMamba` can be set to false to disable the use of Mamba and Gadfly.

## Additional OSX options

Thanks to Robert Feldt and the brew/Homebrew.jl folks, on OSX, in addition to the user following the steps in Stan's CmdStan User's Guide, CmdStan can also be installed using brew or Julia's Homebrew.

	 Executing in a terminal:
	 ```
	 brew tap homebrew/science
	 brew install cmdstan
	 ```
	 should install the latest available (on Homebrew) cmdstan in /usr/local/Cellar/cmdstan/x.x.x
	 
	 Or, from within the Julia REPL:
	 ```
	 using Homebrew
	 Homebrew.add("homebrew/science/cmdstan")
	 ```
	 will install CmdStan in ~/.julia/v0.x/Homebrew/deps/usr/Cellar/cmdstan/x.x.x.
