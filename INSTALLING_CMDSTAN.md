# Installing cmdstan.

## Clone the cmdstan.git repo. Big! Takes a while, by far the longest step.

```
git clone https://github.com/stan-dev/cmdstan.git --recursive cmdstan

# or e.g.
# git clone -b v2.28.2 https://github.com/stan-dev/cmdstan.git --recursive cmdstan
```

## Customize cmdstan.

```
cd cmdstan

# Create ./make/local from ./make/local.example or copy from a previous install
# ls -lia ./make/local
#ls: ./make/local: No such file or directory

# If you want to customize the ./make/local.example file
# ls -lia ./make/local.example
# cp -R ./make/local.example ./make/local
# ls -lia ./make/local

# Now un-comment the CXX=clang++ and STAN_THREADS=true lines in ./make/local.

# Or do:
touch ./make/local
echo "CXX=clang++\nSTAN_THREADS=true" > ./make/local

# If you prefer using gcc instead of clang++ use:
# echo "STAN_THREADS=true" > ./make/local

```

## Build cmdstan.

```

# If a previous install has been compiled in this directory:
# make clean-all   # or
# make -B -j9 build

make -j9 build

```

## Test cmdstan was built correctly.

```
make examples/bernoulli/bernoulli

./examples/bernoulli/bernoulli num_threads=6 sample num_chains=4 data file=examples/bernoulli/bernoulli.data.json

bin/stansummary output_*.csv

```

## For Stan.jl etc. to find cmdstan, export CMDSTAN
```
export CMDSTAN=`pwd`   # Use value of `pwd` here

```

## Below an example of the `make/local` file mentioned above with the CXX and STAN_THREADS lines enabled.

```
# To use this template, make a copy from make/local.example to make/local
# and uncomment options as needed.

# Be sure to run `make clean-all` before compiling a model to make sure
# everything gets rebuilt.

# Change the C++ compiler if needed
CXX=clang++                    # Only needed on macOS if clang++ is preferred.

# Enable threading
STAN_THREADS=true

# Enable the MPI backend (requires also setting (replace gcc with clang on Mac)
# STAN_MPI=true
# CXX=mpicxx
# TBB_CXX_TYPE=gcc

```