import Base.*
type Mat4f
	v1::Vec4f
	v2::Vec4f
	v3::Vec4f
	v4::Vec4f
end

# Matrix vector multiplication.
*(M::Mat4f, v::Vec4f) = Vec4f(
	M.v1.e1 * v.e1 + M.v1.e2 * v.e2 + M.v1.e3 * v.e3 + M.v1.e4 * v.e4,
	M.v2.e1 * v.e1 + M.v2.e2 * v.e2 + M.v2.e3 * v.e3 + M.v2.e4 * v.e4,
	M.v3.e1 * v.e1 + M.v3.e2 * v.e2 + M.v3.e3 * v.e3 + M.v3.e4 * v.e4,
	M.v4.e1 * v.e1 + M.v4.e2 * v.e2 + M.v4.e3 * v.e3 + M.v4.e4 * v.e4)

function getCol(M1::Mat4f, c::Int64)
	if c == 1
		return Vec4f(M1.v1.e1, M1.v2.e1, M1.v3.e1, M1.v4.e1)
	elseif c == 2
		return Vec4f(M1.v1.e2, M1.v2.e2, M1.v3.e2, M1.v4.e2)
	elseif c == 3
		return Vec4f(M1.v1.e3, M1.v2.e3, M1.v3.e3, M1.v4.e3)
	else
		return Vec4f(M1.v1.e4, M1.v2.e4, M1.v3.e4, M1.v4.e4)
	end
end

# Matrix multiplication.
*(M1::Mat4f,M2::Mat4f) = Mat4f(
	Vec4f(M1.v1*getCol(M2, 1), M1.v1*getCol(M2, 2), M1.v1*getCol(M2, 3), M1.v1*getCol(M2, 4)),
	Vec4f(M1.v2*getCol(M2, 1), M1.v2*getCol(M2, 2), M1.v2*getCol(M2, 3), M1.v2*getCol(M2, 4)),
	Vec4f(M1.v3*getCol(M2, 1), M1.v3*getCol(M2, 2), M1.v3*getCol(M2, 3), M1.v3*getCol(M2, 4)),
	Vec4f(M1.v4*getCol(M2, 1), M1.v4*getCol(M2, 2), M1.v4*getCol(M2, 3), M1.v4*getCol(M2, 4))
)

import Base: inv

function GenIdentityMat4f()
	return Mat4f(Vec4f(1,0,0,0), Vec4f(0,1,0,0), Vec4f(0,0,1,0), Vec4f(0,0,0,1))
end

function GenExampleMat()
	return Mat4f(Vec4f(1,2,3,4), Vec4f(0,2,2,3), Vec4f(2,2,3,1), Vec4f(0,1,4,5))
end

function inv(M::Mat4f)
	m = zeros(4,4)
	m[1,1] = M.v1.e1; m[1,2] = M.v1.e2; m[1,3] = M.v1.e3; m[1,4] = M.v1.e4;
	m[2,1] = M.v2.e1; m[2,2] = M.v2.e2; m[2,3] = M.v2.e3; m[2,4] = M.v2.e4;
	m[3,1] = M.v3.e1; m[3,2] = M.v3.e2; m[3,3] = M.v3.e3; m[3,4] = M.v3.e4;
	m[4,1] = M.v4.e1; m[4,2] = M.v4.e2; m[4,3] = M.v4.e3; m[4,4] = M.v4.e4;
	minv = inv(m)
	v1 = Vec4f(minv[1,1:4]...)
	v2 = Vec4f(minv[2,1:4]...)
	v3 = Vec4f(minv[3,1:4]...)
	v4 = Vec4f(minv[4,1:4]...)
	return Mat4f(v1,v2,v3,v4)
end
