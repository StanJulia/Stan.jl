using Distributed, StanSample, CSV, DataFrames, StatsPlots, Statistics

ProjDir = @__DIR__
#include(joinpath(ProjDir, "redcardstudy.jl"))

function timings(model, nts, ncs; N=6, use_cpp=[false, true])

    df = DataFrame()
    res_t = zeros(N)
    println("\n\n")
    for nt in nts                   # Number of C++ threads
        for n in ncs                # Number of chains
            for j in use_cpp        # types==1: Julia, types==2: C++
              println("(num_threads=$nt, use_cpp-chains=$j, \
                num_chains=$n) runs")
              for i in 1:N
                  res_t[i] = @elapsed stan_sample(model; 
                    data, num_threads=nt, use_cpp_chains=j, num_chains=n)
                  println("Iteration=$i, time=$(res_t[i])") 
              end
              append!(df, DataFrame(
                  num_threads=nt, 
                  use_cpp_chains=j,
                  num_chains=n, 
                  min=minimum(res_t),
                  median=median(res_t),
                  max=maximum(res_t))
              )
            end
        end
    end

    df
end

nts = [1, 4, 7, 9]
ncs = [1, 2, 4]
N = 2

println("\nlogistic_0 runs\n")
model = logistic_0
arm_log_0_df = timings(model, nts, ncs; N)
arm_log_0_df |> display

CSV.write(joinpath(ProjDir, "results", "arm_log_0_df.csv"), arm_log_0_df)

println("\nlogistic_1 runs\n")
model = logistic_1
arm_log_1_df = timings(model, nts, ncs; N)
arm_log_1_df |> display

CSV.write(joinpath(ProjDir, "results", "arm_log_1_df.csv"), arm_log_1_df)
