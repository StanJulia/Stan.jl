import Base: show, showcompact

abstract Methods

include("./sampletype.jl")
include("./optimizetype.jl")
include("./diagnosetype.jl")
include("./variationaltype.jl")

type Init
  init::Int64
end
Init(;init::Number=2) = Init(init)

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
  data::Array{Dict{String, Any}, 1}
  data_file_array::Array{String, 1}
  data_file::String
  command::Array{Base.AbstractCmd, 1}
  method::Methods
  random::Random
  init::Init
  output::Output
  tmpdir::String
end

function Stanmodel(
  method=Sample();
  name="noname", 
  nchains=4,
  adapt=1000, 
  update=1000,
  thin=1,
  model="",
  monitors=String[],
  data=Dict{String, Any}[], 
  random=Random(),
  init=Init(),
  output=Output(),
  pdir::String=pwd())
    
  cd(pdir)
  
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
    cmdarray, method, random, init, output, tmpdir);
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
  println("  update =                   $(m.update)")
  println("  adapt =                    $(m.adapt)")
  println("  thin =                     $(m.thin)")
  println("  monitors =                $(m.monitors)")
  println("  model_file =              \"$(m.model_file)\"")
  println("  data_file =                \"$(m.data_file)\"")
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
