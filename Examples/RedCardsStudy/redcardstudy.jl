using Distributed, StanSample, CSV, DataFrames, StatsPlots

ProjDir = @__DIR__

rcd = CSV.read(joinpath(ProjDir, "RedCardData.csv"), DataFrame; missingstring = "NA")
rcd = dropmissing(rcd, :rater1)
rcd[!, :rater1] = Float64.(rcd.rater1)

stan_logistic_0 ="
data {
  int<lower=0> N;
  int<lower=0> n_redcards[N];
  int<lower=0> n_games[N];
  vector[N] rating;
}
parameters {
  vector[2] beta;
}
model {
  beta[1] ~ normal(0, 10);
  beta[2] ~ normal(0, 1);
  n_redcards ~ binomial_logit(n_games, beta[1] + beta[2] * rating);
}
";

stan_logistic_1 = "
functions {
  real partial_sum_lpmf(int[] slice_n_redcards,
                        int start, int end,
                        int[] n_games,
                        vector rating,
                        vector beta) {
    return binomial_logit_lupmf(slice_n_redcards |
                               n_games[start:end],
                               beta[1] + beta[2] * rating[start:end]);
  }
}
data {
  int<lower=0> N;
  int<lower=0> n_redcards[N];
  int<lower=0> n_games[N];
  vector[N] rating;
  int<lower=1> grainsize;
}
parameters {
  vector[2] beta;
}
model {

  beta[1] ~ normal(0, 10);
  beta[2] ~ normal(0, 1);
  target += reduce_sum(partial_sum_lupmf, n_redcards, grainsize,
                       n_games, rating, beta);
}
";

isdir(joinpath(ProjDir, "tmp")) && rm(joinpath(ProjDir, "tmp"), recursive=true);
if !isdir("tmp")
  tmp = mkdir(joinpath(ProjDir, "tmp"))
else
  tmp = joinpath(ProjDir, "tmp")
end;

logistic_0 = SampleModel("logistic0", stan_logistic_0, tmp)
logistic_1 = SampleModel("logistic1", stan_logistic_1, tmp)

data = Dict(
    :N => size(rcd, 1),
    :grainsize => 1,
    :n_redcards => rcd.redCards,
    :n_games => rcd.games,
    :rating => rcd.rater1
)

println("\nUsing $(Threads.nthreads()) threads.\n")

println("Timing of logitic_0 (4 Julia chains):")
@time rc_0 = stan_sample(logistic_0; data);

if success(rc_0)
    dfs_0 = read_summary(logistic_0)
    dfs_0[8:9, [1,2,4,8,9,10]] |> display
    println()
end

println("Timing of logitic_1 (4 Julia chains):")
@time rc_1 = stan_sample(logistic_1; data);

if success(rc_1)
    dfs_1 = read_summary(logistic_1)
    dfs_1[8:9, [1,2,4,8,9,10]] |> display
    println()
end

log_0_df = DataFrame()
for k = 1:2:5
  res = zeros(length(1:4:9));
  for i in 1:4:9
    res[i] = @elapsed stan_sample(logistic_0; 
      data, num_threads=i, num_cpp_chains=1, num_chains=k);
  end
  log_0_df[!, "1_$(k)"] = res
  log_0_df |> display
end
for k = 1:2:5
  res = zeros(length(1:2:9));
  for i in 1:2:9
    res[i] = @elapsed stan_sample(logistic_0; 
      data, num_threads=i, num_cpp_chains=k, num_chains=1);
  end
  log_0_df[!, "_$(k)_1"] = res
  log_0_df |> display
end

CSV.write(joinpath(ProjDir, "arm_log_0.csv"), log_0_df)
#CSV.write(joinpath(ProjDir, "intel_log_0.csv"), log_0_df)

arm_log_0 = CSV.read(joinpath(ProjDir, "arm_log_0.csv"), DataFrame)
#intel_log_0 = CSV.read(joinpath(ProjDir, "intel_log_0.csv"), DataFrame)

fig1 = plot(; title="M1/ARM log_0 results", ylims=(0, 140))
for name in names(arm_log_0)
  plot!(arm_log_0[:, name], marker=:dot, lab=name)
end
#=
fig2 = plot(; title="Intel log_0 results", ylims=(0, 140))
for name in names(intel_log_0)
  plot!(intel_log_0[:, name], marker=:xcross, lab=name)
end
plot(fig1, fig2, layout=(1, 2))
=#
savefig(joinpath(ProjDir, "rcd_log_0.png"))

log_1_df = DataFrame()
for k = 1:4
  res = zeros(9);
  for i in 1:9
    res[i] = @elapsed stan_sample(logistic_0; 
      data, num_threads=i, num_cpp_chains=1, num_chains=k);
  end
  log_1_df[!, "1_$(k)"] = res
  log_1_df |> display
end
for k = 1:4
  res = zeros(9);
  for i in 1:9
    res[i] = @elapsed stan_sample(logistic_1; 
      data, num_threads=i, num_cpp_chains=k, num_chains=1);
  end
  log_1_df[!, "_$(k)_1"] = res
end

CSV.write(joinpath(ProjDir, "arm_log_1.csv"), log_1_df)
#CSV.write(joinpath(ProjDir, "intel_log_1.csv"), log_1_df)

arm_log_1 = CSV.read(joinpath(ProjDir, "arm_log_1.csv"), DataFrame)
#intel_log_1 = CSV.read(joinpath(ProjDir, "intel_log_1.csv"), DataFrame)

fig1 = plot(; title="M1/ARM log_1 results", ylims=(0, 140))
for name in names(arm_log_1)
  plot!(arm_log_1[:, name], marker=:dot, lab=name)
end
#=
fig2 = plot(; title="Intel log_1 results", ylims=(0, 140))
for name in names(intel_log_1)
  plot!(intel_log_1[:, name], marker=:xcross, lab=name)
end
plot(fig1, fig2, layout=(1, 2))
=#
savefig(joinpath(ProjDir, "rcd_log_1.png"))


