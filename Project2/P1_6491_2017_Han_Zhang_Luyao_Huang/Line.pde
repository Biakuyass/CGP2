class Line
{
  float k, b;
  boolean isperpendicular;
  float x_value; // x = x_value when isperpendicular is true
  Line()
  {
    k = 1;
    b = 1;
  };
  Line(float k_, float b_)
  {
    k = k_;
    b = b_;
  }

  void figureoutLine(pt point_a, pt point_b)
  {
    if (abs(point_b.x - point_a.x) < 0.0001)
    {
      isperpendicular = true;
      x_value = point_b.x;
    } else
    {
      isperpendicular = false;
      k = (point_b.y - point_a.y) / (point_b.x - point_a.x);
      b = point_a.y - k * point_a.x;
    }
  }
  
  boolean onLine(pt testPoint)
  {
    float resulty = testPoint.x * k + b;
    if(abs(resulty - testPoint.y) < 0.001f)
    return true;
    else
    return false;  
  }
}


//draw line with pt 
void LinePoint(pt point_a, pt point_b)
{
  line(point_a.x, point_a.y, point_b.x, point_b.y);
}



pt intersection_LineAndLine(Line line_a, Line line_b)
{
  pt resultpt = new pt();
  resultpt.x = (line_b.b - line_a.b) / (line_a.k - line_b.k);
  resultpt.y = line_a.k * resultpt.x + line_a.b;

  return resultpt;
}

//this method may cause a bug in special condition
//only for minor arc
pt intersection_LineAndArc(Line line, pt CircleCenter, float radius, pt line_startPoint)
{
  pt resultpt = new pt();

  float a = 1 + line.k * line.k;
  float b = 2 * line.k * line.b - 2 * CircleCenter.x - 2 * CircleCenter.y * line.k ;
  float c = line.b * line.b + CircleCenter.x * CircleCenter.x + CircleCenter.y * CircleCenter.y - 2 * CircleCenter.y * line.k - radius * radius;

  if (b * b - 4 * a * c < 0)
    println("Error! LineAndArc");
  float x1 = (-b + sqrt(b * b - 4 * a * c)) / (2 * a);
  float y1 = line.k * x1 + line.b;
  pt pt1 = new pt(x1, y1);


  float x2 = (-b - sqrt(b * b - 4 * a * c)) / (2 * a);
  float y2 = line.k * x2 + line.b;

  pt pt2 = new pt(x2, y2);

  resultpt = d(pt1, line_startPoint) < d(pt2, line_startPoint)? pt1 : pt2;

  return resultpt;
}



//this method may cause a bug in special condition
//only for minor ellipse arc
pt intersection_LineAndEllipse(Line line, Ellipse ellipse, pt line_startPoint)
{
  pt resultpt = new pt();

  float ellipse_a = sqrt(ellipse.square_a);
  float ellipse_b = sqrt(ellipse.square_b);

  float a = ellipse_b * ellipse_b + ellipse_a * ellipse_a * line.k * line.k;
  float b = 2 * ellipse_a * ellipse_a * line.k * line.b ;
  float c = ellipse_a * ellipse_a * line.b * line.b - ellipse_a * ellipse_a * ellipse_b * ellipse_b;

  if (b * b - 4 * a * c < 0)
    println("Error! bb Ellipse");

  float x1 = (-b + sqrt(b * b - 4 * a * c)) / (2 * a);
  float y1 = line.k * x1 + line.b;
  pt pt1 = new pt(x1, y1);


  float x2 = (-b - sqrt(b * b - 4 * a * c)) / (2 * a);
  float y2 = line.k * x2 + line.b;

  pt pt2 = new pt(x2, y2);

  resultpt = d(pt1, line_startPoint) < d(pt2, line_startPoint)? pt1 : pt2;

  return resultpt;
}


pt intersection_LineAndHyperbola(Line line_, Hyperbola hyperbola_, pt line_startPoint)
{


  pt resultpt = new pt();

  float temp_a = hyperbola_.square_b - hyperbola_.square_a * line_.k * line_.k;
  float temp_b = -2 * hyperbola_.square_a * line_.k * line_.b;
  float temp_c = -1 * hyperbola_.square_b * hyperbola_.square_a - hyperbola_.square_a * line_.b * line_.b;


  float x1 = (-1 * temp_b + sqrt(sq(temp_b) - 4 * temp_a * temp_c) ) / (2 * temp_a);
  float y1 = line_.k * x1 + line_.b;
  pt point1 = new pt(x1, y1);

  float x2 = (-1 * temp_b - sqrt(sq(temp_b) - 4 * temp_a * temp_c) ) / (2 * temp_a);
  float y2 =line_.k * x2 + line_.b;
  pt point2 = new pt(x2, y2);

  if (hyperbola_.isright == true)
  {
    if (point1.x < 0.01)
      resultpt = point2;

    if (point2.x < 0.01)
      resultpt = point1;

    if (point1.x < 0.01 && point2.x < 0.01)
    {
      println("Error LineAndHyperbola");
      return new pt();
    }

    if (point1.x > -0.01 && point2.x > -0.01)
    {
      resultpt = d(point1, line_startPoint) < d(point2, line_startPoint) ? point1 : point2;
    }
  } else
  {
    if (point1.x > -0.01)
      resultpt = point2;

    if (point2.x > -0.01)
      resultpt = point1;

    if (point1.x > -0.01 && point2.x > -0.01)
    {
      println("Error LineAndHyperbola");
      return new pt();
    }

    if (point1.x < -0.01 && point2.x < -0.01)
    {
      resultpt = d(point1, line_startPoint) < d(point2, line_startPoint) ? point1 : point2;
    }
  }
  return resultpt;
}


Line figureoutTangentLine(pt circleCenter, pt point_)
{
  Line resultLine;
  resultLine = new Line();


  Line tempLine = new Line();
  tempLine.figureoutLine(circleCenter, point_);

  if (tempLine.isperpendicular)
  {
    resultLine.k = 0;
    resultLine.b = point_.y;

    return resultLine;
  }

  if (abs(tempLine.k) < 0.0001)
  {

    resultLine.isperpendicular = true;
    resultLine.x_value = point_.x;

    return resultLine;
  }


  float k = -1 / tempLine.k;
  float b = point_.y - k * point_.x;

  resultLine = new Line(k, b);

  return resultLine;
}



// intersection of two tangent line of a circle
pt tangentLineIntersection(pt circleCenter, pt point_a, pt point_b) 
{
  pt resultpt;

  Line tangentLineL, tangentLineR;

  tangentLineL = figureoutTangentLine(circleCenter, point_a);
  tangentLineR = figureoutTangentLine(circleCenter, point_b);

  resultpt = intersection_LineAndLine(tangentLineL, tangentLineR);

  return resultpt;
}