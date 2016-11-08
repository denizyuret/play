# watch the directory cheese saves webcam images in and classify the
# new images as they appear.

using Knet,MAT
isdefined(:VGG) || include(Knet.dir("examples/vgg.jl"))
using VGG: weights, data, predict
const vggpath = Knet.dir("data","imagenet-vgg-verydeep-16.mat")
const imgpath = "/mnt/ai/home/dyuret/.gnome2/cheese/media"
isdefined(:vgg) || (vgg = matread(vggpath))
model = weights(vgg["layers"])
averageImage = convert(Array{Float32},vgg["meta"]["normalization"]["averageImage"])
description = vgg["meta"]["classes"]["description"]

function vg()
    imgdir1 = readdir(imgpath)
    while true
        sleep(2)
        imgdir2 = readdir(imgpath); print(".")
        if !isequal(imgdir1, imgdir2)
            for img in setdiff(imgdir2, imgdir1)
                x1 = data(joinpath(imgpath,img), averageImage)
                y1 = predict(model, x1)
                z1 = vec(Array(y1))
                s1 = sortperm(z1,rev=true)
                p1 = exp(logp(z1))
                println(img)
                display(hcat(p1[s1[1:5]], description[s1[1:5]]))
                println()
            end
            imgdir1 = imgdir2
        end
    end
end

# x1 = data(o[:image], averageImage)
# info("Classifying")
# @time y1 = predict(w,x1)
# z1 = vec(Array(y1))
# s1 = sortperm(z1,rev=true)
# p1 = exp(logp(z1))
# display(hcat(p1[s1[1:o[:top]]], description[s1[1:o[:top]]]))
# println()
