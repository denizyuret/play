# Trump suits
const CLUBS=1
const DIAMONDS=2
const HEARTS=3
const SPADES=4
const NOTRUMP=5

# Regular bids are represented by integers 1:35
const TRUMPBIDS=35
makebid(level,suit)=(5*(level-1)+suit)
bidlevel(bid)=1+div(bid-1,5)
bidsuit(bid)=mod1(bid,5)

# Three extra bids
const PASS=36
const DOUBLE=37
const REDOUBLE=38

# Players
WEST=1
NORTH=2
EAST=3
SOUTH=4


# Bridge scoring: based on 

"""
    points(hands, trump, contract, double, vulnerable)

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
    @assert points > 0
    const a = [20,50,90,130,170,220,270,320,370,430,500,600,750,900,1100,1300,1500,1750,2000,2250,2500,3000,3500,4000,10581]
    for i=1:length(a)
        if points < a[i]; return i-1; end
    end
end


# See http://bridgecomposer.com/Par.htm

# Let us assume we have the following deal from library.gz:
# JT852.93.KQ7.J82 AQ97.JT654.T6.A5 43.AK8.A542.7643 K6.Q72.J983.KQT9:88887777A9A977778888
# Hands are given in W,N,E,S order.
# Results are N/S tricks in hex grouped by NT,S,H,D,C.
# Each group has 4 results with S,E,N,W leading.

# The final contract reached by the model should specify trump, level,
# double, vul info.  Vul and dealer can be picked randomly at the
# beginning of bidding. The hands won comes from the DD and points() can
# be used to calculate score.

# The par score is the highest bid on which neither side can
# improve. We can assume all down hands are doubled, and no final par
# contract is redoubled.  Vul determined at start, dealer not
# important, declarer should be the first person bidding the trump
# suit but we can assume it can be freely chosen by the declaring
# partnership.

# Wrong: dealer may be important if both sides can make 1N, for
# example, then the first one to bid gets the score.

# The input is the 20 results and vulnerability, the output is the par N/S score.

function parscore(hands, vul, dealer)
    # par is the best n/s score so far and bid is the last bid so far.
    # ns should return a higher par and a higher bid if possible.
    function ns(par,bid)
        for b = bid+1:BIDMAX
        end
    end
    (par, bid, p, b) = (0, 0, -1, -1)
    while (par,bid) != (p,b)
        (p,b) = (par,bid)
        (par,bid) = ns(par,bid)
        (par,bid) = ew(par,bid)
    end
    return par
end
