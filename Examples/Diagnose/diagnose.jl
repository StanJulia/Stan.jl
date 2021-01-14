######### Stan program example  ###########

using StanSample

ProjDir = @__DIR__

diagnose_1 = "
parameters {
  real y;
  vector[9] x;
}
model {
  y ~ normal(0, 3);
  x ~ normal(0, exp(y/2));
}
";

diagnose_2 = "
parameters {
  real y_raw;
  vector[9] x_raw;
}
transformed parameters {
  real y;
  vector[9] x;

  y = 3.0 * y_raw;
  x = exp(y/2) * x_raw;
}
model {
  y_raw ~ std_normal(); // implies y ~ normal(0, 3)
  x_raw ~ std_normal(); // implies x ~ normal(0, exp(y/2))
}
";

sm1 = SampleModel("diagnose.1", diagnose_1);
rc1 = stan_sample(sm1);
if success(rc1)
  read_summary(sm1, true)
  diagnose(sm1)
end

sm2 = SampleModel("diagnose.2", diagnose_2);
rc2 = stan_sample(sm2);
if success(rc2)
  read_summary(sm2, true)
  diagnose(sm2)
end
