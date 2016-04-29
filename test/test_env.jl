using Stan

## testing accessors to CMDSTAN_HOME
let oldpath = Stan.CMDSTAN_HOME
    newpath = Stan.CMDSTAN_HOME * "##test##"
    set_CMDSTAN_HOME!(newpath)
    @test Stan.CMDSTAN_HOME == newpath
    set_CMDSTAN_HOME!(oldpath)
    @test Stan.CMDSTAN_HOME == oldpath
end
