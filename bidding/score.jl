# Bridge scoring: based on 

"""
    bridgescore(hands, trump, contract, double, vulnerable)

Returns score for the declarer given:

* hands: total number of hands taken by declarer [0:13]
* trump: 1=clubs 2=diamonds 3=hearts 4=spades 5=notrump
* contract: level of contract [1:7]
* double: 1=none 2=doubled 4=redoubled
* vulnerable: true/false

References:
* http://www.rpbridge.net/2y66.htm
* http://www.rpbridge.net/1ub8.htm

"""
function points(hands, trump, contract, double, vul)
    @assert in(hands,0:13) && in(trump,1:5) && in(contract,1:7) && in(double,(1,2,4)) && isa(vul,Bool)
    if hands >= 6 + contract
        trickscore = (contract * (trump <= 2 ? 20 : 30) + (trump == 5 ? 10 : 0)) * double
        overtricks = ((hands - 6 - contract) *
                      (double == 1 ? (trump <= 2 ? 20 : 30) :
                       double == 2 ? (vul ? 200 : 100) :
                       double == 4 ? (vul ? 400 : 200) : error()))
        gamebonus = (trickscore < 100 ? 50 : vul ? 500 : 300)
        slambonus = (contract == 6 ? (vul ? 750 : 500) :
                     contract == 7 ? (vul ? 1500 : 1000) : 0)
        doublebonus = (double == 2 ? 50 : double == 4 ? 100 : 0)
        trickscore + overtricks + gamebonus + slambonus + doublebonus
    else # hands < 6 + contract
        down = 6 + contract - hands
        (double == 1 ? (vul ? -100 : -50) * down :
         vul ? -(down * 300 - 100) * div(double,2) :
         (down == 1 ? -100 : down == 2 ? -300 : -down * 300 + 400) * div(double,2))
    end
end

"""
    imps(points)

Return IMP score given (positive) difference in points.
Based on https://www.bridgehands.com/I/IMP.htm.    

"""
function imps(points)
    const a = [20,50,90,130,170,220,270,320,370,430,500,600,750,900,1100,1300,1500,1750,2000,2250,2500,3000,3500,4000,10581]
    for i=1:length(a)
        if points < a[i]; return i-1; end
    end
end
