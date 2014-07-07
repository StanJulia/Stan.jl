#
# Basic definitions
#

function stan(model::Model, data=Nothing, ProjDir=pwd();
  summary=true, diagnostics=false, StanDir=STANDIR)
  
  old = pwd()
  println()
  try
    cd(string(Pkg.dir("$(ProjDir)")))
    isfile("$(model.name)_build.log") && rm("$(model.name)_build.log")
    isfile("$(model.name)_run.log") && rm("$(model.name)_run.log")

    cd(string(Pkg.dir(StanDir)))
    run(`make $(ProjDir)/$(model.name)` .> "$(ProjDir)/$(model.name)_build.log")

    cd(string(Pkg.dir("$(ProjDir)")))
    if data != Nothing && isa(data, String)
      model.data.file = data
    end
    for i in 1:model.noofchains
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
  local res = DataFrame()

  if isa(model.method, Sample)
    for i in 1:model.noofchains
      res = vcat(res, read_stanfit(("$(model.name)_samples_$(i).csv")))
      push!(samplefiles, "$(model.name)_samples_$(i).csv")
    end
  elseif isa(model.method, Optimize)
    res = read_stanfit(("$(model.name)_optimize_1.csv"))
    push!(samplefiles, "$(model.name)_optimize_1.csv")
  elseif isa(model.method, Diagnose)
    res = read_standiagnose(("$(model.name)_diagnose_1.csv"))
    push!(samplefiles, "$(model.name)_diagnose_1.csv")
  else
    println("Unknown method.")
  end
  
  if isa(model.method, Sample) && summary
    stan_summary(par(samplefiles))
  end
  
  cd(old)
  res
end

function stan_summary(file::String; StanDir=getenv("STAN_HOME"))
  try
    cmd = @unix ? `$(StanDir)/bin/print $(file)` : `$(StanDir)\bin\print.exe $(file)`
    print(open(readall, cmd, "r"))
  catch e
    println(e)
  end
end

function stan_summary(filecmd::Cmd; StanDir=getenv("STAN_HOME"))
  try
    cmd = @unix ? `$(StanDir)/bin/print $(filecmd)` : `$(StanDir)\bin\print.exe $(filecmd)`
    print(open(readall, cmd, "r"))
  catch e
    println(e)
  end
end

function read_stanfit(file::String)
  
  instream = open(file)
  tmpfile = "tmp_"*file
  outstream = open(tmpfile, "w")
  skipchars(instream, isspace, linecomment='#')

  i = 0
  while true
    i += 1 
    line = readline(instream)
    #println(i, ": ", line)
    if eof(instream)
      write(outstream, line)
      close(outstream)
      break
    end
    write(outstream, line)
    skipchars(instream, isspace, linecomment='#')
  end
  
  
  df = readtable(tmpfile, allowcomments=true, nrows=i)
  rm(tmpfile)
  df
end

function read_standiagnose(file::String)
  
  instream = open(file)
  skipchars(instream, isspace, linecomment='#')

  i = 0
  dict = Dict()
  while true
    i += 1 
    line = readline(instream)
    #println(i, ": ", line)
    if i == 1
      dict = merge(dict, [:lp => float(split(line[1:(length(line)-1)], "=")[2])])
    elseif i == 3
      sa = split(line)
      dict = merge(dict, [:var_id => int(sa[1]), :value => float(sa[2])])
      dict = merge(dict, [:model => float(sa[3]), :finite_dif => float(sa[4])])
      dict = merge(dict, [:error => float(sa[5])])
    end
    if eof(instream)
      break
    end
    skipchars(instream, isspace, linecomment='#')
  end
  dict
end

 