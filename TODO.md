Still to look into:

1. Ability display Stan's summary when calling `stan_summary` and/or `read_summary`.
2. Create an option to (re-)create Stan's summary with a selection of the available chains.
4. Check if the updates in sdewaele's PR need to be applied here as well.

Provisionally ok:

3. Check if start=... works properly to align sample numbers when saving warmup samples - seems ok.
5. Check if there are additional cases where inside the REPL fails while package testing works, e.g. read_samples(stanmodel) - seems ok.
6. Make sure no files are ever created in the `package` dir.
instantiation - seems ok.
7. Any conflicts with running CmdStan.jl and Stan.jl in a single julia 
8. Inclusion of findall() for Julia < v1.3 - seems ok.
