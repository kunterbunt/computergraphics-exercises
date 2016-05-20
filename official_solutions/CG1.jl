using PyPlot

immutable Vec4f
	e1::Float32
	e2::Float32
	e3::Float32
	e4::Float32
end
import Base: +,-,*
+(v1::Vec4f,v2::Vec4f) = Vec4f(v1.e1+v2.e1, v1.e2+v2.e2, v1.e3+v2.e3, v1.e4+v2.e4)
-(v1::Vec4f,v2::Vec4f) = Vec4f(v1.e1-v2.e1, v1.e2-v2.e2, v1.e3-v2.e3, v1.e4-v2.e4)
*(a::Float32,v::Vec4f) = Vec4f(a*v.e1, a*v.e2, a*v.e3, a*v.e4)

immutable Mat4f
	v1::Vec4f
	v2::Vec4f
	v3::Vec4f
	v4::Vec4f
end
import Base: +,-,*
+(M1::Mat4f,M2::Mat4f) = Mat4f(M1.v1+M2.v1, M1.v2+M2.v2, M1.v3+M2.v3, M1.v4+M2.v4)
-(M1::Mat4f,M2::Mat4f) = Mat4f(M1.v1-M2.v1, M1.v2-M2.v2, M1.v3-M2.v3, M1.v4-M2.v4)
*(M::Mat4f,v::Vec4f) = 	v.e1*M.v1 + v.e2*M.v2 + v.e3*M.v3 + v.e4*M.v4

type Object
	vertices::Vector{Vec4f}

	Object(x::Vector{Vec4f}) = new(x)
	Object(x...) = new(collect(Vec4f,x))
end

function render(object::Object;figNum=1, figTitle="Object", figAxis=[-1,1,-1,1])
	# make figure figNum current figure
	figure(figNum)
	# clear content of figure figNum
	clf()
	# plot Title
	title("$figTitle")
	# set and label axis
	axis(figAxis)
	xlabel("X Axis")
	ylabel("Y Axis")
	# isometric z-projection of vertices onto plane z=0
        x = [v.e1 for v in object.vertices]
        y = [v.e2 for v in object.vertices]
	# plot projection data
	plot(x,y)
end

type Transformation
	M::Mat4f

	Transformation(M::Mat4f) = new(M)
	Transformation(v1,v2,v3,v4) = new(Mat4f(v1,v2,v3,v4))
end
import Base: *
*(T::Transformation,v::Vec4f) = T.M*v
*(T::Transformation,O::Object) = Object(map(x->T*x,O.vertices))

function translation(x,y,z)
	v1 = Vec4f(1,0,0,0)
	v2 = Vec4f(0,1,0,0)
	v3 = Vec4f(0,0,1,0)
	v4 = Vec4f(x,y,z,1)
	return Transformation(v1,v2,v3,v4)
end

function rotx(ϕ)
	v1 = Vec4f(1,0,0,0)
	v2 = Vec4f(0,cos(ϕ),+sin(ϕ),0)
	v3 = Vec4f(0,-sin(ϕ),cos(ϕ),0)
	v4 = Vec4f(0,0,0,1)
	return Transformation(v1,v2,v3,v4)
end

function roty(ϕ)
	v1 = Vec4f(cos(ϕ),0,-sin(ϕ),0)
	v2 = Vec4f(0,1,0,0)
	v3 = Vec4f(+sin(ϕ),0,cos(ϕ),0)
	v4 = Vec4f(0,0,0,1)
	return Transformation(v1,v2,v3,v4)
end

function rotz(ϕ)
	v1 = Vec4f(cos(ϕ),+sin(ϕ),0,0)
	v2 = Vec4f(-sin(ϕ),cos(ϕ),0,0)
	v3 = Vec4f(0,0,1,0)
	v4 = Vec4f(0,0,0,1)
	return Transformation(v1,v2,v3,v4)
end

function scaling(sx,sy,sz)
	sx*sy*sz == 0 && error("Scaling factors need to be non-zero")
	v1 = Vec4f(sx,0,0,0)
	v2 = Vec4f(0,sy,0,0)
	v3 = Vec4f(0,0,sz,0)
	v4 = Vec4f(0,0,0,1)
	return Transformation(v1,v2,v3,v4)
end
