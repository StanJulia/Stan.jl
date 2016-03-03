module Stan

# package code goes here

  using Mamba

  include("stanmodel.jl")
  include("stancode.jl")
  include("utilities.jl")
  
  if !isdefined(Main, :CMDSTAN_HOME)
    if haskey(ENV, "CMDSTAN_HOME")
       global const CMDSTAN_HOME = ENV["CMDSTAN_HOME"]
    else
      CMDSTAN_HOME = ""
      error("Environment variable CMDSTAN_HOME not found.")
    end
  end
  
  if !isdefined(Main, :JULIA_SVG_BROWSER)
    if haskey(ENV, "JULIA_SVG_BROWSER")
       global const JULIA_SVG_BROWSER = ENV["JULIA_SVG_BROWSER"]
    else
      JULIA_SVG_BROWSER = ""
      error("Environment variable JULIA_SVG_BROWSER not found.")
    end
  end
  
  export
  # From stancode.jl
    stan,
    stan_summary,
    read_stanfit,
    read_stanfit_samples,
    read_stanfit_warmup_samples,
    CMDSTAN_HOME,
    JULIA_SVG_BROWSER,
  # From stanmodel.jl
    Stanmodel,
    Data,
    RNG,
    Output,
  # From sampletype.jl
    Sample,
    Hmc,
    diag_e,
    unit_e,
    dense_e,
    Engine,
    Nuts,
    Static,
    Metrics,
    SampleAlgorithm,
    Fixed_param,
    Adapt,
  # From optimizetype.jl
    Optimize,
    Lbfgs,
    Bfgs,
    Newton,
  # From diagnosetype.jl
    Diagnose,
    Diagnostics,
    Gradient,
  # From variationaltype.jl
    Variational,
  # From cmdline.jl
    cmdline

end # module
