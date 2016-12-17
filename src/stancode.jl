#
# Basic definitions
#

function check_data_type(data)
  if typeof(data) <: Array && length(data) > 0
    if keytype(data[1]) == String && valtype(data[1]) <: Any
      return true
    end
  end
  return false
end

function prepare_init(model::Stanmodel, init::Init{Int})
    # do nothing
end
function prepare_init(model::Stanmodel, init::Init{Float64})
    # do nothing
end
function prepare_init(model::Stanmodel, init::Init{Vector{DataDict}})
  init.init_files = String[]
  init_data = init.init
  if length(init_data) == model.nchains
    for i in 1:model.nchains
      if length(keys(init_data[i])) > 0
        init_file="$(model.name)_$(i).init.R"
        push!(init.init_files, init_file)
        update_R_file(init_file, init_data[i])
      end
    end
  else
    for i in 1:model.nchains
      if length(keys(init_data[1])) > 0
        if i == 1
          println("\nLength of init array is not equal to nchains,")
          println("all chains will use the first init dictionary.")
        end
        init_file="$(model.name)_$(i).init.R"
        push!(init.init_files, init_file)
        update_R_file(init_file, init_data[1])
      end
    end
  end
end

function stan(
  model::Stanmodel, 
  data=Void, 
  ProjDir=pwd();
  summary=true, 
  diagnostics=false, 
  CmdStanDir=CMDSTAN_HOME)
  
  old = pwd()
  
  println()
  if length(model.model) == 0
    println("\nNo proper model specified in \"$(model.name).stan\".")
    println("This file is typically created from a String passed to Stanmodel().\n")
    return
  end
  try
    cd(string(Pkg.dir("$(ProjDir)")))
    isfile("$(model.name)_build.log") && rm("$(model.name)_build.log")
    isfile("$(model.name)_run.log") && rm("$(model.name)_run.log")

    #println("Current working dir: $(pwd())")
    #println("Moving to dir: $(CmdStanDir)")
    
    cd(CmdStanDir)
    local tmpmodelname::String
    tmpmodelname = Pkg.dir(model.tmpdir, model.name)
    if @static is_windows() ? true : false
      tmpmodelname = replace(tmpmodelname*".exe", "\\", "/")
    end
    #println("Current working dir: $(pwd())")
    #println("Compile using make $(tmpmodelname)")
    run(pipeline(`make $(tmpmodelname)`, stderr="$(tmpmodelname)_build.log"))
        
    cd(model.tmpdir)
    if data != Void && check_data_type(data)
      if length(data) == model.nchains
        for i in 1:model.nchains
          if length(keys(data[i])) > 0
            update_R_file("$(model.name)_$(i).data.R", data[i])
          end
        end
      else
        for i in 1:model.nchains
          if length(keys(data[1])) > 0
            if i == 1
              println("\nLength of data array is not equal to nchains,")
              println("all chains will use the first data dictionary.")
            end
            update_R_file("$(model.name)_$(i).data.R", data[1])
          end
        end
      end
    end
    prepare_init(model, model.init)
    for i in 1:model.nchains
      model.id = i
      model.data_file ="$(model.name)_$(i).data.R"
      if length(model.init.init_files) > 0
          model.init.init_file = model.init.init_files[i]
      end
      if isa(model.method, Sample)
        model.output.file = model.name*"_samples_$(i).csv"
        isfile("$(model.name)_samples_$(i).csv") && rm("$(model.name)_samples_$(i).csv")
        if diagnostics
          model.output.diagnostic_file = model.name*"_diagnostics_$(i).csv"
          isfile("$(model.name)_diagnostics_$(i).csv") && rm("$(model.name)_diagnostics_$(i).csv")
        end
      elseif isa(model.method, Optimize)
        isfile("$(model.name)_optimize_$(i).csv") && rm("$(model.name)_optimize_$(i).csv")
        model.output.file = model.name*"_optimize_$(i).csv"
      elseif isa(model.method, Variational)
        isfile("$(model.name)_variational_$(i).csv") && rm("$(model.name)_variational_$(i).csv")
        model.output.file = model.name*"_variational_$(i).csv"
      elseif isa(model.method, Diagnose)
        isfile("$(model.name)_diagnose_$(i).csv") && rm("$(model.name)_diagnose_$(i).csv")
        model.output.file = model.name*"_diagnose_$(i).csv"
      end
      model.command[i] = cmdline(model)
    end
    run(pipeline(par(model.command), stdout="$(model.name)_run.log"))
  catch e
    println(e)
    cd(old)
    return
  end
  
  local samplefiles = String[]
  local res = Dict[]
  local ftype
  
  if isa(model.method, Sample)
    ftype = diagnostics ? "diagnostics" : "samples"
    for i in 1:model.nchains
      push!(samplefiles, "$(model.name)_$(ftype)_$(i).csv")
    end
    if isa(model.method, Sample) && summary
      stan_summary(par(samplefiles), CmdStanDir=CmdStanDir)
    end
    #cd(pwd()*"1"); println(pwd())
    res = read_stanfit_samples(model, diagnostics)
  elseif isa(model.method, Variational)
    ftype = "variational"
    for i in 1:model.nchains
      push!(samplefiles, "$(model.name)_$(ftype)_$(i).csv")
    end
    if isa(model.method, Variational) && summary
      stan_summary(par(samplefiles), CmdStanDir=CmdStanDir)
    end
    #cd(pwd()*"1"); println(pwd())
    res = read_stanfit_variational_samples(model)
  elseif isa(model.method, Optimize)
    res = read_stanfit(model)
  elseif isa(model.method, Diagnose)
    res = read_stanfit(model)
  else
    println("Unknown method.")
  end
  
  cd(old)
  res
end

function update_R_file{T<:Any}(file::String, dct::Dict{String, T}; replaceNaNs::Bool=true)
	isfile(file) && rm(file)
	strmout = open(file, "w")
	
	str = ""
	for entry in dct
		str = "\""entry[1]"\""" <- "
		val = entry[2]
		if length(val)==1 && length(size(val))==0
			# Scalar
			str = str*"$(val)\n"
      #elseif length(val)==1 && length(size(val))==1
			# Single element vector
			#str = str*"$(val[1])\n"
		elseif length(val)>=1 && length(size(val))==1
			# Vector
			str = str*"structure(c("
			write(strmout, str)
			str = ""
			writecsv(strmout, val');
			str = str*"), .Dim=c($(length(val))))\n"
		elseif length(val)>1 && length(size(val))>1
			# Array
			str = str*"structure(c("
			write(strmout, str)
			str = ""
			writecsv(strmout, val[:]');
			dimstr = "c"*string(size(val))
			str = str*"), .Dim=$(dimstr))\n"
		end
		write(strmout, str)
	end
	close(strmout)
end

function stan_summary(file::String; CmdStanDir=CMDSTAN_HOME)
  try
    pstring = Pkg.dir("$(CmdStanDir)", "bin", "stansummary")
    cmd = `$(pstring) $(file)`
    print(open(readstring, cmd, "r"))
  catch e
    println(e)
  end
end

function stan_summary(filecmd::Cmd; CmdStanDir=CMDSTAN_HOME)
  try
    pstring = Pkg.dir("$(CmdStanDir)", "bin", "stansummary")
    cmd = `$(pstring) $(filecmd)`
    println()
    println("Calling $(pstring) to infer across chains.")
    println()
    print(open(readstring, cmd, "r"))
  catch e
    println()
    println("Stan.jl caught above exception in Stan's 'stansummary' program.")
    println("This is a usually caused by the setting:")
    println("  Sample(save_warmup=true, thin=n)")
    println("in the call to stanmodel() with n > 1.")
    println()
  end
end

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
          str = readstring(instream)
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
            skipchars(instream, isspace, linecomment='#')
            i = 0
            skipchars(instream, isspace, linecomment='#')
            while true
              i += 1 
              line = normalize_string(readline(instream), newline2lf=true)
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
              skipchars(instream, isspace, linecomment='#')
            end
          end
        else
          #println("Type of result file is $(res_type)")
          tdict = Dict()
          skipchars(instream, isspace, linecomment='#')
          line = normalize_string(readline(instream), newline2lf=true)
          idx = split(line[1:length(line)-1], ",")
          index = [idx[k] for k in 1:length(idx)]
          #res_type == "optimize" && println(index)
          j = 0
          skipchars(instream, isspace, linecomment='#')
          while true
            j += 1
            #skipchars(instream, isspace, linecomment='#')
            line = normalize_string(readline(instream), newline2lf=true)
            flds = Float64[]
            #res_type == "optimize" && println(line)
            if eof(instream) && length(line) < 2
              #println("EOF detected")
              close(instream)
              #return(tdict)
              break
            else
              flds = float(split(line[1:length(line)-1], ","))
              #res_type == "optimize" && println(flds)
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


#### Create a Mamba::Chains for results or warmup samples

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
      skipchars(instream, isspace, linecomment='#')
      line = normalize_string(readline(instream), newline2lf=true)
      idx = split(line[1:length(line)-1], ",")
      index = [idx[k] for k in 1:length(idx)]
      if length(m.monitors) == 0
        indvec = 1:length(index)
      else
        indvec = findin(index, m.monitors)
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
      skipchars(instream, isspace, linecomment='#')
      for j in 1:noofsamples
        skipchars(instream, isspace, linecomment='#')
        line = normalize_string(readline(instream), newline2lf=true)
        if eof(instream) && length(line) < 2
          close(instream)
          break
        else
          flds = float(split(line[1:length(line)-1], ","))
          flds = reshape(flds[indvec], 1, length(indvec))
          a3d[j,:,i] = flds
        end
      end
    end
  end
  
  if m.method.save_warmup
    if warmup_samples
      sr = getindex(a3d, [1:1:size(a3d, 1);], 
        [1:size(a3d, 2);], [1:size(a3d, 3);])
      Chains(sr, start=1, thin=1, names=idx[indvec], 
        chains=[i for i in 1:m.nchains])
    else
      skip_warmup_indx = floor(Int, m.method.num_warmup/m.method.thin) + 1
      sr = getindex(a3d, [skip_warmup_indx:1:noofsamples;], 
        [1:size(a3d, 2);], [1:size(a3d, 3);])
      Chains(sr, start=skip_warmup_indx, thin=1, 
        names=idx[indvec], chains=[i for i in 1:m.nchains])
    end
  else  
    sr = getindex(a3d, [1:m.thin:size(a3d, 1);], 
      [1:size(a3d, 2);], [1:size(a3d, 3);])
    Chains(sr, start=1, thin=m.thin, names=idx[indvec], chains=[i for i in 1:m.nchains])
  end
end

function read_stanfit_variational_samples(m::Stanmodel)

  local a3d, monitors, index, idx, indvec, ftype
  ftype = "variational"
  
  for i in 1:m.nchains
    if isfile("$(m.name)_$(ftype)_$(i).csv")
      instream = open("$(m.name)_$(ftype)_$(i).csv")
      skipchars(instream, isspace, linecomment='#')
      line = normalize_string(readline(instream), newline2lf=true)
      idx = split(line[1:length(line)-1], ",")
      index = [idx[k] for k in 1:length(idx)]
      if length(m.monitors) == 0
        indvec = 1:length(index)
      else
        indvec = findin(index, m.monitors)
      end
      if i == 1
        a3d = fill(0.0, m.method.output_samples, length(indvec), m.nchains)
      end
      skipchars(instream, isspace, linecomment='#')
      for j in 1:m.method.output_samples
        skipchars(instream, isspace, linecomment='#')
        line = normalize_string(readline(instream), newline2lf=true)
        if eof(instream) && length(line) < 2
          close(instream)
          break
        else
          flds = float(split(line[1:length(line)-1], ","))
          flds = reshape(flds[indvec], 1, length(indvec))
          a3d[j,:,i] = flds
        end
      end
    end
  end
  
  sr = getindex(a3d, [1:1:size(a3d, 1);], [1:size(a3d, 2);], [1:size(a3d, 3);])
  Chains(sr, start=1, thin=1, names=idx[indvec], chains=[i for i in 1:m.nchains])
	
end


function init_cmdline(init::Init{Int})
  return `init=$(init.init)`
end
function init_cmdline(init::Init{Float64})
  return `init=$(init.init)`
end
function init_cmdline(init::Init{Vector{DataDict}})
  return `init=$(init.init_file)`
end

"Recursively parse the model to construct command line"
function cmdline(m)
  cmd = ``
  if isa(m, Stanmodel)
    # Handle the model name field for unix and windows
    cmd = @static is_unix() ? `./$(getfield(m, :name))` : `cmd /c $(getfield(m, :name)).exe`

    # Method (sample, optimize, variational and diagnose) specific portion of the model
    cmd = `$cmd $(cmdline(getfield(m, :method)))`
    
    # Common to all models
    cmd = `$cmd $(cmdline(getfield(m, :random)))`
    cmd = `$cmd $(init_cmdline(m.init))`
    
    # Data file required?
    if length(m.data_file) > 0 && isfile(m.data_file)
      cmd = `$cmd id=$(m.id) data file=$(m.data_file)`
    end
    
    # Output options
    cmd = `$cmd output`
    if length(getfield(m, :output).file) > 0
      cmd = `$cmd file=$(string(getfield(m, :output).file))`
    end
    if length(getfield(m, :output).diagnostic_file) > 0
      cmd = `$cmd diagnostic_file=$(string(getfield(m, :output).diagnostic_file))`
    end
    cmd = `$cmd refresh=$(string(getfield(m, :output).refresh))`
  else
    # The 'recursive' part
    #println(lowercase(string(typeof(m))))
    if isa(m, Algorithm)
      cmd = `$cmd algorithm=$(split(lowercase(string(typeof(m))), '.')[end])`
    elseif isa(m, Engine)
      cmd = `$cmd engine=$(split(lowercase(string(typeof(m))), '.')[end])`
    elseif isa(m, Diagnostics)
      cmd = `$cmd test=$(split(lowercase(string(typeof(m))), '.')[end])`
    else
      cmd = `$cmd $(split(lowercase(string(typeof(m))), '.')[end])`
    end
    #println(cmd)
    for name in fieldnames(m)
      #println("$(name) = $(getfield(m, name)) ($(typeof(getfield(m, name))))")
      if  isa(getfield(m, name), String) || isa(getfield(m, name), Tuple)
        cmd = `$cmd $(name)=$(getfield(m, name))`
      elseif length(fieldnames(typeof(getfield(m, name)))) == 0
        if isa(getfield(m, name), Bool)
          cmd = `$cmd $(name)=$(getfield(m, name) ? 1 : 0)`
        else
          if name == :metric || isa(getfield(m, name), DataType) 
            cmd = `$cmd $(name)=$(split(lowercase(string(typeof(getfield(m, name)))), '.')[end])`
          else
            cmd = `$cmd $(name)=$(getfield(m, name))`
          end
        end
      else
        cmd = `$cmd $(cmdline(getfield(m, name)))`
      end
    end
  end
  cmd
end

