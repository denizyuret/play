using StaticArrays,JLD2

"""
The file library.gz is a gzipped ascii file.  In this file, each
line refers to a deal.  Here is a typical one (the first, in fact):

JT852.93.KQ7.J82 AQ97.JT654.T6.A5 43.AK8.A542.7643 K6.Q72.J983.KQT9:88887777A9A977778888

There are 88 characters per line.  The first 16 give West's hand, with
suits separated by periods.  Then there is a space.  The next 16
characters give North's hand, then East's, and then South's.  Then
there is a colon, followed by 20 results (in hexadecimal).  The first
four refer to NT: the number of tricks that can be taken by N/S with S
leading, then E, then N, then W.  The next four refer to S trumps,
then H trumps, then D trumps, and finally C trumps.
"""
function readdoubledummy(stream::IO)
    data = []
    for line in eachline(stream)
        @assert length(line) == 88
        (hands,results) = split(line,':')
        hands = split(hands, ' ')
        h = zeros(UInt64,4)
        for player in 1:4 # w,n,e,s
            suits = reverse(split(hands[player],'.'))
            for suit in 1:4 # c,d,h,s
                for char in collect(suits[suit])
                    value = findfirst(CARDCHAR,char)
                    @assert value > 0
                    card = makecard(suit,value)
                    h[player] |= (1 << (card - 1))
                end
            end
        end
        r = zeros(UInt8,4,5)
        for trump in 1:5 # c,d,h,s,n
            for leader in 1:4 # w,n,e,s
                r[leader,trump] = hex2int(results[5-leader+4*(5-trump)])
            end
        end
        push!(data, (SVector{4}(h),SMatrix{4,5}(r)))
    end
    return data
end

function writedoubledummy(stream::IO,data)
    for (h,r) in data
        for player in 1:4
            for suit in 4:-1:1
                for value in 13:-1:1
                    card = makecard(suit,value)
                    if (h[player] & (1 << (card-1)) != 0)
                        print(stream, CARDCHAR[value])
                    end
                end
                if suit > 1; print(stream, '.'); end
            end
            if player < 4; print(stream, ' '); end
        end
        print(stream, ':')
        for trump in 5:-1:1
            for leader in 4:-1:1
                print(stream, int2hex(r[leader,trump]))
            end
        end
        println(stream)
    end
end

writedoubledummy(data)=writedoubledummy(STDOUT,data)

#= this is buggy
"""
Reads library.dat from GIB.

The file library.dat is a binary file.

Each hand in the library is stored using 26 bytes of information.
These 26 bytes comprise 4 32-bit integers, followed by 5 16-bit
integers.  The 32-bit integers refer to the four suits, with bits 0-1
indicating who holds the ace (I take West to be 0, North to be 1, and
so on; it doesn't matter as long as it's clockwise), bits 2-3 giving
the holder of the king, and so on.  I take spades to be suit 0, but
that doesn't matter at all.

The 5 16-bit integers indicate how many tricks can be taken by each
player and in each denomination.  The first integer refers to NT, and
the subsequent ones to the suits.  Bits 0-3 give the number of tricks
that can be taken by NS with player 0 (West) on lead; bits 4-7 the
number that can be taken by NS with player 1 on lead, and so on.
"""
function readlibrary(file)
    stream = open(file)
    printrecord(readrecord(stream)...)
    close(file)
end

# WNES
# JT852.93.KQ7.J82 AQ97.JT654.T6.A5 43.AK8.A542.7643 K6.Q72.J983.KQT9:88887777A9A977778888

function readrecord(stream)
    cards = zeros(Int,4)
    hands = falses(52,4)
    @show a = read(stream, UInt32, 4)
    for suit in 1:4
        ai = a[5-suit]
        for value in 1:13
            card = makecard(value, suit)
            owner = 1 + (ai >> (2*value+4)) & 3
            hands[card,owner] = true
            cards[owner] += 1
        end
    end
    @show cards
    @assert cards == [13,13,13,13]
    b = read(stream, UInt16, 5)
    results = zeros(UInt8,4,5)
    return hands,results
end

function printrecord(hands, results)
    for player in 1:4
        for suit in 4:-1:1
            for value in 13:-1:1
                card = makecard(value,suit)
                if hands[card,player]
                    print(CARDCHAR[value])
                end
            end
            if suit > 1; print('.'); end
        end
        if player < 4; print(' '); end
    end
    println()
end

=#
