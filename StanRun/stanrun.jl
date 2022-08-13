using Pkg

using StanRun

html"""
<style>
    main {
        margin: 0 auto;
        max-width: 2000px;
        padding-left: max(160px, 10%);
        padding-right: max(160px, 10%);
    }
</style>
"""


ENV["JULIA_CMDSTAN_HOME"] = expanduser("~/Projects/StanSupport/cmdstan/")

model = StanModel(expanduser("~/.julia/dev/Stan/StanRun/tmp/bernoulli.stan")) # directory should be writable, for compilation

data = (N = 10, y = [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]) # in a format supported by stan_dump

# 1 chain sometimes works on Pluto
# multiple chains nearly always fail
chains = stan_sample(model, data, 1) 
