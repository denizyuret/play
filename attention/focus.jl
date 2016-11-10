using Knet,MAT,Images
using ImageView,TestImages
mview(x)=ImageView.view(x)
#isdefined(:vgg) || (vgg = loadmodel())
#a = load(joinpath("/mnt/ai/home/dyuret/.gnome2/cheese/media/2016-11-08-135940.jpg"))
# some images with multiple objects
# /mnt/ai/data/ImageNet/ILSVRC2015/Data/CLS-LOC/val/ILSVRC2012_val_00026677.JPEG
#img = load("/mnt/ai/data/img/ImageNet/ILSVRC2015/Data/CLS-LOC/val/ILSVRC2012_val_00010447.JPEG")

immutable Model; weights; average; description; end
const op = [1,2,1,2,1,1,2,1,1,2,1,1,2,3,3,4]
convx(w,x)=conv4(w,x;padding=1,mode=1)

function test1(path="/mnt/ai/data/img/ImageNet/ILSVRC2015/Data/CLS-LOC/val/ILSVRC2012_val_00010447.JPEG")
    global vgg
    isdefined(:vgg) || (vgg=loadmodel())
    global img=load(path)
    mview(img)
    global out, coor
    (out,coor) = multipred(vgg,img)
end

function test2()
    global vgg
    isdefined(:vgg) || (vgg=loadmodel())
    global img=rndimg()
    mview(img)
    global out, coor
    (out,coor) = multipred(vgg,img)
end    

# minibatch multiple regions of the image and find the ones with lowest entropy
function multipred(model, img; n=100)
    data = Array(Float32,224,224,3,n)
    coor = Any[]
    for i=1:n
        r = rand(1:div(min(size(img)...),3))
        x = rand(r+1:size(img,1)-r)
        y = rand(r+1:size(img,2)-r)
        a = img[x-r:x+r,y-r:y+r]
        b = normalize(a, model.average)
        Base.unsafe_copy!(data, 1+(i-1)*length(b), b, 1, length(b))
        push!(coor, (x,y,r))
    end
    out = process(model.weights, data)
    lp = logp(out,1)
    en = sum(-lp.*exp(lp),1)
    sp = sortperm(vec(en))
    pr = falses(size(out,1))
    for i in sp
        c = indmax(vec(out[:,i]))
        pr[c] && continue
        pr[c] = true
        println((exp(lp[c,i]), coor[i], model.description[c]))
    end
    (out, coor)
end

# predict a given image: focus on a region by predict(vgg,a[75:700,500:1200]);
function predict(model, img; top=5)
    x = normalize(img, model.average)
    w = model.weights
    y0 = process(w,x)
    printclasses(y0, model, top)
    return y0
end

function printclasses(y0, model, top; msg="")
    y1 = vec(Array(y0))
    s1 = sortperm(y1,rev=true)
    s2 = s1[1:top]
    p1 = exp(logp(y1))
    Base.display(hcat(p1[s2], model.description[s2]))
    println(msg)
end

function process(w, x)
    x = KnetArray(x)
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
    return Array(x)
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

# pick a random image from ImageNet validation set
function rndimg(path="/mnt/ai/data/img/ImageNet/ILSVRC2015/Data/CLS-LOC/val")
    a = readdir(path)
    i = rand(1:length(a))
    println(a[i])
    load(joinpath(path,a[i]))
end

