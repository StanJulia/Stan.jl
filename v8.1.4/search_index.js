var documenterSearchIndex = {"docs":
[{"location":"WALKTHROUGH2/#A-walk-through-example-(using-StanSample.jl)","page":"Walkthrough2","title":"A walk-through example (using StanSample.jl)","text":"","category":"section"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Make StanSample.jl available:","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"using Distributions\nusing DataFrames\nusing MonteCarloMeasurements, AxisKeys\nusing StanSample\n","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Include Distributions.jl as we'll be using that package to create an example model. This example is derived from an example in StatisticalRethinking.jl.","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Inclusion of MonteCarloMeasurements and AxisKeys in this script is for illustration purposes only (see ??read_samples in StanSample.jl).","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"It shows a few more features than the Bernoulli example in WALKTHROUGH.md.","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"N = 100\ndf = DataFrame(\n    height = rand(Normal(10, 2), N),\n    leg_prop = rand(Uniform(0.4, 0.5), N),\n)\ndf.leg_left = df.leg_prop .* df.height + rand(Normal(0, 0.02), N)\ndf.leg_right = df.leg_prop .* df.height + rand(Normal(0, 0.03), N)","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Define a variable stan6_1 to hold the Stan language model definition:","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"stan6_1 = \"\ndata {\n  int <lower=1> N;\n  vector[N] H;\n  vector[N] LL;\n  vector[N] LR;\n}\nparameters {\n  real a;\n  vector[2] b;\n  real <lower=0> sigma;\n}\nmodel {\n  vector[N] mu;\n  mu = a + b[1] * LL + b[2] * LR;\n  a ~ normal(10, 100);\n  b ~ normal(2, 10);\n  sigma ~ exponential(1);\n  H ~ normal(mu, sigma);\n}\n\";","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Create and compile a SampleModel object. By \"compile\" here is meant that SampleModel() will take care of compiling the Stan language program first to a C++ program and subsequantly compile that C++ program to an executable which will be executed in stan_sample().","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"m6_1s = SampleModel(\"m6.1s\", stan6_1);","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Above SampleModel() call creates a default model for sampling. See ?SampleModel for details.","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"The observed input data is defined below. Note here we use a NamedTuple for input:","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"data = (H = df.height, LL = df.leg_left, LR = df.leg_right, N = size(df, 1))","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Generate posterior draws by calling stan_sample(), passing in the model and optionally data, initial settings and keyword arguments to influence how cmdstan is to be called: ","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"rc6_1s = stan_sample(m6_1s; data, seed=-1, num_chains=2, delta=0.85);\n\n\nif success(rc6_1s)\n    st6_1s = read_samples(m6_1s) # By default a StanTable object is returned\n\n    # Display the schema of the tbl\n\n    st6_1s |> display\n    println()\n\n    # Display the draws\n\n    df6_1s = DataFrame(st6_1s)\n    df6_1s |> display\n    println()\n\n    # Or using a KeyedArray object from AxisKeys.jl\n\n    chns6_1s = read_samples(m6_1s, :keyedarray)\n    chns6_1s |> display\nend\n\ninit = (a = 2.0, b = [1.0, 2.0], sigma = 1.0)\nrc6_2s = stan_sample(m6_1s; data, init);\n\nif success(rc6_2s)\n\n    # Retrieve the summary created by the stansummary executable:\n\n    read_summary(m6_1s, true)\n    println()\n\n    # For simple models often a DataFrame is attractive to work with:\n\n    post6_1s_df = read_samples(m6_1s, :dataframe)\n    post6_1s_df |> display\n    println()\n\n    # Or from MonteCarloMeasurements.jl:\n    \n    part6_1s = read_samples(m6_1s, :particles)\n    part6_1s |> display\n    println()\n\n    # Use a NamedTuple:\n    \n    nt6_1s = read_samples(m6_1s, :namedtuple)\n    nt6_1s |> display\n    println()\n\n    nt6_1s.b |> display\n\n    # Compute the mean for vector b:\n\n    mean(nt6_1s.b, dims=2)\n\nend\n","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Many more examples are provided in the Example subdirectories.","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"Additional examples can be found in StanSample.jl and StatisticalRethinking.jl.","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"StatisticalRethinking.jl add features to compare models and coefficients, plotting (including trankplots() for chains) and summarizing results (precis()).","category":"page"},{"location":"WALKTHROUGH2/","page":"Walkthrough2","title":"Walkthrough2","text":"MCMCChains.jl, part of the Turing ecosystem, provides additional tools to evaluate the chains.","category":"page"},{"location":"VERSIONS/#Version-approach-and-history","page":"Versions","title":"Version approach and history","text":"","category":"section"},{"location":"VERSIONS/#Approach","page":"Versions","title":"Approach","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"A version of a Julia package is labeled (tagged) as v\"major.minor.patch\".","category":"page"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"My intention is to update the patch level whenever I make updates which are not visible to any of the existing examples.","category":"page"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"New functionality will be introduced in minor level updates. This includes adding new examples, tests and the introduction of new arguments if they default to previous behavior.","category":"page"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Changes that require updates to some examples bump the major level.","category":"page"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Updates for new releases of Julia and cmdstan bump the appropriate level.","category":"page"},{"location":"VERSIONS/#Testing","page":"Versions","title":"Testing","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"This version of the package has primarily been tested with GitHub workflows and macOS Big Sur v11.5, Julia 1.6+ and cmdstan-2.28.1.","category":"page"},{"location":"VERSIONS/#Versions","page":"Versions","title":"Versions","text":"","category":"section"},{"location":"VERSIONS/#Version-8.0.0","page":"Versions","title":"Version 8.0.0","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"This is a breaking update!","category":"page"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Change the default output format returned by read_samples to :table.\nKeyword based cmdline modification.\nRefactored code between StanBase.jl and the other StanJulia packages.\nWill need cmdstan 2.28.1 (for num_threads).\ntmpdir now positional argument when creating a CmdStanModel.\nSupports both CMDSTAN and JULIACMDSTANHOME environment variables to point to the cmdstan installation (for compatibility between cmdstan for R and Python).\nThanks to @jfb-h completed testing with using conda to install cmdstan","category":"page"},{"location":"VERSIONS/#Version-7.0","page":"Versions","title":"Version 7.0","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"This is a breaking update!","category":"page"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Use KeyedArray chains as default output format returned by read_samples.\nDrop the output_format keyword argument in favor of a regulare argument.\nRemoved mostly outdated cluster and thread based examples.\nAdded a new package DiffEqBayesStan.jl.","category":"page"},{"location":"VERSIONS/#Version-6.4","page":"Versions","title":"Version 6.4","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Default outputformat for readsamples() is now :namedtuple.\nUpdates for StanQuap\nVersion bound updates\nCmdStan is in maintenance mode, new features will be added to StanSample, etc.\nAdditional testing (by users) on Windows 10\nDoc updates\nUse of Github workflows","category":"page"},{"location":"VERSIONS/#Version-6.2-3","page":"Versions","title":"Version 6.2-3","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Updates for dependencies\nAdd several experimental examples and tests (DiffEqBayes, Cluster and Threads)\nAdd :namedtuple as an output_format\nAdd RedCardsStudy example","category":"page"},{"location":"VERSIONS/#Version-6.0","page":"Versions","title":"Version 6.0","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"This is a breaking release. Instead of by default returning an MCMCChains.Chains object, Requires.jl is used to:","category":"page"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Optional include glue code to support Chains through MCMCChains.jl.\nOptional include glue code to support DataFrames through DataFrames.jl.\nOptional include glue code to support Particles through MonteCarloMeasusrements.jl.","category":"page"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"By default stan_sample will return an \"a3d\" and optionally can also return a vector of variable names.","category":"page"},{"location":"VERSIONS/#Version-5.0.2","page":"Versions","title":"Version 5.0.2","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Tracking updates of dependencies.\nMinor docs updates (far from complete!)","category":"page"},{"location":"VERSIONS/#Version-5.0.1","page":"Versions","title":"Version 5.0.1","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Tracking updates of dependencies.","category":"page"},{"location":"VERSIONS/#Version-5.0.0","page":"Versions","title":"Version 5.0.0","text":"","category":"section"},{"location":"VERSIONS/","page":"Versions","title":"Versions","text":"Initial release of Stan.jl based on StanJulia organization packages.\nA key package that will test the new setup is StatisticalRethinking.jl. This likely will drive further fine tuning.\nSee the TODO for outstanding work items.","category":"page"},{"location":"INSTALLATION/#Stan.jl-installation","page":"Installation","title":"Stan.jl installation","text":"","category":"section"},{"location":"INSTALLATION/#Minimal-requirement","page":"Installation","title":"Minimal requirement","text":"","category":"section"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"Note: Stan.jl refers to this Julia package. Stan's executable C++ program is 'cmdstan'.","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"To install Stan.jl e.g. in the Julia REPL: ] add Stan.","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"To run this version of the Stan.jl package on your local machine, it assumes that the cmdstan executable is properly installed.","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"In order for Stan.jl to find the cmdstan you need to set the environment variable CMDSTAN (or JULIA_CMDSTAN_HOME) to point to the cmdstan directory, e.g. add","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"export CMDSTAN=/Users/rob/Projects/Stan/cmdstan\nlaunchctl setenv CMDSTAN /Users/rob/Projects/Stan/cmdstan # Mac specific","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"to your ~/.zshrc or ~/.bash_profile or simply add","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"ENV[\"CMDSTAN\"]=\"_your absolute path to cmdstan_\"","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"to ./julia/config/startup.jl. Remember to use expanduser() if you use ~ in above \"path to cmdstan\" if it is not absolute.","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"I typically prefer cmdstan not to include the cmdstan version number in the above path to cmdstan (no update needed when the cmdstan version is updated).","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"Currently tested with cmdstan 2.28.2.","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"Note: StanSample.jl v5.3, supports multithreading in the cmdstan binary and requires cmdstan v2.28.2 and up. To activate multithreading in cmdstan this needs to be specified during the build process of cmdstan. ","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"Once multithreading is included in cmdstan, set the numthreads in the call to stansample, e.g. rc = stan_sample(sm; data, num_threads=3, num_chains=2, seed=-1)","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"The default value of num_threads in the SampleModel is 4.","category":"page"},{"location":"INSTALLATION/#Conda-based-installation-walkthrough-for-running-Stan-from-Julia-on-Windows","page":"Installation","title":"Conda based installation walkthrough for running Stan from Julia on Windows","text":"","category":"section"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"Note: The conda way of installing also works on other platforms. See also.","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"Make sure you have conda installed on your system and available from the command line (you can use the conda version that comes with Conda.jl or install your own).","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"Activate the conda environment into which you want to install cmdstan (e.g. run conda activate stan-env from the command line) or create a new environment (conda create --name stan-env) and then activate it.","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"Install cmdstan into the active conda environment by running conda install -c conda-forge cmdstan.","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"You can check that cmdstan, g++, and mingw32-make are installed properly by running conda list cmdstan, g++ --version and mingw32-make --version, respectively, from the activated conda environment.","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"Start a Julia session from the conda environment in which cmdstan has been installed (this is necessary for the cmdstan installation and the tools to be found).","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"Add the StanSample.jl package by running ] add StanSample from the REPL.","category":"page"},{"location":"INSTALLATION/","page":"Installation","title":"Installation","text":"Set the CMDSTAN environment variable so that Julia can find the cmdstan installation, e.g. from the Julia REPL do: ENV[\"CMDSTAN\"] = \"C:/Users/Jakob/.julia/conda/3/envs/stan-env/Library/bin/cmdstan\" This needs to be set before you load the StanSample package by e.g. using it. You can add this line to your startup.jl file so that you don't have to run it again in every fresh Julia session.","category":"page"},{"location":"WALKTHROUGH/#A-walk-through-example-(using-StanSample.jl)","page":"Walkthrough","title":"A walk-through example (using StanSample.jl)","text":"","category":"section"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"This script assumes StanSample has been installed in your Julia environment. A better approach would be to use projects, e.g. DrWatson.jl, to manage which packages are available.","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"Make StanSample.jl available:","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"using StanSample","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"Define a 'model' to hold the Stan language program:","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"model = \"\ndata { \n  int<lower=0> N; \n  int<lower=0,upper=1> y[N];\n} \nparameters {\n  real<lower=0,upper=1> theta;\n} \nmodel {\n  theta ~ beta(1,1);\n    y ~ bernoulli(theta);\n}\n\";","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"Create and compile a SampleModel object:","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"sm = SampleModel(\"bernoulli\", model);","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"Above SampleModel() call creates a default model for sampling. See ?SampleModel for details.","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"The observed input data as a Dict:","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"data = Dict(\"N\" => 10, \"y\" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]);","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"Run a simulation by calling stan_sample(), passing in the model and data: ","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"rc = stan_sample(sm; data);\n\nif success(rc)\n  df = read_samples(sm, :dataframe);\n  df |> display\nend","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"Notice that data and init are optional keyword arguments to stan_sample(). Julia expands data to data=data or you can use data=your_data.","category":"page"},{"location":"WALKTHROUGH/","page":"Walkthrough","title":"Walkthrough","text":"A further example can be found in A walk-through example (using StanSample.jl).","category":"page"},{"location":"INTRO/#A-Julia-interface-to-Stan's-cmdstan-executable","page":"Intro","title":"A Julia interface to Stan's cmdstan executable","text":"","category":"section"},{"location":"INTRO/#Stan.jl-v8","page":"Intro","title":"Stan.jl v8","text":"","category":"section"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Stan is a system for statistical modeling, data analysis, and prediction. It is extensively used in social, biological, and physical sciences, engineering, and business. The Stan language and the interfaces to execute a Stan language program are documented here.","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Stan.jl illustrates how the packages available in StanJulia's ecosystem wrap the methods available in Stan's cmdstan executable.","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Stan.jl v8.0.0 uses the latest versions of StanSample.jl (v5), StanOptimize.jl (v3) and StanQuap.jl (v2). Both StanSample.jl (v5) and StanOptimize.jl (v3) use keyword arguments in the stan_sample() call to update the command line options for running the cmdstan binary, e.g.","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"rc = stan_sample(model; data, init, num_chains=2, seed=123, delta=0.85)","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Stan.jl v8 (and the updated StanJulia packages) are intended to use Stan's cmdstan v2.28.1 as a next step in StanJulia is to take advantage of the C++ level multi-threading options enabled in cmdstan v2.28.1.","category":"page"},{"location":"INTRO/#StanJulia-overview","page":"Intro","title":"StanJulia overview","text":"","category":"section"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Stan.jl is part of the StanJulia Github organization set of packages.","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"The use of the underlying method packages in StanJulia, i.e. StanSample.jl (the primary workhorse package), StanOptimize.jl, StanVariational.jl, StanQuap.jl and DiffEqBayesStan.jl are demonstrated in Stan.jl and in a much broader context in StatisticalRethinking.jl.","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Stan.jl is not the only Stan mcmc option in Julia. Other options are PyCall.jl/PyStan and StanRun.jl. In addition, Julia provides other, pure Julia, mcmc options such as DynamicHMC.jl, Turing.jl and Mamba.jl.","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"On a high level, a typical workflow to use Stan.jl looks like:","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"using Stan\n\n# Define a Stan language program.\nbernoulli = \"...\"\n\n# Create and compile a SampleModel, an OptimizeModel, etc.:\nsm = SampleModel(...)\n\n# Run the compiled Stan languauge program and collect draws:\nrc = stan_sample(...)\n\nif success(rc)\n\n  # Retrieve Stan's `stansummary` executable result:\n  sdf = read_summary(sm)\n\n  # Display the summary as a DataFrame:\n  sdf |> display\n\n  # Extract the draws from the SampleModel and show the schema:\n  tbl = read_samples(sm, :table)\n  tbl |> display\n\n  # Or converted to a DataFrame\n\n  DataFrame(tbl) |> display\n\n  # See below for reading in the draws directly into a DataFrame.\n\nend","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Above workflow returns a StanTable.Table object with all chains appended. ","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"If e.g. a DataFrame (with all chains appended) is preferred:","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"df = read_samples(sm, :dataframe)","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Other options are :namedtuple, :particles, :keyedarray, :dimdata, :mcmcchains, etc. See ?read_samples for more details. Walkthrough and Walkthrough2 show StanSample.jl in action.","category":"page"},{"location":"INTRO/#References","page":"Intro","title":"References","text":"","category":"section"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"There is no shortage of good books on Bayesian statistics. A few of my favorites are:","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Bolstad: Introduction to Bayesian statistics\nBolstad: Understanding Computational Bayesian Statistics\nGelman, Hill: Data Analysis using regression and multileve,/hierachical models\nMcElreath: Statistical Rethinking\nKruschke: Doing Bayesian Data Analysis\nLee, Wagenmakers: Bayesian Cognitive Modeling\nBetancourt: A Conceptual Introduction to Hamiltonian Monte Carlo\nGelman, Carlin, and others: Bayesian Data Analysis\nCausal Inference in Statistics - A Primer\nPearl, Judea and MacKenzie, Dana: The Book of Why","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Special mention is appropriate for the new book:","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"Gelman, Hill, Vehtari: Rgression and other stories","category":"page"},{"location":"INTRO/","page":"Intro","title":"Intro","text":"which in a sense is a major update to item 3. above.","category":"page"},{"location":"#Stan-example-programs","page":"Stan example programs","title":"Stan example programs","text":"","category":"section"},{"location":"#Examples","page":"Stan example programs","title":"Examples","text":"","category":"section"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"These are some of the common mcmc examples:","category":"page"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"Basic_intros\nARM\nBernoulli\nBinomial\nDiagnose\nDyes\nEightSchools\nRedCardsStudy","category":"page"},{"location":"#Examples-using-cmdstan-methods","page":"Stan example programs","title":"Examples using cmdstan methods","text":"","category":"section"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"Working with the other (not StanSample.jl based) cmdstan methods:","category":"page"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"Diagnose\nGenerate_Quantities\nOptimize\nParseandInterpolate_Example\nStanQuap\nVariational","category":"page"},{"location":"#Examples-with-special-cmdstan-input-data","page":"Stan example programs","title":"Examples with special cmdstan input data","text":"","category":"section"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"Data and input test cases:","category":"page"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"Diagnostics\nInitThetaDict\nInitRhetaDictArray\nInitThetaFile\nNamedArray\nScalarObs\nZeroLengthArray","category":"page"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"To be completed:","category":"page"},{"location":"#Examples-of-solving-differential-equations-(DiffEqBayesStan)","page":"Stan example programs","title":"Examples of solving differential equations (DiffEqBayesStan)","text":"","category":"section"},{"location":"","page":"Stan example programs","title":"Stan example programs","text":"LotkaVolterra benchmark\nLynx_hare example\nSIR model","category":"page"}]
}
