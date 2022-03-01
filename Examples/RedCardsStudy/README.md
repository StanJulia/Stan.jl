## Performance tests using M1 ARM, Intel w/TBB and Intel

This subdirectory contains an example of comparing the performance of  C++ chainsand Julia level chains.

It uses the RedCardsStudy data to do this and compares the performance on Apple's M1 ARM and an Apple Intel 9 core machine with and without TBB.

The script redcardsstudy.jl should be run first. The timining data is collected in the script timings.jl. The graphs are produced in timings_plot.jl.

The script timings.jl assumes cmdstan supports C++ threads (STAN_THREADS=true), e.g. see the CI.yml workflow or [here](https://github.com/StanJulia/StanSample.jl/blob/master/INSTALLING_CMDSTAN.md).

The results are measured on Julia-1.9 with cmdstan-2.29.0 build with:
```
CXX = clang++
STAN_THREADS = true
STANCFLAGS += --O1
```

1. A few weeks ago I did run these test without `STANCFLAGS += --O1`. I found that adding that flag gives for this example a performance improvement of about 10%!

2. Looking at the result plots in the graphs subdirectory, as expected, more C++ threads doesn't add a lot for the logistic_0 runs if sufficient threads are available for the number of chains requested. The results for C++ chains with only a single thread are not relevant for practical purposes in my opinion.

3. For this example TBB does not significantly outperform the no TBB Intel performance. But is does help a few points.

4. Overall I find for this example the M1 performance pretty impressive (about 25% better that a 2 years older Intel machine).

5. For many models the use of Julia level chains is a good alternative. If constructs like reduce-sum and map-rectare are used in the Stan Laguage program, C++ threads definitely help.

6. Too many threads does not help.

7. StanSample.jl v9 by default will continue to use Julia level chains by default (also for backwards compatibility).
