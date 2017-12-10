using DelimitedFiles

ProjDir = @__DIR__
  
x = [1.0; 2; 3; 4];
y = [5; 6; 7; 8.0];

open(joinpath(ProjDir, "test_delim_file.txt"), "w") do io
  writedlm(io, [x y], ',')
end
res = readdlm(joinpath(ProjDir, "test_delim_file.txt"), ',')
println(res)

dct1 = Dict{String, Any}[
  Dict("theta" => 0.1),
  Dict("theta" => [0.4]),
  Dict("theta" => [0.1, 0.2, 0.4]),
  Dict("theta" => [0.4 0.5; 0.6 0.7]),
]

strmout = open(joinpath(ProjDir, "test_delim_file_2.txt"), "a")
for entry in dct1
  str = '"' * "$entry" * '"' * " <- "
  writedlm(joinpath(ProjDir, "test_delim_file_2.txt"), str, "")
end

strmin = open(joinpath(ProjDir, "test_delim_file_2.txt"), "r")
readdlm(strmin, ',')
