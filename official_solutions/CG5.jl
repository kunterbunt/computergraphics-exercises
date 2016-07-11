using PyPlot

# task 1
# FrameBuffer type
type FrameBuffer
	nx::Int
	ny::Int
	data::Array{UInt8,2}

	FrameBuffer(nx::Int,ny::Int) = new(nx,ny,zeros(UInt8,nx,ny))
end

# function for clearing buffer
function clear!(buffer::FrameBuffer)
	buffer.data = zeros(UInt8,buffer.nx,buffer.ny)
	return nothing
end

# function for coloring a single pixel
function colorPixel!(buffer::FrameBuffer,x::Int,y::Int,color::UInt8)
	@inbounds buffer.data[x,y] = color
end

# function for plotting
function plot(buffer::FrameBuffer;figNum=1)
	T = eltype(buffer.data)
	figure(figNum)
	clf()
	gray()
	imshow(buffer.data',vmin=typemin(T),vmax=typemax(T),interpolation="none")
	return nothing
end

s = FrameBuffer(51,51)
colorPixel!(s,25,25,0xff)
plot(s)

# task 2
#simplest approach works for slopes -1 <= m <= 1
function drawSimpleLine!(buffer::FrameBuffer,x0::Int,y0::Int,x1::Int,y1::Int)
	#calulate slope of line segment
	m = (y1-y0)/(x1-x0)
	if abs(m)>1
		warn("This case is not covered")
		return nothing
	end

	#prepare looping boundaries xmin and xmax
	#make sure loop stays within array boundaries of buffer.data
	xmin = max(min(x0,x1),1)
	xmax = min(max(x0,x1),buffer.nx)
	for x=xmin:xmax
		y = round(Int,m*(x-x0)+y0)
		0<y<buffer.ny && colorPixel!(buffer,x,y,0xff)
	end

	return nothing
end

s = FrameBuffer(51,51)
drawSimpleLine!(s,47,26,5,26)
drawSimpleLine!(s,5,5,47,47)
drawSimpleLine!(s,5,47,47,5)
drawSimpleLine!(s,24,5,28,47)
drawSimpleLine!(s,26,5,26,47)
plot(s)

#next appraoch works for all slopes
function drawLessSimpleLine!(buffer::FrameBuffer,x0::Int,y0::Int,x1::Int,y1::Int)
	if (abs(y1-y0)<=abs(x1-x0))
		#calulate slope of line segment
		m = (y1-y0)/(x1-x0)

		#prepare looping boundaries xmin and xmax
		#make sure loop stays within array boundaries of buffer.data
		xmin = max(min(x0,x1),1)
		xmax = min(max(x0,x1),buffer.nx)
		for x=xmin:xmax
			y = round(Int,m*(x-x0)+y0)
			0<y<buffer.ny && colorPixel!(buffer,x,y,0xff)
		end
	else
		#calulate slope of line segment
		m = (x1-x0)/(y1-y0)

		#prepare looping boundaries xmin and xmax
		#make sure loop stays within array boundaries of buffer.data
		ymin = max(min(y0,y1),1)
		ymax = min(max(y0,y1),buffer.ny)
		for y=ymin:ymax
			x = round(Int,m*(y-y0)+x0)
			0<x<buffer.nx && colorPixel!(buffer,x,y,0xff)
		end
	end
	return nothing
end

s = FrameBuffer(51,51)
drawLessSimpleLine!(s,47,26,5,26)
drawLessSimpleLine!(s,5,5,47,47)
drawLessSimpleLine!(s,5,47,47,5)
drawLessSimpleLine!(s,24,5,28,47)
drawLessSimpleLine!(s,26,5,26,47)
plot(s)

#optimized version
function drawFastSimpleLine!(buffer::FrameBuffer,x0::Int,y0::Int,x1::Int,y1::Int)
	if (abs(y1-y0)<=abs(x1-x0))
		m = (y1-y0)/(x1-x0)
		xmin = max(min(x0,x1),1)
		xmax = min(max(x0,x1),buffer.nx)

		y = m*(xmin-x0)+y0
		for xi=xmin:xmax
			yi = round(Int,y)
			0 < yi < buffer.ny && (buffer.data[xi,yi] = 0xff)
			y += m
		end
	else
		m = (x1-x0)/(y1-y0)
		ymin = max(min(y0,y1),1)
		ymax = min(max(y0,y1),buffer.ny)
		
		x = m*(ymin-y0)+x0
		for yi=ymin:ymax
			xi = round(Int,x)
			0 < xi < buffer.nx && (buffer.data[xi,yi] = 0xff)
			x += m
		end
	end
	return nothing
end

s = FrameBuffer(51,51)
drawFastSimpleLine!(s,47,26,5,26)
drawFastSimpleLine!(s,5,5,47,47)
drawFastSimpleLine!(s,5,10,47,42)
drawFastSimpleLine!(s,5,47,47,5)
drawFastSimpleLine!(s,24,5,28,47)
drawFastSimpleLine!(s,26,5,26,47)

# task 3
function drawBresenhamLine!(buffer::FrameBuffer,x0::Int,y0::Int,x1::Int,y1::Int)
	if x1<x0
		warn("This case is not covered")
		return nothing
	end

	#calulate slope of line segment
	m = (y1-y0)/(x1-x0)
	if !(1>=m>=0)
		warn("This case is not covered")
		return nothing
	end

	A2 = 2*(y1 - y0)
	B = -(x1 - x0)
	B2 = -2*(x1 - x0)
	C2 = 2*(x1-x0)*y0-2*(y1-y0)*x0
	buffer.data[x0,y0] = 0xff
	yi = y0

#This is the naive implementation which requires a lot of multiplications to be evauated
#=
	for xi=x0+1:x1
		#multiplication of Ax+By+C = 0 by 2 avoids non-integer arithmeticas
    		D = A2*xi+B2*yi+B+C2
		D>0 && (yi += 1)
		buffer.data[xi,yi] = 0xff
	end
=#

#Much smarter to only use additions
	D = A2*x0+B*(2*y0+1)+C2
	for xi=x0+1:x1
    		D += A2
		if D>0 
			yi += 1
			D += B2
		end
		buffer.data[xi,yi] = 0xff
	end
	return nothing
end

s = FrameBuffer(51,51)
drawBresenhamLine!(s,47,26,5,26)
drawBresenhamLine!(s,5,5,47,47)
drawBresenhamLine!(s,5,10,47,42)
drawBresenhamLine!(s,5,47,47,5)
drawBresenhamLine!(s,24,5,28,47)
drawBresenhamLine!(s,26,5,26,47)

#task 4
function whichOctant(x0,y0,x1,y1)
	Δx = x1-x0
	Δy = y1-y0
	if y0<=y1
		#Δy is non-negative
		if Δx>=0
			if Δx>Δy
				return 0
			else
				return 1
			end
		else
			if -Δx<Δy
				return 2
			else
				return 3
			end
		end
	else
		#Δy is negative
		if Δx<0
			if Δx<Δy
				return 4
			else
				return 5
			end
		else
			if Δx<-Δy
				return 6
			else
				return 7
			end
		end
	end
end

function switchToOctantZeroFrom(octant,x0,y0,x1,y1) 
	if octant == 0 
		return x0,y0,x1,y1
	elseif octant == 1
		return y0,x0,y1,x1
	elseif octant == 2
		return y0,-x0,y1,-x1
	elseif octant == 3
		return -x0,y0,-x1,y1
	elseif octant == 4
		return -x0,-y0,-x1,-y1
	elseif octant == 5
		return -y0,-x0,-y1,-x1
	elseif octant == 6
		return -y0,x0,-y1,x1
	elseif octant == 7
		return x0,-y0,x1,-y1
	else 
		error("octand=$octand is not in {0,1,...,7}")
	end
end
 
function switchFromOctantZeroTo(octant, xi, yi) 
	if octant == 0
		return xi, yi
	elseif octant == 1
		return yi, xi
	elseif octant == 2
		return -yi, xi
	elseif octant == 3
		return -xi, yi
	elseif octant == 4
		return -xi, -yi
	elseif octant == 5
		return -yi, -xi
	elseif octant == 6
		return yi, -xi
	elseif octant == 7
		return xi, -yi
	else 
		error("octand=$octand is not in {0,1,...,7}")
	end
end

function drawLine!(buffer::FrameBuffer,x0::Int,y0::Int,x1::Int,y1::Int,color::UInt8)
	octant = whichOctant(x0,y0,x1,y1)
	xa,ya,xe,ye = switchToOctantZeroFrom(octant,x0,y0,x1,y1)

	#calulate slope of line segment
	m = (ye-ya)/(xe-xa)
	if !(1>=m>=0)
		warn("This case is not covered")
		return nothing
	end

	A2 = 2*(ye - ya)
	B = -(xe - xa)
	B2 = -2*(xe - xa)
	C2 = 2*(xe-xa)*ya-2*(ye-ya)*xa
	buffer.data[switchFromOctantZeroTo(octant, xa, ya)...] = color
	yi = ya

	D = A2*xa+B*(2*ya+1)+C2
	for xi=xa+1:xe
    		D += A2
		if D>0 
			yi += 1
			D += B2
		end
		setindex!(buffer.data, color, switchFromOctantZeroTo(octant, xi, yi)...)
	end
	return nothing
end

drawLine!(buffer::FrameBuffer,x0::Int,y0::Int,x1::Int,y1::Int) = drawLine!(buffer,x0,y0,x1,y1,0xff)


s = FrameBuffer(51,51)
drawLine!(s,47,26,5,26)
drawLine!(s,5,5,47,47)
drawLine!(s,5,10,47,42)
drawLine!(s,5,47,47,5)
drawLine!(s,24,5,28,47)
drawLine!(s,26,5,26,47)
plot(s)

# task 5
function drawTriangle!(buffer::FrameBuffer,xa::Int,ya::Int,xb::Int,yb::Int,xc::Int,yc::Int,color::UInt8)
	# determine bounding box of triangle
	xmin = max(min(xa,xb,xc),1)
	xmax = min(max(xa,xb,xc),buffer.nx)
	ymin = max(min(ya,yb,yc),1)
	ymax = min(max(ya,yb,yc),buffer.ny)

	δdiv = 1.0/((ya-yb)*xc+(xb-xa)*yc+xa*yb-xb*ya)
	βdiv = 1.0/((ya-yc)*xb+(xc-xa)*yb+xa*yc-xc*ya)

	# loop through bounding box and colorize pixels inside the triangle
	for yi=ymin:ymax
		for xi=xmin:xmax
			δ = δdiv*((ya-yb)*xi+(xb-xa)*yi+xa*yb-xb*ya)
			β = βdiv*((ya-yc)*xi+(xc-xa)*yi+xa*yc-xc*ya)
			α = 1-β-δ
			if 0<α<1 && 0<β<1 && 0<δ<1
				buffer.data[xi,yi] = color
			end
		end
	end
	return nothing
end

s = FrameBuffer(51,51)
drawTriangle!(s,10,10,10,42,42,42,0xff)
plot(s)

# task 6
function drawTriangle!(buffer::FrameBuffer,xa::Int,ya::Int,xb::Int,yb::Int,xc::Int,yc::Int,ca::UInt8,cb::UInt8,cc::UInt8)
	# determine bounding box of triangle
	xmin = max(min(xa,xb,xc),1)
	xmax = min(max(xa,xb,xc),buffer.nx)
	ymin = max(min(ya,yb,yc),1)
	ymax = min(max(ya,yb,yc),buffer.ny)

	δdiv = 1.0/((ya-yb)*xc+(xb-xa)*yc+xa*yb-xb*ya)
	βdiv = 1.0/((ya-yc)*xb+(xc-xa)*yb+xa*yc-xc*ya)

	# loop through bounding box and colorize pixels inside the triangle
	for yi=ymin:ymax
		for xi=xmin:xmax
			δ = δdiv*((ya-yb)*xi+(xb-xa)*yi+xa*yb-xb*ya)
			β = βdiv*((ya-yc)*xi+(xc-xa)*yi+xa*yc-xc*ya)
			α = 1-β-δ
			if 0<α<1 && 0<β<1 && 0<δ<1
				color = round(UInt8, α*ca+β*cb+δ*cc)
				buffer.data[xi,yi] = color
			end
		end
	end
	return nothing
end

s = FrameBuffer(51,51)
drawTriangle!(s,10,10,10,42,42,42,0x40,0x80,0xf0)
plot(s)

