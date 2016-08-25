importall Base

abstract Diagnostics
type Gradient <: Diagnostics
  epsilon::Float64
  error::Float64
end
Gradient(;epsilon=1e-6, error=1e-6) = Gradient(epsilon, error)

type Diagnose <: Methods
  diagnostic::Diagnostics
end
Diagnose(;d=Gradient()) = Diagnose(d)
#Diagnose(d=Gradient()) = Diagnose(d)

function diagnose_show(io::IO, d::Diagnose, compact::Bool)
  if compact
    println("Diagnose($(d.diagnostic))")
  else
    println("  method =                  Diagnose()")
    if isa(d.diagnostic, Gradient)
      println("    diagnostic =              Gradient()")
      println("      epsilon =                 ", d.diagnostic.epsilon)
      println("      error =                   ", d.diagnostic.error)
    end
  end
end

show(io::IO, d::Diagnose) = diagnose_show(io, d, false)
showcompact(io::IO, d::Diagnose) = diagnose_show(io, d, true)
