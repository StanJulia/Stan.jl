using StanSample, Test

ProjDir = @__DIR__
cd(ProjDir) do

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
      array[N] int<lower=0,upper=1> y;
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

  stanmodel = SampleModel("parse_and_interpolate", bernoulli_model)

  observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

  rc = stan_sample(stanmodel; data=observeddata)

  if success(rc)
    # Convert to an MCMCChains.Chains object
    samples = read_samples(stanmodel)

    # Show cmdstan summary in DataFrame format
    df = read_summary(stanmodel)

    # Retrieve mean value of theta from the summary
    @test df[df.parameters .== :theta, :mean][1] ≈ 0.33 rtol=0.1
    
  end

end
