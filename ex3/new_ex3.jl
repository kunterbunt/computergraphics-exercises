include("../ex2/new_ex2.jl")

abstract Camera
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

type Ray
  origin::Vec4f
  direction::Vec4f
end

function generateRay(camera::PinholeCamera, i::Int, j::Int)
  xPixelWidth = camera.w / camera.nx
  yPixelWidth = camera.h / camera.ny
  origin = Vec4f(xPixelWidth * i, yPixelWidth * j, 0, 1)
  direction = Vec4f(0, camera.h, camera.d, 0)
  return Ray(camera.camToWorld * origin, camera.camToWorld * direction)
end

abstract SceneObject
type Sphere <: SceneObject
  center::Vec4f
  radius::Float32
end
Sphere(center::Vector{Float32},r::Float32) = Sphere(Vec4f(center[1],center[2],center[3],1),r)

type AABB <: SceneObject
  center::Vec4f
  # positive half length from center to face of box
  hx::Float32
  hy::Float32
  hz::Float32
end

AABB(center::Vector{Float32}, hx::Float32, hy::Float32, hz::Float32) = AABB(Vec4f(center[1], center[2], center[3], 1), hx, hy, hz)

*(vec1::Vec4f, vec2::Vec4f) = vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
-(vec1::Vec4f, vec2::Vec4f) = Vec4f(vec1.x - vec2.x, vec1.y - vec2.y, vec3.z - vec3.z, vec1.v)

function intersect(ray::Ray, sphere::Sphere)
  A = ray.direction * ray.direction
  B = 2 * ray.direction * (ray.origin - sphere.center)
  C = (ray.origin - sphere.center) * (ray.origin - sphere.center)
  discriminant = B * B - 4 * A * C
  if discriminant >= 0
    return true
  else
    return false
  end
end

function intersect(ray::Ray, aabb::AABB)

end
