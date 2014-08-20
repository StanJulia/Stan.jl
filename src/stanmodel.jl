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
  stan_file::String
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
  random=Random(), init=Init(), data=Data(), output=Output())
  cmdarray = fill(``, noofchains)
  Stanmodel(name, noofchains, cmdarray, method, random, init, data, output)
end

function model_show(io::IO, m::Stanmodel, compact::Bool)
  println("  name =                    \"$(m.name)\"")
  println("  nchains =                 $(m.nchains)")
  println("  init =                    $(m.init.init)")
  #println("  data =                    Data()")
  println("  file =                    \"$(m.data.file)\"")
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
