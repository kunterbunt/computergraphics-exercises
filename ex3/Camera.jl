type OrthoCamera
	camToWorld::Transformation
	worldToCam::Transformation
end

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

function render(object::Object,camera::OrthoCamera;figNum=1)
	# transform scene given in world coordinates to camera space
	camObject = camera.worldToCam*object
	render(camObject;figNum=figNum)
end