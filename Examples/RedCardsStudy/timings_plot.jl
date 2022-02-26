using DataFrames, CSV, StatsPlots

ProjDir = @__DIR__

arm_log_0 = CSV.read(joinpath(ProjDir, "results", "arm_log_0_df.csv"), DataFrame)
arm_log_1 = CSV.read(joinpath(ProjDir, "results", "arm_log_1_df.csv"), DataFrame)
intel_log_0 = CSV.read(joinpath(ProjDir, "results", "intel_log_0_df.csv"), DataFrame)
intel_log_1 = CSV.read(joinpath(ProjDir, "results", "intel_log_1_df.csv"), DataFrame)
intel_tbb_log_0 = CSV.read(joinpath(ProjDir, "results", "intel_tbb_log_0_df.csv"), DataFrame)
intel_tbb_log_1 = CSV.read(joinpath(ProjDir, "results", "intel_tbb_log_1_df.csv"), DataFrame)

# Sort on (:num_threads,:num_chains0 instead on (:num_threads, :num_cpp_chains)
#sort(arm_log_1, [:num_threads, :num_chains])

function timings_plot(df::DataFrame; model = "1", ylim=(0, 250))
    colors = [:darkred, :darkblue, :darkgreen, :black]
    fig1 = plot(; xlim=(0, 9), ylim=ylim,
    xlab="c++ num_threads", ylab="elapsed time [s]")
    println("\nuse_cpp_chains == false\n")
    for (indx, i) in enumerate([1, 4])
        dft = df[df.num_chains .== i .&& df.use_cpp_chains .== false, :]
        println(dft)
        marksym = :cross
        plot!(dft.num_threads, dft.median; 
            marker=marksym, lab="$(i) num_chains")
        title!("Log_$(model) Julia\n(4 Julia threads)")
    end
    println("\nuse_cpp_chains == true\n")
    fig2 = plot(; xlim=(0, 9), ylim=ylim,
    xlab="c++ num_threads", ylab="elapsed time [s]")
    for (indx, i) in enumerate([1, 4])
        dft = df[df.num_chains .== i .&& df.use_cpp_chains .== true, :]
        println(dft)
        marksym = :cross
        plot!(dft.num_threads, dft.median; 
            marker=marksym, lab="$(i) cpp_chains")
        title!("Log_$(model) C++\n(4 Julia threads)")
    end
    plot(fig1, fig2, layout=(1, 2))
end

f0 = timings_plot(arm_log_0; model="0")
savefig(joinpath(ProjDir, "graphs", "arm_log_0.png"))
f1 = timings_plot(arm_log_1)
savefig(joinpath(ProjDir, "graphs", "arm_log_1.png"))

#=
f3 = timings_plot(intel_tbb_log_0; model="0", ylim=(0, 300))
savefig(joinpath(ProjDir, "graphs", "intel_tbb_log_0.png"))
f4 = timings_plot(intel_tbb_log_1)
savefig(joinpath(ProjDir, "graphs", "intel_tbb_log_1.png"))
f5 = timings_plot(intel_log_0; model="0", ylim=(0, 300))
savefig(joinpath(ProjDir, "graphs", "intel_log_0.png"))
f6 = timings_plot(intel_log_1; ylim=(0, 300))
savefig(joinpath(ProjDir, "graphs", "intel_log_1.png"))
=#
