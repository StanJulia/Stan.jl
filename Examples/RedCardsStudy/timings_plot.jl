using DataFrames, CSV, Plots, StatsPlots

ProjDir = @__DIR__

nts = [1, 2, 4, 8]
N = 6

arm_no_tbb = CSV.read(joinpath(ProjDir, "results", "arm_no_tbb.csv"), DataFrame)
intel_tbb = CSV.read(joinpath(ProjDir, "results", "intel_tbb.csv"), DataFrame)

#arm_no_tbb |> display
#intel_tbb |> display

# Sort on (:num_threads,:num_chains0 instead on (:num_threads, :num_cpp_chains)
#sort(intel_tbb, [:num_threads, :num_chains])

function timings_plot(arm::DataFrame, intel::DataFrame; ts = [1, 8])
    ptype = ["arm", "intel"]
    colors = [:darkred, :darkblue, :darkgreen, :black]
    fig = plot(; xlim=(0, 9), ylim=(0, 100),
        xlab="chains (Julia or c++)", ylab="elapsed time [s]")
    for (indx, df) in enumerate([arm, intel])
        for t in ts[1]
            dft = df[df.num_threads .== t .&& df.num_cpp_chains .== 1, :]
            #println(dft)
            marksym = :cross
            plot!(dft.num_chains, dft.median; 
                marker=marksym, lab="$(ptype[indx])_julia", color=colors[indx])
        end
        for t in ts[2]
            dft = df[df.num_threads .== t .&& df.num_chains .== 1, :]
            #println(dft)
            marksym = :xcross
            plot!(dft.num_cpp_chains, dft.median; 
                marker=marksym, lab="$(ptype[indx])_c++", color=:grey)
        end
    end
    title!("Julia & c++\n(8 threads)")
    fig
end

f1 = timings_plot(arm_no_tbb, intel_tbb)

function threads_plot(df::DataFrame; ts = [1, 2, 4, 8])
    colors = [:darkred, :darkblue, :darkgreen, :black]
    fig = plot(; xlim=(0, 9), ylim=(0, 100),
        xlab="num_c++_chains", ylab="elapsed time [s]", leg=:topleft)
    for (indx, t) in enumerate(ts)
        dft = df[df.num_threads .== t .&& df.num_chains .== 1, :]
        #println(dft)
        marksym = :cross
        plot!(dft.num_cpp_chains, dft.median; 
            marker=marksym, lab="threads = $(t)", color=colors[indx])
    end
    title!("TBB & c++\n(8 core Intel)")
    fig
end

f2 = threads_plot(intel_tbb)

fig = plot(f1, f2; layout=(1, 2))
savefig(joinpath(ProjDir, "graphs", "performance.png"))
