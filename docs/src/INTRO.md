# A Julia interface to CmdStan

## Stan.jl

[Stan](https://github.com/stan-dev/stan) is a system for statistical modeling, data analysis, and prediction. It is extensively used in social, biological, and physical sciences, engineering, and business. The Stan program language and interfaces are documented [here](http://mc-stan.org/documentation/).

[CmdStan](http://mc-stan.org/interfaces/cmdstan.html) is the shell/command line interface to run Stan language programs. 

[Stan.jl](https://github.com/StanJulia/Stan.jl) wraps CmdStan and captures the samples for further processing.

## Table of contents

### Examples

1. ARM kids example
2. Bernoulli
...

### Examples showing cmdstan methods

1. Diagnose
2. Generate_Quantities
3. Optimize
4. Parse_and_Interpolate_Example
5. Variational
6. Nuts sampling diagnose using the diagnose binary
...

### Examples added to test special cases

1. Init using a single Dict
2. Init with an Array{Dict, 1}
3. Init using a .R file
...

## References

There is no shortage of good books on Bayesian statistics. A few of my favorites are:

1. [Bolstad: Introduction to Bayesian statistics](http://www.wiley.com/WileyCDA/WileyTitle/productCd-1118593227.html)

2. [Bolstad: Understanding Computational Bayesian Statistics](http://www.wiley.com/WileyCDA/WileyTitle/productCd-0470046090.html)

3. [Gelman, Hill: Data Analysis using regression and multileve,/hierachical models](http://www.stat.columbia.edu/~gelman/arm/)

4. [Gelman, Carlin, and others: Bayesian Data Analysis](http://www.stat.columbia.edu/~gelman/book/)

and a great read:

5. [Betancourt: A Conceptual Introduction to Hamiltonian Monte Carlo](https://arxiv.org/abs/1701.02434)




