include("CG1+2+3.jl")

# task 1
# latest renderings as reference
# set up scene
sphere1 = Sphere(Float32[-0.5,0.5,0],0.25f0)
sphere2 = Sphere(Float32[-0.5,-0.5,0],0.5f0)
aabb1 = AABB(Float32[0.5,-0.5,0],0.25f0,0.25f0,0.25f0)
aabb2 = AABB(Float32[0.5,0.5,0],0.5f0,0.5f0,0.5f0)
scene = Scene(SceneObject[sphere1,sphere2,aabb1,aabb2])
# set up camera
camera = PinholeCamera(Float32[0,0,1],Float32[0,0,-1],Float32[0,1,0])
# set up lights
pointLight1 = PointLight(Vec4f(0.5,-0.5,0.3,1))
pointLight2 = PointLight(Vec4f(0,0,5,1))
sceneLights1 = SceneLights(Lights[pointLight1,pointLight2])

# trace rays using two hit and Lambert shader
tracerays(scene, camera, sceneLights1, hitShader)
savefig("sceneLights1hitShader.png")
tracerays(scene, camera, sceneLights1, lambertShader)
savefig("sceneLights1lambertShader.png")

# task 2
# shade wrt to the number of light sources
function lightShader(ray::Ray,scene::Scene,sceneLights::SceneLights)
	# intersect ray and scene
 	hit, t, object = intersect(ray::Ray,scene::Scene)
	if hit
		# initialize shade
		shade = 1.0f0
		# compute surface normal
		normal = surfaceNormal(ray,t,object)
		# intersection point of camera ray
		p = ray.origin+t*ray.direction
		for light in sceneLights.lights
			for l in positions(light)
				# direction intersection point to light source
				d = l-p
				# dot product of normal vector and direction to light
				s = dot(normal,d)
				# add light if light is in front of surface
				if s>0
					shade += 1.0f0
				end
			end
		end
		return shade
	else
		return 0.0f0
	end
end

tracerays(scene, camera, sceneLights1, lightShader)
savefig("sceneLights1lightShader.png")

function shadowShader(ray::Ray,scene::Scene,sceneLights::SceneLights)
	# intersect ray and scene
 	hit, t, object = intersect(ray::Ray,scene::Scene)
	if hit
		# initialize shade
		shade = 1.0f0
		# compute surface normal
		normal = surfaceNormal(ray,t,object)
		# intersection point of camera ray
		p = ray.origin+t*ray.direction
		for light in sceneLights.lights
			for l in positions(light)
				# direction intersection point to light source
				lp = l-p
				# unit vector
				l = unitize(lp)
				# dot product of normal vector and direction to light
				s = dot(normal,l)
				# add light if light is in front of surface
				if s>0
					# ray from surface to light source
					backwardsLightRay = Ray(p+1.0f-5*l,l)
					# test if point is in shadow
					hit, t, = intersect(backwardsLightRay,scene)
					# increase shade if light source is visible
					# no object hit or hitpoint behind light source
					if !hit || t*t > dot(lp,lp)
						shade += 1f0
					end
				end
			end
		end
		return shade
	else
		return 0.0f0
	end
end

tracerays(scene, camera, sceneLights1, shadowShader)
savefig("sceneLights1shadowShader.png")


# task 3
# create soft shadows by using extended light sources

# flat paralleogram like light source
import Base:cross, norm
cross(v::Vec4f,w::Vec4f) = Vec4f(v.e2*w.e3-v.e3*w.e2,v.e3*w.e1-v.e1*w.e3,v.e1*w.e2-v.e2*w.e1,0f0)
norm(v::Vec4f) = sqrt(dot(v,v))

type FlatLight <: Lights
	center::Vec4f
	height::Vec4f
	width::Vec4f
	samplepoints::Int
	intensity::Float32

	FlatLight(center::Vec4f,height::Vec4f,width::Vec4f,samplepoints::Int) = new(center,height,width,samplepoints,Float32(norm(cross(height,width))/samplepoints))
end

function positions(flatLight::FlatLight)
	out = Array(Vec4f,flatLight.samplepoints)
	for i=1:flatLight.samplepoints
		a = 0.5f0 - rand(Float32)
		b = 0.5f0 - rand(Float32)
		out[i] = flatLight.center + a*flatLight.height + b*flatLight.width
	end
	return out
end

intensity(flatLight::FlatLight) = flatLight.intensity

flatLight1 = FlatLight(Vec4f(0,0,1,1),Vec4f(1,0,0,0),Vec4f(0,1,0,0),25)
flatLight2 = FlatLight(Vec4f(0,0,1,1),Vec4f(1,0,0,0),Vec4f(0,1,0,0),250)
sceneLights2 = SceneLights(Lights[flatLight1])
sceneLights3 = SceneLights(Lights[flatLight2])
tracerays(scene, camera, sceneLights2, shadowShader)
savefig("flatLightshadowShader25.png")
tracerays(scene, camera, sceneLights3, shadowShader)
savefig("flatLightshadowShader500.png")


# taks 4
# combine shadow casting with Pong light model
function shadowBlinnPhongShader(ray::Ray,scene::Scene,sceneLights::SceneLights;phongExponent=64)
	# intersect ray and scene
 	hit, t, object = intersect(ray::Ray,scene::Scene)
	if hit
		# initialize shade (ambient light)
		shade = 0.25f0
		# compute surface normal
		normal = surfaceNormal(ray,t,object)
		# intersection point of camera ray
		p = ray.origin+t*ray.direction
		for light in sceneLights.lights
			for lightpos in positions(light)
				# direction intersection point to light source
				lp = lightpos-p
				# unit vector
				l = unitize(lp)
				# dot product of normal vector and direction to light
				s = dot(normal,l)
				# add light if light is in front of surface
				if s>0
					# ray from surface to light source
					backwardsLightRay = Ray(p+1.0f-5*l,l)
					# test if point is in shadow
					hit, t, = intersect(backwardsLightRay,scene)
					# increase shade if light source is visible
					# no object hit or hitpoint behind light source
					if !hit || t*t > dot(lp,lp)
						# calculate lambert shade
						lambert = intensity(light)*max(0.0f0,s)
						# calculate the unit vector half way between the direction to the light and the eye
						h = l-ray.direction
						h = unitize(h)
						phong = intensity(light)*dot(normal,h)^phongExponent
						shade += lambert+phong
					end
				end
			end
		end
		return shade
	else
		return 0.0f0
	end
end

tracerays(scene, camera, sceneLights1, shadowBlinnPhongShader)
savefig("sceneLights1shadowBlinnPhongShader.png")
tracerays(scene, camera, sceneLights3, shadowBlinnPhongShader)
savefig("sceneLights3shadowBlinnPhongShader.png")


# task 5
function shadowReflectionBlinnPhongShader(ray::Ray,scene::Scene,sceneLights::SceneLights;phongExponent=256,recursionDepth=1)
	# intersect ray and scene
 	hit, t, object = intersect(ray::Ray,scene::Scene)
	if hit
		# initialize shade (ambient light)
		shade = 0.25f0
		# compute surface normal
		normal = surfaceNormal(ray,t,object)
		# intersection point of camera ray
		p = ray.origin+t*ray.direction
		for light in sceneLights.lights
			for lightpos in positions(light)
				# direction intersection point to light source
				lp = lightpos-p
				# unit vector
				l = unitize(lp)
				# dot product of normal vector and direction to light
				s = dot(normal,l)
				# add light if light is in front of surface
				if s>0
					# ray from surface to light source
					backwardsLightRay = Ray(p+1.0f-5*l,l)
					# test if point is in shadow
					hit, t, = intersect(backwardsLightRay,scene)
					# increase shade if light source is visible
					# no object hit or hitpoint behind light source
					if !hit || t*t > dot(lp,lp)
						# calculate lambert shade
						lambert = intensity(light)*max(0.0f0,s)
						# calculate the unit vector half way between the direction to the light and the eye
						h = l-ray.direction
						h = unitize(h)
						phong = intensity(light)*dot(normal,h)^phongExponent
						shade += lambert + phong
					end
				end
			end
		end
		
		if recursionDepth<4
			reflectionDirection = unitize(ray.direction - 2*dot(ray.direction,normal)*normal)
			reflectionRay = Ray(p+1f-5*reflectionDirection,reflectionDirection)
			shade += 0.5f0*shadowReflectionBlinnPhongShader(reflectionRay,scene,sceneLights;recursionDepth=recursionDepth+1)
		end

		return shade
	else
		return 0.0f0
	end
end

tracerays(scene, camera, sceneLights1, shadowReflectionBlinnPhongShader)
savefig("sceneLights1shadowReflectionBlinnPhongShader.png")


# task 6
# transformed object
type TO <: SceneObject
	baseObject::BasicObject
	# transformation from the aabb ccordinate system to world coordinates
	localToWorld::Transformation
	worldToLocal::Transformation

	TO(baseObject::AABB,localToWorld::Transformation) = new(baseObject,localToWorld,inv(localToWorld))
end

import Base: inv
*(T::Transformation,ray::Ray) = Ray(T*ray.origin,T*ray.direction)

function intersect(ray::Ray, to::TO)
	localray = to.worldToLocal*ray
	return intersect(localray,to.baseObject)
end

aabb3 = AABB(Float32[0.0,0.0,0],0.25f0,0.25f0,0.25f0)
localToWorld3 = eulermatrix(-π/4,-π/4,-π/4)*scaling(1,2,3)
obb3 = TO(aabb3,localToWorld3)
scene3 = Scene(SceneObject[obb3])

function surfaceNormal(ray::Ray,t::Float32,to::TO)
	localray = to.worldToLocal*ray
	return unitize(to.localToWorld*surfaceNormal(localray,t,to.baseObject))
end

tracerays(scene3, camera, sceneLights3, hitShader)
tracerays(scene3, camera, sceneLights3, shadowBlinnPhongShader)

