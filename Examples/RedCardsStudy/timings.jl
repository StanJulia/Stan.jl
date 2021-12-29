using Distributed, StanSample, CSV, DataFrames, StatsPlots, Statistics

ProjDir = @__DIR__
#include(joinpath(ProjDir, "redcardstudy.jl"))

function timings(model, nts, nccs, ncjs, N)

    df = DataFrame()
    res_t = zeros(N)
    println("\n\n")
    for nt in nts
        for nc in nccs
            for nj in ncjs
              println("(num_threads=$nt, num_cpp-chains=$nc, \
                num_chains=$nj) runs")
              for i in 1:N
                  res_t[i] = @elapsed stan_sample(model; 
                    data, num_threads=nt, num_cpp_chains=nc, num_chains=nj); 
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

nts = 1:9
nccs = [1, 2, 4]
ncjs = [1, 2, 4]
N = 6

model = logistic_0
arm_log_0_df = timings(model, nts, nccs, ncjs, N)
arm_log_0_df |> display

CSV.write(joinpath(ProjDir, "results", "arm_log_0_df.csv"), arm_log_0_df)

model = logistic_1
arm_log_1_df = timings(model, nts, nccs, ncjs, N)
arm_log_1_df |> display

CSV.write(joinpath(ProjDir, "results", "arm_log_1_df.csv"), arm_log_1_df)
