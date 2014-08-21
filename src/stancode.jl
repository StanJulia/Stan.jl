#
# Basic definitions
#

function stan(model::Stanmodel, data=Nothing, ProjDir=pwd();
  summary=true, diagnostics=false, StanDir=CMDSTANDIR)
  
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

    cd(string(Pkg.dir(StanDir)))
    run(`make $(ProjDir)/$(model.name)` .> "$(ProjDir)/$(model.name)_build.log")

    cd(string(Pkg.dir("$(ProjDir)")))
    if data != Nothing && isa(data, Array{Dict{ASCIIString, Any}, 1}) && length(data) > 0
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
    for i in 1:model.nchains
      model.id = i
      model.data_file ="$(model.name)_$(i).data.R"
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
      elseif isa(model.method, Diagnose)
        isfile("$(model.name)_diagnose_$(i).csv") && rm("$(model.name)_diagnose_$(i).csv")
        model.output.file = model.name*"_diagnose_$(i).csv"
      end
      model.command[i] = cmdline(model)
    end
    println()
    run(par(model.command) >> "$(model.name)_run.log")
  catch e
    println(e)
    cd(old)
    return
  end
  
  local samplefiles = String[]
  local res = Dict[]

  if isa(model.method, Sample)
    for i in 1:model.nchains
      push!(samplefiles, "$(model.name)_samples_$(i).csv")
    end
    res = read_stanfit(model)
  elseif isa(model.method, Optimize)
    res = read_stanfit(model)
  elseif isa(model.method, Diagnose)
    res = read_stanfit(model)
  else
    println("Unknown method.")
  end
  
  if isa(model.method, Sample) && summary
    stan_summary(par(samplefiles))
  end
  
  cd(old)
  res
end

function update_R_file(file::String, dct::Dict{ASCIIString, Any}; replaceNaNs::Bool=true)
  isfile(file) && rm(file)
  strmout = open(file, "w")
  
  str = ""
  for entry in dct
    str = "\""*entry[1]*"\""*" <- "
    val = entry[2]
    #=
    if replaceNaNs && true in isnan(entry[2])
      val = convert(DataArray, entry[2])
      for i in 1:length(val)
        if isnan(val[i])
          val[i] = "NA"
        end
      end
    end
    =#
    if length(val)==1 && length(size(val))==0
      # Scalar
      str = str*"$(val)\n"
    elseif length(val)>1 && length(size(val))==1
      # Vector
      str = str*"structure(c("
      for i in 1:length(val)
        str = str*"$(val[i])"
        if i < length(val)
          str = str*", "
        end
      end
      str = str*"), .Dim=c($(length(val))))\n"
    elseif length(val)>1 && length(size(val))>1
      # Array
      str = str*"structure(c("
      for i in 1:length(val)
        str = str*"$(val[i])"
        if i < length(val)
          str = str*", "
        end
      end
      dimstr = "c"*string(size(val))
      str = str*"), .Dim=$(dimstr))\n"
    end
    write(strmout, str)
  end
  close(strmout)
end

function stan_summary(file::String; StanDir=getenv("CMDSTAN_HOME"))
  try
    cmd = @unix ? `$(StanDir)/bin/print $(file)` : `$(StanDir)\bin\print.exe $(file)`
    print(open(readall, cmd, "r"))
  catch e
    println(e)
  end
end

function stan_summary(filecmd::Cmd; StanDir=getenv("CMDSTAN_HOME"))
  try
    cmd = @unix ? `$(StanDir)/bin/print $(filecmd)` : `$(StanDir)\bin\print.exe $(filecmd)`
    print(open(readall, cmd, "r"))
  catch e
    println(e)
  end
end

function read_stanfit(model::Stanmodel)
  
  ## Collect the results of a chain in an array ##
  
  chainarray = Dict[]
  
  ## Each chain dictionary can contain up to 4 types of results ##
  
  result_type_files = ["samples", "diagnostics", "optimize", "diagnose"]
  rtdict = Dict()
  
  ## tdict contains the arrays of values ##
  tdict = Dict()
  
  for i in 1:model.nchains
    for res_type in result_type_files
      #println(res_type)
      if isfile("$(model.name)_$(res_type)_$(i).csv")
        instream = open("$(model.name)_$(res_type)_$(i).csv")
        #println("$(model.name)_$(res_type)_$(i).csv")
        
        ## A result type file for chain i is present ##
        ## Result type diagnose needs special treatment ##
        
        if res_type == "diagnose"
          skipchars(instream, isspace, linecomment='#')
          i = 0
          tdict = Dict()
          while true
            i += 1 
            line = readline(instream)
            #println(i, ": ", line)
            if i == 1
              tdict = merge(tdict, [:lp => [float(split(line[1:(length(line)-1)], "=")[2])]])
            elseif i == 3
              sa = split(line)
              tdict = merge(tdict, [:var_id => [int(sa[1])], :value => [float(sa[2])]])
              tdict = merge(tdict, [:model => [float(sa[3])], :finite_dif => [float(sa[4])]])
              tdict = merge(tdict, [:error => [float(sa[5])]])
            end
            if eof(instream)
              break
            end
            skipchars(instream, isspace, linecomment='#')
          end
        else
          tdict = Dict()
          skipchars(instream, isspace, linecomment='#')
          line = readline(instream)
          #res_type == "optimize" && println(line)
          idx = split(line[1:length(line)-1], ",")
          index = [idx[k] for k in 1:length(idx)]
          #res_type == "optimize" && println(index)
          j = 0
          skipchars(instream, isspace, linecomment='#')
          while true
            j += 1
            skipchars(instream, isspace, linecomment='#')
            line = readline(instream)
            #res_type == "optimize" && println(line)
            if eof(instream) && length(line) == 0
              #println("EOF detected")
              close(instream)
              break
            else
              flds = float(split(line[1:length(line)-1], ","))
              #res_type == "optimize" && println(flds)
              for k in 1:length(index)
                if j ==1
                  tdict = merge(tdict, [index[k] => [flds[k]]])
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
        rtdict = merge(rtdict, [res_type => tdict])
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

"Recursively parse the model to construct command line"

function cmdline(m)
  cmd = ``
  if isa(m, Stanmodel)
    # Handle the model name field for unix and windows
    cmd = @unix ? `./` : ``
    cmd = @unix ? `$cmd$(getfield(m, :name))` : `$cmd$(getfield(m, :name)).exe`

    # Method (sample, optimize and diagnose) specific portion of the model
    cmd = `$cmd $(cmdline(getfield(m, :method)))`
    
    # Common to all models
    cmd = `$cmd $(cmdline(getfield(m, :random)))`
    cmd = `$cmd init=$(getfield(m, :init).init)`
    
    # Data file required?
    if length(m.data_file) > 0
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
      cmd = `$cmd algorithm=$(lowercase(string(typeof(m))))`
    elseif isa(m, Engine)
      cmd = `$cmd engine=$(lowercase(string(typeof(m))))`
    elseif isa(m, Diagnostics)
      cmd = `$cmd test=$(lowercase(string(typeof(m))))`
    else
      cmd = `$cmd $(lowercase(string(typeof(m))))`
    end
    #println(cmd)
    for name in names(m)
      #println("$(name) = $(getfield(m, name)) ($(typeof(getfield(m, name))))")
      if  isa(getfield(m, name), String) || isa(getfield(m, name), Tuple)
        cmd = `$cmd $(name)=$(getfield(m, name))`
      elseif length(names(typeof(getfield(m, name)))) == 0
        if isa(getfield(m, name), Bool)
          cmd = `$cmd $(name)=$(getfield(m, name) ? 1 : 0)`
        else
          if name == :metric || isa(getfield(m, name), DataType) 
            cmd = `$cmd $(name)=$(typeof(getfield(m, name)))`
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
 