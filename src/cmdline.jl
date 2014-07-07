"Recursively parse the model to construct command line"

function cmdline(m)
  cmd = ``
  if isa(m, Model)
    # Handle the model name field for unix and windows
    cmd = @unix ? `./` : ``
    cmd = @unix ? `$cmd$(getfield(m, :name))` : `$cmd$(getfield(m, :name)).exe`

    # Method (sample, optimize and diagnose) specific portion of the model
    cmd = `$cmd $(cmdline(getfield(m, :method)))`
    
    # Common to all models
    cmd = `$cmd $(cmdline(getfield(m, :random)))`
    cmd = `$cmd init=$(getfield(m, :init).init)`
    
    # Data file required?
    if length(getfield(m, :data).file) > 0
      cmd = `$cmd $(cmdline(getfield(m, :data)))`
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

cmdl = `./bernoulli sample num_samples=1000 num_warmup=1000 save_warmup=0 thin=10 adapt engaged=1 gamma=0.05 delta=0.8 kappa=0.75 t0=10.0 init_buffer=75 term_buffer=50 window=25 algorithm=hmc engine=nuts max_depth=10 metric=diag_e stepsize=1.0 stepsize_jitter=1.0 random seed=-1 init=2 data file='bernoulli.data.R' output file=output.csv refresh=100`

