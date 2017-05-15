data {
  int<lower=1> Nobs;
  int<lower=1> Nsubj;
  int<lower=1> SubjIdx[Nobs];
  int<lower=0,upper=1> y[Nobs];
}
parameters {
  real<lower=0> omega;
  real<lower=0,upper=1> kappa;
  vector<lower = 0,upper=1>[Nsubj] theta;
}
transformed parameters {
  real<lower=0> A;
  real<lower=0> B;
  A = kappa*omega;
  B = (1-kappa)*omega;
}
model {
  omega ~ gamma(2,3);
  kappa ~ beta(7,3);
  theta ~ beta(A,B);
  for (obs in 1:Nobs){
    y[obs] ~ bernoulli(theta[SubjIdx[obs]]);
  }
}
