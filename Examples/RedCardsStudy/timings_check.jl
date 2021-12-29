function timings_check!(df::DataFrame, model::SampleModel; N = 6, upper=0.25)

    for row in 1:nrow(df)
        if df[row, :].max > (1.0 + upper) * df[row, :].median
            println("\n\nFixing row=$row: $(df[row, :])")

            #
            dft = timings(model.
                [df[row, :].num_threads], [df[row, :].num_cpp_chains], 
                [df[row, :].num_chains], N)
            #
            df[row, :] = dft[1, :]
            println("Updating row=$row: $(df[row, :])")
        end
    end
end

#timings_check!(df, model)
#df

# Write df to results subdir

#CSV.write(joinpath(ProjDir, "results", "arm_no_tbb.csv"), df)
#CSV.write(joinpath(ProjDir, "results", "arm_tbb.csv"), df)
#CSV.write(joinpath(ProjDir, "results", "intel_no_tbb.csv"), df)
#CSV.write(joinpath(ProjDir, "results", "intel_tbb.csv"), df)

# Sort on (:num_threads,:num_chains0 instead on (:num_threads, :num_cpp_chains)

#sort(df, [:num_threads, :num_chains])

# Fix rows in df

function fix_row!(df::DataFrame, model, row)
    println(first(df, row))
    df[row, :] = timings(model, 
        [df[row,:].num_threads], [df[row,:].num_cpp_chains],
        [df[row,:].num_chains], 6)[1, :]
    println("Updated row $row: $(df[row, :])")
end

#=
for i in 1:3
    fix_row!(df, model, i)
end
=#
