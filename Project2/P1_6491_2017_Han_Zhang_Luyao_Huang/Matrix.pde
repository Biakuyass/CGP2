class Matrix
{
  float [][] value;
  Matrix()
  {
    value = new float[3][3];
    value[0][0] = 1;
    value[0][1] = 0;
    value[0][2] = 0;
    value[1][0] = 0;
    value[1][1] = 1;
    value[1][2] = 0;
    value[2][0] = 0;
    value[2][1] = 0;
    value[2][2] = 1;
  }
  void setMatrix(Matrix b)
  {
    for (int i = 0; i < 3; i++)
      for (int j = 0; j < 3; j++)
      {
        value[i][j] = b.value[i][j];
      }
  }
  void setRotation(float theta)
  {
    value[0][0] = cos(theta);
    value[0][1] = sin(theta);
    value[0][2] = 0;
    value[1][0] = -sin(theta);
    value[1][1] = cos(theta);
    value[1][2] = 0;
    value[2][0] = 0;
    value[2][1] = 0;
    value[2][2] = 1;
  }

  void setRotation(float costheta, float sintheta)
  {
    value[0][0] = costheta;
    value[0][1] = sintheta;
    value[0][2] = 0;
    value[1][0] = -sintheta;
    value[1][1] = costheta;
    value[1][2] = 0;
    value[2][0] = 0;
    value[2][1] = 0;
    value[2][2] = 1;
  }


  void setTranslation(float x, float y)
  {
    value[0][0] = 1;
    value[0][1] = 0;
    value[0][2] = 0;
    value[1][0] = 0;
    value[1][1] = 1;
    value[1][2] = 0;
    value[2][0] = x;
    value[2][1] = y;
    value[2][2] = 1;
  }
}

Matrix Apply(Matrix mat1, Matrix mat2)
{
  Matrix resultMatrix = new Matrix();
  for (int i = 0; i < 3; i++)
    for (int j = 0; j < 3; j++)
    {
      resultMatrix.value[j][i] = mat1.value[j][0] * mat2.value[0][i] + mat1.value[j][1] * mat2.value[1][i] + mat1.value[j][2] * mat2.value[2][i];
    }
  return resultMatrix;
}

pt Apply(pt point, Matrix mat)
{
  pt resultpt = new pt();
  resultpt.x = point.x * mat.value[0][0] + point.y * mat.value[1][0] + mat.value[2][0];
  resultpt.y = point.x * mat.value[0][1] + point.y * mat.value[1][1] + mat.value[2][1];
  float scale = point.x * mat.value[0][2] + point.y * mat.value[1][2] + mat.value[2][2];

  resultpt.x /= scale;
  resultpt.y /= scale;

  return resultpt;
}

vec Apply(vec vector, Matrix mat)
{
  vec resultvec = new vec();

  resultvec.x = vector.x * mat.value[0][0] + vector.y * mat.value[1][0];
  resultvec.y = vector.x * mat.value[0][1] + vector.y * mat.value[1][1];
  float scale = vector.x * mat.value[0][2] + vector.y * mat.value[1][2] + mat.value[2][2];

  resultvec.x /= scale;
  resultvec.y /= scale;

  return resultvec;
}

void PrintMatrix(Matrix mat)
{
  for (int i = 0; i < 3; i++)
  {
    println(mat.value[i][0] + "  " + mat.value[i][1] + "  " + mat.value[i][2]);
  }
}

//clockwise
vec Rotate(vec vector, float theta)
{
  vec resultvec = new vec();
  Matrix matrix_T = new Matrix();
  matrix_T.setRotation(theta);
  resultvec = Apply(vector, matrix_T);
  return resultvec;
}

Matrix figureoutMatrix(float translate_x, float translate_y, float theta, float translate_x2, float translate_y2)
{
  Matrix translationMat = new Matrix();
  translationMat.setTranslation(translate_x, translate_y);

  Matrix rotationMat = new Matrix();
  rotationMat.setRotation(theta);

  Matrix translationMatAxis = new Matrix();
  translationMatAxis.setTranslation(translate_x2, translate_y2);

  Matrix tempMat = new Matrix();
  tempMat.setMatrix(Apply(translationMat, rotationMat));

  Matrix finalMat = new Matrix();
  finalMat.setMatrix(Apply(tempMat, translationMatAxis));

  return finalMat;
}