type Object
 vertices::Vector{Vec4f}
 # Type constructorwhich allows to use Object(vec1,vec2,...)
 Object(x::Vector{Vec4f}) = new(x)
 Object(x...) = new(collect(Vec4f,x))
end
