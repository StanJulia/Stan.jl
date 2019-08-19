using Documenter, Stan

DOC_ROOT = joinpath(dirname(pathof(Stan)), "..", "docs")

makedocs( root = DOC_ROOT,
  modules = [Stan],
  sitename = "StanJulia/Stan.jl",
  authors = "Rob J Goedman",
  pages = Any[
      "Home" => "INTRO.md",
      "Installation" => "INSTALLATION.md",
      "Walkthrough" => "WALKTHROUGH.md",
      "Versions" => "VERSIONS.md",
      "Index" => "index.md"
  ]
)

deploydocs(
  root = DOC_ROOT,
  repo = "github.com/StanJulia/Stan.jl.git",
 )