include("score.jl")
vul,dealer = false,SOUTH

for line in eachline()
    hands,results = split(line, ':')
    results = reshape(map(hex2int, collect(reverse(results))), (4,5))
    p = parscore(results, vul, dealer)
    println(join((line, p...), ' '))
end
