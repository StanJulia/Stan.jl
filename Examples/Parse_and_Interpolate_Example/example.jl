using CmdStan

ProjDir = @__DIR__
cd(ProjDir)

shared_file = "shared_funcs.stan"

bernoulli_model = "
  functions{
  
    #include $(shared_file)
    //#include shared_funcs.stan // a comment
    //#include shared_funcs.stan // a comment
    //#include /Users/rob/shared_funcs.stan // a comment
  
    void model_specific_function(){
        real x = 1.0;
        return;
    }
  
  }
  data { 
    int<lower=1> N; 
    int<lower=0,upper=1> y[N];
  } 
  parameters {
    real<lower=0,upper=1> theta;
  } 
  model {
    model_specific_function();
    theta ~ beta(my_function(),1);
    y ~ bernoulli(theta);
  }
";

observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

tmpdir = ProjDir*"/tmp"

stanmodel = Stanmodel(name="bernoulli", model=bernoulli_model,
  printsummary=true, tmpdir=tmpdir);

rc, chn, cnames = stan(stanmodel, observeddata, ProjDir);

if rc == 0
  # Describe the results
  show(chn)
  println()
  
  # Ceate a ChainDataFrame
  summary_df = read_summary(stanmodel)
  summary_df[:theta, [:mean, :ess]]
end
