function f(x)
  println("Calling f($x)")
end

function f(x, y::Number)
  println("Calling y::Number f($x, $y)")
end

function f(x, y::Array)
  println("Calling y::Array f($x, $y)")
end

function f(x, y::Matrix)
  println("Calling y::Matrix f($x, $y)")
end

function f(x, y::Dict)
  println("Calling y::Dict f($x, $y)")
end

function f(x, y::Vector{Dict{Symbol, Any}})
  println("Calling y::Vector{Dict{Symbol, Any}} f($x, $y)")
end

function f(x, y::Vector{Dict{String, Any}})
  println("Calling y::Vector{Dict{String, Any}} f($x, $y)")
end

f(5)

f(5, 3)

f(5, [2])

f(5, [2.0])

f(5, [1 2;3 4])

dct1 = Dict{Symbol, Any}(:y => 1)
f(5, dct1)

dct2 = Dict{Symbol, Any}[
  Dict(:theta => 0.1),
  Dict(:theta => [0.4]),
  Dict(:theta => [0.1, 0.2, 0.4]),
  Dict(:theta => [0.4 0.5; 0.6 0.7]),
]
f(5, dct2)

dct3 = Dict{String, Any}[
  Dict("theta" => 0.1),
  Dict("theta" => [0.4]),
  Dict("theta" => [0.1, 0.2, 0.4]),
  Dict("theta" => [0.4 0.5; 0.6 0.7]),
]
f(5, dct3)
