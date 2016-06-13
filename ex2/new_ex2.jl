include("../ex1/new_ex1.jl")
# Task 1.
import Base: *
*(Mat1::Mat4f, Mat2::Mat4f) = Mat4f(
  Mat1 * Mat2.col1,
  Mat1 * Mat2.col2,
  Mat1 * Mat2.col3,
  Mat1 * Mat2.col4
)
# col1 = Vec4f(1,1,1,1);
# col2 = Vec4f(2,2,2,2);
# col3 = Vec4f(1,1,1,1);
# col4 = Vec4f(1,1,1,1);
# M = Mat4f(col1, col2, col3, col4)
# M * M

*(Transf1::Transformation, Transf2::Transformation) = Transformation(Transf1.Mat * Transf2.Mat)

function rotateObject(Object; figNum=1,center=[0,0,0])
  TranslateToCenter = translation(center...)
	TranslateBack = translation((-center)...)
	for t=0:60
		composedTransformation = TranslateToCenter * rotz(2*π*t/60) * TranslateBack
		TransformedObject = composedTransformation * Object
		render(TransformedObject; figNum=figNum,figAxis=[-2,2,-2,2])
		sleep(0.01)
	end
end

#rotateObject(houseOfSantaClaus, center=[1, 1, 1])

# Task 3.
function euler(alpha, beta, delta)
	return Transformation(rotz(delta) * rotx(beta) * roty(alpha))
end
#render(euler(π/4, π/4, π/4) * houseOfSantaClaus, figAxis=[-2, 2, -2, 3])

# Task 4.
import Base: inv
function inv(Mat::Mat4f)
	juliaMat = zeros(4,4)
  # Convert matrix to Julia-standard matrix.
	juliaMat[1,1] = Mat.col1.x; juliaMat[1,2] = Mat.col1.y; juliaMat[1,3] = Mat.col1.z; juliaMat[1,4] = Mat.col1.v;
	juliaMat[2,1] = Mat.col2.x; juliaMat[2,2] = Mat.col2.y; juliaMat[2,3] = Mat.col2.z; juliaMat[2,4] = Mat.col2.v;
	juliaMat[3,1] = Mat.col3.x; juliaMat[3,2] = Mat.col3.y; juliaMat[3,3] = Mat.col3.z; juliaMat[3,4] = Mat.col3.v;
	juliaMat[4,1] = Mat.col4.x; juliaMat[4,2] = Mat.col4.y; juliaMat[4,3] = Mat.col4.z; juliaMat[4,4] = Mat.col4.v;
  # Use built-in invert function.
  invJuliaMat = inv(juliaMat)
  # Put back into Mat4f.
	col1 = Vec4f(invJuliaMat[1,1:4]...)
	col2 = Vec4f(invJuliaMat[2,1:4]...)
	col3 = Vec4f(invJuliaMat[3,1:4]...)
	col4 = Vec4f(invJuliaMat[4,1:4]...)
	return Mat4f(col1, col2, col3, col4)
end

# [1, 2, 3, 4; 0, 0, 0, 1; 1, 0, 2, 0; 1, 2, 2, 4]
# Mat=Mat4f(Vec4f(1, 0, 1, 1), Vec4f(2, 0, 0, 2), Vec4f(3, 0, 2, 2), Vec4f(4, 1, 0, 4))
# inv(Mat)

inv(Transf::Transformation) = Transformation(Mat4f(inv(Transf.Mat)))

type OrthoCamera
  camToWorld::Transformation
  worldToCam::Transformation
end

function crossproduct(vec1::Vec4f, vec2::Vec4f)
  return Vec4f(
    vec1.y * vec2.z - vec1.z * vec2.y,
    vec1.z * vec2.x - vec1.x * vec2.z,
    vec1.x * vec2.y - vec1.y * vec2.x,
    1
  )
end

function euclideanNorm(vec::Vec4f)
  return sqrt(vec.x^2 + vec.y^2 + vec.z^2)
end

function GenIdentityMat4f()
	return Mat4f(Vec4f(1,0,0,0), Vec4f(0,1,0,0), Vec4f(0,0,1,0), Vec4f(0,0,0,1))
end

function OrthoCamera(eW::Vec4f, eUp::Vec4f, eView::Vec4f)
  rCenter = Vec4f(0, 0, 1, 1)
  rUp::Vec4f = Vec4f(1, 0, 0, 1)
  rView::Vec4f = Vec4f(0, 1, 0, 1)

  crossProductZ = crossproduct(rCenter, eW)
  if crossProductZ.x == 0 && crossProductZ.y == 0 && crossProductZ.z == 0
    camToWorld = Transformation(GenIdentityMat4f())
    worldToCam = Transformation(GenIdentityMat4f())
    return OrthoCamera(camToWorld, worldToCam)
  end
  angleZ = asin(euclideanNorm(crossProductZ) / (euclideanNorm(rCenter) * euclideanNorm(eW)))

  crossProductX = crossproduct(rView, eView)
  angleX = asin(euclideanNorm(crossProductX) / (euclideanNorm(rView) * euclideanNorm(eView)))

  crossProductY = crossproduct(rUp, eUp)
  angleY = asin(euclideanNorm(crossProductY) / (euclideanNorm(rUp) * euclideanNorm(eUp)))

  transf = euler(angleX, angleY, angleZ)
  return OrthoCamera(transf, inv(transf))
end



function render(object::Object, camera::OrthoCamera; figNum=1)
  render(camera.worldToCam * object, figNum)
end

# render(houseOfSantaClaus, OrthoCamera(Vec4f(12, 0, 0, 1), Vec4f(1, 23, 0, 1), Vec4f(1, 0, 9, 1)))
OrthoCamera(Vec4f(12, 0, 0, 1), Vec4f(1, 23, 0, 1), Vec4f(1, 0, 9, 1)).worldToCam
# cam =
# v1 = Vec4f(1, 1, 1, 1)
# v2 = Vec4f(1, 1, 1, 1)
# crossproduct(v1, v2)
