using DimensionalData
using StanSample

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

tmpdir = joinpath(@__DIR__, "tmp")

sm = SampleModel("bernoulli", bernoulli_model, tmpdir=tmpdir)

observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

rc = stan_sample(sm, data=observeddata)

if success(rc)
  chns = read_samples(sm, :dimarray)
  chns |> display
  println()
  
  # Show cmdstan summary in DataFrame format
  sdf = read_summary(sm)
  display(sdf)
  println()

  # Retrieve mean value of theta from the summary
  sdf[sdf.parameters .== :theta, :mean]
end
