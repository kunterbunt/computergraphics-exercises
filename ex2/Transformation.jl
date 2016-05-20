import Base.*
type Transformation
	M::Mat4f
	Transformation(v1,v2,v3,v4) = new(Mat4f(v1,v2,v3,v4))
end

*(T::Transformation, v::Vec4f) = T.M * v

*(T::Transformation, O::Object) = objectTranslationHelper(T, O)
function objectTranslationHelper(T, O)
	x = Vec4f[]
	for i = 1:length(O.vertices)
		x = [x; T * O.vertices[i]]
	end
	return Object(x)
end

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
