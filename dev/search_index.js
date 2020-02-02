var documenterSearchIndex = {"docs":
[{"location":"EXAMPLES.html#Cross-reference-of-features-1","page":"Cross reference of features","title":"Cross reference of features","text":"","category":"section"},{"location":"EXAMPLES.html#","page":"Cross reference of features","title":"Cross reference of features","text":"This section is intended to help find an example that shows a specific feature. Work-in-progress!","category":"page"},{"location":"EXAMPLES.html#Stan-manual-examples-1","page":"Cross reference of features","title":"Stan manual examples","text":"","category":"section"},{"location":"EXAMPLES.html#","page":"Cross reference of features","title":"Cross reference of features","text":"These examples show basic usage patterns of this package.","category":"page"},{"location":"EXAMPLES.html#Bernoulli-1","page":"Cross reference of features","title":"Bernoulli","text":"","category":"section"},{"location":"EXAMPLES.html#","page":"Cross reference of features","title":"Cross reference of features","text":"Stan's goto initial example. This example touches pretty much most features available in StanSample.jl and MCMCChains.jl.","category":"page"},{"location":"EXAMPLES.html#","page":"Cross reference of features","title":"Cross reference of features","text":"Features demonstrated:","category":"page"},{"location":"EXAMPLES.html#","page":"Cross reference of features","title":"Cross reference of features","text":"Define a basic SampleModel.\nSet up a permanent tmpdir to prevent recompilation of a Stan language program. Default is to create a new directory using mktempdir().\nUpdate sample and adaptation default parameter settings.\nCall stan_sample.\nCheck the return value of stan_sample, in this example sample_file.\nCreate and show an MCMCChains.Chains object, chns.\nConvert a chns to a DataFrame.\nDisplay ESS (estimated effective sample size).\nPlot the chns.\nExtract Stan's sampling summary (MCMCChains.jl provides a similar summary).\nExtract a, or a few, fields from Stan's summary, e.g. for comparison purposes.","category":"page"},{"location":"EXAMPLES.html#Binomial-1","page":"Cross reference of features","title":"Binomial","text":"","category":"section"},{"location":"EXAMPLES.html#","page":"Cross reference of features","title":"Cross reference of features","text":"Features demonstrated:","category":"page"},{"location":"EXAMPLES.html#","page":"Cross reference of features","title":"Cross reference of features","text":"Use of the generated_quantities section in a Stan program.","category":"page"},{"location":"EXAMPLES.html#Binormal-1","page":"Cross reference of features","title":"Binormal","text":"","category":"section"},{"location":"EXAMPLES.html#","page":"Cross reference of features","title":"Cross reference of features","text":"Features demonstrated:","category":"page"},{"location":"EXAMPLES.html#","page":"Cross reference of features","title":"Cross reference of features","text":"Rename parameters in MCMCChains objects.","category":"page"},{"location":"EXAMPLES.html#Dyes,-ARM-and-Eight-schools-examples-1","page":"Cross reference of features","title":"Dyes, ARM and Eight schools examples","text":"","category":"section"},{"location":"EXAMPLES.html#","page":"Cross reference of features","title":"Cross reference of features","text":"Slightly larger Stan model examples.","category":"page"},{"location":"EXAMPLES.html#","page":"Cross reference of features","title":"Cross reference of features","text":"Features demonstrated:","category":"page"},{"location":"EXAMPLES.html#","page":"Cross reference of features","title":"Cross reference of features","text":"Manipulate sections in MCMCChains objects.","category":"page"},{"location":"EXAMPLES.html#Stan-language-methods-(Sample,-Optimize,-...)-1","page":"Cross reference of features","title":"Stan language methods (Sample, Optimize, ...)","text":"","category":"section"},{"location":"EXAMPLES.html#StanSample.jl-1","page":"Cross reference of features","title":"StanSample.jl","text":"","category":"section"},{"location":"EXAMPLES.html#StanOpimize-1","page":"Cross reference of features","title":"StanOpimize","text":"","category":"section"},{"location":"EXAMPLES.html#StanVariational-1","page":"Cross reference of features","title":"StanVariational","text":"","category":"section"},{"location":"EXAMPLES.html#StanDiagnose-1","page":"Cross reference of features","title":"StanDiagnose","text":"","category":"section"},{"location":"EXAMPLES.html#Generate_Quantities-1","page":"Cross reference of features","title":"Generate_Quantities","text":"","category":"section"},{"location":"EXAMPLES.html#Include-external-functions-1","page":"Cross reference of features","title":"Include external functions","text":"","category":"section"},{"location":"EXAMPLES.html#Special-input-and-output-1","page":"Cross reference of features","title":"Special input and output","text":"","category":"section"},{"location":"EXAMPLES.html#Init-settings-1","page":"Cross reference of features","title":"Init settings","text":"","category":"section"},{"location":"EXAMPLES.html#Init-with-an-array-of-dicts-1","page":"Cross reference of features","title":"Init with an array of dicts","text":"","category":"section"},{"location":"EXAMPLES.html#Init-froma-file-1","page":"Cross reference of features","title":"Init froma file","text":"","category":"section"},{"location":"EXAMPLES.html#NamedArray-1","page":"Cross reference of features","title":"NamedArray","text":"","category":"section"},{"location":"EXAMPLES.html#Scalar-observation-1","page":"Cross reference of features","title":"Scalar observation","text":"","category":"section"},{"location":"EXAMPLES.html#Zero-length-array-test-1","page":"Cross reference of features","title":"Zero length array test","text":"","category":"section"},{"location":"EXAMPLES.html#TBD-1","page":"Cross reference of features","title":"TBD","text":"","category":"section"},{"location":"EXAMPLES.html#Stan's-diagnose-executable-example-1","page":"Cross reference of features","title":"Stan's diagnose executable example","text":"","category":"section"},{"location":"EXAMPLES.html#MCMCChains-1","page":"Cross reference of features","title":"MCMCChains","text":"","category":"section"},{"location":"EXAMPLES.html#MCMCChains-to-DataFrame-1","page":"Cross reference of features","title":"MCMCChains to DataFrame","text":"","category":"section"},{"location":"EXAMPLES.html#NamedTuple-input-and-output-1","page":"Cross reference of features","title":"NamedTuple input and output","text":"","category":"section"},{"location":"EXAMPLES.html#MCMCChains-to-Array-1","page":"Cross reference of features","title":"MCMCChains to Array","text":"","category":"section"},{"location":"VERSIONS.html#Version-approach-and-history-1","page":"Versions","title":"Version approach and history","text":"","category":"section"},{"location":"VERSIONS.html#Approach-1","page":"Versions","title":"Approach","text":"","category":"section"},{"location":"VERSIONS.html#","page":"Versions","title":"Versions","text":"A version of a Julia package is labeled (tagged) as v\"major.minor.patch\".","category":"page"},{"location":"VERSIONS.html#","page":"Versions","title":"Versions","text":"My intention is to update the patch level whenever I make updates which are not visible to any of the existing examples.","category":"page"},{"location":"VERSIONS.html#","page":"Versions","title":"Versions","text":"New functionality will be introduced in minor level updates. This includes adding new examples, tests and the introduction of new arguments if they default to previous behavior.","category":"page"},{"location":"VERSIONS.html#","page":"Versions","title":"Versions","text":"Changes that require updates to some examples bump the major level.","category":"page"},{"location":"VERSIONS.html#","page":"Versions","title":"Versions","text":"Updates for new releases of Julia and cmdstan bump the appropriate level.","category":"page"},{"location":"VERSIONS.html#Testing-1","page":"Versions","title":"Testing","text":"","category":"section"},{"location":"VERSIONS.html#","page":"Versions","title":"Versions","text":"This version of the package has primarily been tested on Travis and Mac OSX 10.15, Julia 1.3 and cmdstan 2.21.0.","category":"page"},{"location":"VERSIONS.html#Versions-1","page":"Versions","title":"Versions","text":"","category":"section"},{"location":"VERSIONS.html#Version-6.0.0-1","page":"Versions","title":"Version 6.0.0","text":"","category":"section"},{"location":"VERSIONS.html#","page":"Versions","title":"Versions","text":"This is a breaking release. Instead of by default returning an MCMCChains.Chains object, Requires.jl is used to:","category":"page"},{"location":"VERSIONS.html#","page":"Versions","title":"Versions","text":"Optional support for Chains through MCMCChains.jl.\nOptional support for ElasticArrays through StanSamples.jl.\nOptional support for Particles through MonteCarloMeasusrements.jl.","category":"page"},{"location":"VERSIONS.html#","page":"Versions","title":"Versions","text":"By default stan_sample will return an \"a3d\" and vector of variable names.","category":"page"},{"location":"VERSIONS.html#Version-5.0.2-1","page":"Versions","title":"Version 5.0.2","text":"","category":"section"},{"location":"VERSIONS.html#","page":"Versions","title":"Versions","text":"Tracking updates of dependencies.\nMinor docs updates (far from complete!)","category":"page"},{"location":"VERSIONS.html#Version-5.0.1-1","page":"Versions","title":"Version 5.0.1","text":"","category":"section"},{"location":"VERSIONS.html#","page":"Versions","title":"Versions","text":"Tracking updates of dependencies.","category":"page"},{"location":"VERSIONS.html#Version-5.0.0-1","page":"Versions","title":"Version 5.0.0","text":"","category":"section"},{"location":"VERSIONS.html#","page":"Versions","title":"Versions","text":"Initial release of Stan.jl based on StanJulia organization packages.\nA key package that will test the new setup is StatisticalRethinking.jl. This likely will drive further fine tuning.\nSee the TODO for outstanding work items.","category":"page"},{"location":"INSTALLATION.html#cmdstan-installation-1","page":"Installation","title":"cmdstan installation","text":"","category":"section"},{"location":"INSTALLATION.html#Minimal-requirement-1","page":"Installation","title":"Minimal requirement","text":"","category":"section"},{"location":"INSTALLATION.html#","page":"Installation","title":"Installation","text":"Note: Stan.jl refers to this Julia package. Stan's executable C++ program is 'cmdstan'.","category":"page"},{"location":"INSTALLATION.html#","page":"Installation","title":"Installation","text":"To install Stan.jl e.g. in the Julia REPL: ] add Stan.","category":"page"},{"location":"INSTALLATION.html#","page":"Installation","title":"Installation","text":"To run this version of the Stan.jl package on your local machine, it assumes that cmdstan executable is properly installed.","category":"page"},{"location":"INSTALLATION.html#","page":"Installation","title":"Installation","text":"In order for Stan.jl to find the cmdstan you need to set the environment variable JULIA_CMDSTAN_HOME to point to the cmdstan directory, e.g. add","category":"page"},{"location":"INSTALLATION.html#","page":"Installation","title":"Installation","text":"export JULIA_CMDSTAN_HOME=/Users/rob/Projects/Stan/cmdstan\nlaunchctl setenv JULIA_CMDSTAN_HOME /Users/rob/Projects/Stan/cmdstan","category":"page"},{"location":"INSTALLATION.html#","page":"Installation","title":"Installation","text":"to ~/.bash_profile or add","category":"page"},{"location":"INSTALLATION.html#","page":"Installation","title":"Installation","text":"ENV[\"JULIA_CMDSTAN_HOME\"]=\"_your absolute path to cmdstan_\"","category":"page"},{"location":"INSTALLATION.html#","page":"Installation","title":"Installation","text":"to ./julia/config/startup.jl. ","category":"page"},{"location":"INSTALLATION.html#","page":"Installation","title":"Installation","text":"I typically prefer cmdstan not to include the cmdstan version number in the above path to cmdstan (no update needed when the cmdstan version is updated).","category":"page"},{"location":"INSTALLATION.html#","page":"Installation","title":"Installation","text":"Currently tested with cmdstan 2.21.0","category":"page"},{"location":"WALKTHROUGH.html#A-walk-through-example-(using-StanSample.jl)-1","page":"Walkthrough","title":"A walk-through example (using StanSample.jl)","text":"","category":"section"},{"location":"WALKTHROUGH.html#","page":"Walkthrough","title":"Walkthrough","text":"Make StanSample.jl available:","category":"page"},{"location":"WALKTHROUGH.html#","page":"Walkthrough","title":"Walkthrough","text":"using StanSample","category":"page"},{"location":"WALKTHROUGH.html#","page":"Walkthrough","title":"Walkthrough","text":"Define a variable 'model' to hold the Stan language model definition:","category":"page"},{"location":"WALKTHROUGH.html#","page":"Walkthrough","title":"Walkthrough","text":"model = \"\ndata { \n  int<lower=0> N; \n  int<lower=0,upper=1> y[N];\n} \nparameters {\n  real<lower=0,upper=1> theta;\n} \nmodel {\n  theta ~ beta(1,1);\n    y ~ bernoulli(theta);\n}\n\"","category":"page"},{"location":"WALKTHROUGH.html#","page":"Walkthrough","title":"Walkthrough","text":"Create a SampleModel object:","category":"page"},{"location":"WALKTHROUGH.html#","page":"Walkthrough","title":"Walkthrough","text":"sm = SampleModel(\"bernoulli\", model)","category":"page"},{"location":"WALKTHROUGH.html#","page":"Walkthrough","title":"Walkthrough","text":"Above SampleModel() call creates a default model for sampling. See ?SampleModel for details.","category":"page"},{"location":"WALKTHROUGH.html#","page":"Walkthrough","title":"Walkthrough","text":"The observed input data:","category":"page"},{"location":"WALKTHROUGH.html#","page":"Walkthrough","title":"Walkthrough","text":"data = Dict(\"N\" => 10, \"y\" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])","category":"page"},{"location":"WALKTHROUGH.html#","page":"Walkthrough","title":"Walkthrough","text":"Run a simulation by calling stan_sample(), passing in the model and data: ","category":"page"},{"location":"WALKTHROUGH.html#","page":"Walkthrough","title":"Walkthrough","text":"rc = stan_sample(sm, data)\n\nif success(rc)\n  chns = read_samples(sm)\n  describe(chns)\n  plot(chns)\nend","category":"page"},{"location":"INTRO.html#A-Julia-interface-to-Stan's-cmdstan-executable-1","page":"Intro","title":"A Julia interface to Stan's cmdstan executable","text":"","category":"section"},{"location":"INTRO.html#Stan.jl-1","page":"Intro","title":"Stan.jl","text":"","category":"section"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"Stan is a system for statistical modeling, data analysis, and prediction. It is extensively used in social, biological, and physical sciences, engineering, and business. The Stan program language and interfaces are documented here.","category":"page"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"cmdstan is the shell/command line interface to run Stan language programs. ","category":"page"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"Stan.jl wraps cmdstan and captures the samples for further processing.","category":"page"},{"location":"INTRO.html#StanJulia-1","page":"Intro","title":"StanJulia","text":"","category":"section"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"Stan.jl is part of the StanJulia Github organization set of packages. It is one of two options in StanJulia to capture draws from a Stan language program. The other option is under development and is illustrated in Stan.jl and StatisticalRethinking.jl.","category":"page"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"These are not the only options to sample using Stan from Julia. Valid other options are PyCall.jl/PyStan and StanRun.jl.","category":"page"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"On a very high level, a typical workflow for using CmdStan.jl looks like:","category":"page"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"using CmdStan\n\n# Define a Stan language program.\nbernoulli = \"...\"\n\n# Prepare for calling cmdstan.\nsm = SampleModel(...)\n\n# Compile and run Stan program, collect draws.\nrc = stan_sample(...)\n\n# Cmdstan summary of result\nsdf = read_summary(sm)\n\n# Dsplay the summary\nsdf |> display\n\n# Show the draws\nsamples = read_samples(sm)","category":"page"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"This workflow creates an array of draws, the default value for the output_format argument in Stanmodel(). Other options are :dataframes and :mcmcchains.","category":"page"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"If at this point a vector of DataFrames (a DataFrame for each chain) is preferred:","category":"page"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"df = StanSample.convert_a3d(samples, cnames, Val(:dataframes))","category":"page"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"Or, if you know upfront a vector of DataFrames is what you want, you can specify that when creating the Stanmodel:","category":"page"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"stanmodel = StanModel(..., output_format=:dataframes,...)","category":"page"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"Version 5 of CmdStan.jl used :mcmcchains by default but the dependencies of MCMCChains.jl, including access to plotting features, can lead to long compile times.","category":"page"},{"location":"INTRO.html#References-1","page":"Intro","title":"References","text":"","category":"section"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"There is no shortage of good books on Bayesian statistics. A few of my favorites are:","category":"page"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"Bolstad: Introduction to Bayesian statistics\nBolstad: Understanding Computational Bayesian Statistics\nGelman, Hill: Data Analysis using regression and multileve,/hierachical models\nMcElreath: Statistical Rethinking\nGelman, Carlin, and others: Bayesian Data Analysis","category":"page"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"and a great read (and implementation in DynamicHMC.jl):","category":"page"},{"location":"INTRO.html#","page":"Intro","title":"Intro","text":"Betancourt: A Conceptual Introduction to Hamiltonian Monte Carlo","category":"page"},{"location":"index.html#Stan-example-programs-1","page":"Stan example programs","title":"Stan example programs","text":"","category":"section"},{"location":"index.html#Bernoulli-1","page":"Stan example programs","title":"Bernoulli","text":"","category":"section"},{"location":"index.html#","page":"Stan example programs","title":"Stan example programs","text":"","category":"page"},{"location":"index.html#Index-1","page":"Stan example programs","title":"Index","text":"","category":"section"},{"location":"index.html#","page":"Stan example programs","title":"Stan example programs","text":"","category":"page"}]
}