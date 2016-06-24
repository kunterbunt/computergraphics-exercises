include("../ex2/new_ex2.jl")

abstract Camera
type PinholeCamera <: Camera
  camToWorld::Transformation
  worldToCam::Transformation

  # screen resolution in x direction
  nx::Int

  # screen resulution in y direction
  ny::Int

  # screen width
  w::Float32

  # screen height
  h::Float32

  # distance eye screen
  d::Float32
  PinholeCamera(camToWorld::Transformation,worldToCam::Transformation) = new(camToWorld,worldToCam,800,800,2.0f0,2.0f0,2.0f0)
end

function PinholeCamera(rc::Vector{Float32},rv::Vector{Float32},ru::Vector{Float32})
  # your code here
  return PinholeCamera(camToWorld,worldToCam)
end
