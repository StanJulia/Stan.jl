######## Stan diagnose example  ###########

using StanDiagnose, Test

bernoulli_model = "
data { 
  int<lower=0> N; 
  int<lower=0,upper=1> y[N];
} 
parameters {
  real<lower=0,upper=1> theta;
} 
model {
  theta ~ beta(1,1);
    y ~ bernoulli(theta);
}
"
bernoulli_data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

sm = DiagnoseModel("diagnose", bernoulli_model);
rc = stan_diagnose(sm; data=bernoulli_data);

if success(rc)
  diags = read_diagnose(sm)
  @test diags[:error][1] ≈ 0.0  atol=0.000001
end
