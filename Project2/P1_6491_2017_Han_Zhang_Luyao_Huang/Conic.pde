
abstract class Conic
{
  float square_a, square_b, square_c;
  Conic(){};
  void setConic(float square_a_, float square_b_, float square_c_)
  {
        square_a = square_a_; 
    square_b = square_b_; 
    square_c = square_c_;
  }
}



class Hyperbola extends Conic
{
  //float square_a, square_b, square_c;
  boolean isright; // decide left or right curve of Hyperbola;
  Hyperbola() {
  };
  Hyperbola(float square_a_, float square_b_, float square_c_) {
    setConic(square_a_,square_b_,square_c_);
  }

  void setHyperbola(float square_a_, float square_b_, float square_c_) {
    setConic(square_a_,square_b_,square_c_);
  }

  void pointSetInHyperbola(pt [] pointSet, pt point_a, pt point_b)
  {

    float a = sqrt(square_a);
    float b = sqrt(square_b);

    float startAngle = atan2((point_a.y * a) / (b * point_a.x), a / point_a.x);
    float endAngle = atan2((point_b.y * a) / (b * point_b.x), a / point_b.x);


    if (endAngle < startAngle)
    {
      float temp = endAngle;
      endAngle = startAngle;
      startAngle = temp;
    }

    if (endAngle - startAngle > PI)
    {
      float temp = endAngle;
      endAngle = startAngle + 2 * PI;
      startAngle = temp;
    }

    if (startAngle < PI / 2.0f && startAngle > -PI / 2.0f)
    {
      isright = true;
    } else
    {
      isright = false;
    }

    float theta = startAngle;
    float deltaAngle = (endAngle - startAngle)  / (point_number - 1);
    for (int i = 0; i < point_number; i++, theta += deltaAngle)
    {
      pointSet[i] = new pt();
      float x = sqrt(square_a) / cos(theta);
      float y = sqrt(square_b) * tan(theta);
      pointSet[i].x = x;
      pointSet[i].y = y;
    }
  }
}

class Ellipse extends Conic
{
  //float square_a, square_b, square_c;
  Ellipse() {
  };
  Ellipse(float square_a_, float square_b_, float square_c_) {
    setConic(square_a_,square_b_,square_c_);
  }

  boolean pointInArc(pt point_a, pt point_b, pt testPoint)
  {
    float a = sqrt(square_a);
    float b = sqrt(square_b);

    float startAngle = atan2(point_a.y / b, point_a.x / a);
    float endAngle = atan2(point_b.y / b, point_b.x / a);

    if (endAngle < startAngle)
    {
      float temp = endAngle;
      endAngle = startAngle;
      startAngle = temp;
    }

    if (endAngle - startAngle > PI)
    {
      float temp = endAngle;
      endAngle = startAngle + 2 * PI;
      startAngle = temp;
    }

    float testAngle = atan2(testPoint.y / b, testPoint.x / a);
    if (testAngle < endAngle && testAngle > startAngle )
      return true;
    else if (testAngle + 2 * PI < endAngle && testAngle + 2 * PI > startAngle )
      return true;
    else if (testAngle - 2 * PI < endAngle && testAngle + 2 * PI > startAngle )
      return true;

    return false;
  }

  void pointSetInEllipse(pt [] pointSet, pt point_a, pt point_b)
  {
    float a = sqrt(square_a);
    float b = sqrt(square_b);
    float startAngle = atan2(point_a.y / b, point_a.x / a);
    float endAngle = atan2(point_b.y / b, point_b.x / a);

    if (endAngle < startAngle)
    {
      float temp = endAngle;
      endAngle = startAngle;
      startAngle = temp;
    }

    if (endAngle - startAngle > PI)
    {
      float temp = endAngle;
      endAngle = startAngle + 2 * PI;
      startAngle = temp;
    }



    float theta = startAngle;
    float deltaAngle = (endAngle - startAngle)  / (point_number - 1);
    for (int i = 0; i < point_number; i++, theta += deltaAngle)
    {
      pointSet[i] = new pt();
      float x = sqrt(square_a) * cos(theta);
      float y = sqrt(square_b) * sin(theta);
      pointSet[i].x = x;
      pointSet[i].y = y;
    }
  }
}

// Only for inferior arc
class CircleArc
{
  CIRCLE circle;
  pt startPoint, endPoint;
  float startAngle,endAngle;

  CircleArc() {
  };
  CircleArc(CIRCLE circle_, pt spt, pt ept)
  {
    circle = circle_;
    startPoint = spt;
    endPoint = ept;

    startAngle = atan2((startPoint.y - circle.C.y)/circle.r, (startPoint.x - circle.C.x) /circle.r);
    endAngle = atan2((endPoint.y - circle.C.y) /circle.r, (endPoint.x - circle.C.x) /circle.r);
  }
  void setCricleArc(CIRCLE circle_, pt spt, pt ept)
  {
    circle = circle_;
    startPoint = spt;
    endPoint = ept;
    startAngle = atan2((startPoint.y - circle.C.y)/circle.r, (startPoint.x - circle.C.x) /circle.r);
    endAngle = atan2((endPoint.y - circle.C.y) /circle.r, (endPoint.x - circle.C.x) /circle.r);
  }

  float Length()
  {
    float angle = abs(endAngle - startAngle);
    angle = angle > PI? 2 * PI - angle: angle;
    float arcLength = angle * circle.r;
    return arcLength;
  }
  // only useful when point in on the circle of this arc
  boolean isPointOnArc(pt point)
  {
    vec vstart = new vec(startPoint.x - circle.C.x, startPoint.y - circle.C.y); 
    vec vend = new vec(endPoint.x - circle.C.x, endPoint.y - circle.C.y); 
    vec pvec = new vec(point.x - circle.C.x, point.y - circle.C.y); 

    float angleS = angle(pvec, vstart);
    float angleE = angle(pvec, vend);

    if (angleS * angleE <= 0.00001 && abs(angleS) + abs(angleE) < PI)
      return true;
    else
      return false;
  }
}



void pointSetonCircle(pt [] pointSet, pt point_a, pt point_b, CIRCLE circle, boolean clockwise)
{
  float startAngle = atan2((point_a.y - circle.C.y)/circle.r, (point_a.x - circle.C.x) /circle.r);
  float endAngle = atan2((point_b.y - circle.C.y) /circle.r, (point_b.x - circle.C.x) /circle.r);

  if (clockwise)
  {
    if (endAngle > startAngle)
      startAngle += 2 * PI;
  } else
  {
    if (endAngle < startAngle)
      endAngle += 2 * PI;
  }

  float theta = startAngle;
  float deltaAngle = (endAngle - startAngle)  / (point_number - 1);
  for (int i = 0; i < point_number; i++, theta += deltaAngle)
  {
    float x = circle.C.x + circle.r * cos(theta);
    float y = circle.C.y + circle.r * sin(theta);
    pointSet[i] = new pt();
    pointSet[i].x = x;
    pointSet[i].y = y;
  }
}

//record points on arc
void drawSmallArc(pt [] pointSet, pt point_a, pt point_b, CIRCLE circle, int smallArc)
{
  pointSetonCircle(pointSet, point_a, point_b, circle, smallArc);

  beginShape();
  for (int i = 0; i < point_number; i++)
  {
    vertex(pointSet[i].x, pointSet[i].y);
  }
  endShape();
}

void drawSmallArc(pt point_a, pt point_b, CIRCLE circle, int smallArc)
{
  pt [] pointSet = new pt [point_number];

  pointSetonCircle(pointSet, point_a, point_b, circle, smallArc);

  beginShape();
  for (int i = 0; i < point_number; i++)
  {
    vertex(pointSet[i].x, pointSet[i].y);
  }
  endShape();
}

void pointSetonCircle(pt [] pointSet, pt point_a, pt point_b, CIRCLE circle, int smallArc)
{


  float startAngle = atan2((point_a.y - circle.C.y)/circle.r, (point_a.x - circle.C.x) /circle.r);
  float endAngle = atan2((point_b.y - circle.C.y) /circle.r, (point_b.x - circle.C.x) /circle.r);

  if (smallArc == 1)
  {
    if (abs(endAngle - startAngle) > PI )
    {
      endAngle = endAngle < 0? 2 * PI + endAngle:endAngle;
      startAngle = startAngle < 0? 2 * PI + startAngle:startAngle;
    }
  } else
  {
    // Won't be used in this project
  }

  float theta = startAngle;
  float deltaAngle = (endAngle - startAngle)  / (point_number - 1);
  for (int i = 0; i < point_number; i++, theta += deltaAngle)
  {
    float x = circle.C.x + circle.r * cos(theta);
    float y = circle.C.y + circle.r * sin(theta);
    pointSet[i] = new pt();
    pointSet[i].x = x;
    pointSet[i].y = y;
  }
}