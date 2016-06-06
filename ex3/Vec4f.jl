import Base.+, Base.*
type Vec4f
	e1::Float32
	e2::Float32
	e3::Float32
	e4::Float32
end

# Vector addition.
+(v1::Vec4f, v2::Vec4f) = Vec4f(
	v1.e1 + v2.e1,
	v1.e2 + v2.e2,
	v1.e3 + v2.e3,
	v1.e4 + v2.e4
)

# Scalar multiplication.
*(a::Float32, v::Vec4f) = Vec4f(
	v.e1 * a,
	v.e2 * a,
	v.e3 * a,
	v.e4 * a
)
*(a::Float64, v::Vec4f) = Vec4f(
	v.e1 * a,
	v.e2 * a,
	v.e3 * a,
	v.e4 * a
)

#Scalarprodut
*(a::Vec4f, b::Vec4f) = 
	a.e1 * b.e1 +
	a.e2 * b.e2 +
	a.e3 * b.e3 +
	a.e4 * b.e4


function Vec4fToArray(v::Vec4f)
	return [v.e1 v.e2 v.e3 v.e4]
end

function ArrayToVec4f(a::Float32...)
	length(a)

	return Vec4f(a[1], a[2], a[3], a[4])
end