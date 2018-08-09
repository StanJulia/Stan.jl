"""

# OptimizeAlgorithm types

### Types defined
```julia
* Lbfgs::OptimizeAlgorithm   : Euclidean manifold with unit metric
* Bfgs::OptimizeAlgorithm    : Euclidean manifold with unit metric
* Newton::OptimizeAlgorithm  : Euclidean manifold with unit metric
```
""" 
abstract type OptimizeAlgorithm end

"""

# Lbfgs type and constructor

Settings for method=Lbfgs() in Optimize(). 

### Method
```julia
Lbfgs(;init_alpha=0.001, tol_obj=1e-8, tol_grad=1e-8, tol_param=1e-8, history_size=5)
```
### Optional arguments
```julia
* `init_alpha::Float64`        : Linear search step size for first iteration
* `tol_obj::Float64`           : Convergence tolerance for objective function
* `tol_rel_obj::Float64`       : Relative change tolerance in objective function
* `tol_grad::Float64`          : Convergence tolerance on norm of gradient
* `tol_rel_grad::Float64`      : Relative change tolerance on norm of gradient
* `tol_param::Float64`         : Convergence tolerance on parameter values
* `history_size::Int`          : No of update vectors to use in Hessian approx
```

### Related help
```julia
?OptimizeMethod               : List of available optimize methods
?Optimize                      : Optimize arguments
```
"""
mutable struct Lbfgs <: OptimizeAlgorithm
  init_alpha::Float64
  tol_obj::Float64
  tol_rel_obj::Float64
  tol_grad::Float64
  tol_rel_grad::Float64
  tol_param::Float64
  history_size::Int64
end
Lbfgs(;init_alpha=0.001, tol_obj=1e-8,  tol_rel_obj=1e4,
  tol_grad=1e-8, tol_rel_grad=1e7, tol_param=1e-8, history_size=5) = 
    Lbfgs(init_alpha, tol_obj, tol_rel_obj, tol_grad, tol_rel_grad,
      tol_param, history_size)

"""

# Bfgs type and constructor

Settings for method=Bfgs() in Optimize(). 

### Method
```julia
Bfgs(;init_alpha=0.001, tol_obj=1e-8, tol_rel_obj=1e4, 
  tol_grad=1e-8, tol_rel_grad=1e7, tol_param=1e-8)
```
### Optional arguments
```julia
* `init_alpha::Float64`        : Linear search step size for first iteration
* `tol_obj::Float64`           : Convergence tolerance for objective function
* `tol_rel_obj::Float64`       : Relative change tolerance in objective function
* `tol_grad::Float64`          : Convergence tolerance on norm of gradient
* `tol_rel_grad::Float64`      : Relative change tolerance on norm of gradient
* `tol_param::Float64`         : Convergence tolerance on parameter values
```

### Related help
```julia
?OptimizeMethod               : List of available optimize methods
?Optimize                      : Optimize arguments
```
"""
mutable struct Bfgs <: OptimizeAlgorithm
  init_alpha::Float64
  tol_obj::Float64
  tol_rel_obj::Float64
  tol_grad::Float64
  tol_rel_grad::Float64
  tol_param::Float64
end
Bfgs(;init_alpha=0.001, tol_obj=1e-8, tol_rel_obj=1e4,
  tol_grad=1e-8, tol_rel_grad=1e7, tol_param=1e-8) = 
    Bfgs(init_alpha, tol_obj, tol_rel_obj, tol_grad, tol_rel_grad, tol_param)


"""

# Newton type and constructor

Settings for method=Newton() in Optimize(). 

### Method
```julia
Newton()
```
### Related help
```julia
?OptimizeMethod               : List of available optimize methods
?Optimize                      : Optimize arguments
```
"""
mutable struct Newton <: OptimizeAlgorithm
end


"""

# Optimize type and constructor

Settings for Optimize top level method. 

### Method
```julia
Optimize(;
  method=Lbfgs(),
  iter=2000,
  save_iterations=false
)
```
### Optional arguments
```julia
* `method::OptimizeMethod`      : Optimization algorithm
* `iter::Int`                   : Total number of iterations
* `save_iterations::Bool`       : Stream optimization progress to output
```

### Related help
```julia
?Stanmodel                      : Create a StanModel
?OptimizeAlgorithm              : Available algorithms
```
"""
mutable struct Optimize <: Method
  method::OptimizeAlgorithm
  iter::Int64
  save_iterations::Bool
end
Optimize(;method::OptimizeAlgorithm=Lbfgs(), iter::Number=2000,
  save_iterations::Bool=false) =
  Optimize(method, iter, save_iterations)
Optimize(method::OptimizeAlgorithm) = Optimize(method, 2000, false)

function optimize_show(io::IO, o::Optimize, compact::Bool)
  if compact
    println("Optimize($(o.method), $(o.iter), $(o.save_iterations))")
  else
    println("  method =                  Optimize()")
    if isa(o.method, Lbfgs)
      println("    algorithm =               Lbfgs()")
      println("      init_alpha =              ", o.method.init_alpha)
      println("      tol_obj =                 ", o.method.tol_obj)
      println("      tol_grad =                ", o.method.tol_grad)
      println("      tol_param =               ", o.method.tol_param)
      println("      history_size =            ", o.method.history_size)
    elseif isa(o.method, Bfgs)
      println("    algorithm =               Bfgs()")
      println("      init_alpha =              ", o.method.init_alpha)
      println("      tol_obj =                 ", o.method.tol_obj)
      println("      tol_grad =                ", o.method.tol_grad)
      println("      tol_param =               ", o.method.tol_param)
    else
      println("    algorithm =               Newton()")
    end
    println("    iterations =              ", o.iter)
    println("    save_iterations =         ", o.save_iterations)
  end
end

show(io::IO, o::Optimize) = optimize_show(io, o, false)
