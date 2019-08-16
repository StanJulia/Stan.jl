functions{
  
     real my_function(){
      real x = 1.0;
      return x;
  }

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
