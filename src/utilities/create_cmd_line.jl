using Unicode

"""

# cmdline 

Recursively parse the model to construct command line. 

### Method
```julia
cmdline(m)
```

### Required arguments
```julia
* `m::Stanmodel`                : Stanmodel
```

### Related help
```julia
?Stanmodel                      : Create a StanModel
```
"""
function cmdline(m)
  cmd = ``
  if isa(m, Stanmodel)
    # Handle the model name field for unix and windows
    cmd = @static Sys.isunix() ? `./$(getfield(m, :name))` : `cmd /c $(getfield(m, :name)).exe`

    # Method (sample, optimize, variational and diagnose) specific portion of the model
    cmd = `$cmd $(cmdline(getfield(m, :method)))`
    
    # Common to all models
    cmd = `$cmd $(cmdline(getfield(m, :random)))`
    
    # Init file required?
    if length(m.init_file) > 0 && isfile(m.init_file)
      cmd = `$cmd init=$(m.init_file)`
    end
    
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
    if isa(m, SamplingAlgorithm) || isa(m, OptimizeAlgorithm)
      cmd = `$cmd algorithm=$(split(lowercase(string(typeof(m))), '.')[end])`
    elseif isa(m, Engine)
      cmd = `$cmd engine=$(split(lowercase(string(typeof(m))), '.')[end])`
    elseif isa(m, Diagnostics)
      cmd = `$cmd test=$(split(lowercase(string(typeof(m))), '.')[end])`
    else
      cmd = `$cmd $(split(lowercase(string(typeof(m))), '.')[end])`
    end
    #println(cmd)
    for name in fieldnames(typeof(m))
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

