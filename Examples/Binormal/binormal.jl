######### Stan program example  ###########

using Stan

old = pwd()
path = @windows ? "\\Examples\\Binormal" : "/Examples/Binormal"
ProjDir = Pkg.dir("Stan")*path
cd(ProjDir)

binorm = "
transformed data {
    matrix[2,2] Sigma;
    vector[2] mu;

    mu[1] <- 0.0;
    mu[2] <- 0.0;
    Sigma[1,1] <- 1.0;
    Sigma[2,2] <- 1.0;
    Sigma[1,2] <- 0.10;
    Sigma[2,1] <- 0.10;
}
parameters {
    vector[2] y;
}
model {
      y ~ multi_normal(mu,Sigma);
}
"
binormalmodel = Stanmodel(name="binormal", model=binorm);

chains = stan(binormalmodel)

chains[1][:samples] |> display
println()

cd(old)
