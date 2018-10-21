import Base: show

"""

# Available top level Method

### Method
```julia
*  Sample::Method             : Sampling
*  Optimize::Method           : Optimization
*  Diagnose::Method           : Diagnostics
*  Variational::Method        : Variational Bayes
```
""" 
abstract type Method end

DataDict = Dict{String, Any}

mutable struct Random
  seed::Int64
end
Random(;seed::Number=-1) = Random(seed)

mutable struct Output
  file::String
  diagnostic_file::String
  refresh::Int64
end
Output(;file::String="", diagnostic_file::String="", refresh::Number=100) =
  Output(file, diagnostic_file, refresh)

mutable struct Stanmodel
  name::String
  nchains::Int
  num_warmup::Int
  num_samples::Int
  thin::Int
  id::Int
  model::String
  model_file::String
  monitors::Vector{String}
  data::Vector{DataDict}
  data_file::String
  command::Vector{Base.AbstractCmd}
  method::Method
  random::Random
  init::Vector{DataDict}
  init_file::String
  output::Output
  tmpdir::String
  useMamba::Bool
  mambaThinning::Int
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
  num_warmup=1000, 
  num_samples=1000,
  thin=1,
  model="",
  monitors=String[],
  data=DataDict[],
  random=Random(),
  init=DataDict[],
  output=Output(),
  pdir::String=pwd(),
  useMamba=true,
  mambaThinning=1
)

```
### Required arguments
```julia
* `method::Method`            : See ?Method
```

### Optional arguments
```julia
* `name::String`               : Name for the model
* `nchains::Int`               : Number of chains, if possible execute in parallel
* `num_warmup::Int`            : Number of samples used for num_warmupation 
* `num_samples::Int`           : Sample iterations
* `thin::Int`                  : Stan thinning factor
* `model::String`              : Stan program source
* `data::DataDict[]`           : Observed input data as an array of Dicts
* `random::Random`             : Random seed settings
* `init::DataDict[]`           : Initial values for parameters in parameter block
* `output::Output`             : File output options
* `pdir::String`               : Working directory
* `monitors::String[] `        : Filter for variables used in Mamba post-processing
* `useMamba::Bool`             : Use Mamba Chains for diagnostics and graphics
* `mambaThinning::Int`         : Additional thinning factor in Mamba Chains
```

### Example
```julia
bernoullimodel = "
data { 
  int<lower=1> N; 
  int<lower=0,upper=1> y[N];
} 
parameters {
  real<lower=0,upper=1> theta;
} 
model {
  theta ~ beta(1,1);
  y ~ bernoulli(theta);
}
"

stanmodel = Stanmodel(num_samples=1200, thin=2, name="bernoulli", model=bernoullimodel);
```

### Related help
```julia
?stan                          : Run a Stanmodel
?Sample                        : Sampling settings
?Method                       : List of available methods
?Output                        : Output file settings
?DataDict                      : Input data dictionaries, will be converted to R syntax
```
"""
function Stanmodel(
  method=Sample();
  name="noname", 
  nchains=4,
  num_warmup=1000, 
  num_samples=1000,
  thin=1,
  model="",
  monitors=String[],
  data=DataDict[],
  random=Random(),
  init=DataDict[],
  output=Output(),
  pdir::String=pwd(),
  useMamba=true,
  mambaThinning=1)
    
  cd(pdir)
  
  if useMamba
    res = ""
    try
    	res = isdefined(Main, :Mamba)
    catch
      println("Package Mamba.jl not installed, please run Pkg.add(\"Mamba\")")
      return
    end

    res = ""
    try
    	res = isdefined(Main, :Gadfly)
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
  
  tmpdir = joinpath(pdir, "tmp")
  if !isdir(tmpdir)
    mkdir(tmpdir)
  end
  
  model_file = "$(name).stan"
  if length(model) > 0
    update_model_file(joinpath(tmpdir, "$(name).stan"), strip(model))
  end
  
  id::Int=0
  data_file::String=""
  init_file::String=""
  cmdarray = fill(``, nchains)
  
  if num_samples != 1000
    method.num_samples=num_samples
  end
  
  if num_warmup != 1000
    method.num_warmup=num_warmup
  end
  
  if thin != 1
    method.thin=thin
  end
  
  Stanmodel(name, nchains, 
    num_warmup, num_samples, thin,
    id, model, model_file, monitors,
    data, data_file, cmdarray, method, random,
    init, init_file, output, tmpdir,
    useMamba, mambaThinning);
end

"""

# Method update_model_file

Update Stan language model file if necessary 

### Method
```julia
update_model_file(
  file::String, 
  str::String
)
```
### Required arguments
```julia
* `file::String`                : File holding existing Stan model
* `str::String`                 : Stan model string
```

### Related help
```julia
?Stan.Stanmodel                 : Create a StanModel
```
"""
function update_model_file(file::AbstractString, str::AbstractString)
  str2 = ""
  if isfile(file)
    resfile = open(file, "r")
    str2 = read(resfile, String)
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
  println("  num_samples =             $(m.num_samples)")
  println("  num_warmup =                   $(m.num_warmup)")
  println("  thin =                    $(m.thin)")
  println("  useMamba =                $(m.useMamba)")
  println("  mambaThinning =           $(m.mambaThinning)")
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
