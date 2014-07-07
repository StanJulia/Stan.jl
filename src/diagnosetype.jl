importall Base

abstract Diagnostics
type Gradient <: Diagnostics
  epsilon::Float64
  error::Float64
end
Gradient(;epsilon=1e-6, error=1e-6) = Gradient(epsilon, error)

type Diagnose <: Methods
  diagnostic::Diagnostics
  id::Int64
end
Diagnose(;d=Gradient(), id=1) = Diagnose(d, id)
Diagnose(d=Gradient()) = Diagnose(d, 1)

function diagnose_show(io::IO, d::Diagnose, compact::Bool)
  if compact
    println("Diagnose($(d.diagnostic), $(d.id))")
  else
    println("  method =                  Diagnose()")
    if isa(d.diagnostic, Gradient)
      println("    diagnostic =              Gradient()")
      println("      epsilon =                 ", d.diagnostic.epsilon)
      println("      error =                   ", d.diagnostic.error)
    end
    println("    id =                      ", d.id)
  end
end

show(io::IO, d::Diagnose) = diagnose_show(io, d, false)
showcompact(io::IO, d::Diagnose) = diagnose_show(io, d, true)
