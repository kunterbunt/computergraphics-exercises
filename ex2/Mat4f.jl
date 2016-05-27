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

# Matrix multiplication.
*(M1::Mat4f,M2::Mat4f) = Mat4f(
	M1 * M2.v1,
	M1 * M2.v2,
	M1 * M2.v3,
	M1 * M2.v4
)

import Base: inv

function GenIdentityMat4f()
	return Mat4f(Vec4f(1,0,0,0), Vec4f(0,1,0,0), Vec4f(0,0,1,0), Vec4f(0,0,0,1))
end

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
