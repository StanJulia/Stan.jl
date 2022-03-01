## Performance tests using M1 ARM, Intel w/TBB and Intel

This subdirectory contains an example of comparing the performance of  Julia level chains and C++ level chains as supported since cmdstan-2.28+.

It uses the RedCardsStudy data to do this and compares the performance on Apple's M1 ARM (in native mode, not Rosetta) and an Apple Intel 9 core machine with and without TBB.

The script redcardsstudy.jl should be run first. The timing data is collected in the script timings.jl. The graphs are produced in timings_plot.jl.

The script timings.jl assumes cmdstan supports C++ threads (STAN_THREADS=true), e.g. see the CI.yml workflow or [here](https://github.com/StanJulia/StanSample.jl/blob/master/INSTALLING_CMDSTAN.md).

The timings script takes quite some time. A cup of coffee helps!

The results are measured on Julia-1.9 with cmdstan-2.29.0 build with:
```
CXX = clang++
STAN_THREADS = true
STANCFLAGS += --O1
```

Some preliminary conclusions:

1. A few weeks ago I did run these test without `STANCFLAGS += --O1`. I found that adding that flag gives for this example a performance improvement of about 10%!

2. Looking at the result plots in the graphs subdirectory, as expected, more C++ threads doesn't add a lot for the logistic_0 runs as long as sufficient threads are available for the number of chains requested. 

Note: The results for C++ chains with only a single thread are not relevant for practical purposes in my opinion.

3. For this example TBB does not significantly outperform the no TBB Intel performance. But is does help a few points.

4. Overall I find for this example the M1 performance pretty impressive (about 25% better that a 2 years older Intel machine).

5. For many models the use of Julia level chains is a good alternative. If constructs like reduce-sum and map-rectare are used in the Stan Language program, C++ threads definitely help.

6. Too many (combined in all processes) threads do not help.

7. For now StanSample.jl v9 will continue to use Julia level chains by default (also for backwards compatibility).
