var documenterSearchIndex = {"docs": [

{
    "location": "INTRO/#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "INTRO/#A-Julia-interface-to-CmdStan-1",
    "page": "Home",
    "title": "A Julia interface to CmdStan",
    "category": "section",
    "text": ""
},

{
    "location": "INTRO/#Stan.jl-1",
    "page": "Home",
    "title": "Stan.jl",
    "category": "section",
    "text": "Stan is a system for statistical modeling, data analysis, and prediction. It is extensively used in social, biological, and physical sciences, engineering, and business. The Stan program language and interfaces are documented here.CmdStan is the shell/command line interface to run Stan language programs. Stan.jl wraps CmdStan and captures the samples for further processing."
},

{
    "location": "INTRO/#Table-of-contents-1",
    "page": "Home",
    "title": "Table of contents",
    "category": "section",
    "text": ""
},

{
    "location": "INTRO/#Examples-1",
    "page": "Home",
    "title": "Examples",
    "category": "section",
    "text": "ARM kids example\nBernoulli..."
},

{
    "location": "INTRO/#Examples-showing-cmdstan-methods-1",
    "page": "Home",
    "title": "Examples showing cmdstan methods",
    "category": "section",
    "text": "Diagnose\nGenerate_Quantities\nOptimize\nParseandInterpolate_Example\nVariational\nNuts sampling diagnose using the diagnose binary..."
},

{
    "location": "INTRO/#Examples-added-to-test-special-cases-1",
    "page": "Home",
    "title": "Examples added to test special cases",
    "category": "section",
    "text": "Init using a single Dict\nInit with an Array{Dict, 1}\nInit using a .R file..."
},

{
    "location": "INTRO/#References-1",
    "page": "Home",
    "title": "References",
    "category": "section",
    "text": "There is no shortage of good books on Bayesian statistics. A few of my favorites are:Bolstad: Introduction to Bayesian statistics\nBolstad: Understanding Computational Bayesian Statistics\nGelman, Hill: Data Analysis using regression and multileve,/hierachical models\nGelman, Carlin, and others: Bayesian Data Analysisand a great read:Betancourt: A Conceptual Introduction to Hamiltonian Monte Carlo"
},

{
    "location": "INSTALLATION/#",
    "page": "Installation",
    "title": "Installation",
    "category": "page",
    "text": ""
},

{
    "location": "INSTALLATION/#Cmdstan-installation-1",
    "page": "Installation",
    "title": "Cmdstan installation",
    "category": "section",
    "text": ""
},

{
    "location": "INSTALLATION/#Minimal-requirement-1",
    "page": "Installation",
    "title": "Minimal requirement",
    "category": "section",
    "text": "To run this version of the Stan.jl package on your local machine, it assumes that the  cmdstan executable is properly installed."
},

{
    "location": "WALKTHROUGH/#",
    "page": "Walkthrough",
    "title": "Walkthrough",
    "category": "page",
    "text": ""
},

{
    "location": "WALKTHROUGH/#A-walk-through-example-1",
    "page": "Walkthrough",
    "title": "A walk-through example",
    "category": "section",
    "text": "Make StanSample.jl available:using StanSampleDefine a variable \'model\' to hold the Stan language model definition:model = \"\ndata { \n  int<lower=0> N; \n  int<lower=0,upper=1> y[N];\n} \nparameters {\n  real<lower=0,upper=1> theta;\n} \nmodel {\n  theta ~ beta(1,1);\n    y ~ bernoulli(theta);\n}\n\"Create a SampleModel object:sm = SampleModel(\"bernoulli\", model)Above SampleModel() call creates a default model for sampling. See ?SampleModel for details.The observed input data:data = Dict(\"N\" => 10, \"y\" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])Run a simulation by calling stan_sample(), passing in the model and data: (sample_file, log_file) = stan_sample(sm, data)If sample_file is defined the sampling completed and can (and should!) be inspected:if !(sample_file == Nothing)\n  chns = read_samples(sm)\n  describe(chns)\n  plot(chns)\nend"
},

{
    "location": "EXAMPLES/#",
    "page": "Feature cross reference",
    "title": "Feature cross reference",
    "category": "page",
    "text": ""
},

{
    "location": "EXAMPLES/#Cross-referenece-of-features-1",
    "page": "Feature cross reference",
    "title": "Cross referenece of features",
    "category": "section",
    "text": "This section is intended to help find an example that shows a specific feature. Work-in-progress!"
},

{
    "location": "EXAMPLES/#Stan-manual-examples-1",
    "page": "Feature cross reference",
    "title": "Stan manual examples",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#ARM-1",
    "page": "Feature cross reference",
    "title": "ARM",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#Bernoulli-1",
    "page": "Feature cross reference",
    "title": "Bernoulli",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#Binomial-1",
    "page": "Feature cross reference",
    "title": "Binomial",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#Binormal-1",
    "page": "Feature cross reference",
    "title": "Binormal",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#Dyes-1",
    "page": "Feature cross reference",
    "title": "Dyes",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#Eight-schools-1",
    "page": "Feature cross reference",
    "title": "Eight schools",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#Stan-language-methods-(Sample,-Optimize,-...)-1",
    "page": "Feature cross reference",
    "title": "Stan language methods (Sample, Optimize, ...)",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#StanSample.jl-1",
    "page": "Feature cross reference",
    "title": "StanSample.jl",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#StanOpimize-1",
    "page": "Feature cross reference",
    "title": "StanOpimize",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#StanVariational-1",
    "page": "Feature cross reference",
    "title": "StanVariational",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#StanDiagnose-1",
    "page": "Feature cross reference",
    "title": "StanDiagnose",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#Generate_Quantities-1",
    "page": "Feature cross reference",
    "title": "Generate_Quantities",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#Include-external-functions-1",
    "page": "Feature cross reference",
    "title": "Include external functions",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#Special-input-and-output-1",
    "page": "Feature cross reference",
    "title": "Special input and output",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#Init-settings-1",
    "page": "Feature cross reference",
    "title": "Init settings",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#Init-with-an-array-of-dicts-1",
    "page": "Feature cross reference",
    "title": "Init with an array of dicts",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#Init-froma-file-1",
    "page": "Feature cross reference",
    "title": "Init froma file",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#NamedArray-1",
    "page": "Feature cross reference",
    "title": "NamedArray",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#Scalar-observation-1",
    "page": "Feature cross reference",
    "title": "Scalar observation",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#Zero-length-array-test-1",
    "page": "Feature cross reference",
    "title": "Zero length array test",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#TBD-1",
    "page": "Feature cross reference",
    "title": "TBD",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#Stan\'s-diagnose-executable-example-1",
    "page": "Feature cross reference",
    "title": "Stan\'s diagnose executable example",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#MCMCChains-1",
    "page": "Feature cross reference",
    "title": "MCMCChains",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#MCMCChains-to-DataFrame-1",
    "page": "Feature cross reference",
    "title": "MCMCChains to DataFrame",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#NamedTuple-input-and-output-1",
    "page": "Feature cross reference",
    "title": "NamedTuple input and output",
    "category": "section",
    "text": ""
},

{
    "location": "EXAMPLES/#MCMCChains-to-Array-1",
    "page": "Feature cross reference",
    "title": "MCMCChains to Array",
    "category": "section",
    "text": ""
},

{
    "location": "VERSIONS/#",
    "page": "Versions",
    "title": "Versions",
    "category": "page",
    "text": ""
},

{
    "location": "VERSIONS/#Version-approach-and-history-1",
    "page": "Versions",
    "title": "Version approach and history",
    "category": "section",
    "text": ""
},

{
    "location": "VERSIONS/#Approach-1",
    "page": "Versions",
    "title": "Approach",
    "category": "section",
    "text": "A version of a Julia package is labeled (tagged) as v\"major.minor.patch\".My intention is to update the patch level whenever I make updates which are not visible to any of the existing examples.New functionality will be introduced in minor level updates. This includes adding new examples, tests and the introduction of new arguments if they default to previous behavior, e.g. in v\"1.1.0\" the useMamba and init arguments to Stanmodel().Changes that require updates to some examples bump the major level.Updates for new releases of Julia and CmdStan bump the appropriate level."
},

{
    "location": "VERSIONS/#Testing-1",
    "page": "Versions",
    "title": "Testing",
    "category": "section",
    "text": "This version of the package has primarily been tested on Mac OSX 10.14, Julia 1.3 and CmdStan 2.20.0."
},

{
    "location": "VERSIONS/#Version-6.0.0-1",
    "page": "Versions",
    "title": "Version 6.0.0",
    "category": "section",
    "text": "Initial release of Stan.jl based on StanJulia organization packages."
},

{
    "location": "#",
    "page": "Index",
    "title": "Index",
    "category": "page",
    "text": ""
},

{
    "location": "#Stan-example-programs-1",
    "page": "Index",
    "title": "Stan example programs",
    "category": "section",
    "text": ""
},

{
    "location": "#Bernoulli-1",
    "page": "Index",
    "title": "Bernoulli",
    "category": "section",
    "text": ""
},

{
    "location": "#Index-1",
    "page": "Index",
    "title": "Index",
    "category": "section",
    "text": ""
},

]}
