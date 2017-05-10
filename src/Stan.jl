module Stan

using Compat, Documenter

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
    
Example: `set_CMDSTAN_HOME!(homedir() * "/Projects/Stan/cmdstan/")`"""
set_CMDSTAN_HOME!(path) = global CMDSTAN_HOME=path

include("stanmodel.jl")
include("stancode.jl")
include("parallel.jl")
include("utilities.jl")
include("types/sampletype.jl")
include("types/optimizetype.jl")
include("types/diagnosetype.jl")
include("types/variationaltype.jl")

export
# from this file
set_CMDSTAN_HOME!,
CMDSTAN_HOME,
# From stanmodel.jl
Stanmodel,
# From stancode.jl
stan,
# From sampletype.jl
Sample,
# From optimizetype.jl
Optimize,
# From diagnosetype.jl
Diagnose,
# From variationaltype.jl
Variational

end # module
