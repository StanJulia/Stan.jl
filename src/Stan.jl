module Stan
using Mamba
using Compat, DelimitedFiles, Statistics
using LinearAlgebra, Printf, CSV

"""
The directory which contains the CmdStan executables such as `bin/stanc` and
`bin/stansummary`. Inferred from `Main.CMDSTAN_HOME` or `ENV["CMDSTAN_HOME"]`
when available. Use `set_cmdstan_home!` to modify.
"""
global CMDSTAN_HOME=""

function __init__()
    global CMDSTAN_HOME = if isdefined(Main, :CMDSTAN_HOME)
        eval(Main, :CMDSTAN_HOME)
    elseif haskey(ENV, "CMDSTAN_HOME")
        ENV["CMDSTAN_HOME"]
    else
        @warn("Environment variable CMDSTAN_HOME not found. Use set_cmdstan_home!.")
        ""
    end
end

"""Set the path for the `CMDSTAN_HOME` environment variable.

Example: `set_cmdstan_home!(homedir() * "/Projects/Stan/cmdstan/")`
"""
set_cmdstan_home!(path) = global CMDSTAN_HOME=path

include("main/stanmodel.jl")
include("main/stancode.jl")
include("utilities/parallel.jl")
include("utilities/create_cmd_line.jl")
include("utilities/create_r_files.jl")
include("utilities/read_stan_files.jl")
include("types/sampletype.jl")
include("types/optimizetype.jl")
include("types/diagnosetype.jl")
include("types/variationaltype.jl")

export
# From this file
set_cmdstan_home!,
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
Variational,
# From DelimitedFiles
writedlm,
readdlm

end # module
