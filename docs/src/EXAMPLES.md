# Cross reference of features

This section is intended to help find an example that shows a specific feature. Work-in-progress!

## Stan manual examples

These examples show basic usage patterns of this package.

### Bernoulli

Stan's `goto` initial example. This example touches pretty much most features available in StanSample.jl and MCMCChains.jl.

Features demonstrated:

1. Define a basic `SampleModel`.
2. Set up a permanent `tmpdir` to prevent recompilation of a Stan language program. Default is to create a new directory using `mktempdir()`.
3. Update sample and adaptation default parameter settings.
4. Call `stan_sample`.
5. Check the return value of `stan_sample`, in this example `sample_file`.
6. Create and show an MCMCChains.Chains object, `chns`.
7. Convert a `chns` to a DataFrame.
8. Display ESS (estimated effective sample size).
9. Plot the `chns`.
10. Extract Stan's sampling summary (MCMCChains.jl provides a similar summary).
11. Extract a, or a few, fields from Stan's summary, e.g. for comparison purposes.

### Binomial

Features demonstrated:

1. Use of the `generated_quantities` section in a Stan program.

### Binormal

Features demonstrated:

1. Rename parameters in MCMCChains objects.

### Dyes, ARM and Eight schools examples

Slightly larger Stan model examples.

Features demonstrated:

1. Manipulate sections in MCMCChains objects.

## Stan language methods (Sample, Optimize, ...)

### StanSample.jl

### StanOpimize

### StanVariational

### StanDiagnose

### Generate_Quantities

### Include external functions

## Special input and output 

### Init settings

### Init with an array of dicts

### Init froma file

### NamedArray

### Scalar observation

### Zero length array test

## TBD

### Stan's diagnose executable example

### MCMCChains

### MCMCChains to DataFrame

### NamedTuple input and output

### MCMCChains to Array