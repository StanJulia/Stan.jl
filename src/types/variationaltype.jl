mutable struct Variational <: Method
  algorithm::Symbol
  grad_samples::Int64
  elbo_samples::Int64
  #eta_adagrad::Float64
  iter::Int64
  tol_rel_obj::Float64
  eval_elbo::Int64
  output_samples::Int64
end
"""

# Variational type and constructor

Settings for method=Variational() in Stanmodel. 

### Method
```julia
Variational(;
  grad_samples=1,
  elbo_samples=100,
  eta_adagrad=0.1,
  iter=10000,
  tol_rel_obj=0.01,
  eval_elbo=100,
  algorithm=:meanfield,          
  output_samples=10000
)
```
### Optional arguments
```julia
* `algorithm::Symbol`             : Variational inference algorithm
                                    :meanfiedl;
                                    :fullrank
* `iter::Int64`                   : Maximum number of iterations
* `grad_samples::Int`             : No of samples for MC estimate of gradients
* `elbo_samples::Int`             : No of samples for MC estimate of ELBO
* `eta::Float64`                  : Stepsize weighing parameter for adaptive sequence
* `adapt::Adapt`                  : Warmupadaptations
* `tol_rel_obj::Float64`          : Tolerance on the relative norm of objective
* `eval_elbo::Int`                : Tolerance on the relative norm of objective
* `output_samples::Int`           : Numberof posterior samples to draw and save
```

### Related help
```julia
?Stanmodel                      : Create a StanModel
?Stan.Method                   : Available top level methods
?Stan.Adapt                     : Adaptation settings
```
"""
Variational(;grad_samples=1, elbo_samples=100,
  eta_adagrad=0.1, iter=10000, 
  tol_rel_obj=0.01, eval_elbo=100,
  algorithm=:meanfield, output_samples=10000) = Variational(algorithm,
    grad_samples, elbo_samples, 
    #eta_adagrad,
    iter, tol_rel_obj, eval_elbo, output_samples)

function variational_show(io::IO, v::Variational, compact::Bool)
  if compact
    println("Variational($(v.algorithm). $(v.grad_samples), $(v.elbo_samples), $(v.eta_adagrad), $(v.iter), $(v.tol_rel_obj), $(v.eval_elbo), $(v.output_samples))")
  else
    println("  method =                     Variational()")
    println("    algorithm =               ", v.algorithm)
    println("    grad_samples =            ", v.grad_samples)
    println("    elbo_samples =            ", v.elbo_samples)
    #println("    eta_adagrad =             ", v.eta_adagrad)
    println("    iter =                    ", v.iter)
    println("    tol_rel_obj =             ", v.tol_rel_obj)
    println("    eval_elbo =               ", v.eval_elbo)
    println("    output_samples =          ", v.output_samples)
  end
end

show(io::IO, v::Variational) = variational_show(io, v, false)
showcompact(io::IO, v::Variational) = variational_show(io, v, true)
