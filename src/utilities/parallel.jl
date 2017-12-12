if !isdefined(Main, :Jags)
  function *(c1::Cmd, c2::Cmd)
    res = deepcopy(c1)
    for i in 1:length(c2.exec)
      push!(res.exec, c2.exec[i])
    end
    res
  end

  function *(c1::Cmd, sa::Array{String, 1})
    res = deepcopy(c1)
    for i in 1:length(sa)
      push!(res.exec, sa[i])
    end
    res
  end

  function *(c1::Cmd, s::String)
    res = deepcopy(c1)
    push!(res.exec, s)
    res
  end
end

"""

# par 

Rewrite dct to R format in file. 

### Method
```julia
par(cmds)
```

### Required arguments
```julia
* `cmds::Array{Base.AbstractCmd,1}`    : Multiple commands to concatenate

or

* `cmd::Base.AbstractCmd`              : Single command to be
* `n::Number`                            inserted n times into cmd


or
* `cmd::Array{String, 1}`              : Array of cmds as Strings
```

"""
function par(cmds::Array{Base.AbstractCmd,1})
  if length(cmds) > 2
    return(par([cmds[1:(length(cmds)-2)];
      Base.AndCmds(cmds[length(cmds)-1], cmds[length(cmds)])]))
  elseif length(cmds) == 2
    return(Base.AndCmds(cmds[1], cmds[2]))
  else
    return(cmds[1])
  end
end

function par(cmd::Base.AbstractCmd, n::Number)
  res = deepcopy(cmd)
  if n > 1
    for i in 2:n
      res = Base.AndCmds(res, cmd)
    end
  end
  res
end

function par(cmd::Array{String, 1})
  res = `$(cmd[1])`
  for i in 2:length(cmd)
    res = res*` $(cmd[i])`
  end
  res
end
