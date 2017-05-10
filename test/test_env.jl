using Stan

## testing accessors to CMDSTAN_HOME
let oldpath = Stan.CMDSTAN_HOME
    newpath = Stan.CMDSTAN_HOME * "##test##"
    set_cmdstan_home!(newpath)
    @test Stan.CMDSTAN_HOME == newpath
    set_cmdstan_home!(oldpath)
    @test Stan.CMDSTAN_HOME == oldpath
end
