var documenterSearchIndex = {"docs":
[{"location":"WALKTHROUGH2/#A-walk-through-example-(using-StanSample.jl)","page":"Walkthrough2","title":"A walk-through example (using StanSample.jl)","text":"","category":"section"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Make StanSample.jl available:","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"using StanSample, Distributions","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Include also Distributions.jl as we'll be using that package to create an example model. This example is derived from an example in StatisticalRethinking.jl.","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"It shows a few more features than the Bernoulli example in WALKTHROUGH.md.","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"N = 100\ndf = DataFrame(\n    height = rand(Normal(10, 2), N),\n    leg_prop = rand(Uniform(0.4, 0.5), N),\n)\ndf.leg_left = df.leg_prop .* df.height + rand(Normal(0, 0.02), N)\ndf.leg_right = df.leg_prop .* df.height + rand(Normal(0, 0.03), N)","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Define a variable stan6_1 to hold the Stan language model definition:","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"stan6_1 = \"\ndata {\n  int <lower=1> N;\n  vector[N] H;\n  vector[N] LL;\n  vector[N] LR;\n}\nparameters {\n  real a;\n  vector[2] b;\n  real <lower=0> sigma;\n}\nmodel {\n  vector[N] mu;\n  mu = a + b[1] * LL + b[2] * LR;\n  a ~ normal(10, 100);\n  b ~ normal(2, 10);\n  sigma ~ exponential(1);\n  H ~ normal(mu, sigma);\n}\n\";","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Create and compile a SampleModel object. By \"compile\" here is meant that SampleModel() will take care of compiling the Stan language program first to a C++ program and subsequantly compile that C++ program to an executable which will be executed in stan_sample().","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"sm = SampleModel(\"m6.1s\", stan6_1);","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Above SampleModel() call creates a default model for sampling. See ?SampleModel for details.","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"The observed input data is defined below. Note here we use a NamedTuple for input:","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"data = (H = df.height, LL = df.leg_left, LR = df.leg_right, N = size(df, 1))","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Generate posterior draws by calling stan_sample(), passing in the model and optionally data and sometimes initial settings: ","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"rc6_1s = stan_sample(m6_1s; data);\n\nif success(rc)\n  samples_nt = read_samples(sm);\nend","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Samples_nt now contains a NamedTuple:","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"nt6_1s.b","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Compute the mean for vector b:","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"mean(nt6_1s.b, dims=2)","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Some more options:","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"init = (a = 2.0, b = [1.0, 2.0], sigma = 1.0)\nrc6_2s = stan_sample(m6_1s; data, init);\nif success(rc6_1s)\n    nt6_2s = read_samples(m6_1s)\nend\n\nnt6_2s.b\nprintln()\nmean(nt6_2s.b, dims=2)\nprintln()\n\nread_summary(m6_1s)\nprintln()\n\npost6_1s_df = read_samples(m6_1s; output_format=:dataframe)\nprintln()\n\npart6_1s = read_samples(m6_1s; output_format=:particles)","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Walkthrough2.jl is also available as a script in the examples/Walkthrough2 directory.","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Many more examples are provided in the six Example subdirectories. ","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Additional examples can be found in StanSample.jl and StatisticalRethinking.jl.","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"StatisticalRethinking.jl add features to compare models and coefficients, plotting (including trankplots() for chains) and summarizing results (precis()). MCMCChains.jl, part of the Turing ecosystem, provides additional tools to evaluate the chains.","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"StatsModelComparisons.jl add WAIC, PSIS and a few other model comparison methods.","category":"page"},{"location":"VERSIONS/#Version-approach-and-history","page":"Versions","title":"Version approach and history","text":"","category":"section"},{"location":"VERSIONS/#Approach","page":"Versions","title":"Approach","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"A version of a Julia package is labeled (tagged) as v\"major.minor.patch\".","category":"page"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"My intention is to update the patch level whenever I make updates which are not visible to any of the existing examples.","category":"page"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"New functionality will be introduced in minor level updates. This includes adding new examples, tests and the introduction of new arguments if they default to previous behavior.","category":"page"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Changes that require updates to some examples bump the major level.","category":"page"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Updates for new releases of Julia and cmdstan bump the appropriate level.","category":"page"},{"location":"VERSIONS/#Testing","page":"Versions","title":"Testing","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"This version of the package has primarily been tested with GitHub workflows and macOS Big Sur v11.3, Julia 1.5+ and cmdstan-2.26.1.","category":"page"},{"location":"VERSIONS/#Versions","page":"Versions","title":"Versions","text":"","category":"section"},{"location":"VERSIONS/#Version-6.4","page":"Versions","title":"Version 6.4","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Default outputformat for readsamples() is now :namedtuple.\nUpdates for StanQuap\nVersion bound updates\nCmdStan is in maintenance mode, new features will be added to StanSample, etc.\nAdditional testing (by users) on Windows 10\nDoc updates\nUse of Github workflows","category":"page"},{"location":"VERSIONS/#Version-6.2-3","page":"Versions","title":"Version 6.2-3","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Updates for dependencies\nAdd several experimental examples and tests (DiffEqBayes, Cluster and Threads)\nAdd :namedtuple as an output_format\nAdd RedCardsStudy example","category":"page"},{"location":"VERSIONS/#Version-6.0","page":"Versions","title":"Version 6.0","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"This is a breaking release. Instead of by default returning an MCMCChains.Chains object, Requires.jl is used to:","category":"page"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Optional include glue code to support Chains through MCMCChains.jl.\nOptional include glue code to support DataFrames through DataFrames.jl.\nOptional include glue code to support Particles through MonteCarloMeasusrements.jl.","category":"page"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"By default stan_sample will return an \"a3d\" and optionally can also return a vector of variable names.","category":"page"},{"location":"VERSIONS/#Version-5.0.2","page":"Versions","title":"Version 5.0.2","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Tracking updates of dependencies.\nMinor docs updates (far from complete!)","category":"page"},{"location":"VERSIONS/#Version-5.0.1","page":"Versions","title":"Version 5.0.1","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Tracking updates of dependencies.","category":"page"},{"location":"VERSIONS/#Version-5.0.0","page":"Versions","title":"Version 5.0.0","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Initial release of Stan.jl based on StanJulia organization packages.\nA key package that will test the new setup is StatisticalRethinking.jl. This likely will drive further fine tuning.\nSee the TODO for outstanding work items.","category":"page"},{"location":"INSTALLATION/#Cmdstan-installation","page":"Installation","title":"Cmdstan installation","text":"","category":"section"},{"location":"INSTALLATION/#Minimal-requirement","page":"Installation","title":"Minimal requirement","text":"","category":"section"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"Note: Stan.jl refers to this Julia package. Stan's executable C++ program is 'cmdstan'.","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"To install Stan.jl e.g. in the Julia REPL: ] add Stan.","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"To run this version of the Stan.jl package on your local machine, it assumes that the cmdstan executable is properly installed.","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"In order for Stan.jl to find the cmdstan you need to set the environment variable JULIA_CMDSTAN_HOME to point to the cmdstan directory, e.g. add","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"export JULIA_CMDSTAN_HOME=/Users/rob/Projects/Stan/cmdstan\nlaunchctl setenv JULIA_CMDSTAN_HOME /Users/rob/Projects/Stan/cmdstan # Mac specific","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"to your ~/.zshrc or ~/.bash_profile or simply add","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"ENV[\"JULIA_CMDSTAN_HOME\"]=\"_your absolute path to cmdstan_\"","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"to ./julia/config/startup.jl. Remember to use expanduser() if you use ~ in above \"path to cmdstan\" if it is not absolute.","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"I typically prefer cmdstan not to include the cmdstan version number in the above path to cmdstan (no update needed when the cmdstan version is updated).","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"Currently tested with cmdstan 2.26.1","category":"page"},{"location":"WALKTHROUGH/#A-walk-through-example-(using-StanSample.jl)","page":"Walkthrough","title":"A walk-through example (using StanSample.jl)","text":"","category":"section"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"This script assumes StanSample has been installed in your environment.","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"A better approach would be to use projects, e.g. DrWatson.jl, to manage which packages are available.","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"Make StanSample.jl available:","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"using StanSample","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"Define a variable 'model' to hold the Stan language model definition:","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"model = \"\ndata { \n  int<lower=0> N; \n  int<lower=0,upper=1> y[N];\n} \nparameters {\n  real<lower=0,upper=1> theta;\n} \nmodel {\n  theta ~ beta(1,1);\n    y ~ bernoulli(theta);\n}\n\";","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"Create and compile a SampleModel object:","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"sm = SampleModel(\"bernoulli\", model);","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"Above SampleModel() call creates a default model for sampling. See ?SampleModel for details.","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"The observed input data as a Dict:","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"data = Dict(\"N\" => 10, \"y\" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]);","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"Run a simulation by calling stan_sample(), passing in the model and data: ","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"rc = stan_sample(sm; data);\n\nif success(rc)\n  samples_df = read_samples(sm; output_format=:dataframe);\n  samples_df |> display\nend","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"Notice that data and init are optional keyword arguments to stan_sample(). Julia expands data to data=data or you can use data=your_data.","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"A further example can be found in WALKTHROUGH2.md.","category":"page"},{"location":"INTRO/#A-Julia-interface-to-Stan's-cmdstan-executable","page":"Intro","title":"A Julia interface to Stan's cmdstan executable","text":"","category":"section"},{"location":"INTRO/#Stan.jl","page":"Intro","title":"Stan.jl","text":"","category":"section"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Stan is a system for statistical modeling, data analysis, and prediction. It is extensively used in social, biological, and physical sciences, engineering, and business. The Stan language and the interfaces to execute a Stan language program are documented here.","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Cmdstan is the shell/command line interface to run Stan language programs. ","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Stan.jl wraps cmdstan and captures the samples for further processing.","category":"page"},{"location":"INTRO/#StanJulia-overview","page":"Intro","title":"StanJulia overview","text":"","category":"section"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Stan.jl is part of the StanJulia Github organization set of packages.","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Stan.jl is the primary option in StanJulia to capture draws from a Stan language program.  How to use the underlying component packages in StanJulia, e.g. StanSample.jl, StanOptimize.jl and StanVariational.jl, is illustrated in Stan.jl and in a much broader context in StatisticalRethinking.jl.","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"The other option to capture draws from a Stan language program in StanJulia is CmdStan, which is the older approach and is currently in maintenance mode. Thus new features will be added to Stan.jl and the supporting component packages.","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"These are not the only options to sample using Stan from Julia. Valid other options are PyCall.jl/PyStan and StanRun.jl. In addition, Julia provides other, pure Julia, mcmc options such as DynamicHMC.jl, Turing.jl and Mamba.jl.","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"On a very high level, a typical workflow for using Stan.jl looks like:","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"using Stan\n\n# Define a Stan language program.\nbernoulli = \"...\"\n\n# Create and compile a SampleModel, an OptimizeModel, etc.:\nsm = SampleModel(...)\n\n# Run the compiled Stan languauge program and collect draws:\nrc = stan_sample(...)\n\nif success(rc)\n  # Retrieve Stan's `stansummary` executable result:\n  sdf = read_summary(sm)\n\n  # Display the summary as a DataFrame:\n  sdf |> display\n\n  # Extract the draws from the SampleModel:\n  named_tuple_of_samples = read_samples(sm)\n\nend","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"This workflow creates an NamedTuple with the draws, the default value for the output_format argument in read_samples().","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"If a DataFrame (with all chains appended) is preferred:","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"df = read_samples(sm; output_format=:dataframe)","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Other options are :dataframes, :mcmcchains, :array and :particles. See","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"?read_samples","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"for more details. Walkthrough and Walkthrough2 show StanSample.jl in action.","category":"page"},{"location":"INTRO/#References","page":"Intro","title":"References","text":"","category":"section"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"There is no shortage of good books on Bayesian statistics. A few of my favorites are:","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Bolstad: Introduction to Bayesian statistics\nBolstad: Understanding Computational Bayesian Statistics\nGelman, Hill: Data Analysis using regression and multileve,/hierachical models\nMcElreath: Statistical Rethinking\nKruschke: Doing Bayesian Data Analysis\nLee, Wagenmakers: Bayesian Cognitive Modeling\nGelman, Carlin, and others: Bayesian Data Analysis\nCausal Inference in Statistics - A Primer\nBetancourt: A Conceptual Introduction to Hamiltonian Monte Carlo\nGelman, Carlin, and others: Bayesian Data Analysis\nPearl, Judea and MacKenzie, Dana: The Book of Why","category":"page"},{"location":"#Stan-example-programs","page":"Stan example programs","title":"Stan example programs","text":"","category":"section"},{"location":"#Examples","page":"Stan example programs","title":"Examples","text":"","category":"section"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"These are some of the common mcmc examples:","category":"page"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"ARM\nBernoulli\nBinomial\nDiagnose\nDyes\nEightSchools\nRedCardsStudy\nWalkthrough2","category":"page"},{"location":"#Examples-using-cmdstan-methods","page":"Stan example programs","title":"Examples using cmdstan methods","text":"","category":"section"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"Working with the other (not StanSample.jl based) cmdstan methods:","category":"page"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"Diagnose\nGenerate_Quantities\nOptimize\nParseandInterpolate_Example\nStanQuap\nVariational","category":"page"},{"location":"#Examples-with-special-cmdstan-input-data","page":"Stan example programs","title":"Examples with special cmdstan input data","text":"","category":"section"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"Data and input test cases:","category":"page"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"Diagnostics\nInitThetaDict\nInitRhetaDictArray\nInitThetaFile\nNamedArray\nScalarObs\nZeroLengthArray","category":"page"},{"location":"#Experimental-examples","page":"Stan example programs","title":"Experimental examples","text":"","category":"section"},{"location":"#Examples-of-using-a-cluster-to-run-Stan.jl","page":"Stan example programs","title":"Examples of using a cluster to run Stan.jl","text":"","category":"section"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"Possible ways to use a cluster.","category":"page"},{"location":"#Examples-of-solving-differential-equations-using-cmdstan","page":"Stan example programs","title":"Examples of solving differential equations using cmdstan","text":"","category":"section"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"LotkaVolterra benchmark\nLynx_hare example\nDiffEqBayes example runs","category":"page"},{"location":"#Examples-of-using-Julia-threads-model","page":"Stan example programs","title":"Examples of using Julia threads model","text":"","category":"section"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"Initial experiment with a threads formulation","category":"page"}]
}
