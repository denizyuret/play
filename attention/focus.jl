using Knet,MAT,Images
#using ImageView,TestImages
#mview(x)=ImageView.view(x)
#vgg = loadmodel()
#a = load(joinpath("/mnt/ai/home/dyuret/.gnome2/cheese/media/2016-11-08-135940.jpg"))

immutable Model; weights; average; description; end
const op = [1,2,1,2,1,1,2,1,1,2,1,1,2,3,3,4]
convx(w,x)=conv4(w,x;padding=1,mode=1)

# predict a given image: focus on a region by predict(vgg,a[75:700,500:1200]);
function predict(model, img; top=5)
    x = normalize(img, model.average)
    w = model.weights
    for k=1:div(length(w),2)
        if op[k] == 1
            x = relu(convx(w[2k-1],x) .+ w[2k])
        elseif op[k] == 2
            x = pool(relu(convx(w[2k-1],x) .+ w[2k]))
        elseif op[k] == 3
            x = relu(w[2k-1]*mat(x) .+ w[2k])
        else
            x = w[2k-1]*mat(x) .+ w[2k]
        end
    end
    y1 = vec(Array(x))
    s1 = sortperm(y1,rev=true)
    s2 = s1[1:top]
    p1 = exp(logp(y1))
    display(hcat(p1[s2], model.description[s2]))
    println()
    return x
end

# normalize a given image
function normalize(img, averageImage)
    new_size = ntuple(i->div(size(img,i)*224,minimum(size(img))),2)
    a1 = Images.imresize(img, new_size)
    i1 = div(size(a1,1)-224,2)
    j1 = div(size(a1,2)-224,2)
    b1 = a1[i1+1:i1+224,j1+1:j1+224]
    c1 = separate(b1)
    d1 = convert(Array{Float32}, c1)
    e1 = reshape(d1[:,:,1:3], (224,224,3,1))
    f1 = (255 * e1 .- averageImage)
    g1 = permutedims(f1, [2,1,3,4])
    x1 = KnetArray(g1)
end

function loadmodel(path=Knet.dir("data","imagenet-vgg-verydeep-16.mat"))
    m = matread(path)
    w = Any[]
    for l in m["layers"]
        haskey(l,"weights") && !isempty(l["weights"]) && push!(w, l["weights"]...)
    end
    for i in 2:2:26             # reshape bias layers to 1,1,n,1
        w[i] = reshape(w[i], (1,1,length(w[i]),1))
    end
    for i in 27:2:32            # reshape fully connected layers to m,n
        w[i] = mat(w[i])'
    end
    w = map(KnetArray,w)
    a = convert(Array{Float32},m["meta"]["normalization"]["averageImage"])
    d = m["meta"]["classes"]["description"]
    Model(w,a,d)
end

