"""

# Engine types

Engine for Hamiltonian Monte Carlo

### Types defined
```julia
* Nuts       : No-U-Tyrn sampler
* Static     : Static integration time
```
""" 
abstract type Engine end

"""

# Available sampling algorithms

Currently limited to Hmc().

""" 
abstract type SamplingAlgorithm end

"""

# Nuts type and constructor

Settings for engine=Nuts() in Hmc(). 

### Method
```julia
Nuts(;max_depth=10)
```
### Optional arguments
```julia
* `max_depth::Number`           : Maximum tree depth
```

### Related help
```julia
?Sample                        : Sampling settings
?Engine                        : Engine for Hamiltonian Monte Carlo
```
"""
mutable struct Nuts <: Engine
  max_depth::Int64
end
Nuts(;max_depth::Number=10) = Nuts(max_depth)

"""

# Static type and constructor

Settings for engine=Static() in Hmc(). 

### Method
```julia
Static(;int_time=2 * pi)
```
### Optional arguments
```julia
* `;int_time::Number`          : Static integration time
```

### Related help
```julia
?Sample                        : Sampling settings
?Engine                        : Engine for Hamiltonian Monte Carlo
```
"""
mutable struct Static <: Engine
  int_time::Float64
end
Static(;int_time::Number=2 * pi) = Static(int_time)

"""

# Metric types

Geometry of base manifold

### Types defined
```julia
* unit_e::Metric      : Euclidean manifold with unit metric
* dense_e::Metric     : Euclidean manifold with dense netric
* diag_e::Metric      : Euclidean manifold with diag netric
```
""" 
abstract type Metric end
mutable struct unit_e <: Metric
end
mutable struct dense_e <: Metric
end
mutable struct diag_e <: Metric
end


"""

# Hmc type and constructor

Settings for algorithm=Hmc() in Sample(). 

### Method
```julia
Hmc(;
  engine=Nuts(),
  metric=Stan.diag_e,
  stepsize=1.0,
  stepsize_jitter=1.0
)
```
### Optional arguments
```julia
* `engine::Engine`            : Engine for Hamiltonian Monte Carlo
* `metric::Metric`            : Geometry for base manifold
* `stepsize::Float64`         : Stepsize for discrete evolutions
* `stepsize_jitter::Float64`  : Uniform random jitter of the stepsize [%]
```

### Related help
```julia
?Sample                        : Sampling settings
?Engine                        : Engine for Hamiltonian Monte Carlo
?Nuts                          : Settings for Nuts
?Static                        : Settings for Static
?Metric                        : Base manifold geometries
```
"""
mutable struct Hmc <: SamplingAlgorithm
  engine::Engine
  metric::Metric
  stepsize::Float64
  stepsize_jitter::Float64
end
Hmc(;engine::Engine=Nuts(), metric::DataType=diag_e, 
  stepsize::Number=1.0, stepsize_jitter::Number=1.0) = 
    Hmc(engine, metric(), stepsize, stepsize_jitter)
Hmc(engine::Engine) = Hmc(engine, diag_e(), 1.0, 1.0)

"""

# Adapt type and constructor

Settings for adapt=Adapt() in Sample(). 

### Method
```julia
Adapt(;
  engaged=true,
  gamma=0.05,
  delta=0.8,
  kappa=0.75,
  t0=10.0,
  init_buffer=75,
  term_buffer=50,
  window::25
)
```
### Optional arguments
```julia
* `engaged::Bool`              : Adaptation engaged?
* `gamma::Float64`             : Adaptation regularization scale
* `delta::Float64`             : Adaptation target acceptance statistic
* `kappa::Float64`             : Adaptation relaxation exponent
* `t0::Float64`                : Adaptation iteration offset
* `init_buffer::Int64`         : Width of initial adaptation interval
* `term_buffer::Int64`         : Width of final fast adaptation interval
* `window::Int64`              : Initial width of slow adaptation interval
```

### Related help
```julia
?Sample                        : Sampling settings
```
"""
mutable struct Adapt
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


"""

# Sample type and constructor

Settings for method=Sample() in Stanmodel. 

### Method
```julia
Sample(;
  num_samples=1000,
  num_warmup=1000,
  save_warmup=false,
  thin=1,
  adapt=Adapt(),
  algorithm=SamplingAlgorithm()
)
```
### Optional arguments
```julia
* `num_samples::Int64`          : Number of sampling iterations ( >= 0 )
* `num_warmup::Int64`           : Number of warmup iterations ( >= 0 )
* `save_warmup::Bool`           : Include warmup samples in output
* `thin::Int64`                 : Period between saved samples
* `adapt::Adapt`                : Warmup adaptation settings
* `algorithm::SamplingAlgorithm`: Sampling algorithm

```

### Related help
```julia
?Stanmodel                      : Create a StanModel
?Adapt
?SamplingAlgorithm
```
"""
mutable struct Sample <: Method
  num_samples::Int64
  num_warmup::Int64
  save_warmup::Bool
  thin::Int64
  adapt::Adapt
  algorithm::SamplingAlgorithm
end
Sample(;num_samples::Number=1000, num_warmup::Number=1000,
  save_warmup::Bool=false, thin::Number=1, 
  adapt::Adapt=Adapt(), algorithm::SamplingAlgorithm=Hmc()) = 
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
