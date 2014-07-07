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
Output(;file::String="output.csv", diagnostic_file::String="", refresh::Number=100) =
  Output(file, diagnostic_file, refresh)

type Model
  name::String
  noofchains::Int
  command::Array{Base.AbstractCmd, 1}
  method::Methods
  random::Random
  init::Init
  data::Data
  output::Output
end

function Model(;name::String="noname", noofchains::Int=4, method::Methods=Sample(),
  random=Random(), init=Init(), data=Data(), output=Output())
  cmdarray = fill(``, noofchains)
  Model(name, noofchains, cmdarray, method, random, init, data, output)
end

function model_show(io::IO, m::Model, compact::Bool)
  println("  name =                    \"$(m.name)\"")
  println("  noofchains =              $(m.noofchains)")
  println("  init =                    $(m.init.init)")
  println("  data =                    Data()")
  println("    file =                    \"$(m.data.file)\"")
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

show(io::IO, m::Model) = model_show(io, m, false)
showcompact(io::IO, m::Model) = model_show(io, m, true)
