module Stan

using Mamba

"""The directory which contains the executable `bin/stanc`. Inferred
from `Main.CMDSTAN_HOME` or `ENV["CMDSTAN_HOME"]` when available. Use
`set_CMDSTAN_HOME!` to modify."""
CMDSTAN_HOME=""

function __init__()
    global CMDSTAN_HOME = if isdefined(Main, :CMDSTAN_HOME)
        eval(Main, :CMDSTAN_HOME)
    elseif haskey(ENV, "CMDSTAN_HOME")
        ENV["CMDSTAN_HOME"]
    else
        warn("Environment variable CMDSTAN_HOME not found. Use set_CMDSTAN_HOME!.")
        ""
    end
end

"""Set the path for `CMDSTAN`.
    
Example: `set_CMDSTAN_HOME!(homedir() * "/src/src/cmdstan-2.9.0/")`"""
set_CMDSTAN_HOME!(path) = global CMDSTAN_HOME=path

if !isdefined(Main, :JULIA_SVG_BROWSER)
    JULIA_SVG_BROWSER = ""
    try
        JULIA_SVG_BROWSER = ENV["JULIA_SVG_BROWSER"]
    catch e
        println("Environment variable JULIA_SVG_BROWSER not found.")
        JULIA_SVG_BROWSER = ""
    end
end

include("stanmodel.jl")
include("stancode.jl")
include("utilities.jl")

export
# from this file
set_CMDSTAN_HOME!,
# From stancode.jl
stan,
stan_summary,
read_stanfit,
read_stanfit_samples,
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
