var documenterSearchIndex = {"docs": [

{
    "location": "INTRO.html#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "INTRO.html#Introduction-1",
    "page": "Introduction",
    "title": "Introduction",
    "category": "section",
    "text": ""
},

{
    "location": "INTRO.html#Stan.jl:-A-Julia-interface-to-CmdStan-1",
    "page": "Introduction",
    "title": "Stan.jl: A Julia interface to CmdStan",
    "category": "section",
    "text": "CmdStan"
},

{
    "location": "GETTINGSTARTED.html#",
    "page": "Getting started",
    "title": "Getting started",
    "category": "page",
    "text": ""
},

{
    "location": "GETTINGSTARTED.html#Getting-started-1",
    "page": "Getting started",
    "title": "Getting started",
    "category": "section",
    "text": ""
},

{
    "location": "GETTINGSTARTED.html#Minimal-requirement-1",
    "page": "Getting started",
    "title": "Minimal requirement",
    "category": "section",
    "text": "To run this version of the Stan.jl package on your local machine, it assumes that:CmdStan is properly installed.In order for Stan.jl to find the CmdStan executable you can either1.1) set the environment variable CMDSTAN_HOME to point to the CmdStan directory, e.g. addexport CMDSTAN_HOME=/Users/rob/Projects/Stan/cmdstan\nlaunchctl setenv CMDSTAN_HOME /Users/rob/Projects/Stan/cmdstanto .bash_profile. I typically prefer not to include the cmdstan version number in the path so no update is needed when CmdStan is updated.Or, alternatively,1.2) define CMDSTAN_HOME in ~/.juliarc.jl, e.g. append lines like CMDSTAN_HOME = \"/Users/rob/Projects/Stan/cmdstan\" # Choose the appropriate directory here\nJULIA_SVG_BROWSER = \"Google Chrome.app\"to ~/.juliarc.jl.On Windows this could look like:CMDSTAN_HOME = \"C:\\\\cmdstan\""
},

{
    "location": "GETTINGSTARTED.html#Optional-requirements-1",
    "page": "Getting started",
    "title": "Optional requirements",
    "category": "section",
    "text": "Stan.jl uses Mamba.jl for diagnostics and graphics.Mamba. \nGadflyBoth packages can be installed using Pkg.add(), e.g. Pkg.add(\"Mamba\"). It requires Mamba v\"0.10.0\". Mamba will install Gadfly.jl."
},

{
    "location": "GETTINGSTARTED.html#Additional-OSX-options-1",
    "page": "Getting started",
    "title": "Additional OSX options",
    "category": "section",
    "text": "Thanks to Robert Feldt and the brew/Homebrew.jl folks, on OSX, in addition to the user following the steps in Stan's CmdStan User's Guide, CmdStan can also be installed using brew or Julia's Homebrew. Executing in a terminal:\n ```\n brew tap homebrew/science\n brew install cmdstan\n ```\n should install the latest available (on Homebrew) cmdstan in /usr/local/Cellar/cmdstan/x.x.x\n \n Or, from within the Julia REPL:\n ```\n using Homebrew\n Homebrew.add(\"homebrew/science/cmdstan\")\n ```\n will install CmdStan in ~/.julia/v0.x/Homebrew/deps/usr/Cellar/cmdstan/x.x.x."
},

{
    "location": "GETTINGSTARTED.html#Selected-examples-1",
    "page": "Getting started",
    "title": "Selected examples",
    "category": "section",
    "text": "Bernoulli\nDyes\nBinormal"
},

{
    "location": "WALKTHROUGH.html#",
    "page": "Example walkthrough",
    "title": "Example walkthrough",
    "category": "page",
    "text": ""
},

{
    "location": "WALKTHROUGH.html#A-walk-through-example-1",
    "page": "Example walkthrough",
    "title": "A walk-through example",
    "category": "section",
    "text": ""
},

{
    "location": "WALKTHROUGH.html#Bernoulli-example-1",
    "page": "Example walkthrough",
    "title": "Bernoulli example",
    "category": "section",
    "text": "To run the Bernoulli example, start by concatenating the home directory and project directory:using Mamba, Stan\n\nProjDir = dirname()@__FILE)\ncd(ProjDir) do'ProjDir' is the path where permanent and transient files will be created (in a subdirectory /tmp of ProjDir).Next define the variable 'bernoullistanmodel' to hold the Stan model definition:const bernoullistanmodel = \"\ndata { \n  int<lower=0> N; \n  int<lower=0,upper=1> y[N];\n} \nparameters {\n  real<lower=0,upper=1> theta;\n} \nmodel {\n  theta ~ beta(1,1);\n    y ~ bernoulli(theta);\n}\n\"The next step is to create a Stanmodel object. The most common way to create such an object is by giving the model a name while the Stan model is passed in, both through keyword (hence optional) arguments:stanmodel = Stanmodel(name=\"bernoulli\", model=bernoullistanmodel);\nstanmodel |> displayAbove Stanmodel() call creates a default model for sampling. See the other examples for methods optimize, diagnose and variational in the Bernoulli example directory and below for some more possible Stanmodel() arguments.The input data is defined below.const bernoullidata = Dict(\"N\" => 10, \"y\" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])Run the simulation by calling stan(), passing in the data and the intended working directory. sim1 = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME)To get a summary description of the results, describe() is called (describe() is a Mamba.jl function):sim1 = stan(stanmodel, bernoullidata, ProjDir, CmdStanDir=CMDSTAN_HOME)\ndescribe(sim1)The first time (or when updates to the model or data have been made) stan() will compile the model and create the executable.On Windows, the CmdStanDir argument appears needed (this is still being investigated). On OSX/Unix CmdStanDir is obtained from either ~/.juliarc.jl or an environment variable (see the Requirements section).By default it will run 4 chains, optionally display a combined summary and returns a Mamba Chains object for a sampler. Some other Stan methods, e.g. optimize, return a dictionary.In this case 'sim1' is a Mamba Chains object. We can inspect sim1 as follows:typeof(sim1) |> display\nfieldnames(sim1) |> display\nsim1.names |> displayTo inspect the simulation results by Mamba's describe() we can't use all monitored variables by Stan. In this example a good subset is selected as follows and stored in 'sim':println(\"Subset Sampler Output\")\nsim = sim1[1:1000, [\"lp__\", \"theta\", \"accept_stat__\"], :]\ndescribe(sim)\nprintln()Notice that in this example 7 variables are read in but only 3 are used for diagnostics and posterior inference. In some cases Stan can monitor 100s or even 1000s of variables in which case it might be better to use the monitors keyword argument to stan(), see the next section for more details.The following diagnostics and Gadfly based plot functions (all from Mamba.jl) are available:println(\"Brooks, Gelman and Rubin Convergence Diagnostic\")\ntry\n  gelmandiag(sim, mpsrf=true, transform=true) |> display\ncatch e\n  #println(e)\n  gelmandiag(sim, mpsrf=false, transform=true) |> display\nend\nprintln()\n\nprintln(\"Geweke Convergence Diagnostic\")\ngewekediag(sim) |> display\nprintln()\n\nprintln(\"Highest Posterior Density Intervals\")\nhpd(sim) |> display\nprintln()\n\nprintln(\"Cross-Correlations\")\ncor(sim) |> display\nprintln()\n\nprintln(\"Lag-Autocorrelations\")\nautocor(sim) |> display\nprintln()To plot the simulation results:p = plot(sim, [:trace, :mean, :density, :autocor], legend=true);\ndraw(p, ncol=4, filename=\"summaryplot\", fmt=:svg)\ndraw(p, ncol=4, filename=\"summaryplot\", fmt=:pdf)On OSX, if e.g. JULIA_SVG_BROWSER=\"Google's Chrome.app\" is exported as an environment variable, the .svg files can be displayed as follows:if length(JULIA_SVG_BROWSER) > 0\n  @static is_apple() ? for i in 1:3\n    isfile(\"summaryplot-$(i).svg\") &&\n      run(`open -a $(JULIA_SVG_BROWSER) \"summaryplot-$(i).svg\"`)\n  end : println()\nend\n\ncd(old)"
},

{
    "location": "WALKTHROUGH.html#Running-a-Stan-script,-some-details-1",
    "page": "Example walkthrough",
    "title": "Running a Stan script, some details",
    "category": "section",
    "text": "Stan.jl really only consists of 2 functions, Stanmodel() and stan().Stanmodel() is used to define basic attributes for a model:monitor = [\"theta\", \"lp__\", \"accept_stat__\"]\nstanmodel = Stanmodel(name=\"bernoulli\", model=bernoulli, monitors=monitor);\nstanmodel\n````\nShows all parameters in the model, in this case (by default) a sample model.\n\nCompared to the call to Stanmodel() above, the keyword argument monitors has been added. This means that after the simulation is complete, only the monitored variables will be read in from the .csv file produced by Stan. This can be useful if many, e.g. 100s, nodes are being observed.stanmodel2 = Stanmodel(Sample(adapt=Adapt(delta=0.9)), name=\"bernoulli2\", nchains=6)An example of updating default model values when creating a model. The format is slightly different from CmdStan, but the parameters are as described in the CmdStan Interface User's Guide. This is also the case for the Stanmodel() optional arguments random, init and output (refresh only).\n\nNow stanmodel2 will look like:stanmodel2 ```` After the Stanmodel object has been created fields can be updated, e.g.stanmodel2.method.adapt.delta=0.85After the stan() call, the stanmodel.command contains an array of Cmd fields that contain the actual run commands for each chain. These are executed in parallel. The call to stan() might update other info in the StanModel, e.g. the names of diagnostics files.The full signature of Stanmodel() is:function Stanmodel(\n  method=Sample();\n  name=\"noname\", \n  nchains=4,\n  adapt=1000, \n  update=1000,\n  thin=1,\n  model=\"\",\n  model_file::String=\"\", \n  monitors=String[],\n  data=Dict{String, Any}[], \n  random=Random(),\n  init=Init(),\n  output=Output())All arguments have default values, although usually at least the name and model arguments will be provided.An external stan model file can be specified by leaving model=\"\" (the default value) and specifying a model_file name.Notice that 'thin' as an argument to Stanmodel() works slightly different from passing it through the Sample() argument to Stanmodel. In the first case the thinning is applied after Stan has finished, the second case asks Stan to handle the thinning. For Mamba post-processing of the results, the thin argument to Stanmodel() is the preferred option.If the method=Sample(save_warmup=true) is used, it is possible to retrieve just the warmup samples by callingread_stanfit_warmup_samples(stanmodel)After a Stanmodel has been created, the workhorse function stan() is called to run the simulation.The stan() call uses 'make' to create (or update when needed) an executable with the given model.name, e.g. bernoulli in the above example. If no model String (or of zero length) is found, a message will be shown.If the Julia REPL is started in the correct directory, stan(model) is sufficient for a model that does not require a data file. See the Binormal example.The full signature of stan() is:function stan(\n  model::Stanmodel,\n  data=Nothing, \n  ProjDir=pwd();\n  summary=true, \n  diagnostics=false, \n  StanDir=CMDSTAN_HOME)All parameters to compile and run the Stan script are implicitly passed in through the model argument. In Stan.jl v\"1.0.3\" an example has been added to show passing in parameter values to Stanmodel (see below version release note 2). The example can be found in directory Examples/BernoulliInitTheta."
},

{
    "location": "EXAMPLES.html#",
    "page": "Examples",
    "title": "Examples",
    "category": "page",
    "text": ""
},

{
    "location": "EXAMPLES.html#Examples-1",
    "page": "Examples",
    "title": "Examples",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES.html#Selected-examples-1",
    "page": "Examples",
    "title": "Selected examples",
    "category": "section",
    "text": "bernoulli.jl\ndyes.jl\nbinormal.jl"
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
    "text": "A version of a Julia package is labeled (tagged) as v\"major.minor.patch\".My intention is to update the patch level whenever I make updates to programs which are not visible to the then existing examples. This also includes adding new chapters and examples.Changes that require updates to some examples bump the minor level.Updates for new releases of Julia bump the major level."
},

{
    "location": "VERSIONS.html#Testing-1",
    "page": "Versions",
    "title": "Testing",
    "category": "section",
    "text": "This version of the package has primarily been tested on Mac OSX 10.12, Julia 0.5 and 0.6, CmdStan 2.15.0, Mamba 0.10.0 and Gadfly 0.6.1A limited amount of testing has taken place on other platforms by other users of the package (see note 1 in the 'To Do' section below)."
},

{
    "location": "VERSIONS.html#Version-2.0.0-(Currently-slated-for-late-2017-and-possibly-Julia-1.0)-1",
    "page": "Versions",
    "title": "Version 2.0.0 (Currently slated for late 2017 and possibly Julia 1.0)",
    "category": "section",
    "text": "Please see the \"Future of Stan.jl\" issue"
},

{
    "location": "VERSIONS.html#Version-1.1.0-(next)-1",
    "page": "Versions",
    "title": "Version 1.1.0 (next)",
    "category": "section",
    "text": "Thanks to Jon Alm Eriksen the performance of update_R_file() has been improved tremendously. \nA further suggestion by Michael Prange to directly write to the R file also prevents a Julia segmentation trap for very large arrays (N > 10^6).\nThanks to Maxime Rischard it is now possible for parameter values to be passed to a Stanmodel as an array of data dictionaries.\nBumped REQUIRE for Julia to v\"0.5.0\".\nFix for Stan 2.13.1 (for runs without a data file).\nAdded Marco Cox' fix for scalar data elements.\nUpdates to README suggested by Frederik Beaujean.\nFurther work on initialization with Chris Fisher\nAdded 2 tests to track outstanding CmdStan issues (#510 and #547). Slated for Stan 3.0\nFix to not depend on Homebrew on non OSX patforms\nInitiated the \"Future of Stan.jl\" discussion (Stan.jl issue #40).\nCompatible with Julia 0.6\nAdded optional keyward argument useMamba to stanmodel()\nAll test now set useMamba=false and do not depend on either Mamba or Gadfly"
},

{
    "location": "VERSIONS.html#Version-1.0.2-(currently-tagged-version)-1",
    "page": "Versions",
    "title": "Version 1.0.2 (currently tagged version)",
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
    "location": "index.html#stanmodel()-1",
    "page": "Stan.jl documentation",
    "title": "stanmodel()",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#stan()-1",
    "page": "Stan.jl documentation",
    "title": "stan()",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Mamba-diagnostics-1",
    "page": "Stan.jl documentation",
    "title": "Mamba diagnostics",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Mamba/Gadfly-graphics-1",
    "page": "Stan.jl documentation",
    "title": "Mamba/Gadfly graphics",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Index-1",
    "page": "Stan.jl documentation",
    "title": "Index",
    "category": "section",
    "text": ""
},

]}
