using StatsBase, NamedTupleTools
using StanSample

df = CSV.read(joinpath(@__DIR__, "..", "..", "data", "WaffleDivorce.csv"), DataFrame);
df.D = zscore(df.Divorce)
df.M = zscore(df.Marriage)
df.A = zscore(df.MedianAgeMarriage)
data = (N=size(df, 1), D=df.D, A=df.A, M= df.M)

stan5_1 = "
data {
    int < lower = 1 > N; // Sample size
    vector[N] D; // Outcome
    vector[N] A; // Predictor
}
parameters {
    real a; // Intercept
    real bA; // Slope (regression coefficients)
    real < lower = 0 > sigma;    // Error SD
}
transformed parameters {
    vector[N] mu;               // mu is a vector
    for (i in 1:N)
        mu[i] = a + bA * A[i];
}
model {
    a ~ normal(0, 0.2);         //Priors
    bA ~ normal(0, 0.5);
    sigma ~ exponential(1);
    D ~ normal(mu , sigma);     // Likelihood
}
generated quantities {
    vector[N] log_lik;
    for (i in 1:N)
        log_lik[i] = normal_lpdf(D[i] | mu[i], sigma);
}
";

m5_1s = SampleModel("m5.1s", stan5_1)
rc5_1s = stan_sample(m5_1s; data)

if success(rc5_1s)

    nt5_1s = read_samples(m5_1s, :particles)
    NamedTupleTools.select(nt5_1s, (:a, :bA, :sigma)) |> display

    chns = read_samples(m5_1s)
    chns |> display
end
