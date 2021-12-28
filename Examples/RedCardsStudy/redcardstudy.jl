using Distributed, StanSample, CSV, DataFrames
Pkg.instantiate()

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

isdir("tmp") && rm("tmp", recursive=true);
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

println("Timing of logitic_0:")
for i in 1:9
  @time stan_sample(logistic_0; data, num_threads=i, num_cpp_chains=1, num_chains=1);
end

df = DataFrame()
for k = 1:4
  res = zeros(9);
  for i in 1:9
    res[i] = @elapsed stan_sample(logistic_0; 
      data, num_threads=i, num_cpp_chains=1, num_chains=k);
  end
  df[!, "log_0, $k chns"] = res
  df |> display
end
for k = 1:4
  res = zeros(9);
  for i in 1:9
    res[i] = @elapsed stan_sample(logistic_1; 
      data, num_threads=i, num_cpp_chains=1, num_chains=k);
  end
  df[!, "log_1, $k chns"] = res
  df |> display
end

