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

import Base: *
*(M1::Mat4f,M2::Mat4f) = Mat4f(M1*M2.v1,M1*M2.v2,M1*M2.v3,M1*M2.v4)
*(T1::Transformation,T2::Transformation) = Transformation(T1.M*T2.M)

# define vertices of the houseOfSantaClaus
v1 = Vec4f(-1,-1,0,1)
v2 = Vec4f(1,-1,0,1)
v3 = Vec4f(-1,1,0,1)
v4 = Vec4f(0,2,0,1)
v5 = Vec4f(1,1,0,1)
v6 = Vec4f(-1,-1,0,1)
v7 = Vec4f(-1,1,0,1)
v8 = Vec4f(1,1,0,1)
v9 = Vec4f(1,-1,0,1)
# create houseOfSantaClaus from vertices
houseOfSantaClaus = Object(v1,v2,v3,v4,v5,v6,v7,v8,v9)

# define funcction eulermatrix
function eulermatrix(α,β,δ)
	cosh = cos(α); sinh = sin(α);
	cosp = cos(β); sinp = sin(β);
	cosr = cos(δ); sinr = sin(δ);
	v1 = Vec4f(cosr*cosh-sinr*sinp*sinh,sinr*cosh+cosr*sinp*sinh,-cosp*sinh,0.0f0)
	v2 = Vec4f(-sinr*cosp,cosr*cosp,sinp,0.0f0)
	v3 = Vec4f(cosr*sinh+sinr*sinp*cosh,sinr*sinh-cosr*sinp*cosh,cosp*cosh,0.0f0)
	v4 = Vec4f(0,0,0,1.0f0)

	return Transformation(v1,v2,v3,v4)
end

import Base: inv
# implement matrix inversion by faling back to the build in inv() function
function inv(M::Mat4f)
	m = zeros(4,4)
	m[1,1] = M.v1.e1; m[1,2] = M.v2.e1; m[1,3] = M.v3.e1; m[1,4] = M.v4.e1; 
	m[2,1] = M.v1.e2; m[2,2] = M.v2.e2; m[2,3] = M.v3.e2; m[2,4] = M.v4.e2; 
	m[3,1] = M.v1.e3; m[3,2] = M.v2.e3; m[3,3] = M.v3.e3; m[3,4] = M.v4.e3; 
	m[4,1] = M.v1.e4; m[4,2] = M.v2.e4; m[4,3] = M.v3.e4; m[4,4] = M.v4.e4; 
	minv = inv(m)
	v1 = Vec4f(minv[1:4,1]...)
	v2 = Vec4f(minv[1:4,2]...)
	v3 = Vec4f(minv[1:4,3]...)
	v4 = Vec4f(minv[1:4,4]...)
	return Mat4f(v1,v2,v3,v4)
end

inv(T::Transformation) = Transformation(Mat4f(inv(T.M)))


abstract Camera

type OrthoCamera <: Camera
	camToWorld::Transformation
	worldToCam::Transformation
end

#= create OrthoCamera from center vector of screen (rc), viewing direction (rv) and 
the direction of the upper side of the screen=#
function OrthoCamera(rc::Vector{Float32},rv::Vector{Float32},ru::Vector{Float32})
	a = [rv[2]*ru[3]-rv[3]*ru[2],rv[3]*ru[1]-rv[1]*ru[3],rv[1]*ru[2]-rv[2]*ru[1]]
	b = ru
	c = -rv

	v1 = Vec4f(a[1], a[2], a[3], 0)
	v2 = Vec4f(b[1], b[2], b[3], 0)
	v3 = Vec4f(c[1], c[2], c[3], 0)
	v4 = Vec4f(rc[1], rc[2], rc[3], 1)
	T = Transformation(Mat4f(v1,v2,v3,v4))
	Tinv = inv(T)

	return OrthoCamera(T,Tinv)
end

type PinholeCamera <: Camera
	camToWorld::Transformation
	worldToCam::Transformation
	# screen width
	w::Float32
	# screen height
	h::Float32
	# distance eye screen
	d::Float32

	PinholeCamera(camToWorld::Transformation,worldToCam::Transformation) = new(camToWorld,worldToCam,2.0f0,2.0f0,1.0f0)
end

function PinholeCamera(rc::Vector{Float32},rv::Vector{Float32},ru::Vector{Float32})
	a = [rv[2]*ru[3]-rv[3]*ru[2],rv[3]*ru[1]-rv[1]*ru[3],rv[1]*ru[2]-rv[2]*ru[1]]
	b = ru
	c = -rv

	v1 = Vec4f(a[1], a[2], a[3], 0)
	v2 = Vec4f(b[1], b[2], b[3], 0)
	v3 = Vec4f(c[1], c[2], c[3], 0)
	v4 = Vec4f(rc[1], rc[2], rc[3], 1)
	T = Transformation(Mat4f(v1,v2,v3,v4))
	Tinv = inv(T)

	return PinholeCamera(T,Tinv)
end

# FrameBuffer type
type FrameBuffer
	nx::Int
	ny::Int
	data::Array{UInt8,2}

	FrameBuffer(nx::Int,ny::Int) = new(nx,ny,zeros(UInt8,nx,ny))
end

# function for clearing buffer
function clear!(buffer::FrameBuffer)
	buffer.data = zeros(UInt8,buffer.nx,buffer.ny)
	return nothing
end

# function for coloring a single pixel
function colorPixel!(buffer::FrameBuffer,x::Int,y::Int,color::UInt8)
	@inbounds buffer.data[x,y] = color
end

# function for plotting
function plot(buffer::FrameBuffer;figNum=1)
	T = eltype(buffer.data)
	figure(figNum)
	clf()
	gray()
	imshow(buffer.data',vmin=typemin(T),vmax=typemax(T),interpolation="none")
	return nothing
end

function whichOctant(x0,y0,x1,y1)
	Δx = x1-x0
	Δy = y1-y0
	if y0<=y1
		#Δy is non-negative
		if Δx>=0
			if Δx>Δy
				return 0
			else
				return 1
			end
		else
			if -Δx<Δy
				return 2
			else
				return 3
			end
		end
	else
		#Δy is negative
		if Δx<0
			if Δx<Δy
				return 4
			else
				return 5
			end
		else
			if Δx<-Δy
				return 6
			else
				return 7
			end
		end
	end
end

function switchToOctantZeroFrom(octant,x0,y0,x1,y1) 
	if octant == 0 
		return x0,y0,x1,y1
	elseif octant == 1
		return y0,x0,y1,x1
	elseif octant == 2
		return y0,-x0,y1,-x1
	elseif octant == 3
		return -x0,y0,-x1,y1
	elseif octant == 4
		return -x0,-y0,-x1,-y1
	elseif octant == 5
		return -y0,-x0,-y1,-x1
	elseif octant == 6
		return -y0,x0,-y1,x1
	elseif octant == 7
		return x0,-y0,x1,-y1
	else 
		error("octand=$octand is not in {0,1,...,7}")
	end
end
 
function switchFromOctantZeroTo(octant, xi, yi) 
	if octant == 0
		return xi, yi
	elseif octant == 1
		return yi, xi
	elseif octant == 2
		return -yi, xi
	elseif octant == 3
		return -xi, yi
	elseif octant == 4
		return -xi, -yi
	elseif octant == 5
		return -yi, -xi
	elseif octant == 6
		return yi, -xi
	elseif octant == 7
		return xi, -yi
	else 
		error("octand=$octand is not in {0,1,...,7}")
	end
end

function drawLine!(buffer::FrameBuffer,x0::Int,y0::Int,x1::Int,y1::Int,color::UInt8)
	octant = whichOctant(x0,y0,x1,y1)
	xa,ya,xe,ye = switchToOctantZeroFrom(octant,x0,y0,x1,y1)

	#calulate slope of line segment
	m = (ye-ya)/(xe-xa)
	if !(1>=m>=0)
		warn("m=$m. This case is not covered")
		return nothing
	end

	A2 = 2*(ye - ya)
	B = -(xe - xa)
	B2 = -2*(xe - xa)
	C2 = 2*(xe-xa)*ya-2*(ye-ya)*xa
	buffer.data[switchFromOctantZeroTo(octant, xa, ya)...] = color
	yi = ya

	D = A2*xa+B*(2*ya+1)+C2
	for xi=xa+1:xe
    		D += A2
		if D>0 
			yi += 1
			D += B2
		end
		setindex!(buffer.data, color, switchFromOctantZeroTo(octant, xi, yi)...)
	end
	return nothing
end

drawLine!(buffer::FrameBuffer,x0::Int,y0::Int,x1::Int,y1::Int) = drawLine!(buffer,x0,y0,x1,y1,0xff)

function drawTriangle!(buffer::FrameBuffer,xa::Int,ya::Int,xb::Int,yb::Int,xc::Int,yc::Int,color::UInt8)
	# determine bounding box of triangle
	xmin = max(min(xa,xb,xc),1)
	xmax = min(max(xa,xb,xc),buffer.nx)
	ymin = max(min(ya,yb,yc),1)
	ymax = min(max(ya,yb,yc),buffer.ny)

	δdiv = 1.0/((ya-yb)*xc+(xb-xa)*yc+xa*yb-xb*ya)
	βdiv = 1.0/((ya-yc)*xb+(xc-xa)*yb+xa*yc-xc*ya)

	# loop through bounding box and colorize pixels inside the triangle
	for yi=ymin:ymax
		for xi=xmin:xmax
			δ = δdiv*((ya-yb)*xi+(xb-xa)*yi+xa*yb-xb*ya)
			β = βdiv*((ya-yc)*xi+(xc-xa)*yi+xa*yc-xc*ya)
			α = 1-β-δ
			if 0<α<1 && 0<β<1 && 0<δ<1
				buffer.data[xi,yi] = color
			end
		end
	end
	return nothing
end

function drawTriangle!(buffer::FrameBuffer,xa::Int,ya::Int,xb::Int,yb::Int,xc::Int,yc::Int,ca::UInt8,cb::UInt8,cc::UInt8)
	# determine bounding box of triangle
	xmin = max(min(xa,xb,xc),1)
	xmax = min(max(xa,xb,xc),buffer.nx)
	ymin = max(min(ya,yb,yc),1)
	ymax = min(max(ya,yb,yc),buffer.ny)

	δdiv = 1.0/((ya-yb)*xc+(xb-xa)*yc+xa*yb-xb*ya)
	βdiv = 1.0/((ya-yc)*xb+(xc-xa)*yb+xa*yc-xc*ya)

	# loop through bounding box and colorize pixels inside the triangle
	for yi=ymin:ymax
		for xi=xmin:xmax
			δ = δdiv*((ya-yb)*xi+(xb-xa)*yi+xa*yb-xb*ya)
			β = βdiv*((ya-yc)*xi+(xc-xa)*yi+xa*yc-xc*ya)
			α = 1-β-δ
			if 0<α<1 && 0<β<1 && 0<δ<1
				color = round(UInt8, α*ca+β*cb+δ*cc)
				buffer.data[xi,yi] = color
			end
		end
	end
	return nothing
end
