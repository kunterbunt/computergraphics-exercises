import Base.*
type Mat4f
	v1::Vec4f
	v2::Vec4f
	v3::Vec4f
	v4::Vec4f
end

# Matrix vector multiplication.
*(M::Mat4f, v::Vec4f) = Vec4f(M.v1.e1 * v.e1 + M.v1.e2 * v.e2 + M.v1.e3 * v.e3 + M.v1.e4 * v.e4,
	M.v2.e1 * v.e1 + M.v2.e2 * v.e2 + M.v2.e3 * v.e3 + M.v2.e4 * v.e4,
	M.v3.e1 * v.e1 + M.v3.e2 * v.e2 + M.v3.e3 * v.e3 + M.v3.e4 * v.e4,
	M.v4.e1 * v.e1 + M.v4.e2 * v.e2 + M.v4.e3 * v.e3 + M.v4.e4 * v.e4)
