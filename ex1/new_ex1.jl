# Task 1.
type Vec4f # 4-dimensional column vector.
	x::Float32
	y::Float32
	z::Float32
	v::Float32 # Homogeneous coordinate.
end

type Mat4f
	col1::Vec4f
	col2::Vec4f
	col3::Vec4f
	col4::Vec4f
end

import Base.-, Base.+, Base.*, Base./
# Vector-Vector Addition.
+(vec1::Vec4f, vec2::Vec4f) = Vec4f(
  vec1.x + vec2.x,
  vec1.y + vec2.y,
  vec1.z + vec2.z,
  vec1.v + vec2.v
)

# Scalar-Vector Multiplication.
*(scalar::Float64, vec::Vec4f) = Vec4f(
  vec.x * scalar,
  vec.y * scalar,
  vec.z * scalar,
  vec.v * scalar
)
*(vec::Vec4f, scalar::Float64) = scalar * vec
*(scalar::Float32, vec::Vec4f) = Vec4f(
  vec.x * scalar,
  vec.y * scalar,
  vec.z * scalar,
  vec.v * scalar
)
*(vec::Vec4f, scalar::Float32) = scalar * vec

# Matrix-Vector Multiplication.
*(M::Mat4f,v::Vec4f) = Vec4f(v.x * M.col1 + v.y*M.col2 + v.z*M.col3 + v.v*M.col4)

# Task 2.
type Object
 vertices::Vector{Vec4f}
 # Constructor which allows to use Object(vec1,vec2,...)
 Object(x::Vector{Vec4f}) = new(x)
 Object(x...) = new(collect(Vec4f,x))
end

triangle = Object(
  Vec4f(0,0,0,1), # Bottom left.
  Vec4f(1,0,0,1), # Bottom right.
  Vec4f(0.5,1,0,1), # Up middle.
  Vec4f(0,0,0,1)  # And back to bottom left.
)

using PyPlot
function render(object; figNum=1, figTitle="Object", figAxis=[-1, 1, -1, 1])
  clf()
  axis(figAxis)
  title("$figTitle")
  axis(figAxis)
  xlabel("x axis")
  ylabel("y axis")
  x = [vec.x for vec in object.vertices]
  y = [vec.y for vec in object.vertices]
	plot(x, y)
end

houseOfSantaClaus = Object(
  Vec4f(-1,-1,0,1),
  Vec4f(1,-1,0,1),
  Vec4f(-1,1,0,1),
  Vec4f(0,2,0,1),
  Vec4f(1,1,0,1),
  Vec4f(-1,-1,0,1),
  Vec4f(-1,1,0,1),
  Vec4f(1,1,0,1),
  Vec4f(1,-1,0,1)
)

#render(houseOfSantaClaus, figAxis=[-2, 2, -2, 3])

# Task 3.
type Transformation
	Mat::Mat4f
	Transformation(vec1, vec2, vec3, vec4) = new(Mat4f(vec1, vec2, vec3, vec4))
end
*(Transf::Transformation, vec::Vec4f) = Transf.Mat * vec
*(Transf::Transformation, Obj::Object) = Object(map(vertex -> Transf * vertex, Obj.vertices))
function translation(x, y, z)
	return Transformation(
    Vec4f(1, 0, 0, 0),
    Vec4f(0, 1, 0 , 0),
    Vec4f(0, 0, 1, 0),
    Vec4f(x, y, z, 1)
  )
end
function rotx(ϕ)
	return Transformation(
    Vec4f(1, 0, 0, 0),
    Vec4f(0, cos(ϕ), +sin(ϕ), 0),
    Vec4f(0, -sin(ϕ), cos(ϕ), 0),
    Vec4f(0, 0, 0, 1)
  )
end
function roty(ϕ)
	return Transformation(
    Vec4f(cos(ϕ), 0, -sin(ϕ), 0),
    Vec4f(0, 1, 0 , 0),
    Vec4f(+sin(ϕ), 0, cos(ϕ), 0),
    Vec4f(0, 0, 0, 1)
  )
end
function rotz(ϕ)
	return Transformation(
    Vec4f(cos(ϕ), +sin(ϕ), 0, 0),
    Vec4f(-sin(ϕ), cos(ϕ), 0 , 0),
    Vec4f(0, 0, 1, 0),
    Vec4f(0, 0, 0, 1)
  )
end
function scaling(sx, sy, sz)
  sx * sy * sz == 0 && error("Scaling factors need to be non-zero")
	return Transformation(
    Vec4f(sx, 0, 0, 0),
    Vec4f(0, sy, 0 , 0),
    Vec4f(0, 0, sz, 0),
    Vec4f(0, 0, 0, 1)
  )
end

#render(scaling(1.25, 0.75, 1) * houseOfSantaClaus, figAxis=[-2, 2, -2, 3])
#render(roty(pi/3) * houseOfSantaClaus, figAxis=[-2,2,-2,2])
