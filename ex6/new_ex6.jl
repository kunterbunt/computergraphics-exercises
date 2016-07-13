include("CG.jl")


scaledHouse = scaling(0.5, 0.5, 0.5) * houseOfSantaClaus
# model transformation scales down the house
modelTransformation = scaling(0.45,0.45,0.45)
# canonical view direction
camera = OrthoCamera(Float32[0,0,1],Float32[0,0,-1],Float32[0,1,0])

houseInCamera = camera.worldToCam * scaledHouse
