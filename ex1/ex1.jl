type Vec4f
	e1::Float32
	e2::Float32
	e3::Float32
	e4::Float32
end

type Mat4f
	v1::Vec4f
	v2::Vec4f
	v3::Vec4f
	v4::Vec4f
end



import Base.-, Base.+, Base.*, Base./

# Vector addition.
+(v1::Vec4f, v2::Vec4f) = Vec4f(v1.e1 + v2.e1,
	v1.e2 + v2.e2, v1.e3 + v2.e3, v1.e4 + v2.e4)

a = Vec4f(1.0,2.0,3.0,4);
b = Vec4f(1.0,2.0,3.0,4);
c = a + b

# Scalar multiplication.
*(a::Float32, v::Vec4f) = Vec4f(v.e1 * a, v.e2 * a, v.e3 * a, v.e4 * a)
*(a::Float64, v::Vec4f) = Vec4f(v.e1 * a, v.e2 * a, v.e3 * a, v.e4 * a)
c = 3.0 * c

# Matrix vector multiplication.
*(M::Mat4f, v::Vec4f) = Vec4f(M.v1.e1 * v.e1 + M.v1.e2 * v.e2 + M.v1.e3 * v.e3 + M.v1.e4 * v.e4,
	M.v2.e1 * v.e1 + M.v2.e2 * v.e2 + M.v2.e3 * v.e3 + M.v2.e4 * v.e4,
	M.v3.e1 * v.e1 + M.v3.e2 * v.e2 + M.v3.e3 * v.e3 + M.v3.e4 * v.e4,
	M.v4.e1 * v.e1 + M.v4.e2 * v.e2 + M.v4.e3 * v.e3 + M.v4.e4 * v.e4)

a1 = Vec4f(1,1,1,1);
a2 = Vec4f(2,2,2,2);
a3 = Vec4f(1,1,1,1);
a4 = Vec4f(1,1,1,1);
M = Mat4f(a1, a2, a3, a4)
M = M * a2

type Object
 vertices::Vector{Vec4f}
 # Type constructorwhich allows to use Object(vec1,vec2,...)
 Object(x::Vector{Vec4f}) = new(x)
 Object(x...) = new(collect(Vec4f,x))
end

o = Object(a1, a2)

v1 = Vec4f(0,0,0,1)
v2 = Vec4f(1,0,0,1)
v3 = Vec4f(0,1,0,1)
triangle = Object(v1,v2,v3,v1)

using PyPlot

function render(object;figAxis=[-1,1,-1,1])
	axis(figAxis)
	x = []
	y = []
	for i in 1:length(object.vertices)
		x = [x; object.vertices[i].e1]
		y = [y; object.vertices[i].e2]
	end
	x = [x; object.vertices[1].e1]
	y = [y; object.vertices[1].e2]
	plot(x, y, linestyle="-")
end

render(triangle)
v1 = Vec4f(-1,-1,0,1)
v2 = Vec4f(1,-1,0,1)
v3 = Vec4f(-1,1,0,1)
v4 = Vec4f(0,2,0,1)
v5 = Vec4f(1,1,0,1)
v6 = Vec4f(-1,-1,0,1)
v7 = Vec4f(-1,1,0,1)
v8 = Vec4f(1,1,0,1)
v9 = Vec4f(1,-1,0,1)
houseOfSantaClaus = Object(v1,v2,v3,v4,v5,v6,v7,v8,v9)
render(houseOfSantaClaus, figAxis=[-2,2,-2,2])

type Transformation
	M::Mat4f
	Transformation(v1,v2,v3,v4) = new(Mat4f(v1,v2,v3,v4))
end
*(T::Transformation, v::Vec4f) = T.M * v
*(T::Transformation, O::Object) = objectTranslationHelper(T, O)

T = Transformation(Vec4f(2, 0, 0, 0), Vec4f(0, 2, 0 , 0), Vec4f(0, 0, 2, 0), Vec4f(0, 0, 0, 2))

function objectTranslationHelper(T, O)
	x = Vec4f[]
	for i = 1:length(O.vertices)
		x = [x; T * O.vertices[i]]
	end
	return Object(x)
end

#render(T * houseOfSantaClaus, figAxis=[-8,8,-8,8])

function translation(x, y, z)
	return Transformation(Vec4f(1, 0, 0, x), Vec4f(0, 1, 0 , y), Vec4f(0, 0, 1, z), Vec4f(0, 0, 0, 1))
end
function rotx(phi)
	return Transformation(Vec4f(1, 0, 0, 0), Vec4f(0, cos(phi), -sin(phi), 0), Vec4f(0, sin(phi), cos(phi), 0), Vec4f(0, 0, 0, 1))
end
function roty(phi)
	return Transformation(Vec4f(cos(phi), 0, sin(phi), 0), Vec4f(0, 1, 0 , 0), Vec4f(-sin(phi), 0, cos(phi), 0), Vec4f(0, 0, 0, 1))
end
function rotz(phi)
	return Transformation(Vec4f(cos(phi), -sin(phi), 0, 0), Vec4f(sin(phi), cos(phi), 0 , 0), Vec4f(0, 0, 1, 0), Vec4f(0, 0, 0, 1))
end
function scaling(sx, sy, sz)
	return Transformation(Vec4f(sx, 0, 0, 0), Vec4f(0, sy, 0 , 0), Vec4f(0, 0, sz, 0), Vec4f(0, 0, 0, 1))
end

#render(translation(1, 0, 0) * houseOfSantaClaus, figAxis=[-8,8,-8,8])
#render(rotx(10) * houseOfSantaClaus, figAxis=[-8,8,-8,8])
render(translation(1, 0, 0) * houseOfSantaClaus, figAxis=[-2,2,-2,2])
render(rotx(pi/4) * houseOfSantaClaus, figAxis=[-2,2,-2,2])
