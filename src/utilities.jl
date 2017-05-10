function check_data_type(data)
  if typeof(data) <: Array && length(data) > 0
    if keytype(data[1]) == String && valtype(data[1]) <: Any
      return true
    end
  end
  return false
end

