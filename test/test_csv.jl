using Stan

N1 = 10
data1 = Dict(
  "Scalar" => rand(),
  "Single_element_vector" => [rand()], 
  "Vector" => rand(N1),
  "Array" => rand(N1,3)
)

N = 100000
data = Dict(
  "Scalar" => rand(),
  "Single_element_vector" => [rand()], 
  "Vector" => rand(N),
  "Array" => rand(N,3)
)

Stan.update_R_file("testdata0", data1)
Stan.update_R_file_jon("testdata1", data1)

@time Stan.update_R_file("testdata0", data)
@time Stan.update_R_file_jon("testdata1", data)
