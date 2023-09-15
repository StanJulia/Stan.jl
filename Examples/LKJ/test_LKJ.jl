using DataFrames
using StanSample
using LinearAlgebra
using Distributions
using Random
using Test

Omega = [1 0.3 0.2; 0.3 1 0.1; 0.2 0.1 1]
sigma = [1, 2, 3]
Sigma = diagm(sigma) .* Omega .* diagm(sigma)
N = 100
y = rand(MvNormal([0,0,0], Sigma), N)

stan1_0 = "
data {
  int<lower=1> N; // number of observations
  int<lower=1> J; // dimension of observations
  array[N] vector[J] y; // observations
  vector[J] Zero; // a vector of Zeros (fixed means of observations)
}
parameters {
  corr_matrix[J] Omega; 
  vector[J] sigma; 
}
transformed parameters {
  cov_matrix[J] Sigma; 
  Sigma = quad_form_diag(Omega, sigma); 
}
model {
  y ~ multi_normal(Zero,Sigma); // sampling distribution of the observations
  sigma ~ cauchy(0, 5); // prior on the standard deviations
  Omega ~ lkj_corr(1); // LKJ prior on the correlation matrix 
}";

stan2_0 = "
data {
  int<lower=1> N; // number of observations
  int<lower=1> J; // dimension of observations
  array[N] vector[J] y; // observations
  vector[J] Zero; // a vector of Zeros (fixed means of observations)
}
parameters {
  cholesky_factor_corr[J] Lcorr;  
  vector[J] sigma; 
}
model {
  y ~ multi_normal_cholesky(Zero, diag_pre_multiply(sigma, Lcorr));
  sigma ~ cauchy(0, 5);
  Lcorr ~ lkj_corr_cholesky(1);
}
generated quantities {
  matrix[J,J] Omega;
  matrix[J,J] Sigma;
  Omega = multiply_lower_tri_self_transpose(Lcorr);
  Sigma = quad_form_diag(Omega, sigma); 
}";

data = (N = N, J = 3, y=Matrix(transpose(y)), Zero=zeros(3))
m1_0s = SampleModel("stan1_0s", stan1_0)
rc1_0s = stan_sample(m1_0s; sig_figs=18, num_samples=9000, data)

if success(rc1_0s)
    sdf1_0s = read_summary(m1_0s)
    sdf1_0s[[17, 18, 19, 21, 22, 25], :] |> display
    println()
end

m2_0s = SampleModel("stan2_0s", stan2_0)
rc2_0s = stan_sample(m2_0s; num_samples=9000, data)

if success(rc2_0s)
    sdf2_0s = read_summary(m2_0s)
    ss2_0s = describe(m2_0s)
    ss2_0s |> display
end

nd = read_samples(m2_0s, :nesteddataframe)
@test size(nd) == (36000, 4)
println()

@testset "array()" begin
    for i in 1:10
        @test nd.Omega[i] == array(nd, :Omega)[:, :, i]
    end
    @test ss2_0s["sigma[1]", "mean"] ≈ 1.2 atol=0.5
end
println()
