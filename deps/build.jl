using BinDeps, Homebrew

@BinDeps.setup
cmdstan = library_dependency("cmdstan")

function install_cmdstan()
  println("Checking if Homebrew is installed")
  if Pkg.installed("Homebrew") === nothing
      error("Homebrew package not installed, please run Pkg.add(\"Homebrew\")")
  end
  
  println("Installing cmdstan.")
  provides( Homebrew.HB, "homebrew/science/cmdstan", cmdstan, os = :Darwin )
end

function install_cmdstan_manually()
  println("Currently there is no support to install CmdStan automatically on your platform.")
  println("Please check <http://mc-stan.org> on how to install it.\n")
  println("Define the ENV variable CMDSTAN_HOME, e.g.:\n")
  println("CMDSTAN_HOME=/Users/rob/Projects/Stan/cmdstan\n")
  println("to point to where the 'cmdstan' directory is installed on your system.")
end
  
@static is_apple() ? install_cmdstan() : install_cmdstan_manually()
