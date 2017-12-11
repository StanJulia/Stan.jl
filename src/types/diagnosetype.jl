"""

# Available method diagnostics

Currently limited to Gradient().

""" 
abstract type Diagnostics end

"""

# Gradient type and constructor

Settings for diagnostic=Gradient() in Diagnose(). 

### Method
```julia
Gradient(;epsilon=1e-6, error=1e-6)
```
### Optional arguments
```julia
* `epsilon::Float64`           : Finite difference step size
* `error::Float64`             : Error threshold
```

### Related help
```julia
?Diagnose                      : Diagnostic method
```
"""
mutable struct Gradient <: Diagnostics
  epsilon::Float64
  error::Float64
end
Gradient(;epsilon=1e-6, error=1e-6) = Gradient(epsilon, error)

"""

# Diagnose type and constructor

### Method
```julia
Diagnose(;d=Gradient())
```
### Optional arguments
```julia
* `d::Diagnostics`            : Finite difference step size
```

### Related help
```julia
?Diagnostics                  : Diagnostic methods
?Gradient                     : Currently sole diagnostic method
"""
mutable struct Diagnose <: Method
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
