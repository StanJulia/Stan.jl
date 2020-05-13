using Distributions
function stan_string(p::Union{Type{Bernoulli},Bernoulli})
  try
    parameters = (params(p)[1])
    return string("bernoulli($parameters)")
  catch
    return string("bernoulli")
  end
end
function stan_string(p::Union{Type{Binomial},Binomial})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("binomial$parameters")
  catch
    return string("binomial")
  end
end
function stan_string(p::Union{Type{BetaBinomial},BetaBinomial})
  try
    parameters = (params(p)[1],params(p)[2],params(p)[3])
    return string("beta_binomial$parameters")
  catch
    return string("beta_binomial")
  end
end
function stan_string(p::Union{Type{Hypergeometric},Hypergeometric})
  try
    parameters = (params(p)[1],params(p)[2],params(p)[3])
    return string("hypergeometric$parameters")
  catch
    return string("hypergeometric")
  end
end
function stan_string(p::Union{Type{Categorical},Categorical})
  try
    parameters = (params(p)[1])
    return string("categorical($parameters)")
  catch
    return string("categorical")
  end
end
function stan_string(p::Union{Type{NegativeBinomial},NegativeBinomial})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("neg_binomial$parameters")
  catch
    return string("neg_binomial")
  end
end
function stan_string(p::Union{Type{Poisson},Poisson})
  try
    parameters = (params(p)[1])
    return string("poisson($parameters)")
  catch
    return string("poisson")
  end
end
function stan_string(p::Union{Type{Normal},Normal})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("normal$parameters")
  catch
    return string("normal")
  end
end
function stan_string(p::Union{Type{TDist},TDist})
  try
    parameters = (params(p)[1])
    return string("student_t($parameters,0,1)")
  catch
    return string("student_t")
  end
end
function stan_string(p::Union{Type{Cauchy},Cauchy})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("cauchy$parameters")
  catch
    return string("cauchy")
  end
end
function stan_string(p::Union{Type{Laplace},Laplace})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("double_exponential$parameters")
  catch
    return string("double_exponential")
  end
end
function stan_string(p::Union{Type{Distributions.Logistic},Distributions.Logistic})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("logistic$parameters")
  catch
    return string("logistic")
  end
end
function stan_string(p::Union{Type{Gumbel},Gumbel})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("gumbel$parameters")
  catch
    return string("gumbel")
  end
end
function stan_string(p::Union{Type{LogNormal},LogNormal})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("lognormal$parameters")
  catch
    return string("lognormal")
  end
end
function stan_string(p::Union{Type{Chisq},Chisq})
  try
    parameters = (params(p)[1])
    return string("chi_square($parameters)")
  catch
    return string("chi_square")
  end
end
function stan_string(p::Union{Type{Exponential},Exponential})
  try
    parameters = (params(p)[1])
    return string("exponential($parameters)")
  catch
    return string("exponential")
  end
end
function stan_string(p::Union{Type{Gamma},Gamma})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("gamma$parameters")
  catch
    return string("gamma")
  end
end
function stan_string(p::Union{Type{InverseGamma},InverseGamma})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("inv_gamma$parameters")
  catch
    return string("inv_gamma")
  end
end
function stan_string(p::Union{Type{Weibull},Weibull})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("weibull$parameters")
  catch
    return string("weibull")
  end
end
function stan_string(p::Union{Type{Frechet},Frechet})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("frechet$parameters")
  catch
    return string("frechet")
  end
end
function stan_string(p::Union{Type{Rayleigh},Rayleigh})
  try
    parameters = (params(p)[1])
    return string("rayleigh($parameters)")
  catch
    return string("rayleigh")
  end
end
function stan_string(p::Union{Type{Pareto},Pareto})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("pareto$parameters")
  catch
    return string("pareto")
  end
end
function stan_string(p::Union{Type{GeneralizedPareto},GeneralizedPareto})
  try
    parameters = (params(p)[1],params(p)[2],params(p)[3])
    return string("pareto_type_2$parameters")
  catch
    return string("pareto_type_2")
  end
end
function stan_string(p::Union{Type{Beta},Beta})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("beta$parameters")
  catch
    return string("beta")
  end
end
function stan_string(p::Union{Type{Uniform},Uniform})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("uniform$parameters")
  catch
    return string("uniform")
  end
end
function stan_string(p::Union{Type{VonMises},VonMises})
  try
    parameters = (params(p)[1],params(p)[2])
    return string("von_mises$parameters")
  catch
    return string("von_mises")
  end
end
function stan_string(p::T) where {T<:Truncated}
  lower = p.lower
  upper = p.upper
  raw_string = stan_string(p.untruncated)
  return string(raw_string," T[$lower,$upper]")
end
