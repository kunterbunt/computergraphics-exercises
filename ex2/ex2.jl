using PyPlot

include("Vec4f.jl")
include("Mat4f.jl")
include("Object.jl")
include("Transformation.jl")

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

render(houseOfSantaClaus)

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

GenExampleMat() * inv(GenExampleMat())

