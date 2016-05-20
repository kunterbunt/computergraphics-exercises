import Base.+, Base.*
type Vec4f
	e1::Float32
	e2::Float32
	e3::Float32
	e4::Float32
end

# Vector addition.
+(v1::Vec4f, v2::Vec4f) = Vec4f(v1.e1 + v2.e1,
	v1.e2 + v2.e2, v1.e3 + v2.e3, v1.e4 + v2.e4)

# Scalar multiplication.
*(a::Float32, v::Vec4f) = Vec4f(v.e1 * a, v.e2 * a, v.e3 * a, v.e4 * a)
*(a::Float64, v::Vec4f) = Vec4f(v.e1 * a, v.e2 * a, v.e3 * a, v.e4 * a)
