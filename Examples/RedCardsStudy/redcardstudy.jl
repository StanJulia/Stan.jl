using CSV, DataFrames
using StanSample, Statistics

ProjDir = @__DIR__

rcd = CSV.read(joinpath(ProjDir, "RedCardData.csv"), DataFrame;
  missingstring = "NA")
rcd = dropmissing(rcd, :rater1)
rcd[!, :rater1] = Float64.(rcd.rater1)

stan_logistic_0 ="
data {
  int<lower=0> N;
  array[N] int<lower=0> n_redcards;
  array[N] int<lower=0> n_games;
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

println("\nUsing $(Threads.nthreads()) Julia threads.\n")


println("Timing of logistic_0 (4 Julia chains):")
@time rc_0 = stan_sample(logistic_0; data);

if success(rc_0)
    dfs_0 = read_summary(logistic_0)
    dfs_0[8:9, [1,2,4,8,9,10]] |> display
    println()
end

println("Timing of logistic_1 (4 Julia chains):")
@time rc_1 = stan_sample(logistic_1; data);

if success(rc_1)
    dfs_1 = read_summary(logistic_1)
    dfs_1[8:9, [1,2,4,8,9,10]] |> display
    println()
end

println("Timing of logistic_1 (4 C++ chains, 4 num_threads):")
@time rc_2 = stan_sample(logistic_1; data, 
  use_cpp_chains=true, num_threads=4);

if success(rc_2)
    dfs_2 = read_summary(logistic_1)
    dfs_2[8:9, [1,2,4,8,9,10]] |> display
    println()
end

println("Timing of logistic_1 (4 C++ chains, 8 num_threads):")
@time rc_3 = stan_sample(logistic_1; data,
  use_cpp_chains=true, num_threads=8);

if success(rc_3)
    dfs_3 = read_summary(logistic_1)
    dfs_3[8:9, [1,2,4,8,9,10]] |> display
    println()
end

println("Timing of logistic_1 (2 C++ chains, 2 Julia chains, 8 num_threads):")
@time rc_4 = stan_sample(logistic_1; data,
  use_cpp_chains=true, check_num_chains=false,
  num_threads=8, num_cpp_chains=2, num_julia_chains=2);

if success(rc_4)
    dfs_4 = read_samples(logistic_1, :dataframe)
    size(dfs_4) |> display
    mean(Array(dfs_4), dims=1) |> display
    read_summary(logistic_1, true) |> display
    println()
end


