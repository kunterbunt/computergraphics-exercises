using PyPlot

include("CG1+2.jl")

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

	OrthoCamera(camToWorld::Transformation,worldToCam::Transformation) = new(camToWorld,worldToCam,800,800,2.0f0,2.0f0)
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

	PinholeCamera(camToWorld::Transformation,worldToCam::Transformation) = new(camToWorld,worldToCam,800,800,2.0f0,2.0f0,2.0f0)
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

# sphere
type Sphere <: SceneObject
	center::Vec4f
	radius::Float32
end

Sphere(center::Vector{Float32},r::Float32) = Sphere(Vec4f(center[1],center[2],center[3],1),r)

function intersect(ray::Ray,sphere::Sphere)
	l = sphere.center-ray.origin
	l² = dot(l,l)
	s = dot(l,ray.direction)
	r² = sphere.radius^2
	# sphere at backside of camera
	if s<0 && l²>r²
		return false, 0.0f0
	end
	m² = l²-s^2
	# ray passes sphere
	if m² > r²
		return false, 0.0f0
	end
	q = sqrt(r²-m²)
	# hit point depends on camera position (inside or outside the sphere)
	t = l²>r² ? s-q : s+q
	return true, t
end

# axis aligned bounding box
type AABB <: SceneObject
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
	# reduce hiting problem to 1D
	# for each axis aligned band calculate the intersection points
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
	# return if hit, hit point and object hit
	return hit, tin, objhit
end

# very simple shader
function hitShader(ray::Ray,scene::Scene,args...)
	# check if object is hit and omit all other info
	hit,  = intersect(ray,scene)
	return hit ? 1.0f0 : 0.0f0
end

function tracerays(scene::Scene,camera::Camera,shader::Function)
	nx = camera.nx
	ny = camera.ny
	screen = Array(Float32,nx,ny)
	for i=1:nx
		for j=1:ny
			# generate ray for pixel i,j
			ray = generateRay(camera, i, j)
			# use shader function to calculate pixel value
			screen[i,j] = shader(ray, scene)
		end
	end
	# final visualization of image
	figure()
	gray()
	imshow(screen')
	colorbar()
end

# set up scene
sphere1 = Sphere(Float32[-0.5,0.5,0],0.25f0)
sphere2 = Sphere(Float32[-0.5,-0.5,0],0.5f0)
aabb1 = AABB(Float32[0.5,-0.5,0],0.25f0,0.25f0,0.25f0)
aabb2 = AABB(Float32[0.5,0.5,0],0.5f0,0.5f0,0.5f0)

scene = Scene(SceneObject[sphere1,sphere2,aabb1,aabb2])
camera1 = PinholeCamera(Float32[0,0,1],Float32[0,0,-1],Float32[0,1,0])

tracerays(scene, camera1, hitShader)


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

type PointLights <: Lights
	positions::Vector{Vec4f}
end

function tracerays(scene::Scene,camera::Camera,lights::Lights,shader::Function)
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
	gray()
	imshow(screen')
	colorbar()
end


# Lambertian shading
function lambertShader(ray::Ray,scene::Scene,lights::Lights)
	# intersect ray and scene
 	hit, t, object = intersect(ray::Ray,scene::Scene)
	if hit
		# compute surface normal
		normal = surfaceNormal(ray,t,object)
		# intersection point of camera ray
		p = ray.origin+t*ray.direction
		# initial shade of object 
		shade = 1.0f0
		for l in lights.positions
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

# set up lights
lights = PointLights(Vec4f[Vec4f(0.5,-0.5,0.3,1),Vec4f(0,0,5,1)])

tracerays(scene, camera1, lights, lambertShader)
