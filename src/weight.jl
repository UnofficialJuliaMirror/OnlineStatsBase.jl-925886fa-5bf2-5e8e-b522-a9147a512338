Base.show(io::IO, w::Weight) = print(io, name(w))
function Base.:(==)(o1::Weight, o2::Weight)
    typeof(o1) == typeof(o2) || return false
    nms = fieldnames(o1)
    all(getfield.(o1, nms) .== getfield.(o2, nms))
end
Base.copy(w::Weight) = deepcopy(w)

#-----------------------------------------------------------------------# EqualWeight
struct EqualWeight <: Weight end
(::EqualWeight)(n, n2=1) = n2 / n
#-----------------------------------------------------------------------# ExponentialWeight
struct ExponentialWeight <: Weight 
    λ::Float64 
    ExponentialWeight(λ::Real = .1) = new(λ)
    ExponentialWeight(lookback::Integer) = new(2 / (lookback + 1))
end
(w::ExponentialWeight)(n, n2=1) = n == 1 ? 1.0 : w.λ
#-----------------------------------------------------------------------# LearningRate
struct LearningRate <: Weight 
    r::Float64 
    LearningRate(r = .6) = new(r)
end
(w::LearningRate)(n, n2=1) = 1 / n ^ w.r
#-----------------------------------------------------------------------# LearningRate2
struct LearningRate2 <: Weight 
    c::Float64 
    LearningRate2(c = .5) = new(c)
end
(w::LearningRate2)(n, n2=1) = 1 / (1 + w.c * (n - 1))
#-----------------------------------------------------------------------# HarmonicWeight
struct HarmonicWeight <: Weight 
    a::Float64 
    HarmonicWeight(a = 10.0) = new(a)
end
(w::HarmonicWeight)(n, n2=1) = w.a / (w.a + n - 1)
#-----------------------------------------------------------------------# McclainWeight
mutable struct McclainWeight <: Weight
    α::Float64
    last::Float64
    McclainWeight(α = .1) = new(α, 1.0)
end
(w::McclainWeight)(n, n2=1) = n == 1 ? 1.0 : (w.last = w.last / (1 + w.last - w.α))
#-----------------------------------------------------------------------# Bounded
struct Bounded{W <: Weight} <: Weight 
    weight::W 
    λ::Float64 
end
(w::Bounded)(n, n2=1) = max(w.λ, w.weight(n, n2))
#-----------------------------------------------------------------------# Scaled
struct Scaled{W <: Weight} <: Weight
    weight::W 
    λ::Float64
end
Base.:*(λ::Real, w::Weight) = Scaled(w, Float64(λ))
(w::Scaled)(n, n2=1) = w.λ * w.weight(n, n2)
