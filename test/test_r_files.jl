using Stan
wd = dirname(@__FILE__)

if !isdefined(Main, :update_R_file)
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
      elseif length(val)==1 && length(size(val))==1
  			# Single element vector
  			#str = str*"$(val[1])\n"
  		elseif length(val)>1 && length(size(val))==1
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
end

dct = Dict{String, Any}[
  Dict("theta" => 0.1),
  Dict("theta" => [0.4]),
  Dict("theta" => [0.1, 0.2, 0.4]),
  Dict("theta" => [0.4 0.5; 0.6 0.7]),
]

for i in 1:length(dct)
  #for j in ["data", "init"]
  for j in ["data"]
    file = joinpath(wd, "test_r_$(i)_$(j).R")
    isfile(file) && rm(file)
    open(file, "w")
    Stan.update_R_file(file, dct[i])
  end
end
