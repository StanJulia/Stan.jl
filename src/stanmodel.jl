import Base: show, showcompact

@compat abstract type Methods end

include("./sampletype.jl")
include("./optimizetype.jl")
include("./diagnosetype.jl")
include("./variationaltype.jl")

const DataDict = Dict{String, Any}

type Init{I<:Union{Int,Float64, Vector{DataDict}}}
  init::I
  init_files::Vector{String}
  init_file::String
end
Init(;init::Union{Int,Float64, Vector{DataDict}}=2) = Init(init, String[], "")

type Random
  seed::Int64
end
Random(;seed::Number=-1) = Random(seed)

type Output
  file::String
  diagnostic_file::String
  refresh::Int64
end
Output(;file::String="", diagnostic_file::String="", refresh::Number=100) =
  Output(file, diagnostic_file, refresh)

type Stanmodel
  name::String
  nchains::Int
  adapt::Int
  update::Int
  thin::Int
  id::Int
  model::String
  model_file::String
  monitors::Vector{String}
  data::Vector{DataDict}
  data_file_array::Vector{String}
  data_file::String
  command::Vector{Base.AbstractCmd}
  method::Methods
  random::Random
  init::Init
  output::Output
  tmpdir::String
  useMamba::Bool
end

"""
# Method Stanmodel 

Create a Stanmodel. 

### Constructors
```julia
Stanmodel(
  method=Sample();
  name="noname", 
  nchains=4,
  adapt=1000, 
  update=1000,
  thin=1,
  model="",
  monitors=String[],
  data=DataDict[],
  random=Random(),
  init=Init(),
  output=Output(),
  pdir::String=pwd(),
  useMamba=true,
  mambaThinning=1)
)
```
### Required arguments
```julia
* `method=Sample()`            : See ?Methods
```

### Optional arguments
```julia
* name="noname"                : Name for model
* nchains=4                    : Number of (parallel) chains
* adapt=1000                   : Number of samples used for adaptation 
* update=1000                  : Samples used for inference
* thin=1                       : Stan thinning factor
* model=""                     : Stan program
* monitors=String[]            : Filter for variables used in Mamba post-processing
* data=DataDict[]              : Input data
* random=Random()              : Random seed settings
* init=Init()                  : Initial values
* output=Output()              : File output options
* pdir::String=pwd()           : Working directory
* useMamba=true                : Use Mamba Chains for diagnostics and graphics
* mambaThinning=1)             : Additional thinning factor in Mamba Chains
```

### Related help
```julia
?stan                          : List of available structural element types
?Sample                        : List of available structural element types
?Methods                       : List of available structural element types
?Output                        : List of available structural element types
?DataDict                      : List of available structural element types
```
"""
function Stanmodel(
  method=Sample();
  name="noname", 
  nchains=4,
  adapt=1000, 
  update=1000,
  thin=1,
  model="",
  monitors=String[],
  data=DataDict[],
  random=Random(),
  init=Init(),
  output=Output(),
  pdir::String=pwd(),
  useMamba=true,
  mambaThinning=1)
    
  cd(pdir)
  
  if useMamba
    res = ""
    try
    	res = Pkg.installed("Mamba")
    catch
      println("Package Mamba.jl not installed, please run Pkg.add(\"Mamba\")")
      return
    end

    res = ""
    try
    	res = Pkg.installed("Gadfly")
    catch
      println("Package Gadfly.jl not installed, please run Pkg.add(\"Gadfly\")")
      return
    end

    if typeof(res) == VersionNumber
      eval(quote
        using Mamba
        using Gadfly
      end)
    end
  end
  
  tmpdir = Pkg.dir(pdir, "tmp")
  if !isdir(tmpdir)
    mkdir(tmpdir)
  end
  
  model_file = "$(name).stan"
  if length(model) > 0
    update_model_file(Pkg.dir(tmpdir, "$(name).stan"), strip(model))
  end
  
  id::Int=0
  data_file_array::Vector{String}=String[]
  data_file::String=""
  cmdarray = fill(``, nchains)
  
  if update != 1000
    method.num_samples=update
  end
  
  if adapt != 1000
    method.num_warmup=adapt
  end
  
  Stanmodel(name, nchains, 
    adapt, update, thin,
    id, model, model_file, monitors,
    data, data_file_array, data_file,
    cmdarray, method, random, init, output, tmpdir,
    useMamba, mambaThinning);
end

function update_model_file(file::String, str::String)
  str2 = ""
  if isfile(file)
    str2 = open(readstring, file, "r")
    str != str2 && rm(file)
  end
  if str != str2
    println("\nFile $(file) will be updated.\n")
    strmout = open(file, "w")
    write(strmout, str)
    close(strmout)
  end
end

function model_show(io::IO, m::Stanmodel, compact::Bool)
  println("  name =                    \"$(m.name)\"")
  println("  nchains =                 $(m.nchains)")
  println("  update =                  $(m.update)")
  println("  adapt =                   $(m.adapt)")
  println("  thin =                    $(m.thin)")
  println("  useMamba =                $(m.useMamba)")
  println("  monitors =                $(m.monitors)")
  println("  model_file =              \"$(m.model_file)\"")
  println("  data_file =               \"$(m.data_file)\"")
  println("  output =                  Output()")
  println("    file =                    \"$(m.output.file)\"")
  println("    diagnostics_file =        \"$(m.output.diagnostic_file)\"")
  println("    refresh =                 $(m.output.refresh)")
  if isa(m.method, Sample)
    sample_show(io, m.method, compact)
  elseif isa(m.method, Optimize)
    optimize_show(io, m.method, compact)
  elseif isa(m.method, Variational)
    variational_show(io, m.method, compact)
  else
    diagnose_show(io, m.method, compact)
  end
end

show(io::IO, m::Stanmodel) = model_show(io, m, false)
showcompact(io::IO, m::Stanmodel) = model_show(io, m, true)
