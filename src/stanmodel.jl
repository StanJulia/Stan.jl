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
  model::String
  model_file::String
  data::Dict
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
  model::String="", model_file::String="",
  data::Dict{ASCIIString, Any}=Dict{ASCIIString, Any}(), 
  data_file::String="",
  cmdarray = fill(``, nchains),
  random=Random(), init=Init(), output=Output())
    
  if length(model) > 0
    update_model_file("$(name).stan", strip(model))
  end
  
  if length(keys(data)) > 0
    update_R_file("$(name).data.R", data)
  end
  
  model_file = "$(name).stan";
  data_file = "$(name).data.R"
  
  Stanmodel(name, nchains, 
    adapt, update, thin,
    model, model_file, 
    data, data_file, 
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

function update_R_file(file::String, dct::Dict{ASCIIString, Any}; replaceNaNs::Bool=true)
  isfile(file) && rm(file)
  strmout = open(file, "w")
  
  str = ""
  for entry in dct
    str = "\""*entry[1]*"\""*" <- "
    val = entry[2]
    if replaceNaNs && true in isnan(entry[2])
      val = convert(DataArray, entry[2])
      for i in 1:length(val)
        if isnan(val[i])
          val[i] = NA
        end
      end
    end
    if length(val)==1 && length(size(val))==0
      # Scalar
      str = str*"$(val)\n"
    elseif length(val)>1 && length(size(val))==1
      # Vector
      str = str*"structure(c("
      for i in 1:length(val)
        str = str*"$(val[i])"
        if i < length(val)
          str = str*", "
        end
      end
      str = str*"), .Dim=c($(length(val))))\n"
    elseif length(val)>1 && length(size(val))>1
      # Array
      str = str*"structure(c("
      for i in 1:length(val)
        str = str*"$(val[i])"
        if i < length(val)
          str = str*", "
        end
      end
      dimstr = "c"*string(size(val))
      str = str*"), .Dim=$(dimstr))\n"
    end
    write(strmout, str)
  end
  close(strmout)
end

function model_show(io::IO, m::Stanmodel, compact::Bool)
  println("  name =                    \"$(m.name)\"")
  println("  nchains =                 $(m.nchains)")
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
  else
    diagnose_show(io, m.method, compact)
  end
end

show(io::IO, m::Stanmodel) = model_show(io, m, false)
showcompact(io::IO, m::Stanmodel) = model_show(io, m, true)
