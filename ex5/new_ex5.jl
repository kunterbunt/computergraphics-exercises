include("../ex4/new_ex4.jl")

type FrameBuffer
  nx::UInt8
  ny::UInt8
  pixels::Array

  FrameBuffer(x::Int, y::Int) = new(x, y, zeros(UInt8, x, y))#; clear!(pixels)
end

function clear!(fB::FrameBuffer)
  fB.pixels = zeros(UInt8, fB.nx, fB.ny)
end

function colorPixel!(fB::FrameBuffer, x::Int, y::Int, color::UInt8)
  fB.pixels[x,y] = color
end

function plot(fB::FrameBuffer)
  im = imshow(fB.pixels, interpolation="none")
end

function drawSimpleLine(fB::FrameBuffer, from_x::Int, from_y::Int, to_x::Int, to_y::Int)
  if from_x > to_x
    to_x, from_x = from_x, to_x
    to_y, from_y = from_y, to_y
  end
  m::Float32 = 0.0
  m = (to_y - from_y) / (to_x - from_x)
  if m == NaN
    return
  end

  for x in from_x:to_x
    # println(m*(x-from_x) + from_y)
    # println(x)
    y_f = m*(x-from_x) + from_y
    y = Int(round(y_f))

    if y < fB.ny
      colorPixel!(fB, x, y, 0xff)
    end
  end
end

function drawBetterLine(fB::FrameBuffer, from_x::Int, from_y::Int, to_x::Int, to_y::Int)
  if from_x > to_x
    to_x, from_x = from_x, to_x
    to_y, from_y = from_y, to_y
  end
  m::Float32 = 0.0
  m = (to_y - from_y) / (to_x - from_x)
  println(m)
  if m == NaN
    return
  end

  m = 1/m
  println(m)

  for y in from_y:to_y
    # println(m*(y-from_y) + from_x)
    # println(x)
    x_f = m*(y-from_y) + from_x
    x = round(Int, x_f)

    if x < fB.nx
      colorPixel!(fB, x, y, 0xff)
    end
  end
end

f = FrameBuffer(51,51)
drawBetterLine(f, 47, 26, 5, 26)
drawBetterLine(f, 5, 5, 47, 47)
drawBetterLine(f, 5, 10, 47, 42)
drawBetterLine(f, 5, 47, 47, 5)
drawBetterLine(f, 24, 5, 28, 47)
drawBetterLine(f, 26, 5, 28, 47)
plot(f)
