include("types.jl")
include("score.jl")
for line in eachline()
    hands,results = split(line, ':')
    results = reshape(map(hex2int, collect(reverse(results))), (4,5))
    (par,bid,decl) = parscore(results)
    println(join((line, par), ' '))
end
