if !isdefined(Main, :GenerateData)
  function GenerateData(kappa,omega,Nsubj,Ntrials)
    data = fill(0,Nsubj*Ntrials)
    SubjIdx = similar(data)
    cnt = 0
    for subj in 1:Nsubj
      alpha = kappa*omega
      beta = (1-kappa)*omega
      theta = rand(Beta(alpha,beta))
      for trial in 1:Ntrials
        cnt += 1
        data[cnt] = rand(Bernoulli(theta))
        SubjIdx[cnt] = subj
      end
    end
    return data,SubjIdx
  end
end

if !isdefined(Main, :InitializeChain)
  function InitializeChain(Nteams,Nchains,teamParm,divParm,teamVal,divVal)
    init = Dict{String, Any}[Dict() for chains = 1:Nchains]
    for chain in 1:Nchains
      for team in 1:Nteams
        for i in zip(teamParm,teamVal)
           name = string(i[1],"[",team,"]")
           init[chain][name] = rand(Normal(i[2][1],i[2][2]))
        end
      end
      for i in zip(divParm,divVal)
        name = string(i[1])
        init[chain][name] = i[2]
      end
    end
    return init
  end
end