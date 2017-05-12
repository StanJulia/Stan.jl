function check_data_type(data)
  if typeof(data) <: Array && length(data) > 0
    if keytype(data[1]) == String && valtype(data[1]) <: Any
      return true
    end
  end
  return false
end

function update_R_file{T<:Any}(file::String, dct::Dict{String, T};
    replaceNaNs::Bool=true)
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

