@compat abstract type Engine end

type Nuts <: Engine
  max_depth::Int64
end
Nuts(;max_depth::Number=10) = Nuts(max_depth)

type Static <: Engine
  int_time::Float64
end
Static(;int_time::Number=2 * pi) = Static(int_time)

@compat abstract type Metric end
type unit_e <: Metric
end
type dense_e <: Metric
end
type diag_e <: Metric
end

@compat abstract type Algorithm end

type Hmc <: Algorithm
  engine::Engine
  metric::Metric
  stepsize::Float64
  stepsize_jitter::Float64
end
Hmc(;engine::Engine=Nuts(), metric::DataType=diag_e, 
  stepsize::Number=1.0, stepsize_jitter::Number=1.0) = 
    Hmc(engine, metric(), stepsize, stepsize_jitter)
Hmc(engine::Engine) = Hmc(engine, diag_e(), 1.0, 1.0)

type Adapt
  engaged::Bool
  gamma::Float64
  delta::Float64
  kappa::Float64
  t0::Float64
  init_buffer::Int64
  term_buffer::Int64
  window::Int64
end
Adapt(;engaged::Bool=true, gamma::Number=0.05, delta::Number=0.8,
  kappa::Number=0.75, t0::Number=10.0,
  init_buffer::Number=75, term_buffer::Number=50, window::Number=25) = 
    Adapt(engaged, gamma, delta, kappa, t0, init_buffer, term_buffer, window)

type Sample <: Methods
  num_samples::Int64
  num_warmup::Int64
  save_warmup::Bool
  thin::Int64
  adapt::Adapt
  algorithm::Algorithm
end
Sample(;num_samples::Number=1000, num_warmup::Number=1000,
  save_warmup::Bool=false, thin::Number=1, 
  adapt::Adapt=Adapt(), algorithm::Algorithm=Hmc()) = 
    Sample(num_samples, num_warmup, save_warmup, thin, adapt, algorithm)

function sample_show(io::IO, s::Sample, compact::Bool)
  if compact
    println("Sample($(s.num_samples), $(s.num_warmup), $(s.save_warmup), $(s.thin), $(s.adapt), $(s.algorithm))")
  else
    println("  method =                  Sample()")
    println("    num_samples =             ", s.num_samples)
    println("    num_warmup =              ", s.num_warmup)
    println("    save_warmup =             ", s.save_warmup)
    println("    thin =                    ", s.thin)
    if isa(s.algorithm, Hmc)
      println("    algorithm =               HMC()")
      if isa(s.algorithm.engine, Nuts)
        println("      engine =                  NUTS()")
        println("        max_depth =               ", s.algorithm.engine.max_depth)
      elseif isa(s.algorithm.engine, Static)
        println("      engine =                  Static()")
        println("        int_time =                ", s.algorithm.engine.int_time)
      end
    else
      println("    algorithm =               Unknown")
    end
    println("      metric =                  ", typeof(s.algorithm.metric))
    println("      stepsize =                ", s.algorithm.stepsize)
    println("      stepsize_jitter =         ", s.algorithm.stepsize_jitter)
    println("    adapt =                   Adapt()")
    println("      gamma =                   ", s.adapt.gamma)
    println("      delta =                   ", s.adapt.delta)
    println("      kappa =                   ", s.adapt.kappa)
    println("      t0 =                      ", s.adapt.t0)
    println("      init_buffer =             ", s.adapt.init_buffer)
    println("      term_buffer =             ", s.adapt.term_buffer)
    println("      window =                  ", s.adapt.window)
  end
end

show(io::IO, s::Sample) = sample_show(io, s, false)
showcompact(io::IO, s::Sample) = sample_show(io, s, true)
