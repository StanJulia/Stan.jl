importall Base

#abstract Algorithm

type Lbfgs <: Algorithm
  init_alpha::Float64
  tol_obj::Float64
  tol_grad::Float64
  tol_param::Float64
  history_size::Int64
end
Lbfgs(;init_alpha::Number=0.001, tol_obj::Number=1e-8,
  tol_grad::Number=1e-8, tol_param::Number=1e-8, history_size::Number=5) = 
    Lbfgs(init_alpha, tol_obj, tol_grad, tol_param, history_size)

type Bfgs <: Algorithm
  init_alpha::Float64
  tol_obj::Float64
  tol_grad::Float64
  tol_param::Float64
end
Bfgs(;init_alpha::Number=0.001, tol_obj::Number=1e-8,
  tol_grad::Number=1e-8, tol_param::Number=1e-8) = 
    Bfgs(init_alpha, tol_obj, tol_grad, tol_param)

type Newton <: Algorithm
end

type Optimize <: Methods
  method::Algorithm
  iter::Int64
  save_iterations::Bool
end
Optimize(;method::Algorithm=Lbfgs(), iter::Number=2000, save_iterations::Bool=false) =
  Optimize(method, iter, save_iterations)
Optimize(method::Algorithm) = Optimize(method, 2000, false)

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
showcompact(io::IO, o::Optimize) = optimize_show(io, o, true)
