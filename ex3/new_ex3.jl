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
  # xPixelWidth = camera.w / camera.nx
  # yPixelWidth = camera.h / camera.ny
  # origin = Vec4f(xPixelWidth * i, yPixelWidth * j, 0, 1)
  # direction = Vec4f(0, camera.h, camera.d, 0)
  # return Ray(camera.camToWorld * origin, camera.camToWorld * direction)
  u = -camera.w/2 + camera.w*(i-0.5)/camera.nx
	v = +camera.h/2 - camera.h*(j-0.5)/camera.ny
	# pixel position
	p = Vec4f(u,v,0,1)
	# eye position
	o = Vec4f(0,0,camera.d,1)
  #println(unitize(p-o))
	# origin in world coordinates
	origin = camera.camToWorld*p
	# unit vector for ray direction
  j = p-o
	direction = camera.camToWorld*(unitize(j))
	# println(direction);
	return Ray(origin,direction)
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
-(vec1::Vec4f, vec2::Vec4f) = Vec4f(vec1.x - vec2.x, vec1.y - vec2.y, vec1.z - vec2.z, vec1.v-vec2.v)

*(a::Int64, v::Vec4f) = Vec4f(a*v.x, a*v.y, a*v.z, a*v.v)

import Base: dot
dot(v::Vec4f,w::Vec4f) = dothelper(v, w)
function dothelper(v::Vec4f,w::Vec4f)
  r = v.x*w.x+v.y*w.y+v.z*w.z+v.v*w.v
  #println(v, w)
  return r
end

unitize(v::Vec4f) = (1.0f0 / sqrt(dot(v, v)) * v)

function intersect(ray::Ray, sphere::Sphere)
  # A = ray.direction * ray.direction
  # B = 2 * ray.direction * (ray.origin - sphere.center)
  # C = (ray.origin - sphere.center) * (ray.origin - sphere.center)
  # discriminant = B * B - 4 * A * C
  # if discriminant == 0
  #   t = (-B + sqrt(B*B-4*A*C))/2*A
  #   return true, t, t
  # elseif discriminant > 0
  #   t_min = (-B + sqrt(B*B-4*A*C))/2*A
  #   t_max = (-B - sqrt(B*B-4*A*C))/2*A
  #   if t_min > t_max
  #     t_min, t_max = t_max,  t_min
  #   end
  #   return true, t_min, t_max
  # else
  #   return false, Inf32, Inf32
  # end
  l = sphere.center-ray.origin
  l² = dot(l,l)
  s = dot(l,ray.direction)
  r² = sphere.radius^2
  # sphere at backside of camera
  if s<0 && l²>r²
    return false, 0.0f0, 0.0f0
  end
  m² = l²-s^2
  # ray passes sphere
  if m² > r²
    return false, 0.0f0, 0.0f0
  end
  q = sqrt(r²-m²)
  # hit point depends on camera position (inside or outside the sphere)
  t = l²>r² ? s-q : s+q
  # println("Hit!")
  return true, t, 0.0f0
end

function intersect(ray::Ray, aabb::AABB)
    aabb_x_min = aabb.center.x - aabb.hx
    aabb_x_max = aabb.center.x + aabb.hx
    aabb_y_min = aabb.center.y - aabb.hy
    aabb_y_max = aabb.center.y + aabb.hy
    aabb_z_min = aabb.center.z - aabb.hz
    aabb_z_max = aabb.center.z + aabb.hz

    t_x_min = -Inf32
    t_x_max = Inf32
    t_y_min = -Inf32
    t_y_max = Inf32
    t_z_min = -Inf32
    t_z_max = Inf32

    if (ray.direction.x == 0) && (ray.origin.x <= aabb_x_max) && (ray.origin.x >= aabb_x_min)
      #c_x = true
    elseif (ray.direction.x > 0) || (ray.direction.x < 0)
      # Interval of available t's for x direction
      t_x_min = (aabb_x_min - ray.origin.x) / ray.direction.x
      t_x_max = (aabb_x_max - ray.origin.x) / ray.direction.x
      if t_x_min > t_x_max
          t_x_min, t_x_max = t_x_max, t_x_min
      end
    else
      return false, Inf32, Inf32
    end

    if (ray.direction.y == 0) && (ray.origin.y <= aabb_y_max) && (ray.origin.y >= aabb_y_min)
      #c_x = true
    elseif (ray.direction.y > 0) || (ray.direction.y < 0)
      t_y_min = (aabb_y_min - ray.origin.y) / ray.direction.y
      t_y_max = (aabb_y_max - ray.origin.y) / ray.direction.y
      if t_y_min > t_y_max
          t_y_min, t_y_max = t_y_max, t_y_min
      end
    else
      return false, Inf32, Inf32
    end

    #No overlapp between both intervalls
    if (t_x_min > t_y_max || t_y_min > t_x_max)
        return false, Inf32, Inf32
    end

    #intersection of both intervalls
    if t_y_min > t_x_min
        t_x_min = t_y_min
    end
    if t_y_max < t_x_max
        t_x_max = t_y_max
    end

    if (ray.direction.z == 0) && (ray.origin.z <= aabb_z_max) && (ray.origin.z >= aabb_z_min)
      #c_x = true
    elseif (ray.direction.z > 0) || (ray.direction.z < 0)
      t_z_min = (aabb_z_min - ray.origin.z) / ray.direction.z
      t_z_max = (aabb_z_max - ray.origin.z) / ray.direction.z
      if t_z_min > t_z_max
          t_z_min, t_z_max = t_z_max, t_z_min
      end
    else
      return false, Inf32, Inf32
    end

    if (t_x_min > t_z_max || t_z_min > t_x_max)
        return false, Inf32, Inf32
    end

    if t_z_min > t_x_min
        t_x_min = t_z_min
    end
    if t_z_max < t_x_max
        t_x_max = t_z_max
    end

    return true, t_x_min, t_x_max
end


type Scene
    sceneObjects::Vector{SceneObject}
end

function intersect(ray::Ray, scene::Scene)
    object_hit = nothing
    nearest_dist = Inf32
    b = false
    t_0 = Inf32
    t_1 = Inf32
    obj_hit = false

    for o in scene.sceneObjects
        b, t_0, t_1 = intersect(ray, o)
        if b
            if t_0 < nearest_dist
                nearest_dist = t_0;
                object_hit = o
            end;

            if t_1 < nearest_dist
                nearest_dist = t_0;
                object_hit = o
            end;
            obj_hit = true
        end
    end
    return obj_hit, nearest_dist, object_hit
end

function hitShader(ray::Ray, scene::Scene)
    b, d, t = intersect(ray, scene)
    if b
        return 1.0f0
    else
        return 0.0f0
    end
end


function tracerays(scene::Scene,camera::Camera,shader::Function)
    nx = camera.nx
    ny = camera.ny
    screen = Array(Float32,nx,ny)
    for i=1:nx
        for j=1:ny
            # generate ray for pixel i,j
            ray = generateRay(camera, i, j)
            if i < 10 && j < 10
      				#println(i, j, ray)
      		end
            # use shader function to calculate pixel value
            screen[i,j] = shader(ray, scene)
        end
    end
    # final visualization of image
    figure("new_ex3")
    gray()
    imshow(screen')
    colorbar()
end

# set up individual objects
sphere1 = Sphere(Float32[-0.5,0.5,0],0.25f0)
sphere2 = Sphere(Float32[-0.5,-0.5,0],0.5f0)
aabb1 = AABB(Float32[0.5,-0.5,0],0.25f0,0.25f0,0.25f0)
aabb2 = AABB(Float32[0.5,0.5,0],0.5f0,0.5f0,0.5f0)
# set up scene
scene = Scene(SceneObject[sphere1,sphere2,aabb1,aabb2])

# set up camera
camera = PinholeCamera(Float32[0,0,1],Float32[0,0,-1],Float32[0,1,0])

# render scene
#tracerays(scene, camera, hitShader)


function surfaceNormal(ray::Ray,t::Float32,sphere::Sphere)
  return (ray.origin + t*ray.direction) - sphere.center
end

function surfaceNormal(ray::Ray,t::Float32,aabb::AABB)
  hit = (ray.origin + t*ray.direction)
  aabb_cTohit = hit - aabb.center

  if hit.x == aabb.center.x + aabb.hx
    return Vec4f(1, 0, 0, 0)
  elseif hit.x == aabb.center.x - aabb.hx
    return Vec4f(-1, 0, 0, 0)
  elseif hit.y == aabb.center.y + aabb.hy
    return Vec4f(0, 1, 0, 0)
  elseif hit.y == aabb.center.y - aabb.hy
    return Vec4f(0, -1, 0, 0)
  elseif hit.z == aabb.center.z + aabb.hz
    return Vec4f(0, 0, 1, 0)
  elseif hit.z == aabb.center.z - aabb.hz
    return Vec4f(0, 0, -1, 0)
  else
    println("Error: no case")
    return Vec4f(0,0,0,0)
  end
end

function surfaceNormal(ray::Ray,t::Float32,void::Void)
  return Vec4f(0,0,0,0)
end

abstract Lights
type PointLights <: Lights
  positions::Vector{Vec4f}
end


function tracerays(scene::Scene,camera::Camera, lights::Lights, shader::Function)
    nx = camera.nx
    ny = camera.ny
    screen = Array(Float32,nx,ny)
    for i=1:nx
        for j=1:ny
            # generate ray for pixel i,j
            ray = generateRay(camera, i, j)
            if i < 10 && j < 10
      				#println(i, j, ray)
      		  end
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

function lambertShader(ray::Ray, scene::Scene, lights::Lights)
  hit, distance, object = intersect(ray, scene)
  if (hit)
    surface_normal = surfaceNormal(ray, distance, object)
    sum = 0
    hit_point = ray.origin + distance * ray.direction
    for light in lights.positions
      lightToHit = unitize(light - hit_point)
      angle = dot(lightToHit, surface_normal) / (euclideanNorm(lightToHit) * euclideanNorm(surface_normal))
      sum += abs(angle)
    end
    return 1.0f0 * sum/length(lights.positions)
  else
    return 0.0f0
  end
end

# set up lights
lights = PointLights(Vec4f[Vec4f(0.5,-0.5,0.3,1),Vec4f(0,0,5,1)])

tracerays(scene, camera, lights, lambertShader)
