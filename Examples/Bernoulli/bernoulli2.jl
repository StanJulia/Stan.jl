######### Stan program example  ###########

using StanSample, DataFrames

function duplicate_tmpdir_for_windows_only(sm,)
    tmpdir = mktempdir()
    exefile = Sys.iswindows() ? joinpath(sm.name, ".exe") : sm.name
    files = readdir(sm.tmpdir)
    for f in files
        cp(joinpath(sm.tmpdir, f), joinpath(tmpdir, f))
    end

    sm2 = deepcopy(sm)
    sm2.tmpdir = tmpdir
    sm2.output_base =  joinpath(tmpdir, sm2.name)

    return sm2
end

ProjDir = @__DIR__

bernoullimodel = "
data { 
  int<lower=0> N; 
  array[N] int<lower=0, upper=1> y;
} 
parameters {
  real<lower=0,upper=1> theta;
} 
model {
  theta ~ beta(1,1);
  y ~ bernoulli(theta);
}
";

observed_data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

# Default for tmpdir is to create a new tmpdir location
# To prevent recompilation of a Stan progam, choose a fixed location,
tmpdir= ProjDir * "/tmp"

sm = SampleModel("bernoulli2", bernoullimodel, tmpdir);

rc = stan_sample(sm; data=observed_data,
  save_warmup=true, num_warmups=1000,
  num_samples=1000, thin=1, delta=0.85
);

if success(rc)
  df = read_summary(sm, true)
  df |> display
end

if true # Sys.iswindows()
    df1 = read_samples(sm, :dataframe)

    sm2 = duplicate_tmpdir_for_windows_only(sm)
    rc2 = stan_sample(sm2; data=observed_data,
      save_warmup=true, num_warmups=1000,
      num_samples=1000, thin=1, delta=0.85)

    df2 = read_samples(sm2, :dataframe)

    println(DataFrame(df1=df1[1001:1006, 1], df2=df2[1001:1006, 1]))
    println()
    
    if success(rc2)
    df3 = read_summary(sm, true)
    df3 |> display
end

end
