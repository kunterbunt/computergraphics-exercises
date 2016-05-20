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


# function render(object;figAxis=[-1,1,-1,1])
# 	axis(figAxis)
# 	x = []
# 	y = []
# 	for i in 1:length(object.vertices)
# 		x = [x; object.vertices[i].e1]
# 		y = [y; object.vertices[i].e2]
# 	end
# 	x = [x; object.vertices[1].e1]
# 	y = [y; object.vertices[1].e2]
# 	plot(x, y, linestyle="-")
# end
#
# houseOfSantaClaus = Object(
# 	Vec4f(-1,-1,0,1),
# 	Vec4f(1,-1,0,1),
# 	Vec4f(-1,1,0,1),
# 	Vec4f(0,2,0,1),
# 	Vec4f(1,1,0,1),
# 	Vec4f(-1,-1,0,1),
# 	Vec4f(-1,1,0,1),
# 	Vec4f(1,1,0,1),
# 	Vec4f(1,-1,0,1)
# )
#
# T = Transformation(
# 	Vec4f(2, 0, 0, 0),
# 	Vec4f(0, 2, 0, 0),
# 	Vec4f(0, 0, 2, 0),
# 	Vec4f(0, 0, 0, 2)
# )
#
# render(translation(1, 0, 0) * houseOfSantaClaus, figAxis=[-2,2,-2,2])
# render(rotx(pi/4) * houseOfSantaClaus, figAxis=[-2,2,-2,2])
