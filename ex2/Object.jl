type Object
 vertices::Vector{Vec4f}
 # Type constructorwhich allows to use Object(vec1,vec2,...)
 Object(x::Vector{Vec4f}) = new(x)
 Object(x...) = new(collect(Vec4f,x))
end

function render(object; figAxis=[-1,1,-1,1])
	axis(figAxis)
	x = []
	y = []
	for i in 1:length(object.vertices)
		x = [x; object.vertices[i].e1]
		y = [y; object.vertices[i].e2]
	end
	x = [x; object.vertices[1].e1]
	y = [y; object.vertices[1].e2]
	plot(x, y, linestyle="-")
end

function rotateObject(O)
  for i = 1:60
		render(rotz((2*pi) + (2 * i * (pi / 60))) * houseOfSantaClaus, figAxis=[-2,2,-2,2])
    sleep(0.001)
    if i < 60
      clf()
    end
	end
end
