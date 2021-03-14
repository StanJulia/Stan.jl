using Documenter, Stan

DOC_ROOT = joinpath(dirname(pathof(Stan)), "..", "docs")
DocDir =  joinpath(DOC_ROOT, "src")

page_list = Array{Pair{String, Any}, 1}();
append!(page_list, [Pair("Intro", "INTRO.md")]);
append!(page_list, [Pair("Installation", "INSTALLATION.md")]);
append!(page_list, [Pair("Walkthrough", "WALKTHROUGH.md")]);
append!(page_list, [Pair("Walkthrough2", "WALKTHROUGH2.md")]);
append!(page_list, [Pair("Versions", "VERSIONS.md")]);

makedocs(
  format = Documenter.HTML(prettyurls = haskey(ENV, "GITHUB_ACTIONS")),
  root = DOC_ROOT,
  modules = Module[],
  sitename = "Stan.jl",
  authors = "Rob J Goedman",
  pages = page_list,
)

deploydocs(
  root = DOC_ROOT,
  repo = "github.com/StanJulia/Stan.jl.git",
  devbranch = "master",
  push_preview = true,
)
