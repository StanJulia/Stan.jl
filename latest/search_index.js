var documenterSearchIndex = {"docs": [

{
    "location": "INTRO.html#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "INTRO.html#A-Julia-interface-to-CmdStan-1",
    "page": "Introduction",
    "title": "A Julia interface to CmdStan",
    "category": "section",
    "text": ""
},

{
    "location": "INTRO.html#Stan.jl-1",
    "page": "Introduction",
    "title": "Stan.jl",
    "category": "section",
    "text": "Stan is a system for statistical modeling, data analysis, and prediction. It is extensively used in social, biological, and physical sciences, engineering, and business. The Stan program language and interfaces are documented here.CmdStan is the shell/command line interface to run Stan language programs. Stan.jl wraps CmdStan and captures the samples for further processing."
},

{
    "location": "INTRO.html#A-few-other-MCMC-options-in-Julia-1",
    "page": "Introduction",
    "title": "A few other MCMC options in Julia",
    "category": "section",
    "text": "Mamba.jl and Klara.jl are other Julia packages to run MCMC models (in pure Julia!).Jags.jl is another option, but like CmdStan/Stan.jl, Jags runs as an external program."
},

{
    "location": "INTRO.html#References-1",
    "page": "Introduction",
    "title": "References",
    "category": "section",
    "text": "There is no shortage of good books on Bayesian statistics. A few of my favorites are:Bolstad: Introduction to Bayesian statistics\nBolstad: Understanding Computational Bayesian Statistics\nGelman, Hill: Data Analysis using regression and multileve,/hierachical models\nGelman, Carlin, and others: Bayesian Data Analysisand a great read:Betancourt: A Conceptual Introduction to Hamiltonian Monte Carlo"
},

{
    "location": "INSTALLATION.html#",
    "page": "Installation",
    "title": "Installation",
    "category": "page",
    "text": ""
},

{
    "location": "INSTALLATION.html#CmdStan-installation-1",
    "page": "Installation",
    "title": "CmdStan installation",
    "category": "section",
    "text": ""
},

{
    "location": "INSTALLATION.html#Minimal-requirement-1",
    "page": "Installation",
    "title": "Minimal requirement",
    "category": "section",
    "text": "To run this version of the Stan.jl package on your local machine, it assumes that the  CmdStan executable is properly installed.In order for Stan.jl to find the CmdStan executable you can either1.1) set the environment variable CMDSTAN_HOME to point to the CmdStan directory, e.g. addexport CMDSTAN_HOME=/Users/rob/Projects/Stan/cmdstan\nlaunchctl setenv CMDSTAN_HOME /Users/rob/Projects/Stan/cmdstanto .bash_profile. I typically prefer not to include the cmdstan version number in the path so no update is needed when CmdStan is updated.Or, alternatively,1.2) define CMDSTAN_HOME in ~/.juliarc.jl, e.g. append lines like CMDSTAN_HOME = \"/Users/rob/Projects/Stan/cmdstan\" # Choose the appropriate directory hereto ~/.juliarc.jl.On Windows this could look like:CMDSTAN_HOME = \"C:\\\\cmdstan\""
},

{
    "location": "INSTALLATION.html#Optional-requirements-1",
    "page": "Installation",
    "title": "Optional requirements",
    "category": "section",
    "text": "By default Stan.jl uses Mamba.jl for diagnostics and graphics.Mamba\nGadflyBoth packages can be installed using Pkg.add(), e.g. Pkg.add(\"Mamba\"). It requires Mamba v\"0.10.0\". Mamba will install Gadfly.jl.The Stanmodel field useMamba can be set to false to disable the use of Mamba and Gadfly."
},

{
    "location": "INSTALLATION.html#Additional-OSX-options-1",
    "page": "Installation",
    "title": "Additional OSX options",
    "category": "section",
    "text": "Thanks to Robert Feldt and the brew/Homebrew.jl folks, on OSX, in addition to the user following the steps in Stan's CmdStan User's Guide, CmdStan can also be installed using brew or Julia's Homebrew. Executing in a terminal:\n ```\n brew tap homebrew/science\n brew install cmdstan\n ```\n should install the latest available (on Homebrew) cmdstan in /usr/local/Cellar/cmdstan/x.x.x\n \n Or, from within the Julia REPL:\n ```\n using Homebrew\n Homebrew.add(\"homebrew/science/cmdstan\")\n ```\n will install CmdStan in ~/.julia/v0.x/Homebrew/deps/usr/Cellar/cmdstan/x.x.x."
},

{
    "location": "WALKTHROUGH.html#",
    "page": "Walkthrough",
    "title": "Walkthrough",
    "category": "page",
    "text": ""
},

{
    "location": "WALKTHROUGH.html#A-walk-through-example-1",
    "page": "Walkthrough",
    "title": "A walk-through example",
    "category": "section",
    "text": ""
},

{
    "location": "WALKTHROUGH.html#Bernoulli-example-1",
    "page": "Walkthrough",
    "title": "Bernoulli example",
    "category": "section",
    "text": "In this walk-through, it is assumed that 'ProjDir' holds a path to where transient files will be created (in a subdirectory /tmp of ProjDir).Make Stan.jl and Mamba diagnostics and graphics available:using Mamba, StanNext define the variable 'bernoullistanmodel' to hold the Stan model definition:const bernoullistanmodel = \"\ndata { \n  int<lower=0> N; \n  int<lower=0,upper=1> y[N];\n} \nparameters {\n  real<lower=0,upper=1> theta;\n} \nmodel {\n  theta ~ beta(1,1);\n    y ~ bernoulli(theta);\n}\n\"The next step is to create a Stanmodel object. The most common way to create such an object is by giving the model a name while the Stan model is passed in, both through keyword (hence optional) arguments:stanmodel = Stanmodel(name=\"bernoulli\", model=bernoullistanmodel);\nstanmodel |> displayAbove Stanmodel() call creates a default model for sampling. Other arguments to Stanmodel() can be found in StanmodelThe observed input data is defined below.const bernoullidata = Dict(\"N\" => 10, \"y\" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])Run the simulation by calling stan(), passing in the data and the intended working directory. rc, sim1 = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME)More documentation on stan() can be found in stanIf the return code rc indicated success (rc == 0), Mamba.jl provides the describe() function. We can't use all monitored variables by Stan. In this example a good subset is selected as below and stored in 'sim'if rc == 0\n  sim1 = stan(stanmodel, [bernoullidata], ProjDir, CmdStanDir=CMDSTAN_HOME)\n  println(\"Subset Sampler Output\")\n  sim = sim1[1:1000, [\"lp__\", \"theta\", \"accept_stat__\"], :]\n  describe(sim)\nendThe first time (or when updates to the model have been made) stan() will compile the model and create the executable.On Windows, the CmdStanDir argument appears needed (this is still being investigated). On OSX/Unix CmdStanDir is obtained from either ~/.juliarc.jl or an environment variable (see the Requirements section).By default stan() will run 4 chains, optionally display a combined summary and returns a Mamba Chains object for a sampler. Some other Stan methods, e.g. optimize, return a dictionary.The following diagnostics and Gadfly based plot functions (all from Mamba.jl) are available:println(\"Brooks, Gelman and Rubin Convergence Diagnostic\")\ntry\n  gelmandiag(sim, mpsrf=true, transform=true) |> display\ncatch e\n  #println(e)\n  gelmandiag(sim, mpsrf=false, transform=true) |> display\nend\nprintln()\n\nprintln(\"Geweke Convergence Diagnostic\")\ngewekediag(sim) |> display\nprintln()\n\nprintln(\"Highest Posterior Density Intervals\")\nhpd(sim) |> display\nprintln()\n\nprintln(\"Cross-Correlations\")\ncor(sim) |> display\nprintln()\n\nprintln(\"Lag-Autocorrelations\")\nautocor(sim) |> display\nprintln()To plot the simulation results:p = plot(sim, [:trace, :mean, :density, :autocor], legend=true);\ndraw(p, ncol=4, filename=\"summaryplot\", fmt=:svg)\ndraw(p, ncol=4, filename=\"summaryplot\", fmt=:pdf)"
},

{
    "location": "WALKTHROUGH.html#Running-a-Stan-script,-some-details-1",
    "page": "Walkthrough",
    "title": "Running a Stan script, some details",
    "category": "section",
    "text": "Stan.jl really only consists of 2 functions, Stanmodel() and stan()."
},

{
    "location": "WALKTHROUGH.html#[Stanmodel](@ref)-1",
    "page": "Walkthrough",
    "title": "Stanmodel",
    "category": "section",
    "text": "Stanmodel() is used to define the basic attributes for a model:monitor = [\"theta\", \"lp__\", \"accept_stat__\"]\nstanmodel = Stanmodel(name=\"bernoulli\", model=bernoulli, monitors=monitor);\nstanmodelAbove script, in the Julia REPL, shows all parameters in the model, in this case (by default) a sample model.Compared to the call to Stanmodel() above, the keyword argument monitors has been added. This means that after the simulation is complete, only the monitored variables will be read in from the .csv file produced by Stan. This can be useful if many, e.g. 100s, nodes are being observed.stanmodel2 = Stanmodel(Sample(adapt=Adapt(delta=0.9)), name=\"bernoulli2\", nchains=6)An example of updating default model values when creating a model. The format is slightly different from CmdStan, but the parameters are as described in the CmdStan Interface User's Guide. This is also the case for the Stanmodel() optional arguments random, init and output (refresh only).Now, in the REPL, the stanmodel2 can be shown by:stanmodel2After the Stanmodel object has been created fields can be updated, e.g.stanmodel2.method.adapt.delta=0.85"
},

{
    "location": "WALKTHROUGH.html#[stan](@ref)-1",
    "page": "Walkthrough",
    "title": "stan",
    "category": "section",
    "text": "After a Stanmodel has been created, the workhorse function stan() is called to run the simulation. Note that some fields in the Stanmodel are updated by stan().After the stan() call, the stanmodel.command contains an array of Cmd fields that contain the actual run commands for each chain. These are executed in parallel if that is possible. The call to stan() might update other info in the StanModel, e.g. the names of diagnostics files.The stan() call uses 'make' to create (or update when needed) an executable with the given model.name, e.g. bernoulli in the above example. If no model String (or of zero length) is found, a message will be shown."
},

{
    "location": "VERSIONS.html#",
    "page": "Versions",
    "title": "Versions",
    "category": "page",
    "text": ""
},

{
    "location": "VERSIONS.html#Version-approach-and-history-1",
    "page": "Versions",
    "title": "Version approach and history",
    "category": "section",
    "text": ""
},

{
    "location": "VERSIONS.html#Approach-1",
    "page": "Versions",
    "title": "Approach",
    "category": "section",
    "text": "A version of a Julia package is labeled (tagged) as v\"major.minor.patch\".My intention is to update the patch level whenever I make updates which are not visible to any of the existing examples.New functionality will be introduced in minor level updates. This includes adding new examples, tests and the introduction of new arguments if they default to previous behavior, e.g. in v\"1.1.0\" the useMamba and init arguments to Stanmodel().Changes that require updates to some examples bump the major level.Updates for new releases of Julia and CmdStan bump the appropriate level."
},

{
    "location": "VERSIONS.html#Testing-1",
    "page": "Versions",
    "title": "Testing",
    "category": "section",
    "text": "This version of the package has primarily been tested on Mac OSX 10.12, Julia 0.5 and 0.6, CmdStan 2.15.0, Mamba 0.10.0 and Gadfly 0.6.1.Note that at this point in time Mamba and Gadfly are not yet available for Julia 0.6-RC1, thus only the NoMamba examples will work on Julia 0.6-RC1. Once Mamba and Gadfly are available for Julia 0.6 I will bump the Stan.jl version.A limited amount of testing has taken place on other platforms by other users of the package."
},

{
    "location": "VERSIONS.html#Version-2.0.0-1",
    "page": "Versions",
    "title": "Version 2.0.0",
    "category": "section",
    "text": "Compatible with Julia 0.6.\nAdded optional keyward argument useMamba to stanmodel().\nAll test now set useMamba=false and do not depend on either Mamba or Gadfly.\nTamas Papp figured out how to install CmdStan on Travis! This allows proper testing of Stan.jl on various unix/linux versions. Currently Travis tests Julia 0.5, 0.6 and nightlies on both linux and OSX.\nComplete documentation (initial version, will take additional work).\nStreamline R file creation for observed data and initialization values.\nImprove error catching."
},

{
    "location": "VERSIONS.html#Breaking-changes:-1",
    "page": "Versions",
    "title": "Breaking changes:",
    "category": "section",
    "text": "Parameter initialization values (for parameters in the parameter block) are now passed in as an optional keyword argument to stan(). See BernoulliInitTheta for an example.\nThe main execution method, stan(), now returns a tuple consisting of a return code and the simulation results.\nThe simulation results can either be in the form of Mamba.Chains or as a Array of values (the latter if the argument useMamba=false is added to Stanmodel())."
},

{
    "location": "VERSIONS.html#Version-1.1.0-1",
    "page": "Versions",
    "title": "Version 1.1.0",
    "category": "section",
    "text": "Please see the \"Future of Stan.jl\" issue.Thanks to Jon Alm Eriksen the performance of update_R_file() has been improved tremendously. \nA further suggestion by Michael Prange to directly write to the R file also prevents a Julia segmentation trap for very large arrays (N > 10^6).\nThanks to Maxime Rischard it is now possible for parameter values to be passed to a Stanmodel as an array of data dictionaries.\nBumped REQUIRE for Julia to v\"0.5.0\".\nFix for Stan 2.13.1 (for runs without a data file).\nAdded Marco Cox' fix for scalar data elements.\nUpdates to README suggested by Frederik Beaujean.\nFurther work on initialization with Chris Fisher. Added keyword init to Stanmodel(). This needs further work, see below under outstanding issues.\nAdded 2 tests to track outstanding CmdStan issues (#510 and #547). Slated for Stan 3.0\nFix to not depend on Homebrew on non OSX patforms\nInitiated the \"Future of Stan.jl\" discussion (Stan.jl issue #40)."
},

{
    "location": "VERSIONS.html#Version-1.0.2-1",
    "page": "Versions",
    "title": "Version 1.0.2",
    "category": "section",
    "text": "Bumped REQUIRE for Julia to v\"0.5.0-rc3\"\nUpdated Homebrew section as CmdStan 2.11.0 is now available from Homebrew\nUpdated .travis.yml to just test on Julia 0.5"
},

{
    "location": "VERSIONS.html#Version-1.0.0-1",
    "page": "Versions",
    "title": "Version 1.0.0",
    "category": "section",
    "text": "Tested with Stan 2.11.0 (fixed a change in the diagnose .csv file format)\nUpdated how CMDSTAN_HOME is retrieved from ENV (see also REQUIREMENTS section below)\nRequires Julia 0.5\nRequires Mamba 0.10.0\nMamba needs updates to Graphs.jl (will produce warnings otherwise)"
},

{
    "location": "VERSIONS.html#Version-0.3.2-1",
    "page": "Versions",
    "title": "Version 0.3.2",
    "category": "section",
    "text": "Cleaned up message in Pkg.test(\"Stan\")\nAdded experimental use of Mamba.contour() to bernoulli.jl (this requires Mamba 0.7.1+)\nIntroduce the use of Homebrew to install CmdStan on OSX\nPkg.test(\"Stan\") will give an error on variational bayes\nLast version update for Julia 0.4"
},

{
    "location": "index.html#",
    "page": "Stan.jl documentation",
    "title": "Stan.jl documentation",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Programs-1",
    "page": "Stan.jl documentation",
    "title": "Programs",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Stan.CMDSTAN_HOME",
    "page": "Stan.jl documentation",
    "title": "Stan.CMDSTAN_HOME",
    "category": "Constant",
    "text": "The directory which contains the CmdStan executables such as bin/stanc and  bin/stansummary. Inferred from Main.CMDSTAN_HOME or ENV[\"CMDSTAN_HOME\"] when available. Use set_cmdstan_home! to modify.\n\n\n\n"
},

{
    "location": "index.html#CMDSTAN_HOME-1",
    "page": "Stan.jl documentation",
    "title": "CMDSTAN_HOME",
    "category": "section",
    "text": "CMDSTAN_HOME"
},

{
    "location": "index.html#Stan.set_cmdstan_home!",
    "page": "Stan.jl documentation",
    "title": "Stan.set_cmdstan_home!",
    "category": "Function",
    "text": "Set the path for the CMDSTAN_HOME environment variable.\n\nExample: set_cmdstan_home!(homedir() * \"/Projects/Stan/cmdstan/\")\n\n\n\n"
},

{
    "location": "index.html#set_cmdstan_home!-1",
    "page": "Stan.jl documentation",
    "title": "set_cmdstan_home!",
    "category": "section",
    "text": "set_cmdstan_home!"
},

{
    "location": "index.html#Stan.Stanmodel",
    "page": "Stan.jl documentation",
    "title": "Stan.Stanmodel",
    "category": "Type",
    "text": "Method Stanmodel\n\nCreate a Stanmodel. \n\nConstructors\n\nStanmodel(\n  method=Sample();\n  name=\"noname\", \n  nchains=4,\n  num_warmup=1000, \n  num_samples=1000,\n  thin=1,\n  model=\"\",\n  monitors=String[],\n  data=DataDict[],\n  random=Random(),\n  init=DataDict[],\n  output=Output(),\n  pdir::String=pwd(),\n  useMamba=true,\n  mambaThinning=1\n)\n\n\nRequired arguments\n\n* `method::Method`            : See ?Method\n\nOptional arguments\n\n* `name::String`               : Name for the model\n* `nchains::Int`               : Number of chains, if possible execute in parallel\n* `num_warmup::Int`            : Number of samples used for num_warmupation \n* `num_samples::Int`           : Sample iterations\n* `thin::Int`                  : Stan thinning factor\n* `model::String`              : Stan program source\n* `data::DataDict[]`           : Observed input data as an array of Dicts\n* `random::Random`             : Random seed settings\n* `init::DataDict[]`           : Initial values for parameters in parameter block\n* `output::Output`             : File output options\n* `pdir::String`               : Working directory\n* `monitors::String[] `        : Filter for variables used in Mamba post-processing\n* `useMamba::Bool`             : Use Mamba Chains for diagnostics and graphics\n* `mambaThinning::Int`         : Additional thinning factor in Mamba Chains\n\nExample\n\nbernoullimodel = \"\ndata { \n  int<lower=1> N; \n  int<lower=0,upper=1> y[N];\n} \nparameters {\n  real<lower=0,upper=1> theta;\n} \nmodel {\n  theta ~ beta(1,1);\n  y ~ bernoulli(theta);\n}\n\"\n\nstanmodel = Stanmodel(num_samples=1200, thin=2, name=\"bernoulli\", model=bernoullimodel);\n\nRelated help\n\n?stan                          : Run a Stanmodel\n?Sample                        : Sampling settings\n?Method                       : List of available methods\n?Output                        : Output file settings\n?DataDict                      : Input data dictionaries, will be converted to R syntax\n\n\n\n"
},

{
    "location": "index.html#Stan.update_model_file",
    "page": "Stan.jl documentation",
    "title": "Stan.update_model_file",
    "category": "Function",
    "text": "Method update_model_file\n\nUpdate Stan language model file if necessary \n\nMethod\n\nupdate_model_file(\n  file::String, \n  str::String\n)\n\nRequired arguments\n\n* `file::String`                : File holding existing Stan model\n* `str::String`                 : Stan model string\n\nRelated help\n\n?Stan.Stanmodel                 : Create a StanModel\n\n\n\n"
},

{
    "location": "index.html#stanmodel()-1",
    "page": "Stan.jl documentation",
    "title": "stanmodel()",
    "category": "section",
    "text": "Stanmodel\nStan.update_model_file"
},

{
    "location": "index.html#Stan.stan",
    "page": "Stan.jl documentation",
    "title": "Stan.stan",
    "category": "Function",
    "text": "stan\n\nExecute a Stan model. \n\nMethod\n\nrc, sim = stan(\n  model::Stanmodel, \n  data=Void, \n  ProjDir=pwd();\n  init=Void,\n  summary=true, \n  diagnostics=false, \n  CmdStanDir=CMDSTAN_HOME\n)\n\nRequired arguments\n\n* `model::Stanmodel`              : See ?Method\n* `data=Void`                     : Observed input data dictionary \n* `ProjDir=pwd()`                 : Project working directory\n\nOptional arguments\n\n* `init=Void`                     : Initial parameter value dictionary\n* `summary=true`                  : Use CmdStan's stansummary to display results\n* `diagnostics=false`             : Generate diagnostics file\n* `CmdStanDir=CMDSTAN_HOME`       : Location of CmdStan directory\n\nReturn values\n\n* `rc::Int`                       : Return code from stan(), rc == 0 if all is well\n* `sim`                           : Chain results\n\nRelated help\n\n?Stanmodel                      : Create a StanModel\n\n\n\n"
},

{
    "location": "index.html#Stan.stan_summary-Tuple{Cmd}",
    "page": "Stan.jl documentation",
    "title": "Stan.stan_summary",
    "category": "Method",
    "text": "Method stan_summary\n\nDisplay CmdStan summary \n\nMethod\n\nstan_summary(\n  filecmd::Cmd; \n  CmdStanDir=CMDSTAN_HOME\n)\n\nRequired arguments\n\n* `filecmd::Cmd`                : Run command containing names of sample files\n\nOptional arguments\n\n* CmdStanDir=CMDSTAN_HOME       : CmdStan directory for stansummary program\n\nRelated help\n\n?Stan.stan                      : Create a StanModel\n\n\n\n"
},

{
    "location": "index.html#Stan.stan_summary-Tuple{String}",
    "page": "Stan.jl documentation",
    "title": "Stan.stan_summary",
    "category": "Method",
    "text": "Method stan_summary\n\nDisplay CmdStan summary \n\nMethod\n\nstan_summary(\n  file::String; \n  CmdStanDir=CMDSTAN_HOME\n)\n\nRequired arguments\n\n* `file::String`                : Name of file with samples\n\nOptional arguments\n\n* CmdStanDir=CMDSTAN_HOME       : CmdStan directory for stansummary program\n\nRelated help\n\n?Stan.stan                      : Execute a StanModel\n\n\n\n"
},

{
    "location": "index.html#stan()-1",
    "page": "Stan.jl documentation",
    "title": "stan()",
    "category": "section",
    "text": "stan\nStan.stan_summary(filecmd::Cmd; CmdStanDir=CMDSTAN_HOME)\nStan.stan_summary(file::String; CmdStanDir=CMDSTAN_HOME)"
},

{
    "location": "index.html#Stan.Method",
    "page": "Stan.jl documentation",
    "title": "Stan.Method",
    "category": "Type",
    "text": "Available top level Method\n\nMethod\n\n*  Sample::Method             : Sampling\n*  Optimize::Method           : Optimization\n*  Diagnose::Method           : Diagnostics\n*  Variational::Method        : Variational Bayes\n\n\n\n"
},

{
    "location": "index.html#Stan.Sample",
    "page": "Stan.jl documentation",
    "title": "Stan.Sample",
    "category": "Type",
    "text": "Sample type and constructor\n\nSettings for method=Sample() in Stanmodel. \n\nMethod\n\nSample(;\n  num_samples=1000,\n  num_warmup=1000,\n  save_warmup=false,\n  thin=1,\n  adapt=Adapt(),\n  algorithm=SamplingAlgorithm()\n)\n\nOptional arguments\n\n* `num_samples::Int64`          : Number of sampling iterations ( >= 0 )\n* `num_warmup::Int64`           : Number of warmup iterations ( >= 0 )\n* `save_warmup::Bool`           : Include warmup samples in output\n* `thin::Int64`                 : Period between saved samples\n* `adapt::Adapt`                : Warmup adaptation settings\n* `algorithm::SamplingAlgorithm`: Sampling algorithm\n\n\nRelated help\n\n?Stanmodel                      : Create a StanModel\n?Adapt\n?SamplingAlgorithm\n\n\n\n"
},

{
    "location": "index.html#Stan.Adapt",
    "page": "Stan.jl documentation",
    "title": "Stan.Adapt",
    "category": "Type",
    "text": "Adapt type and constructor\n\nSettings for adapt=Adapt() in Sample(). \n\nMethod\n\nAdapt(;\n  engaged=true,\n  gamma=0.05,\n  delta=0.8,\n  kappa=0.75,\n  t0=10.0,\n  init_buffer=75,\n  term_buffer=50,\n  window::25\n)\n\nOptional arguments\n\n* `engaged::Bool`              : Adaptation engaged?\n* `gamma::Float64`             : Adaptation regularization scale\n* `delta::Float64`             : Adaptation target acceptance statistic\n* `kappa::Float64`             : Adaptation relaxation exponent\n* `t0::Float64`                : Adaptation iteration offset\n* `init_buffer::Int64`         : Width of initial adaptation interval\n* `term_buffer::Int64`         : Width of final fast adaptation interval\n* `window::Int64`              : Initial width of slow adaptation interval\n\nRelated help\n\n?Sample                        : Sampling settings\n\n\n\n"
},

{
    "location": "index.html#Stan.SamplingAlgorithm",
    "page": "Stan.jl documentation",
    "title": "Stan.SamplingAlgorithm",
    "category": "Type",
    "text": "Available sampling algorithms\n\nCurrently limited to Hmc().\n\n\n\n"
},

{
    "location": "index.html#Stan.Hmc",
    "page": "Stan.jl documentation",
    "title": "Stan.Hmc",
    "category": "Type",
    "text": "Hmc type and constructor\n\nSettings for algorithm=Hmc() in Sample(). \n\nMethod\n\nHmc(;\n  engine=Nuts(),\n  metric=Stan.diag_e,\n  stepsize=1.0,\n  stepsize_jitter=1.0\n)\n\nOptional arguments\n\n* `engine::Engine`            : Engine for Hamiltonian Monte Carlo\n* `metric::Metric`            : Geometry for base manifold\n* `stepsize::Float64`         : Stepsize for discrete evolutions\n* `stepsize_jitter::Float64`  : Uniform random jitter of the stepsize [%]\n\nRelated help\n\n?Sample                        : Sampling settings\n?Engine                        : Engine for Hamiltonian Monte Carlo\n?Nuts                          : Settings for Nuts\n?Static                        : Settings for Static\n?Metric                        : Base manifold geometries\n\n\n\n"
},

{
    "location": "index.html#Stan.Metric",
    "page": "Stan.jl documentation",
    "title": "Stan.Metric",
    "category": "Type",
    "text": "Metric types\n\nGeometry of base manifold\n\nTypes defined\n\n* unit_e::Metric      : Euclidean manifold with unit metric\n* dense_e::Metric     : Euclidean manifold with dense netric\n* diag_e::Metric      : Euclidean manifold with diag netric\n\n\n\n"
},

{
    "location": "index.html#Stan.Engine",
    "page": "Stan.jl documentation",
    "title": "Stan.Engine",
    "category": "Type",
    "text": "Engine types\n\nEngine for Hamiltonian Monte Carlo\n\nTypes defined\n\n* Nuts       : No-U-Tyrn sampler\n* Static     : Static integration time\n\n\n\n"
},

{
    "location": "index.html#Stan.Nuts",
    "page": "Stan.jl documentation",
    "title": "Stan.Nuts",
    "category": "Type",
    "text": "Nuts type and constructor\n\nSettings for engine=Nuts() in Hmc(). \n\nMethod\n\nNuts(;max_depth=10)\n\nOptional arguments\n\n* `max_depth::Number`           : Maximum tree depth\n\nRelated help\n\n?Sample                        : Sampling settings\n?Engine                        : Engine for Hamiltonian Monte Carlo\n\n\n\n"
},

{
    "location": "index.html#Stan.Static",
    "page": "Stan.jl documentation",
    "title": "Stan.Static",
    "category": "Type",
    "text": "Static type and constructor\n\nSettings for engine=Static() in Hmc(). \n\nMethod\n\nStatic(;int_time=2 * pi)\n\nOptional arguments\n\n* `;int_time::Number`          : Static integration time\n\nRelated help\n\n?Sample                        : Sampling settings\n?Engine                        : Engine for Hamiltonian Monte Carlo\n\n\n\n"
},

{
    "location": "index.html#Stan.Diagnostics",
    "page": "Stan.jl documentation",
    "title": "Stan.Diagnostics",
    "category": "Type",
    "text": "Available method diagnostics\n\nCurrently limited to Gradient().\n\n\n\n"
},

{
    "location": "index.html#Stan.Gradient",
    "page": "Stan.jl documentation",
    "title": "Stan.Gradient",
    "category": "Type",
    "text": "Gradient type and constructor\n\nSettings for diagnostic=Gradient() in Diagnose(). \n\nMethod\n\nGradient(;epsilon=1e-6, error=1e-6)\n\nOptional arguments\n\n* `epsilon::Float64`           : Finite difference step size\n* `error::Float64`             : Error threshold\n\nRelated help\n\n?Diagnose                      : Diagnostic method\n\n\n\n"
},

{
    "location": "index.html#Stan.Diagnose",
    "page": "Stan.jl documentation",
    "title": "Stan.Diagnose",
    "category": "Type",
    "text": "Diagnose type and constructor\n\nMethod\n\nDiagnose(;d=Gradient())\n\nOptional arguments\n\n* `d::Diagnostics`            : Finite difference step size\n\nRelated help\n\n```julia ?Diagnostics                  : Diagnostic methods ?Gradient                     : Currently sole diagnostic method\n\n\n\n"
},

{
    "location": "index.html#Stan.OptimizeAlgorithm",
    "page": "Stan.jl documentation",
    "title": "Stan.OptimizeAlgorithm",
    "category": "Type",
    "text": "OptimizeAlgorithm types\n\nTypes defined\n\n* Lbfgs::OptimizeAlgorithm   : Euclidean manifold with unit metric\n* Bfgs::OptimizeAlgorithm    : Euclidean manifold with unit metric\n* Newton::OptimizeAlgorithm  : Euclidean manifold with unit metric\n\n\n\n"
},

{
    "location": "index.html#Stan.Optimize",
    "page": "Stan.jl documentation",
    "title": "Stan.Optimize",
    "category": "Type",
    "text": "Optimize type and constructor\n\nSettings for Optimize top level method. \n\nMethod\n\nOptimize(;\n  method=Lbfgs(),\n  iter=2000,\n  save_iterations=false\n)\n\nOptional arguments\n\n* `method::OptimizeMethod`      : Optimization algorithm\n* `iter::Int`                   : Total number of iterations\n* `save_iterations::Bool`       : Stream optimization progress to output\n\nRelated help\n\n?Stanmodel                      : Create a StanModel\n?OptimizeAlgorithm              : Available algorithms\n\n\n\n"
},

{
    "location": "index.html#Stan.Lbfgs",
    "page": "Stan.jl documentation",
    "title": "Stan.Lbfgs",
    "category": "Type",
    "text": "Lbfgs type and constructor\n\nSettings for method=Lbfgs() in Optimize(). \n\nMethod\n\nLbfgs(;init_alpha=0.001, tol_obj=1e-8, tol_grad=1e-8, tol_param=1e-8, history_size=5)\n\nOptional arguments\n\n* `init_alpha::Float64`        : Linear search step size for first iteration\n* `tol_obj::Float64`           : Convergence tolerance for objective function\n* `tol_rel_obj::Float64`       : Relative change tolerance in objective function\n* `tol_grad::Float64`          : Convergence tolerance on norm of gradient\n* `tol_rel_grad::Float64`      : Relative change tolerance on norm of gradient\n* `tol_param::Float64`         : Convergence tolerance on parameter values\n* `history_size::Int`          : No of update vectors to use in Hessian approx\n\nRelated help\n\n?OptimizeMethod               : List of available optimize methods\n?Optimize                      : Optimize arguments\n\n\n\n"
},

{
    "location": "index.html#Stan.Bfgs",
    "page": "Stan.jl documentation",
    "title": "Stan.Bfgs",
    "category": "Type",
    "text": "Bfgs type and constructor\n\nSettings for method=Bfgs() in Optimize(). \n\nMethod\n\nBfgs(;init_alpha=0.001, tol_obj=1e-8, tol_rel_obj=1e4, \n  tol_grad=1e-8, tol_rel_grad=1e7, tol_param=1e-8)\n\nOptional arguments\n\n* `init_alpha::Float64`        : Linear search step size for first iteration\n* `tol_obj::Float64`           : Convergence tolerance for objective function\n* `tol_rel_obj::Float64`       : Relative change tolerance in objective function\n* `tol_grad::Float64`          : Convergence tolerance on norm of gradient\n* `tol_rel_grad::Float64`      : Relative change tolerance on norm of gradient\n* `tol_param::Float64`         : Convergence tolerance on parameter values\n\nRelated help\n\n?OptimizeMethod               : List of available optimize methods\n?Optimize                      : Optimize arguments\n\n\n\n"
},

{
    "location": "index.html#Stan.Newton",
    "page": "Stan.jl documentation",
    "title": "Stan.Newton",
    "category": "Type",
    "text": "Newton type and constructor\n\nSettings for method=Newton() in Optimize(). \n\nMethod\n\nNewton()\n\nRelated help\n\n?OptimizeMethod               : List of available optimize methods\n?Optimize                      : Optimize arguments\n\n\n\n"
},

{
    "location": "index.html#Stan.Variational",
    "page": "Stan.jl documentation",
    "title": "Stan.Variational",
    "category": "Type",
    "text": "Variational type and constructor\n\nSettings for method=Variational() in Stanmodel. \n\nMethod\n\nVariational(;\n  grad_samples=1,\n  elbo_samples=100,\n  eta_adagrad=0.1,\n  iter=10000,\n  tol_rel_obj=0.01,\n  eval_elbo=100,\n  algorithm=:meanfield,          \n  output_samples=10000\n)\n\nOptional arguments\n\n* `algorithm::Symbol`             : Variational inference algorithm\n                                    :meanfiedl;\n                                    :fullrank\n* `iter::Int64`                   : Maximum number of iterations\n* `grad_samples::Int`             : No of samples for MC estimate of gradients\n* `elbo_samples::Int`             : No of samples for MC estimate of ELBO\n* `eta::Float64`                  : Stepsize weighing parameter for adaptive sequence\n* `adapt::Adapt`                  : Warmupadaptations\n* `tol_rel_obj::Float64`          : Tolerance on the relative norm of objective\n* `eval_elbo::Int`                : Tolerance on the relative norm of objective\n* `output_samples::Int`           : Numberof posterior samples to draw and save\n\nRelated help\n\n?Stanmodel                      : Create a StanModel\n?Stan.Method                   : Available top level methods\n?Stan.Adapt                     : Adaptation settings\n\n\n\n"
},

{
    "location": "index.html#Types-1",
    "page": "Stan.jl documentation",
    "title": "Types",
    "category": "section",
    "text": "Stan.Method\nStan.Sample\nStan.Adapt\nStan.SamplingAlgorithm\nStan.Hmc\nStan.Metric\nStan.Engine\nStan.Nuts\nStan.Static\nStan.Diagnostics\nStan.Gradient\nStan.Diagnose\nStan.OptimizeAlgorithm\nStan.Optimize\nStan.Lbfgs\nStan.Bfgs\nStan.Newton\nStan.Variational"
},

{
    "location": "index.html#Stan.cmdline",
    "page": "Stan.jl documentation",
    "title": "Stan.cmdline",
    "category": "Function",
    "text": "cmdline\n\nRecursively parse the model to construct command line. \n\nMethod\n\ncmdline(m)\n\nRequired arguments\n\n* `m::Stanmodel`                : Stanmodel\n\nRelated help\n\n?Stanmodel                      : Create a StanModel\n\n\n\n"
},

{
    "location": "index.html#Stan.check_dct_type",
    "page": "Stan.jl documentation",
    "title": "Stan.check_dct_type",
    "category": "Function",
    "text": "check_dct_type\n\nCheck if dct == Dict{String, Any}[] and has length > 0. \n\nMethod\n\ncheck_dct_type(dct)\n\nRequired arguments\n\n* `dct::Dict{String, Any}`      : Observed data or parameter init data\n\n\n\n"
},

{
    "location": "index.html#Stan.update_R_file",
    "page": "Stan.jl documentation",
    "title": "Stan.update_R_file",
    "category": "Function",
    "text": "update_R_file\n\nRewrite a dictionary of observed data or initial parameter values in R dump file format to a file. \n\nMethod\n\nupdate_R_file{T<:Any}(file, dct)\n\nRequired arguments\n\n* `file::String`                : R file name\n* `dct::Dict{String, T}`        : Dictionary to format in R\n\n\n\n"
},

{
    "location": "index.html#Stan.par",
    "page": "Stan.jl documentation",
    "title": "Stan.par",
    "category": "Function",
    "text": "par\n\nRewrite dct to R format in file. \n\nMethod\n\npar(cmds)\n\nRequired arguments\n\n* `cmds::Array{Base.AbstractCmd,1}`    : Multiple commands to concatenate\n\nor\n\n* `cmd::Base.AbstractCmd`              : Single command to be\n* `n::Number`                            inserted n times into cmd\n\n\nor\n* `cmd::Array{String, 1}`              : Array of cmds as Strings\n\n\n\n"
},

{
    "location": "index.html#Stan.read_stanfit-Tuple{Stan.Stanmodel}",
    "page": "Stan.jl documentation",
    "title": "Stan.read_stanfit",
    "category": "Method",
    "text": "read_stanfit\n\nRewrite dct to R format in file. \n\nMethod\n\npar(cmds)\n\nRequired arguments\n\n* `cmds::Array{Base.AbstractCmd,1}`    : Multiple commands to concatenate\n\nor\n\n* `cmd::Base.AbstractCmd`              : Single command to be\n* `n::Number`                            inserted n times into cmd\n\n\nor\n* `cmd::Array{String, 1}`              : Array of cmds as Strings\n\n\n\n"
},

{
    "location": "index.html#Utilities-1",
    "page": "Stan.jl documentation",
    "title": "Utilities",
    "category": "section",
    "text": "Stan.cmdline\nStan.check_dct_type\nStan.update_R_file\nStan.par\nStan.read_stanfit(model::Stanmodel)"
},

{
    "location": "index.html#Index-1",
    "page": "Stan.jl documentation",
    "title": "Index",
    "category": "section",
    "text": ""
},

]}
