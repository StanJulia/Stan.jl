using StanSample

stan_data = (N=3, nu=13, L_Psi=[1.0 0.0 0.0; 2.0 3.0 0.0; 4.0 5.0 6.0]);

model_code = "
data {
    int<lower=1> N;
    real<lower=N-1> nu;
    cholesky_factor_cov[N] L_Psi;
}
parameters {
    cholesky_factor_cov[N] L_X;
}
model {
    L_X ~ inv_wishart_cholesky(nu, L_Psi);
}
";


sm = SampleModel("test", model_code);
rc = stan_sample(sm; data=stan_data);

if success(rc)
    df = read_samples(sm, :dataframe)
    ndf = read_samples(sm, :nesteddataframe)
    display(ndf.L_X[1])
    println()
end

for j in 1:5
    run(pipeline(StanSample.par(sm.cmds), stdout=sm.log_file[1]));
    ndf = read_samples(sm, :nesteddataframe)
    display(ndf.L_X[1])
    println()
end    
