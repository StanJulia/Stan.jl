importall Base

abstract Methods

include("./sampletype.jl")
include("./optimizetype.jl")
include("./diagnosetype.jl")

type Data
  file::String
end
Data(;file::String="") = Data(file)

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
  data::Array{Dict{ASCIIString, Any}, 1}
  data_file_array::Array{ASCIIString, 1}
  data_file::String
  command::Array{Base.AbstractCmd, 1}
  method::Methods
  random::Random
  init::Init
  output::Output
end

function Stanmodel(method::Methods=Sample();
  name::String="noname", nchains::Int=4,
  adapt::Number=1000, update::Number=1000, thin::Number=10,
  id::Int=0, model::String="", model_file::String="",
  data::Array{Dict{ASCIIString, Any}, 1}=[], 
  data_file_array::Vector{String}=String[],
  data_file::String="",
  cmdarray = fill(``, nchains),
  random=Random(), init=Init(), output=Output())
    
  if length(model) > 0
    update_model_file("$(name).stan", strip(model))
  end
  
  model_file = "$(name).stan";
  
  Stanmodel(name, nchains, 
    adapt, update, thin,
    id, model, model_file, 
    data, data_file_array, data_file,
    cmdarray, method, random, init, output);
end

function update_model_file(file::String, str::String)
  str2 = ""
  if isfile(file)
    str2 = open(readall, file, "r")
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
  else
    diagnose_show(io, m.method, compact)
  end
end

show(io::IO, m::Stanmodel) = model_show(io, m, false)
showcompact(io::IO, m::Stanmodel) = model_show(io, m, true)
