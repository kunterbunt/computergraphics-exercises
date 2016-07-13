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

function drawMidpointLine(fB::FrameBuffer, from_x::Int, from_y::Int, to_x::Int, to_y::Int)
  delta_y = to_y - from_y
  delta_x = to_x - from_x

  if delta_y > delta_x
    from_x, from_y = from_y, from_x
    to_x, to_y = to_y, to_x
    switched = true
  else
    switched = false
  end

  if from_x > to_x
    to_x, from_x = from_x, to_x
    to_y, from_y = from_y, to_y
  end

  # d = f(from_x+0.5, from_y+0.5)
  delta_y = to_y - from_y
  delta_x = to_x - from_x

  if delta_x == 0
    println("delta_x is 0")
    return
  end

  f = (x, y) -> (from_y-to_y)*x + (delta_x)*y + to_y*from_x - from_y*to_x

  if delta_y/delta_x > 1
    println("case of m>1 not covered")
    return
  end

  d = f(from_x+1, from_y+0.5)

  delta_o = from_y - to_y
  delta_no = delta_x + (from_y - to_y)
  println("from: ", from_x, " ", from_y)
  println("to: ", to_x, " ", to_y)
  println(d)
  println(delta_o)
  println(delta_no)
  y = from_y

  fB.pixels[from_x, y] = 1

  println("in midpoint function")
  for x in from_x+1:to_x
    #println(x, y)

    if d >= 0
      # y = y+1
      d = d + delta_o
    else
      d = d + delta_no
      y = y + 1
    end

    if x <= fB.nx && y <= fB.ny
      #println("printing ", x, " ", y)
      # if switched
      #   fB.pixels[y, x] = 1
      # else
        fB.pixels[x, y] = 1
      # end
    else
      println("Out of Bounds ", x, " ", y)
    end
  end
end


function lineDrawing(drawing::Function)
  f = FrameBuffer(51,51)
  drawing(f, 47, 26, 5, 26)
  drawing(f, 5, 5, 47, 47)
  drawing(f, 5, 10, 47, 42)
  drawing(f, 5, 47, 47, 5) # WROMG
  drawing(f, 24, 5, 28, 47) # WRONG
  drawing(f, 26, 5, 28, 47) # WRONG
  plot(f)
end

lineDrawing(drawMidpointLine)

function drawTriangle(fB::FrameBuffer, ax::Int, ay::Int, bx::Int, by::Int, cx::Int, cy::Int, c0::UInt8, c1::UInt8, c2::UInt8)
  gamma = (x, y) -> ((ay-by)*x + (bx-ax)*y + ax*by - bx*ay) / ((ay-by)*cx+ (bx-ax)*cy + ax*by - bx*ay)
  beta = (x, y) -> ((ay-cy)*x + (cx-ax)*y + ax*cy - cx*ay) / ((ay-cy)*bx+ (cx-ax)*by + ax*cy - cx*ay)

  x_min = min(ax, bx, cx)
  x_max = max(ax, bx, cx)
  y_min = min(ay, by, cy)
  y_max = max(ay, by, cy)

  for x = x_min:x_max
    for y = y_min:y_max
      g = gamma(x, y)
      b = beta(x, y)
      if g < 1 && g > 0
        if b < 1 && b > 0
          a = 1 - b - g
          if a < 1 && a > 0
            color = a*c0 + b*c1 + g*c2
            #println(color)
            fB.pixels[x, y] = round(UInt8, color)
          end
        end
      end
    end
  end
end

# f = FrameBuffer(51,51)
# drawTriangle(f, 10, 10, 10, 42, 42, 42, 0x40, 0x80, 0xf0)
# plot(f)
