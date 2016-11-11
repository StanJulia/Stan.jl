data {real sigma;}
  parameters {real y;}
  model {y ~ normal(0,sigma);}