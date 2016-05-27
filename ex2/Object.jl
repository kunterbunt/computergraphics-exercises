type Object
 vertices::Vector{Vec4f}
 # Type constructorwhich allows to use Object(vec1,vec2,...)
 Object(x::Vector{Vec4f}) = new(x)
 Object(x...) = new(collect(Vec4f,x))
end

function render(object; figNum=1, figTitle="Object", figAxis=[-1,1,-1,1])
	axis(figAxis)
  figure(figNum)
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

function rotateObject(O; figNum=1, center=[0,0,0])
  translateBefore = translation(center...)
  translateAfter = translation(-center...)
  for t = 1:60
		render(translateBefore * rotz(2 * pi * t / 60) * translateAfter * O; figNum=figNum, figAxis=[-2,2,-2,2])
    sleep(0.001)
    if t < 60
      clf() # Clear figure.
    end
  end
end
