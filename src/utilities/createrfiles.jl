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

