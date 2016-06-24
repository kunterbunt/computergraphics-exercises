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
*(M1::Mat4f,M2::Mat4f) = Mat4f(M1*M2.v1,M1*M2.v2,M1*M2.v3,M1*M2.v4)
*(T1::Transformation,T2::Transformation) = Transformation(T1.M*T2.M)


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

import Base: dot
dot(v::Vec4f,w::Vec4f) = v.e1*w.e1+v.e2*w.e2+v.e3*w.e3+v.e4*w.e4
unitize(v::Vec4f) = (1.0f0 / sqrt(dot(v, v)) * v)


# task 1
abstract Camera

type OrthoCamera <: Camera
	camToWorld::Transformation
	worldToCam::Transformation
	# screen resolution in x direction
	nx::Int
	# screen resulution in y direction
	ny::Int
	# screen width
	w::Float32
	# screen height
	h::Float32

	OrthoCamera(camToWorld::Transformation,worldToCam::Transformation) = new(camToWorld,worldToCam,256,256,2.0f0,2.0f0)
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

type PinholeCamera <: Camera
	camToWorld::Transformation
	worldToCam::Transformation
	# screen resolution in x direction
	nx::Int
	# screen resulution in y direction
	ny::Int
	# screen width
	w::Float32
	# screen height
	h::Float32
	# distance eye screen
	d::Float32

	PinholeCamera(camToWorld::Transformation,worldToCam::Transformation) = new(camToWorld,worldToCam,256,256,2.0f0,2.0f0,2.0f0)
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


# task 2
type Ray
	origin::Vec4f
	direction::Vec4f
end

function generateRay(camera::OrthoCamera, i::Int, j::Int)
	u = -camera.w/2 + camera.w*(i-0.5)/camera.nx
	v = +camera.h/2 - camera.h*(j-0.5)/camera.ny

	# origin in world coordinates
	origin = camera.camToWorld*Vec4f(u,v,0,1)
	# unit vector for ray direction
	direction = camera.camToWorld*Vec4f(0,0,-1,0)
	return Ray(origin,direction)
end

function generateRay(camera::PinholeCamera, i::Int, j::Int)
	u = -camera.w/2 + camera.w*(i-0.5)/camera.nx
	v = +camera.h/2 - camera.h*(j-0.5)/camera.ny
	# pixel position
	p = Vec4f(u,v,0,1)
	# eye position
	o = Vec4f(0,0,camera.d,1)

	# origin in world coordinates
	origin = camera.camToWorld*p
	# unit vector for ray direction
	direction = camera.camToWorld*(unitize(p-o))
	return Ray(origin,direction)

end

# task 3
abstract SceneObject
# added another type to be able to differentiate basic objects
abstract BasicObject <: SceneObject

# sphere
type Sphere <: BasicObject
	center::Vec4f
	radius::Float32
end

Sphere(center::Vector{Float32},r::Float32) = Sphere(Vec4f(center[1],center[2],center[3],1),r)

function intersect(ray::Ray,sphere::Sphere)
	l = sphere.center-ray.origin
	l² = dot(l,l)
	s = dot(l,ray.direction)
	r² = sphere.radius^2
	if s<0 && l²>r²
		return false, 0.0f0
	end
	m² = l²-s^2
	if m² > r²
		return false, 0.0f0
	end
	q = sqrt(r²-m²)
	t = l²>r² ? s-q : s+q
	return true, t
end

# axis aligned bounding box
type AABB <: BasicObject
	center::Vec4f
	# positive half length from center to face of box
	hx::Float32
	hy::Float32
	hz::Float32
end

AABB(center::Vector{Float32},hx::Float32,hy::Float32,hz::Float32) = AABB(Vec4f(center[1],center[2],center[3],1),hx,hy,hz)

function intersect(ray::Ray, aabb::AABB)
	tmin::Float32 = -Inf32
	tmax::Float32 = Inf32
	p = aabb.center-ray.origin
	for (f,g,h) in [(p.e1,ray.direction.e1,aabb.hx),(p.e2,ray.direction.e2,aabb.hy),(p.e3,ray.direction.e3,aabb.hz)]
		t₁ = (f+h)/g
		t₂ = (f-h)/g
		if t₁ > t₂
			tmp = t₁
			t₁ = t₂
			t₂ = tmp
		end
		t₁ > tmin && (tmin=t₁)
		t₂ < tmax && (tmax=t₂)
		# if cube hit this wont hold true
		if tmin > tmax
			return false, 0.0f0
		# if tmax < 0 cube is behind camera
		elseif tmax < 0
			return false, 0.0f0
		end
	end
	# cube is in front of us
	if tmin > 0 
		return true, tmin
	# cam is inside the cube
	else
		return true, tmax
	end
end

# task 4
type Scene
	sceneObjects::Vector{SceneObject}
end

function intersect(ray::Ray,scene::Scene)
	hit = false
	tin = Inf32
	objhit = nothing
	for object in scene.sceneObjects
		hittmp, t = intersect(ray,object)
		hit = hittmp || hit
		if hittmp & (t < tin) 
			tin = t
			objhit = object
		end
	end
	return hit, tin, objhit
end

# very simple shader
function hitShader(ray::Ray,scene::Scene,args...)
	# check if object is hit and omit all other info
	hit,  = intersect(ray,scene)
	return hit ? 1.0f0 : 0.0f0
end

# task 5
function surfaceNormal(ray::Ray,t::Float32,sphere::Sphere)
	# center of sphere
	c = sphere.center
	# point ray hits on sphere
	h = ray.origin+t*ray.direction
	return unitize(h-c)
end

function surfaceNormal(ray::Ray,t::Float32,aabb::AABB)
	# center of cube
	c = aabb.center
	#point ray hits on aabb
	h = ray.origin+t*ray.direction
	ch = h-c
	x = abs(ch.e1/aabb.hx)
	y = abs(ch.e2/aabb.hy)
	z = abs(ch.e3/aabb.hz)
	if x > y
		if x > z
			return sign(ch.e1/aabb.hx)*Vec4f(1,0,0,0)
		else
			return sign(ch.e3/aabb.hz)*Vec4f(0,0,1,0)
		end
	else
		if y > z
			return sign(ch.e2/aabb.hy)*Vec4f(0,1,0,0)
		else
			return sign(ch.e3/aabb.hz)*Vec4f(0,0,1,0)
		end
	end
end

surfaceNormal(ray::Ray,t::Float32,void::Void) = Vec4f(0,0,0,0)

abstract Lights

type PointLight <:Lights
	position::Vec4f
end

intensity(pointLight::PointLight) = 1f0

type SceneLights
	lights::Vector{Lights}
end

positions(pointLight::PointLight) = Vec4f[pointLight.position]
function positions(sceneLights::SceneLights)
	out = Vec4f[]
	for light in sceneLights.lights
		append!(out,positions(light))
	end
	return out
end

function tracerays(scene::Scene,camera::Camera,lights::SceneLights,shader::Function)
	nx = camera.nx
	ny = camera.ny
	screen = Array(Float32,nx,ny)
	for i=1:nx
		for j=1:ny
			# generate ray for pixel i,j
			ray = generateRay(camera, i, j)
			# use shader function to calculate pixel value
			screen[i,j] = shader(ray, scene, lights)
		end
	end
	# final visualization of image
	figure()
	clf()
	gray()
	imshow(screen')
	colorbar()
end

# Lambertian shading
function lambertShader(ray::Ray,scene::Scene,lights::SceneLights)
	# intersect ray and scene
 	hit, t, object = intersect(ray::Ray,scene::Scene)
	if hit
		# compute surface normal
		normal = surfaceNormal(ray,t,object)
		# intersection point of camera ray
		p = ray.origin+t*ray.direction
		# initial shade of object 
		shade = 1.0f0
		for l in positions(lights)
			# direction intersection point to light source
			d = unitize(l-p)
			# dot product of normal vector and direction to light
			s = dot(normal,d)
			# add light if light is in front of surface
			shade += max(0.0f0,s)
		end
		return shade
	else
		return 0.0f0
	end
end
