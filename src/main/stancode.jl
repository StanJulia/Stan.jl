import Base:*

"""

# stan 

Execute a Stan model. 

### Method
```julia
stan(
  model::Stanmodel, 
  data=Void, 
  ProjDir=pwd();
  summary=true, 
  diagnostics=false, 
  CmdStanDir=CMDSTAN_HOME
)
```
### Required arguments
```julia
* `model::Stanmodel`              : See ?Method
* `data=Void`                     : Observed input data dictionary 
* `ProjDir=pwd()`                 : Project working directory
```

### Optional arguments
```julia
* `init=Void`                     : Initial parameter value dictionary
* `summary=true`                  : Use CmdStan's stansummary to display results
* `diagnostics=false`             : Generate diagnostics file
* `CmdStanDir=CMDSTAN_HOME`       : Location of CmdStan directory
```

### Related help
```julia
?Stanmodel                      : Create a StanModel
```
"""
function stan(
  model::Stanmodel, 
  data=Void, 
  ProjDir=pwd();
  init=Void,
  summary=true, 
  diagnostics=false, 
  CmdStanDir=CMDSTAN_HOME)
  
  old = pwd()
  local rc = 0
  local res = Dict[]
  
  println()
  if length(model.model) == 0
    println("\nNo proper model specified in \"$(model.name).stan\".")
    println("This file is typically created from a String passed to Stanmodel().\n")
    return((-1, res))
  end
  
  @assert isdir(ProjDir) "Incorrect ProjDir specified: $(ProjDir)"
  @assert isdir(model.tmpdir) "$(model.tmpdir) not created"
  
  cd(model.tmpdir)
  isfile("$(model.name)_build.log") && rm("$(model.name)_build.log")
  isfile("$(model.name)_run.log") && rm("$(model.name)_run.log")

  cd(CmdStanDir)
  local tmpmodelname::String
  tmpmodelname = Pkg.dir(model.tmpdir, model.name)
  if @static is_windows() ? true : false
    tmpmodelname = replace(tmpmodelname*".exe", "\\", "/")
  end
  try
    run(pipeline(`make $(tmpmodelname)`, stderr="$(tmpmodelname)_build.log"))
  catch
    println("\nAn error occurred while compiling the Stan program")
    print("Please check your Stan program in variable '$(model.name)' ")
    println("and the contents of $(tmpmodelname)_build.log")
    return(-3, res)
  end
        
  cd(model.tmpdir)
  if data != Void && check_dct_type(data)
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
  if init != Void && check_dct_type(init)
    if length(init) == model.nchains
      for i in 1:model.nchains
        if length(keys(init[i])) > 0
          update_R_file("$(model.name)_$(i).init.R", init[i])
        end
      end
    else
      for i in 1:model.nchains
        if length(keys(init[1])) > 0
          if i == 1
            println("\nLength of init array is not equal to nchains,")
            println("all chains will use the first init dictionary.")
          end
          update_R_file("$(model.name)_$(i).init.R", init[1])
        end
      end
    end
  end
  for i in 1:model.nchains
    model.id = i
    model.data_file ="$(model.name)_$(i).data.R"
    if !(model.init == Void)
        model.init_file = "$(model.name)_$(i).init.R"
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
  try
    run(pipeline(par(model.command), stdout="$(model.name)_run.log"))
  catch e
    println("\nAn error occurred while running the previously compiled Stan program.")
    print("Please check the contents of file $(tmpmodelname)_run.log and the")
    println("'command' field in the Stanmodel, e.g. stanmodel.command.")
    cd(old)
    return(-5, res)
  end
  
  local samplefiles = String[]
  local ftype
  
  if isa(model.method, Sample)
    ftype = diagnostics ? "diagnostics" : "samples"
    for i in 1:model.nchains
      push!(samplefiles, "$(model.name)_$(ftype)_$(i).csv")
    end
    if isa(model.method, Sample) && summary
      stan_summary(par(samplefiles), CmdStanDir=CmdStanDir)
    end
    res = read_stanfit_samples(model, diagnostics)
  elseif isa(model.method, Variational)
    ftype = "variational"
    for i in 1:model.nchains
      push!(samplefiles, "$(model.name)_$(ftype)_$(i).csv")
    end
    if isa(model.method, Variational) && summary
      stan_summary(par(samplefiles), CmdStanDir=CmdStanDir)
    end
    res = read_stanfit_variational_samples(model)
  elseif isa(model.method, Optimize)
    res = read_stanfit(model)
  elseif isa(model.method, Diagnose)
    res = read_stanfit(model)
  else
    println("Unknown method.")
    rc = -10
  end
  
  cd(old)
  (rc, res)
end

"""

# Method stan_summary

Display CmdStan summary 

### Method
```julia
stan_summary(
  file::String; 
  CmdStanDir=CMDSTAN_HOME
)
```
### Required arguments
```julia
* `file::String`                : Name of file with samples
```

### Optional arguments
```julia
* CmdStanDir=CMDSTAN_HOME       : CmdStan directory for stansummary program
```

### Related help
```julia
?Stan.stan                      : Execute a StanModel
```
"""
function stan_summary(file::String; CmdStanDir=CMDSTAN_HOME)
  try
    pstring = Pkg.dir("$(CmdStanDir)", "bin", "stansummary")
    cmd = `$(pstring) $(file)`
    print(open(readstring, cmd, "r"))
  catch e
    println(e)
  end
end

"""

# Method stan_summary

Display CmdStan summary 

### Method
```julia
stan_summary(
  filecmd::Cmd; 
  CmdStanDir=CMDSTAN_HOME
)
```
### Required arguments
```julia
* `filecmd::Cmd`                : Run command containing names of sample files
```

### Optional arguments
```julia
* CmdStanDir=CMDSTAN_HOME       : CmdStan directory for stansummary program
```

### Related help
```julia
?Stan.stan                      : Create a StanModel
```
"""
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

