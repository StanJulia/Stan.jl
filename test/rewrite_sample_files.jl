function rewrite_file(model, chain, chainno::Int, fname)
  isfile("simple_samples_1.csv") && rm("simple_samples_1.csv")
  fd = open("simple_samples_1.csv", "w")

  count = 1
  for name in sim3.names
    write(fd, name)
    count += 1
    count <= length(sim3.names) && write(fd, ",")
  end
  write(fd, "\n")
  
  count = 1
  for i in 1:size(sim3.value, 1)
    for j in 1:size(sim3.value, 2)
      write(fd, string(sim3.value[i, j, chainno]))
      count += 1
      if count <= size(sim3.value, 2)
        write(fd, ",")
      end
    end
    write(fd, "\n")
  end
  close(fd)
  pstring = joinpath("/Users/rob/Projects/Stan/cmdstan", "bin", "stansummary")
  cmd = `$(pstring) $(fname)`
  println(cmd)
  #print(open(readstring, cmd, "r"))
end

rewrite_file(stanmodel1, sim1, 1, "simple_samples_1.csv")
