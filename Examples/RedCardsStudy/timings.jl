using Distributed, StanSample, CSV, DataFrames, StatsPlots, Statistics

ProjDir = @__DIR__
#include(joinpath(ProjDir, "redcardstudy.jl"))

function timings(model, nts, ncs; N=6, types=[1, 2])

    df = DataFrame()
    res_t = zeros(N)
    println("\n\n")
    for nt in nts                   # Number of C++ threads
        for n in ncs                # Number of chains
            for j in types          # types==1: Julia, types==2: C++
              if j ==1
                nc = 1
                nj = n
              else
                nc = n
                nj = 1
              end
              if j==1 && n==1 
                continue
              end
              println("(num_threads=$nt, num_cpp-chains=$nc, \
                num_chains=$nj) runs")
              for i in 1:N
                  res_t[i] = @elapsed stan_sample(model; 
                    data, num_threads=nt, num_cpp_chains=nc, num_chains=nj)
                  println("Iteration=$i, time=$(res_t[i])") 
              end
              append!(df, DataFrame(
                  num_threads=nt, 
                  num_cpp_chains=nc,
                  num_chains=nj, 
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


model = logistic_0
arm_log_0_df = timings(model, nts, ncs; N)
arm_log_0_df |> display

CSV.write(joinpath(ProjDir, "results", "arm_log_0_df.csv"), arm_log_0_df)

model = logistic_1
arm_log_1_df = timings(model, nts, ncs; N)
arm_log_1_df |> display

CSV.write(joinpath(ProjDir, "results", "arm_log_1_df.csv"), arm_log_1_df)
