module Stan

# package code goes here

  include("stanmodel.jl")
  include("stancode.jl")
  if !isdefined(Main, :Jags)
    include("utilities.jl")
  end
  
  function getenv(var::String)
    val = ccall( (:getenv, "libc"),
      Ptr{Uint8}, (Ptr{Uint8},), bytestring(var))
    if val == C_NULL
     error("getenv: undefined variable: ", var)
    end
    bytestring(val)
  end

  STANDIR = ""
  CMDSTANDIR = ""
  try
    STANDIR = getenv("STAN_HOME");
  catch e
    println("Environment variable STAN_HOME not found.")
  end
  try
    CMDSTANDIR = getenv("CMDSTAN_HOME");
  catch e
    println("Environment variable CMDSTAN_HOME not found.")
  end

  export
  # From stancmnds.jl
    stan,
    getenv,
    stan_summary,
    read_stanfit,
    CMDSTANDIR,
    STANDIR,
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
  # From cmdline.jl
    cmdline
    

end # module
