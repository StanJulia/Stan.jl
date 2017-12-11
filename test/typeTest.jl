abstract type Metrics end
mutable struct Unit_e <: Metrics
end
mutable struct Diag_e <: Metrics
end

abstract type SamplingAlgorithm end
mutable struct Hmc <: SamplingAlgorithm
  # ...
  metric::Metrics
end
mutable struct Fixed_param <: SamplingAlgorithm
end

Hmc() = Hmc(Diag_e())
Hmc(m::DataType) = ( m <: Metrics ? Hmc(m()) : "Error: $(m) not a subtype of Metrics" )
Hmc(m::Symbol) = ( eval(m) <: Metrics ? Hmc(eval(m)()) : "Error: $(m) not a subtype of Metrics" )

h = Hmc()
l = Hmc(Diag_e)
k = Hmc(:Unit_e)

@assert isa(h.metric, Metrics)
@assert isa(l.metric, Metrics)
@assert isa(k.metric, Metrics)
@assert typeof(k.metric) <: Metrics

