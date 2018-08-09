"""

# read_stanfit 

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
function read_stanfit(model::Stanmodel)
  
  ## Collect the results of a chain in an array ##
  
  chainarray = Dict[]
  
  ## Each chain dictionary can contain up to 5 types of results ##
  
  result_type_files = ["samples", "diagnostics", "optimize", "diagnose", "variational"]
  rtdict = Dict()
  
  ## tdict contains the arrays of values ##
  tdict = Dict()
  
  for i in 1:model.nchains
    for res_type in result_type_files
      if isfile("$(model.name)_$(res_type)_$(i).csv")
        ## A result type file for chain i is present ##
        ## Result type diagnose needs special treatment ##
        instream = open("$(model.name)_$(res_type)_$(i).csv")
        if res_type == "diagnose"
          tdict = Dict()
          str = read(instream, String)
          sstr = split(str)
          tdict = merge(tdict, Dict(:stan_major_version => [parse(Int, sstr[4])]))
          tdict = merge(tdict, Dict(:stan_minor_version => [parse(Int, sstr[8])]))
          tdict = merge(tdict, Dict(:stan_patch_version => [parse(Int, sstr[12])]))
          if tdict[:stan_minor_version][1] >= 10
            # Stan minor version >= 10
            sstr_lp = sstr[79]
            sstr_lp = parse(Float64, split(sstr_lp, '=')[2])
            tdict = merge(tdict, Dict(:lp => [sstr_lp]))
            tdict = merge(tdict, Dict(:var_id => [parse(Int, sstr[90])]))
            tdict = merge(tdict, Dict(:value => [parse(Float64, sstr[91])]))
            tdict = merge(tdict, Dict(:model => [parse(Float64, sstr[92])]))
            tdict = merge(tdict, Dict(:finite_dif => [parse(Float64, sstr[93])]))
            tdict = merge(tdict, Dict(:error => [parse(Float64, sstr[94])]))
          else
            instream = open("$(model.name)_$(res_type)_$(i).csv")
            skipchars(isspace, instream, linecomment='#')
            i = 0
            skipchars(isspace, instream, linecomment='#')
            while true
              i += 1 
              line = Unicode.normalize(readline(instream), newline2lf=true)
              if i == 1
                tdict = merge(tdict, Dict(:lp => [float(split(line[1:(length(line)-1)], "=")[2])]))
              elseif i == 3
                sa = split(line[1:(length(line)-1)])
                tdict = merge(tdict, Dict(:var_id => [parse(Int, sa[1])], :value => [float(sa[2])]))
                tdict = merge(tdict, Dict(:model => [float(sa[3])], :finite_dif => [float(sa[4])]))
                tdict = merge(tdict, Dict(:error => [float(sa[5])]))
              end
              if eof(instream)
                close(instream)
                break
              end
              skipchars(isspace, instream, linecomment='#')
            end
          end
        else
          #println("Type of result file is $(res_type)")
          tdict = Dict()
          skipchars(isspace, instream, linecomment='#')
          line = Unicode.normalize(readline(instream), newline2lf=true)
          idx = split(strip(line), ",")
          index = [idx[k] for k in 1:length(idx)]
          #res_type == "optimize" && println(index)
          j = 0
          skipchars(isspace, instream, linecomment='#')
          while true
            j += 1
            #skipchars(isspace, instream, linecomment='#')
            line = Unicode.normalize(readline(instream), newline2lf=true)
            flds = Float64[]
            if eof(instream) && length(line) < 2
              #println("EOF detected")
              close(instream)
              #return(tdict)
              break
            else
              #println(split(strip(line)))
              flds = parse.(Float64, (split(strip(line), ",")))
              for k in 1:length(index)
                if j ==1
                  tdict = merge(tdict, Dict(index[k] => [flds[k]]))
                else
                  tdict[index[k]] = push!(tdict[index[k]], flds[k])
                end
              end
            end
          end
        end
        
      end
      
      ## End of processing result type file ##
      ## If any keys were found, merge it in the rtdict ##
      
      if length(keys(tdict)) > 0
        #println("Merging $(res_type) with keys $(keys(tdict))")
        rtdict = merge(rtdict, Dict(res_type => tdict))
        tdict = Dict()
      end
    end
    
    ## If rtdict has keys, push it to the chain array ##
    
    if length(keys(rtdict)) > 0
      #println("Pushing the rtdict with keys $(keys(rtdict))")
      push!(chainarray, rtdict)
      rtdict = Dict()
    end
  end
  chainarray
end


#### Create
####   if m.useMamba = true
####     a Mamba::Chains for results or warmup samples
####   else
####     an Array
####   end

function read_stanfit_warmup_samples(m::Stanmodel, diagnostics=false)
  if !m.method.save_warmup
    println("Saving of warmup samples not requested in StanModel. Returning samples.")
  end
  Stan.read_stanfit_samples(m::Stanmodel, diagnostics, true)
end

function read_stanfit_samples(m::Stanmodel, diagnostics=false, warmup_samples=false)

  global a3d, monitors, index, idx, indvec, ftype
  
  local noofsamples
  
  ftype = diagnostics ? "diagnostics" : "samples"
	
  for i in 1:m.nchains
    if isfile("$(m.name)_$(ftype)_$(i).csv")
      noofsamples = 0
      instream = open("$(m.name)_$(ftype)_$(i).csv")
      skipchars(isspace, instream, linecomment='#')
      line = Unicode.normalize(readline(instream), newline2lf=true)
      idx = split(strip(line), ",")
      index = [idx[k] for k in 1:length(idx)]
      if length(m.monitors) == 0
        indvec = 1:length(index)
      else
        indvec = findall(in(m.monitors), index)
      end
      if m.method.save_warmup
        noofsamples = floor(Int, (m.method.num_samples+m.method.num_warmup)/m.method.thin)
      else
        noofsamples = floor(Int, m.method.num_samples/m.method.thin)
      end
      if i == 1
        a3d = fill(0.0, noofsamples, length(indvec), m.nchains)
      end
      #println(size(a3d))
      skipchars(isspace, instream, linecomment='#')
      for j in 1:noofsamples
        skipchars(isspace, instream, linecomment='#')
        line = Unicode.normalize(readline(instream), newline2lf=true)
        if eof(instream) && length(line) < 2
          close(instream)
          break
        else
          flds = parse.(Float64, (split(strip(line), ",")))
          flds = reshape(flds[indvec], 1, length(indvec))
          a3d[j,:,i] = flds
        end
      end
    end
  end
  
  if m.method.save_warmup
    if warmup_samples
      if m.useMamba
        sr = getindex(a3d, [1:1:size(a3d, 1);], 
          [1:size(a3d, 2);], [1:size(a3d, 3);])
        Chains(sr, start=1, thin=1, names=idx[indvec], 
          chains=[i for i in 1:m.nchains])
      else
        a3d
      end
    else
      skip_warmup_indx = floor(Int, m.method.num_warmup/m.method.thin) + 1
      if m.useMamba
        sr = getindex(a3d, [skip_warmup_indx:1:noofsamples;], 
          [1:size(a3d, 2);], [1:size(a3d, 3);])
        Chains(sr, start=skip_warmup_indx, thin=1, 
          names=idx[indvec], chains=[i for i in 1:m.nchains])
      else
        a3d
      end
    end
  else  
    if m.useMamba
      sr = getindex(a3d, [1:size(a3d, 1);], 
        [1:size(a3d, 2);], [1:size(a3d, 3);])
      Chains(sr, start=1, thin=m.mambaThinning, names=idx[indvec],
        chains=[i for i in 1:m.nchains])
    else
      a3d
    end
  end
end

function read_stanfit_variational_samples(m::Stanmodel)

  local a3d, monitors, index, idx, indvec, ftype
  ftype = "variational"
  
  for i in 1:m.nchains
    if isfile("$(m.name)_$(ftype)_$(i).csv")
      instream = open("$(m.name)_$(ftype)_$(i).csv")
      skipchars(isspace, instream, linecomment='#')
      line = Unicode.normalize(readline(instream), newline2lf=true)
      idx = split(strip(line), ",")
      index = [idx[k] for k in 1:length(idx)]
      if length(m.monitors) == 0
        indvec = 1:length(index)
      else
        indvec = findall(in(m.monitors), index)
      end
      if i == 1
        a3d = fill(0.0, m.method.output_samples, length(indvec), m.nchains)
      end
      skipchars(isspace, instream, linecomment='#')
      for j in 1:m.method.output_samples
        skipchars(isspace, instream, linecomment='#')
        line = Unicode.normalize(readline(instream), newline2lf=true)
        if eof(instream) && length(line) < 2
          close(instream)
          break
        else
          flds = parse.(Float64, (split(strip(line), ",")))
          flds = reshape(flds[indvec], 1, length(indvec))
          a3d[j,:,i] = flds
        end
      end
    end
  end
  
  if m.useMamba
    sr = getindex(a3d, [1:1:size(a3d, 1);], [1:size(a3d, 2);], [1:size(a3d, 3);])
    Chains(sr, start=1, thin=m.mambaThinning, names=idx[indvec],
      chains=[i for i in 1:m.nchains])
  else
    a3d
  end
end

