include("CG1.jl")

# task 1
import Base: *
*(M1::Mat4f,M2::Mat4f) = Mat4f(M1*M2.v1,M1*M2.v2,M1*M2.v3,M1*M2.v4)
*(T1::Transformation,T2::Transformation) = Transformation(T1.M*T2.M)


# Task 2
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

function rotateObject(Object;figNum=1,center=[0,0,0])
	T1 = translation((-center)...)
	T3 = translation(center...)
	for t=0:60
		# set transformation
		T = T3*rotz(2*π*t/60)*T1
		# transform Object
		TObject = T*Object
		# render transformed Object
		render(TObject;figNum=figNum,figAxis=[-2,2,-2,2])
		# sleep for 10ms 
		sleep(0.01)	
	end
end

# rotate houseOfSantaClaus around origin
rotateObject(houseOfSantaClaus)
# rotate houseOfSantaClaus around edge
rotateObject(houseOfSantaClaus;figNum=2,center=[1,1,0])


# task 3
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

# rotate houseOfSantaClaus by π/4 aroud each axis
R = eulermatrix(π/4,π/4,π/4)
rotatedHouseOfSantaClaus = R*houseOfSantaClaus
# render rotated houseOfSantaClaus
render(rotatedHouseOfSantaClaus;figNum=3,figAxis=[-2,2,-2,2])


# task 4
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


# task 5
type OrthoCamera
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


# task 6
# render function, which takes the camera position into account
function render(object::Object,camera::OrthoCamera;figNum=1)
	# transform scene given in world coordinates to camera space
	camObject = camera.worldToCam*object
	render(camObject;figNum=figNum)
end

# first scale down the houseOfSantaClaus
scaledHouseOfSantaClaus = scaling(0.5,0.5,0.5)*houseOfSantaClaus

# canonical view direction
camera = OrthoCamera(Float32[0,0,1],Float32[0,0,-1],Float32[0,1,0])
render(scaledHouseOfSantaClaus,camera;figNum=4)

# screen moved backwards 9 unit length
camera = OrthoCamera(Float32[0,0,10],Float32[0,0,-1],Float32[0,1,0])
render(scaledHouseOfSantaClaus,camera;figNum=5)

# rotate screen clockwise
for t=0:60
	camera = OrthoCamera(Float32[0,0,1],Float32[0,0,-1],Float32[sin(2*π*t/60),cos(2*π*t/60),0])
	render(scaledHouseOfSantaClaus,camera;figNum=6)
	sleep(0.01)
end
