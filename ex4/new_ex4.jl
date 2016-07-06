include("../ex3/new_ex3.jl")

type SceneLights
	lights::Vector{Lights}
end

function positions(pointLight::PointLights)
	out = Vec4f[]
	for position in pointLight.positions
    out = Vec4f[position; out]
	end
	return out
end

function positions(sceneLights::SceneLights)
	out = Vec4f[]
	for light in sceneLights.lights
		append!(out, positions(light))
	end
	return out
end

function lambertShader(ray::Ray, scene::Scene, lights::SceneLights)
  hit, distance, object = intersect(ray, scene)
  if (hit)
    surface_normal = surfaceNormal(ray, distance, object)
    sum = 1f0
    hit_point = ray.origin + distance * ray.direction
    counter = 0
    for light in positions(lights)
      lightToHit = unitize(light - hit_point)
      cosAngle = dot(lightToHit, surface_normal) / (euclideanNorm(lightToHit) * euclideanNorm(surface_normal))
      sum += max(0, cosAngle)
      counter = counter + 1
    end
    return 1.0f0 * sum #/ counter
  else
    return 0.0f0
  end
end

function tracerays(scene::Scene,camera::Camera, scenelights::SceneLights, shader::Function)
    nx = camera.nx
    ny = camera.ny
    screen = Array(Float32,nx,ny)
    for i=1:nx
        for j=1:ny
            # generate ray for pixel i,j
            ray = generateRay(camera, i, j)
            # use shader function to calculate pixel value
            screen[i,j] += shader(ray, scene, scenelights)
        end
    end
    # final visualization of image
    figure()
    gray()
    imshow(screen')
    colorbar()
		println("In new tracerays")
end

sphere1 = Sphere(Float32[-0.5,0.5,0],0.25f0)
sphere2 = Sphere(Float32[-0.5,-0.5,0],0.5f0)
aabb1 = AABB(Float32[0.5,-0.5,0],0.25f0,0.25f0,0.25f0)
aabb2 = AABB(Float32[0.5,0.5,0],0.5f0,0.5f0,0.5f0)
scene = Scene(SceneObject[sphere1,sphere2,aabb1,aabb2])
# set up camera
camera = PinholeCamera(Float32[0,0,1],Float32[0,0,-1],Float32[0,1,0])
# set up lights
pointLight1 = PointLights([Vec4f(0.5,-0.5,0.3,1)])
pointLight2 = PointLights([Vec4f(0,0,5,1)])
sceneLights1 = SceneLights(Lights[pointLight1,pointLight2])
# trace rays using two hit and Lambert shader
# tracerays(scene, camera, sceneLights1, hitShader)
tracerays(scene, camera, sceneLights1, lambertShader)
