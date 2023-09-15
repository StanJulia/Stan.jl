using StanSample
using Distributions
using DataFrames
using StatsBase
using StatsFuns
using Test

function zscore_transform(data)
    μ = mean(data)
    σ = std(data)
    z(d) = (d .- μ) ./ σ
    return z
end


N = 500
U_sim = rand(Normal(), N )
Q_sim = sample( 1:4 , N ; replace=true )
E_sim = [rand(Normal( U_sim[i] + Q_sim[i]), 1)[1] 
    for i in 1:length(U_sim)]
W_sim = [rand(Normal( U_sim[i] + 0 * Q_sim[i]), 1)[1] 
    for i in 1:length(U_sim)]

data = (
    W=standardize(ZScoreTransform, W_sim),
    E=standardize(ZScoreTransform, E_sim),
    Q=standardize(ZScoreTransform, Float64.(Q_sim))
)

stan14_6 = "
data{
    vector[500] W;
    vector[500] E;
    vector[500] Q;
}
parameters{
    real aE;
    real aW;
    real bQE;
    real bEW;
    corr_matrix[2] Rho;
    vector<lower=0>[2] Sigma;
}
model{
    vector[500] muW;
    vector[500] muE;
    Sigma ~ exponential( 1 );
    Rho ~ lkj_corr( 2 );
    bEW ~ normal( 0 , 0.5 );
    bQE ~ normal( 0 , 0.5 );
    aW ~ normal( 0 , 0.2 );
    aE ~ normal( 0 , 0.2 );
    for ( i in 1:500 ) {
        muE[i] = aE + bQE * Q[i];
    }
    for ( i in 1:500 ) {
        muW[i] = aW + bEW * E[i];
    }
    {
        array[2] vector[500] YY;
        array[2] vector[500] MU;
        for ( j in 1:500 ) MU[j] = [ muW[j] , muE[j] ]';
        for ( j in 1:500 ) YY[j] = [ W[j] , E[j] ]';
        YY ~ multi_normal( MU , quad_form_diag(Rho , Sigma) );
    }
}";

m14_6s = SampleModel("m14_6s", stan14_6)
rc14_6s = stan_sample(m14_6s; data)

if success(rc14_6s)
    sdf14_6s = read_summary(m14_6s)
    sdf14_6s[8:17, [1, 2, 4, 5, 6, 7, 8]] |> display
end

#=
> precis( m14.6 , depth=3 )
          mean   sd  5.5% 94.5% n_eff Rhat4
aE        0.00 0.04 -0.06  0.06  1669     1
aW        0.00 0.04 -0.07  0.07  1473     1
bQE       0.59 0.03  0.53  0.64  1396     1
bEW      -0.05 0.07 -0.17  0.07   954     1
Rho[1,1]  1.00 0.00  1.00  1.00   NaN   NaN
Rho[1,2]  0.54 0.05  0.46  0.62  1010     1
Rho[2,1]  0.54 0.05  0.46  0.62  1010     1
Rho[2,2]  1.00 0.00  1.00  1.00   NaN   NaN
Sigma[1]  1.02 0.04  0.96  1.10  1011     1
Sigma[2]  0.81 0.03  0.77  0.85  1656     1
=#

nd = read_samples(m14_6s, :nesteddataframe)
@test size(nd) == (4000, 6)
