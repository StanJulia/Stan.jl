data {
  int T;
  real y0;
  real phi;
  real sigma;
}
parameters{}
model{}
generated quantities {
  vector[T] yhat;
  yhat[1] = y0;
  for (t in 2:T)
    yhat[t] = normal_rng(phi*yhat[t-1],sigma);
}