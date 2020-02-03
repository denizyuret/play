using Combinatorics, Base.Iterators, Knet

gods = (:t,:f,:r)
responses = (:a,:b)
universes = [ (g,a) for g in permutations(gods), a in permutations(responses) ] |> vec
questions = [ (q,g) for q in 1:3, g in gods ] |> vec
push!(questions, (1,1))

# wlog we ask the first question to god1: 9 choices for question
# wlog we ask the second question to god1 or god2 regardless of the answer to the first question: 2x9 choices
# choice of targets: 111, 112, 121, 122, 123
# !!! third question and its target may depend on whether first two answers were same or different !!!
# represent this as a separate fourth question
# using g3/q3 if first two answers were equal, g4/q4 if different
strategies = product(1:3, 1:3, 1:3, 1:3, 1:3,
                     questions, questions, questions, questions, questions) |> collect |> vec

strategies = filter(strategies) do s
    s[1] <= 1 && s[2] <= 1+s[1] && s[3] <= 1+s[2] && s[4] <= 1+maximum(s[1:3]) && s[5] <= 1+maximum(s[1:4])
end

function answers(universe, godindex, question)
    gods,yesno = universe
    god = gods[godindex]
    yes,no = yesno
    qsubject, qpred = question
    correct = ((qsubject == qpred) || (gods[qsubject] == qpred))
    ans = (god == :t ? (correct ? (yes,) : (no,)) :
           god == :f ? (correct ? (no,) : (yes,)) :
           (yes,no))
    [ (godindex, question, a) for a in ans ]
end

# enumerating strategies:
function search()
    for (g1,g2,g3,g4,g5,q1,q2,q3,q4,q5) in progress(strategies)
        a = map(universes) do u
            a1 = answers(u,g1,q1)
            a2 = answers(u,g2,q2)
            a3 = answers(u,g3,q3)
            a4 = answers(u,g4,q4)
            a5 = answers(u,g5,q5)
            possible_observations = product(a1,a2,a3,a4,a5) |> collect |> vec |> sort
            (u, possible_observations)
        end
        uniq = true
        for (p1,p2) in combinations(a,2)
            u1,o1 = p1
            u2,o2 = p2
            gods1,yesno1 = u1
            gods2,yesno2 = u2
            if gods1 == gods2
                continue        # no need to distinguish
            end
            for x in o1
                if x in o2
                    uniq=false  # same observation in two universes
                    break
                end
            end
            uniq || break
        end
        if uniq
            return ((g1,q1),(g2,q2),(g3,q3),(g4,q4),(g5,q5))
        end
    end
end

#     for g1 in 1:1,
#         q1 in questions,
        
#         g2 in 1:2,
#         q2 in questions,
#         g3 in (g1 == g2 ? (1,2) : (1,2,3)),
#         q3 in questions,
#         g4 in (g1 == g2 ? (1,2) : (1,2,3)),
#         q4 in questions

#         for u in universes
#             a1 = answers(u,g1,q1)
#             a2 = answers(u,g2,q2)
#             a12 = sort(vec(collect(product(a1,a2))))
#         end
#     end
# end

#         a1 = [ answers(u,g1,q1) for u in universes ]
#         for g2 in 1:2, q2 in questions
#             a2 = [ answers(u,g2,q2) for u in universes ]
#             a12 = [ sort(vec(collect(product(a1[i],a2[i])))) for i in 1:U ]


#             for g3 in (g1 == g2 ? (1,2) : (1,2,3)), q3 in questions # question if two answers equal
#                 for g4 in (g1 == g2 ? (1,2) : (1,2,3)), q4 in questions # question if two answers are different
#                     a3 = map(a12) do h12
#                         h123 = []
#                         for h in h12
#                             if h[1][end] == h[2][end]
#                                 a3 = [ answers(u,g3,q3)
#                             end
#                         end
#                     end
#                 end
#             end 
#         end
#     end
# end

#             a3 = [ answers(u,g3,q3) for u in universes ]

#                         aa = [ sort(vec(collect(product(a1[i],a2[i],a3[i])))) for i in 1:U ]

#                         uniq = true
#                         for i in 1:U-1, j in i+1:U, x in aa[i]
#                             if x in aa[j]
#                                 uniq = false
#                                 break
#                             end
#                         end

#                         if uniq
#                             println(Any[ (g1,q1), (g2,q2), (g3,q3) ])
#                             println(aa)
#                             return
#                         end
#                     end
#                 end
#             end
#         end
#     end
# end

#=
strategies = permutations(questions, 3) |> collect

function responses(s)
    [ (answer(u,1,s[1]), answer(u,2,s[2]), answer(u,3,s[3])) for u in universes ]
end

function goodstrategy(s)
    a = responses(s)
    length(unique(a)) == 12
end

=#
