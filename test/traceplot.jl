using Mamba, Plots
pyplot(size=(800,800))

if !isdefined(Main, :traceplot)
  function traceplot(c::AbstractChains; legend::Bool=false, na...)
    nrows, nvars, nchains = size(c.value)
    plts = Array{Plots.Plot{Plots.PyPlotBackend}}(nvars)
    for i in 1:nvars
      plts[i] = plot(1:nrows, c.value[:, i, :])
    end
    plts
  end
end

if !isdefined(Main, :meanplot)
  function meanplot(c::AbstractChains; legend::Bool=false, na...)
    nrows, nvars, nchains = size(c.value)
    plts = Array{Plots.Plot{Plots.PyPlotBackend}}(nvars)
    val = Mamba.cummean(c.value)
    for i in 1:nvars
      plts[i] = plot(1:nrows, val[:, i, :], lab="Chain $i")
    end
    plts
  end
end

tp = traceplot(sim)

mp = meanplot(sim)
