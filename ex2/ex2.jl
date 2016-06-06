using PyPlot

include("Vec4f.jl")
include("Mat4f.jl")
include("Object.jl")
include("Transformation.jl")
include("Camera.jl")

M1 = Mat4f(
	Vec4f(1, 2, 3, 4),
	Vec4f(5, 6, 7, 8),
	Vec4f(1, 2, 3, 4),
	Vec4f(5, 6, 7, 8)
)

M2 = Mat4f(
	Vec4f(1, 1, 1, 1),
	Vec4f(1, 1, 1, 1),
	Vec4f(1, 1, 1, 1),
	Vec4f(1, 1, 1, 1)
)

M1 * M2




houseOfSantaClaus = Object(
	Vec4f(-1,-1,0,1),
	Vec4f(1,-1,0,1),
	Vec4f(-1,1,0,1),
	Vec4f(0,2,0,1),
	Vec4f(1,1,0,1),
	Vec4f(-1,-1,0,1),
	Vec4f(-1,1,0,1),
	Vec4f(1,1,0,1),
	Vec4f(1,-1,0,1)
)

T = Transformation(
	Vec4f(2, 0, 0, 0),
	Vec4f(0, 2, 0, 0),
	Vec4f(0, 0, 2, 0),
	Vec4f(0, 0, 0, 2)
)

#render(houseOfSantaClaus)

# Rotate around origin.
#rotateObject(houseOfSantaClaus)
# Rotate around edge.
#rotateObject(houseOfSantaClaus; figNum=2, center=[1,1,0])

#Ex2.2 rotation
#render(euler(pi/4,pi/4,pi/4)*houseOfSantaClaus, figAxis=[-2,2,-2,2])

#render(euler(pi/4,0,0)*houseOfSantaClaus, figAxis=[-2,2,-2,2])
#render(euler(0,pi/4,0)*houseOfSantaClaus, figAxis=[-2,2,-2,2])
#render(euler(0,04,pi/4)*houseOfSantaClaus, figAxis=[-2,2,-2,2])

#Mat4fToArray(GenIdentityMat4f())
#inv(GenIdentityMat4f())

#GenExampleMat() * inv(GenExampleMat())
#GenIdentityMat4f() * GenIdentityMat4f()
#inv(euler(0,0,0))



scaledHouseOfSantaClaus = scaling(0.5,0.5,0.5)*houseOfSantaClaus

# canonical view direction
camera = OrthoCamera(Float32[0,0,1],Float32[0,0,-1],Float32[0,1,0])
render(scaledHouseOfSantaClaus,camera;figNum=4)

# screen moved backwards 9 unit length
camera = OrthoCamera(Float32[0,0,10],Float32[0,0,-1],Float32[0,1,0])
render(scaledHouseOfSantaClaus,camera;figNum=5)

# rotate screen clockwise
for t=0:60
    camera = OrthoCamera(Float32[0,0,1],Float32[0,0,-1],Float32[sin(2*pi*t
       /60),cos(2*pi*t/60),0])
    render(scaledHouseOfSantaClaus,camera;figNum=6)
    sleep(0.01)
end