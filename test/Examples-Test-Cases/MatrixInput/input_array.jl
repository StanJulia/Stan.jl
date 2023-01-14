using StanSample, Random, Statistics

stan_chris = "
data { 
    int n_rows;
    int<lower=1> n_cols;
    matrix<lower=0>[n_rows,n_cols] x; 
}

parameters {
   real mu;
} 

model {
    mu ~ normal(0, 1);
}";

seed = 65445
Random.seed!(seed)

n_rows = 10
n_cols = 2
data = [(x = rand(n_rows, n_cols), n_rows = n_rows, n_cols = n_cols) for i in 1:4]

tmpdir = joinpath(@__DIR__, "tmp")
sm = SampleModel("chris", stan_chris, tmpdir);
rc = stan_sample(sm; data, seed);

if success(rc)
	df = read_samples(sm , :dataframe)
    #df |> display
    [mean(df.mu), std(df.mu)] |> display
end

tmpdir = joinpath(@__DIR__, "tmp")
sm = SampleModel("chris", stan_chris, tmpdir);
rc = stan_sample(sm; data=data[1:3], seed);

if success(rc)
    df = read_samples(sm , :dataframe)
    #df |> display
    [mean(df.mu), std(df.mu)] |> display
end

