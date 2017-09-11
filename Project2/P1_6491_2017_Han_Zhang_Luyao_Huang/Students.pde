 //<>//
final int point_number = 41;
pt [] pointSetCircleArcL = new pt[point_number];
pt [] pointSetCircleArcR = new pt[point_number];
pt [] pointSet_MedialAxis = new pt[point_number * 4];

//all points on lower arcs
pt [][] pointSetLowerArcs = new pt [4][point_number];
LocalCoordinates [][] LowerArcsBotLC = new LocalCoordinates[4][point_number - 1];
ArrayList<LocalCoorArea> CoordinateR = new ArrayList<LocalCoorArea>();
// Medial Axis start point
pt curveStartPoint;


int ImageArraySize = 51;
//record which part of the image is in the area R.
boolean [][] texInArea = new boolean [ImageArraySize][ImageArraySize];
ImageTexture imageR = new ImageTexture();
pt [][] imageLocalCoor = new pt [ImageArraySize][ImageArraySize];

pt tangentPointL = new pt();
pt tangentPointR = new pt();
CIRCLE Circle_NL, Circle_NR, Circle_ML, Circle_MR;


// calculate the local coordinates once at the beginning 
boolean recordFlag = true;

//ori_x -- global coordinate,x--- local coordinate
class LocalCoordinates
{
  float ori_x, ori_y;
  float x, y;
  LocalCoordinates() {
  };
  LocalCoordinates(float ori_x_, float ori_y_, float x_, float y_)
  {
    ori_x = ori_x_;
    ori_y = ori_y_;
    x = x_;
    y = y_;
  }
  void setLocalCoordinates(float ori_x_, float ori_y_, float x_, float y_)
  {
    ori_x = ori_x_;
    ori_y = ori_y_;
    x = x_;
    y = y_;
  }
}

LocalCoordinates Lerp_LC(LocalCoordinates a, LocalCoordinates b, float t)
{
  LocalCoordinates resultlc = new LocalCoordinates();

  resultlc.x = a.x + t * (b.x - a.x);
  resultlc.y = a.y + t * (b.y - a.y);
  resultlc.ori_x = a.ori_x + t * (b.ori_x - a.ori_x);
  resultlc.ori_y = a.ori_y + t * (b.ori_y - a.ori_y);

  return resultlc;
}

class LocalCoorArea
{
  LocalCoordinates startPoint;
  LocalCoordinates [] allPointsInSameX; // Y axis
  LocalCoorArea()
  {
    allPointsInSameX = new LocalCoordinates[point_number];
  }
}

class SixArcArea

{
  CircleArc [] upperArcs;
  CircleArc [] lowerArcs;  
  int xaxis_resolution;
  int yaxis_resolution;
  SixArcArea() {
  };
  void Init()
  {
    pt S=P.G[0], E=P.G[1], L=P.G[2], R=P.G[3];
    pt M=P.G[4], N=P.G[5];

    curveStartPoint = S;

    xaxis_resolution = 40;
    yaxis_resolution = 40;

    upperArcs = new CircleArc [4];
    lowerArcs = new CircleArc [4];

    float s=d(S, L), e=d(E, R); 
    CIRCLE Cs = C(S, s), Ce = C(E, e); 

    upperArcs[0] = new CircleArc(Cs, pointSetCircleArcL[point_number / 2], L);
    upperArcs[1] = new CircleArc(Circle_NL, L, N);
    upperArcs[2] = new CircleArc(Circle_NR, N, tangentPointR);
    upperArcs[3] = new CircleArc(Ce, tangentPointR, pointSetCircleArcR[point_number / 2]);

    lowerArcs[0] = new CircleArc(Cs, pointSetCircleArcL[point_number / 2], tangentPointL);
    lowerArcs[1] = new CircleArc(Circle_ML, tangentPointL, M);
    lowerArcs[2] = new CircleArc(Circle_MR, M, R);
    lowerArcs[3] = new CircleArc(Ce, R, pointSetCircleArcR[point_number / 2]);


    for (int i = 0; i < 4; i++)
    {
      drawSmallArc(upperArcs[i].startPoint, upperArcs[i].endPoint, upperArcs[i].circle, 1);  
      drawSmallArc(pointSetLowerArcs[i], lowerArcs[i].startPoint, lowerArcs[i].endPoint, lowerArcs[i].circle, 1);
    }

    float lengthSumOfLowerArcs = 0;
    for (int i = 0; i < 4; i++)
    {
      lengthSumOfLowerArcs += lowerArcs[i].Length();
    }

    float startX = 0;

    for (int i = 0; i < 4; i++)
    {
      for (int j = 0; j < point_number - 1; j++)
      {

        float localdeltax = (lowerArcs[i].Length() / lengthSumOfLowerArcs) / (point_number - 1);

        float local_x = startX + localdeltax * j;
        float local_y = -1;

        LowerArcsBotLC[i][j] =  new LocalCoordinates();
        LowerArcsBotLC[i][j].setLocalCoordinates(pointSetLowerArcs[i][j].x, pointSetLowerArcs[i][j].y, local_x, local_y);
      }

      startX += lowerArcs[i].Length() / lengthSumOfLowerArcs;
    }

    //Special Condition, if the arc calculated is original circle arc(Cs,Ce), the point_number will change
    float localdeltax_s1 = (lowerArcs[0].Length() / lengthSumOfLowerArcs) / (point_number - 1);
    for (int i = point_number/ 2 + 1; i < point_number - 1; i++)
    {
      pt pointOnArcA = pointSetCircleArcL[i];

      //startPoint_x = 0

      float local_x = localdeltax_s1 * (i - point_number/ 2);
      float local_y = -1;

      LowerArcsBotLC[0][i - point_number/ 2 - 1] =  new LocalCoordinates();
      LowerArcsBotLC[0][i - point_number/ 2 - 1].setLocalCoordinates(pointOnArcA.x, pointOnArcA.y, local_x, local_y);
    }

    float localdeltax_s2 = (lowerArcs[3].Length() / lengthSumOfLowerArcs) / (point_number - 1);
    float startX_s2 = (lowerArcs[0].Length() + lowerArcs[1].Length() + lowerArcs[2].Length()) / lengthSumOfLowerArcs;
    for (int i = 1; i < (point_number - 1) / 2; i++)
    {
      pt pointOnArcA = pointSetCircleArcR[i];

      //startPoint_x = 0

      float local_x = startX_s2 + localdeltax_s2 * i;
      float local_y = -1;

      LowerArcsBotLC[3][i - 1] =  new LocalCoordinates();
      LowerArcsBotLC[3][i - 1].setLocalCoordinates(pointOnArcA.x, pointOnArcA.y, local_x, local_y);
    }

    //test
    /* beginShape();
     for(int i = 0;i < 4;i++)
     for(int j = 0;j < point_number -1;j++)
     {
     vertex(LowerArcsBotLC[i][j].ori_x,LowerArcsBotLC[i][j].ori_y);
     // vertex(pointSetLowerArcs[i][j].x,pointSetLowerArcs[i][j].y);
     // println(pointSetLowerArcs[i][j].x,pointSetLowerArcs[i][j].y);
     
     }
     endShape();*/
  }
}
// To test if the point is in area R
boolean inAreaR(pt globalpt)
{

  boolean foundflag = false;
  //look for x
  for (int i = 0; i < CoordinateR.size() - 1; i++)
  {
    for (int j = 0; j < point_number - 1; j++)
    {
      pt [] quad = new pt[4];
      quad[0] = new pt(CoordinateR.get(i).allPointsInSameX[j].ori_x, CoordinateR.get(i).allPointsInSameX[j].ori_y);
      quad[1] = new pt(CoordinateR.get(i + 1).allPointsInSameX[j].ori_x, CoordinateR.get(i  + 1).allPointsInSameX[j].ori_y);
      quad[2] = new pt(CoordinateR.get(i + 1).allPointsInSameX[j + 1].ori_x, CoordinateR.get(i + 1).allPointsInSameX[j + 1].ori_y);
      quad[3] = new pt(CoordinateR.get(i).allPointsInSameX[j + 1].ori_x, CoordinateR.get(i).allPointsInSameX[j + 1].ori_y);

      if (inQuadGlobal(globalpt, quad))
      {
        foundflag = true;
        break;
      }
    }
    if (foundflag)
      break;
  }

  if (foundflag)
  {
    return true;
  }
  return false;
}
//clockwise
// To test if the point is in a quad of area R
boolean inQuadGlobal(pt testpoint, pt [] quadPoints)
{
  int intersectionCount = 0;
  
 /* float minX = 10000;
  float minY = 10000;
  float maxX = -1;
  float maxY = -1;
  for(int i = 0 ; i < 4 ;i++)
  {
    if(quadPoints[i].x < minX)
    minX = quadPoints[i].x;
    if(quadPoints[i].y < minY)
    minY = quadPoints[i].y;
    if(quadPoints[i].x > maxX)
    maxX = quadPoints[i].x;
    if(quadPoints[i].y > maxY)
    maxY = quadPoints[i].y;
  }
  // first detection
  if(testpoint.x < minX || testpoint.y < minY || testpoint.x > maxX || testpoint.x > maxY)
  return false;*/

  // exact detection
  for (int i = 0; i < 4; i++)
  {
    float t = (testpoint.x - quadPoints[i].x) / (quadPoints[(i + 1) % 4 ].x - quadPoints[i].x);
    
    float y = quadPoints[i].y + t * (quadPoints[(i + 1) % 4 ].y - quadPoints[i].y);
    if (t > -0.0001 && t < 1.0001 && y < testpoint.y)
      intersectionCount++;
  }

  if (intersectionCount % 2 == 0)
    return false;
  else
    return true;

  // float t2 = (testpoint.x - a.x) / (b.x - a.x);
  // float t3 = (testpoint.x - a.x) / (b.x - a.x);
  // float t4 = (testpoint.x - a.x) / (b.x - a.x);
}


pt LerpInQuadLocal(pt point, LocalCoordinates [] quad)
{
  pt resultpt = new pt();

  Line [] quadlines= new Line [4];
  for (int i = 0; i < 4; i++)
  {
    quadlines[i] = new Line();
    pt point_a = new pt(quad[i].ori_x, quad[i].ori_y);
    pt point_b = new pt(quad[(i + 1) % 4].ori_x, quad[(i + 1) % 4].ori_y);

    quadlines[i].figureoutLine(point_a, point_b);
    if (quadlines[i].onLine(point))
    {
      float t = (point.x - point_a.x) / (point_b.x - point_a.x);
      resultpt.x = quad[i].x + t * (quad[(i + 1) % 4].x - quad[i].x);
      resultpt.y = quad[i].y + t * (quad[(i + 1) % 4].y - quad[i].y);
      return resultpt;
    }
  }

  pt quadCorner = new pt(quad[0].ori_x, quad[0].ori_y);

  Line line = new Line();
  line.figureoutLine(quadCorner, point);

  pt intersectionPoint1 = intersection_LineAndLine(line, quadlines[1]);
  pt intersectionPoint2 = intersection_LineAndLine(line, quadlines[2]);

  // t1 and t2 are larger than 1
  float t1 = (point.x - quadCorner.x) / (intersectionPoint1.x - quadCorner.x);
  float t2 = (point.x- quadCorner.x) / (intersectionPoint2.x - quadCorner.x);

  pt intersectionPoint;
  float intersect_t;
  pt intersect_local = new pt();
  if (t1 > t2)
  {
    intersectionPoint = intersectionPoint1;
    intersect_t = t1;

    float t = (intersectionPoint.x - quad[1].ori_x) / (quad[2].ori_x - quad[1].ori_x);
    intersect_local.x =  quad[1].x + t * (quad[2].x - quad[1].x);
    intersect_local.y =  quad[1].y + t * (quad[2].y - quad[1].y);
  } else
  {
    intersectionPoint = intersectionPoint2;
    intersect_t = t2;

    float t = (intersectionPoint.x - quad[2].ori_x) / (quad[3].ori_x - quad[2].ori_x);
    intersect_local.x =  quad[2].x + t * (quad[3].x - quad[2].x);
    intersect_local.y =  quad[2].y + t * (quad[3].y - quad[2].y);
  }

  resultpt.x = quad[0].x + intersect_t * (intersect_local.x - quad[0].x);
  resultpt.y = quad[0].y + intersect_t * (intersect_local.y - quad[0].y);
  
  /*if(resultpt.y < -1.001)
  {
    println("");
    println(point.x + "   " + point.y);
     println(quad[0].ori_x + "   " + quad[0].ori_y);
      println(quad[1].ori_x + "   " + quad[1].ori_y);
       println(quad[2].ori_x + "   " + quad[2].ori_y);
    println(quad[3].ori_x + "   " + quad[3].ori_y);
  }*/



  return resultpt;
}


pt FromGlobaltoLocal(pt globalpt)
{
  pt localpt = new pt();
  boolean foundflag = false;
  //look for x
  for (int i = 0; i < CoordinateR.size() - 1; i++)
  {
    for (int j = 0; j < point_number - 1; j++)
    {
      pt [] quad = new pt[4];
      quad[0] = new pt(CoordinateR.get(i).allPointsInSameX[j].ori_x, CoordinateR.get(i).allPointsInSameX[j].ori_y);
      quad[1] = new pt(CoordinateR.get(i + 1).allPointsInSameX[j].ori_x, CoordinateR.get(i  + 1).allPointsInSameX[j].ori_y);
      quad[2] = new pt(CoordinateR.get(i + 1).allPointsInSameX[j + 1].ori_x, CoordinateR.get(i + 1).allPointsInSameX[j + 1].ori_y);
      quad[3] = new pt(CoordinateR.get(i).allPointsInSameX[j + 1].ori_x, CoordinateR.get(i).allPointsInSameX[j + 1].ori_y);

      if (inQuadGlobal(globalpt, quad))
      {
        LocalCoordinates [] quadLocal = new LocalCoordinates [4];
        quadLocal[0] = CoordinateR.get(i).allPointsInSameX[j];
        quadLocal[1] = CoordinateR.get(i + 1).allPointsInSameX[j];
        quadLocal[2] = CoordinateR.get(i + 1).allPointsInSameX[j + 1];
        quadLocal[3] = CoordinateR.get(i).allPointsInSameX[j + 1];
        
       /* if(quadLocal[0].y < -1.001 || quadLocal[1].y < -1.001 || quadLocal[2].y < -1.001 || quadLocal[3].y < -1.001)
        {
          println("");
          println(quadLocal[0] + "   " +quadLocal[1] + "   " +quadLocal[2] + "   " +quadLocal[3] + "   " );
        }*/

        localpt = LerpInQuadLocal(globalpt, quadLocal);
        foundflag = true;
        break;
      }
    }
    if (foundflag)
      break;
  }

  if (!foundflag)
  {
    localpt = new pt(-1, -1);
  }


  return localpt;
}


pt FromLocaltoGlobal(pt localpt)
{
  pt globalpt = new pt();

  boolean foundflag = false;

  float delta_y = 2.0f / (point_number - 1);

  //look for x
  for (int i = 0; i < CoordinateR.size() - 1; i++)
  {
    float x1 = CoordinateR.get(i).startPoint.x;
    float x2 = CoordinateR.get(i + 1).startPoint.x;

    foundflag = true;
    //bug possible
    //found the point
    if (localpt.x >= x1 && localpt.x <= x2)
    {
      int yIndex = (int)((localpt.y + 1.0f) / delta_y);
      
      //not a good way to solve bug,should be changed after
      if(yIndex < 0)
      {
       // println(localpt.y + "    " + delta_y );
        yIndex = 0;
      }
      if(yIndex > point_number - 1)
      {
        yIndex = point_number - 1;
      }
      
      

      int yIndex2 = yIndex + 1;
      
      //upborder
      if (yIndex == point_number - 1)
      {
        yIndex2 = yIndex;
        yIndex--;
      }
      float tx = (localpt.x - x1) / (x2 - x1);
      
      /*if(yIndex >= point_number || yIndex2 >=point_number || yIndex < 0 || yIndex2 < 0)
      {
        println("");
        println(localpt.y + "    " + delta_y );
        println(yIndex+ "    " + yIndex2);
      }*/
      
      float ty = (localpt.y - CoordinateR.get(i).allPointsInSameX[yIndex].y) / (CoordinateR.get(i).allPointsInSameX[yIndex2].y - CoordinateR.get(i).allPointsInSameX[yIndex].y); //<>//

      LocalCoordinates lc1 = Lerp_LC(CoordinateR.get(i).allPointsInSameX[yIndex], CoordinateR.get(i + 1).allPointsInSameX[yIndex], tx);
      LocalCoordinates lc2 = Lerp_LC(CoordinateR.get(i).allPointsInSameX[yIndex2], CoordinateR.get(i + 1).allPointsInSameX[yIndex2], tx);
      LocalCoordinates result_lc = Lerp_LC(lc1, lc2, ty);

      globalpt.x = result_lc.ori_x;
      globalpt.y = result_lc.ori_y;

      break;
    }
  }

  if (!foundflag)
  {
    globalpt = new pt(-1, -1);
  }

  return globalpt;
}

void CreateCoordinateR()
{
  pt S=P.G[0], E=P.G[1];

  SixArcArea areaR = new SixArcArea();
  areaR.Init();

  CoordinateR.clear();

  // divide the two cricles into 4 arcs
  //Calculate traversals in all lower arcs
  //First arc
  TraversalExtend(pointSetCircleArcL, S, LowerArcsBotLC[0], 1);
  //Seoncd and third arc
  int result_i = CreateMedialAxis(areaR.lowerArcs[1], areaR.upperArcs[1], pointSetLowerArcs[1], 0, 0, LowerArcsBotLC[1]);
  
  //next bottom arc,four different conditions
  if (result_i == point_number)
  {
    result_i = CreateMedialAxis(areaR.lowerArcs[2], areaR.upperArcs[1], pointSetLowerArcs[2], 0, 0, LowerArcsBotLC[2]);

    result_i = CreateMedialAxis(areaR.lowerArcs[2], areaR.upperArcs[2], pointSetLowerArcs[2], result_i, 0, LowerArcsBotLC[2]);
  } else
  {
    result_i = CreateMedialAxis(areaR.lowerArcs[1], areaR.upperArcs[2], pointSetLowerArcs[1], result_i, 0, LowerArcsBotLC[1]);

    result_i = CreateMedialAxis(areaR.lowerArcs[2], areaR.upperArcs[2], pointSetLowerArcs[2], 0, 0, LowerArcsBotLC[2]);
  }

  //lastarc
  TraversalExtend(pointSetCircleArcR, E, LowerArcsBotLC[3], 0);

//record the local coordinates at the beginning
  if (recordFlag)
  {
    recordFlag = false;
    imageR.Init();
    
    for (int i = 0; i < ImageArraySize; i++)
      for (int j = 0; j < ImageArraySize; j++)
      {
        if(inAreaR(imageR.coordinates[i][j].position))
        {
          texInArea[i][j] = true;
          imageLocalCoor[i][j] = new pt();
          imageLocalCoor[i][j] = FromGlobaltoLocal(imageR.coordinates[i][j].position);
        }
        
      }
  }
  
  //calculate global coordinates 
   for (int i = 0; i < ImageArraySize; i++)
      for (int j = 0; j < ImageArraySize; j++)
      {
        if(texInArea[i][j])
        {
          imageR.coordinates[i][j].position = FromLocaltoGlobal(imageLocalCoor[i][j]);
        }
      }

  drawImage(imageR,texInArea);
  //imageR.drawImage(); //<>//

  //test
  //println(CoordinateR.size());
  /*beginShape();
   for(int j = 0; j < CoordinateR.size();j++)
   for(int i = 0; i < point_number ;i++)
   vertex(CoordinateR.get(j).allPointsInSameX[i].ori_x,CoordinateR.get(j).allPointsInSameX[i].ori_y);
   endShape();*/
  //test
  /* println("***************************************************");
   for(int j = 0; j < CoordinateR.size();j++)
   {
   for (int i = 0; i < point_number; i++)
   {
   float x = CoordinateR.get(j).allPointsInSameX[i].x;
   float y = CoordinateR.get(j).allPointsInSameX[i].y;
   print(x + "," + y + "     ");
   }
   println("");
   }*/


  /* line(pointSetCircleArcL[point_number / 2].x,pointSetCircleArcL[point_number / 2].y,L.x,L.y);
   line(pointSetCircleArcL[point_number / 2].x,pointSetCircleArcL[point_number / 2].y,tangentPointL.x,tangentPointL.y);
   line(pointSetCircleArcR[point_number / 2].x,pointSetCircleArcR[point_number / 2].y,R.x,R.y);
   line(pointSetCircleArcR[point_number / 2].x,pointSetCircleArcR[point_number / 2].y,tangentPointR.x,tangentPointR.y);*/
  /* pt testCircleCenter = new pt(100, 100);
   CIRCLE testc = new CIRCLE(testCircleCenter, 100);
   pt testspt = testc.PtOnCircle(PI / 3);
   pt testept = testc.PtOnCircle(-PI * 2 / 3);
   CircleArc testarc = new CircleArc(testc,testspt,testept);
   println(testarc.Length());*/
}

//Draw arcs on Ce,Cs
void drawOriCircleArc()
{
  pt S=P.G[0], E=P.G[1], L=P.G[2], R=P.G[3];
  pt M=P.G[4], N=P.G[5];

  CIRCLE Cs = C(S, d(S, L)), Ce = C(E, d(E, R));

  vec vec_SL, vec_STL, vec_ER, vec_ETR;

  vec_SL = new vec(L.x - S.x, L.y - S.y);
  vec_STL = new vec(N.x - S.x, N.y - S.y);

  vec_ER = new vec(R.x - E.x, R.y - E.y);
  vec_ETR = new vec(M.x - E.x, M.y - E.y);


  if (angle(vec_SL, vec_STL) < 0 )
  {
    pointSetonCircle(pointSetCircleArcL, L, tangentPointL, Cs, false);
  } else
  {
    pointSetonCircle(pointSetCircleArcL, L, tangentPointL, Cs, true);
  }

  if (angle(vec_ER, vec_ETR) < 0 )
  {
    pointSetonCircle(pointSetCircleArcR, R, tangentPointR, Ce, false);
  } else
  {
    pointSetonCircle(pointSetCircleArcR, R, tangentPointR, Ce, true);
  }


  pt CircleCenterNL = crossPoint((L.y-S.y) / (L.x-S.x), L.y - L.x*(L.y-S.y) / (L.x-S.x), -(N.x-L.x)/(N.y-L.y), (N.x+L.x)*(N.x-L.x)/(2*(N.y-L.y))+(N.y+L.y)/2);
  float radiusNL = d(CircleCenterNL, L);
  Circle_NL = new CIRCLE(CircleCenterNL, radiusNL);

  pt CircleCenterMR = crossPoint((R.y-E.y) / (R.x-E.x), R.y - R.x*(R.y-E.y) / (R.x-E.x), -(M.x-R.x)/(M.y-R.y), (M.x+R.x)*(M.x-R.x)/(2*(M.y-R.y))+(M.y+R.y)/2);
  float radiusMR = d(CircleCenterMR, R);
  Circle_MR = new CIRCLE(CircleCenterMR, radiusMR);


}

void TraversalExtend(pt [] pointSet, pt CircleCenter, LocalCoordinates [] localCoor, int leftorRight)
{
  pt line_endPoint = pointSet[point_number / 2];
  int division = (point_number - 1) / 2 - 1;
  float delta_t = 1.0f / division;

  for (int i = 1; i < (point_number - 1) / 2; i++)
  {
    pt pointOnMA = L(CircleCenter, line_endPoint, delta_t * i);
    pt pointOnArcA = pointSet[point_number - 1 - i];
    pt pointOnArcB = pointSet[i];

     
    //Calculate all coordiates when x = ....;
    LocalCoorArea oneCol = new LocalCoorArea();
    if (leftorRight == 1)
    {
      oneCol.startPoint = localCoor[(point_number - 1) / 2 - 1 - i];
      pt [] tempPointSet = new pt[point_number];
      GetGlobalYInHat(tempPointSet, pointOnArcA, pointOnMA, pointOnArcB);

      CalculateLocalY(oneCol.allPointsInSameX, tempPointSet, oneCol.startPoint);

      //line(oneCol.startPoint.ori_x,oneCol.startPoint.ori_y,pointOnMA.x,pointOnMA.y);

      CoordinateR.add(0,oneCol);
      
    } else
    {

      oneCol.startPoint = localCoor[i - 1];
      
      pt [] tempPointSet = new pt[point_number];
      GetGlobalYInHat(tempPointSet, pointOnArcB, pointOnMA, pointOnArcA);
      CalculateLocalY(oneCol.allPointsInSameX, tempPointSet, oneCol.startPoint);

      CoordinateR.add(oneCol);
    }

  }
}
//changed version of drawCircleArcInHat
void GetGlobalYInHat(pt[] pointSet, pt PA, pt B, pt PC) // draws circular arc from PA to PB that starts tangent to B-PA and ends tangent to PC-B
{
  float e = (d(B, PC)+d(B, PA))/2;
  pt A = P(B, e, U(B, PA));
  pt C = P(B, e, U(B, PC));
  vec BA = V(B, A), BC = V(B, C);
  float d = dot(BC, BC) / dot(BC, W(BA, BC));
  pt X = P(B, d, W(BA, BC));
  float r=abs(det(V(B, X), U(BA)));
  vec XA = V(X, A), XC = V(X, C); 

  float a = angle(XA, XC), da=a/(point_number - 1);
  //int i = 0;
  float w = 0;

  for (int i = 0; i < point_number; i++)
  {
    w = i * da;
    pointSet[i] = P(X, R(XA, w));
  }

  //  println(i);

  //beginShape(); 

  // endShape();
}  

// pointSet is the coordinates of all points on the Y-Axis with same local X
void CalculateLocalY(LocalCoordinates [] localCoor, pt[] pointSet, LocalCoordinates startPoint)
{

  int division = point_number - 1;
  float delta_t = 2.0f / division;

  for (int i = 0; i < point_number; i++)
  {
    localCoor[i] = new LocalCoordinates();
    localCoor[i].ori_x = pointSet[i].x;
    localCoor[i].ori_y = pointSet[i].y;
    localCoor[i].x = startPoint.x;
    localCoor[i].y = startPoint.y + i * delta_t;
  }
}


int CreateMedialAxis(CircleArc arc_a, CircleArc arc_b, pt [] bottomPoints, int start_i, int test, LocalCoordinates [] localCoor)
{
  pt circleCenterL = arc_a.circle.C;
  pt circleCenterR = arc_b.circle.C;
  int divisionNumber = point_number;
  float radiusL = arc_a.circle.r;
  float radiusR = arc_b.circle.r;

  boolean contineue_flag = true;

  vec vector_LR = new vec(circleCenterR.x - circleCenterL.x, circleCenterR.y - circleCenterL.y);
  float theta = angle(vector_LR);

  Matrix finalMat = figureoutMatrix(-circleCenterL.x, -circleCenterL.y, -theta, -d(circleCenterL, circleCenterR)/2.0f, 0);
  Matrix finalMat_inv = figureoutMatrix(d(circleCenterL, circleCenterR)/2.0f, 0, theta, circleCenterL.x, circleCenterL.y);


  pt changed_circleCenterL, changed_circleCenterR, changed_S;

  changed_circleCenterL = Apply(circleCenterL, finalMat);
  changed_circleCenterR = Apply(circleCenterR, finalMat);
  changed_S = Apply(curveStartPoint, finalMat);


  float square_a, square_b, square_c;

  square_c = d2(changed_circleCenterL, changed_circleCenterR) * 0.25f;

  pt [] pointset = new pt [divisionNumber];
  
  //Ellipse
  if ( abs(( d(curveStartPoint, circleCenterL) + d(curveStartPoint, circleCenterR) ) - (radiusL + radiusR)) < 0.01 )
  {

    square_a = pow((d(curveStartPoint, circleCenterL) + d(curveStartPoint, circleCenterR)) / 2.0f, 2);
    square_b = square_a - square_c;

    Ellipse temp_ellipse = new Ellipse(square_a, square_b, square_c); 

    int i = start_i;

    while (contineue_flag == true)
    {

      pt point = new pt(bottomPoints[i].x, bottomPoints[i].y);
      pt changed_Point = Apply(point, finalMat);

      Line line = new Line();
      line.figureoutLine(changed_Point, changed_circleCenterL);

      pt changed_pointOnMA = intersection_LineAndEllipse(line, temp_ellipse, changed_Point);

      Line line_b = new Line();
      line_b.figureoutLine(changed_pointOnMA, changed_circleCenterR);

      pt changed_pointOnArcB = intersection_LineAndArc(line_b, changed_circleCenterR, radiusR, changed_pointOnMA);

      pt pointOnArcB = Apply(changed_pointOnArcB, finalMat_inv);
      pt pointOnMA = Apply(changed_pointOnMA, finalMat_inv);


      // upper arc is not long enough
      if (!arc_b.isPointOnArc(pointOnArcB))
      {
        contineue_flag = false;

        if (i > 0)
        {
          pt point2 = arc_b.endPoint;
          pt changed_Point2 = Apply(point2, finalMat);

          Line line2 = new Line();
          line2.figureoutLine(changed_Point2, changed_circleCenterR);

          pt changed_pointOnMA2 = intersection_LineAndEllipse(line2, temp_ellipse, changed_Point2);

          pt pointOnMA2 = Apply(changed_pointOnMA2, finalMat_inv);

          curveStartPoint = pointOnMA2;
        }
      }

      if (contineue_flag)
      {
        if (i < point_number -1)
        {
          pointset[i] = pointOnMA;

          //Calculate all coordiates when x = ....;
          LocalCoorArea oneCol = new LocalCoorArea();
          oneCol.startPoint = localCoor[i];

          pt [] tempPointSet = new pt[point_number];
          GetGlobalYInHat(tempPointSet, point, pointOnMA, pointOnArcB);
          CalculateLocalY(oneCol.allPointsInSameX, tempPointSet, oneCol.startPoint);

          CoordinateR.add(oneCol);
        } else
          curveStartPoint = pointOnMA;
        i++;
        
     // Lower arc finished
        if (i == point_number)
        {
          contineue_flag = false;
        }
        
        //only for test
        if (test == 1 && i - 1< point_number -1 )
        {
          line(point.x, point.y, pointOnMA.x, pointOnMA.y);
          line(pointOnArcB.x, pointOnArcB.y, pointOnMA.x, pointOnMA.y);
        }
      }
    }
    beginShape();
    for (int j = start_i; j < i - 1; j++)
      vertex(pointset[j].x, pointset[j].y);
    endShape();

    return i;

  } else if ( abs(abs(d(curveStartPoint, circleCenterL) - d(curveStartPoint, circleCenterR)) - abs(radiusL - radiusR)) < 0.01)
  {

    square_a = pow((d(curveStartPoint, circleCenterL) - d(curveStartPoint, circleCenterR)) / 2.0f, 2);
    square_b = square_c - square_a;

    float a = sqrt(square_a);
    float b = sqrt(square_b);


    Hyperbola temp_hyperbola = new Hyperbola(square_a, square_b, square_c); 

    float startAngle = atan2((changed_S.y * a) / (b * changed_S.x), a / changed_S.x);

    if (startAngle < PI / 2.0f && startAngle > -PI / 2.0f)
    {
      temp_hyperbola.isright = true;
    } else
    {
      temp_hyperbola.isright = false;
    }


    int i = start_i;

    while (contineue_flag == true)
    {

      pt point = new pt(bottomPoints[i].x, bottomPoints[i].y);
      pt changed_Point = Apply(point, finalMat);

      Line line = new Line();
      line.figureoutLine(changed_Point, changed_circleCenterL);

      pt changed_pointOnMA = intersection_LineAndHyperbola(line, temp_hyperbola, changed_Point);

      Line line_b = new Line();
      line_b.figureoutLine(changed_pointOnMA, changed_circleCenterR);

      pt changed_pointOnArcB = intersection_LineAndArc(line_b, changed_circleCenterR, radiusR, changed_pointOnMA);

      pt pointOnArcB = Apply(changed_pointOnArcB, finalMat_inv);
      pt pointOnMA = Apply(changed_pointOnMA, finalMat_inv);



      if (!arc_b.isPointOnArc(pointOnArcB))
      {
        contineue_flag = false;

        if (i > 0)
        {
          pt point2 = arc_b.endPoint;
          pt changed_Point2 = Apply(point2, finalMat);

          Line line2 = new Line();
          line2.figureoutLine(changed_Point2, changed_circleCenterR);

          pt changed_pointOnMA2 = intersection_LineAndHyperbola(line2, temp_hyperbola, changed_Point2);

          pt pointOnMA2 = Apply(changed_pointOnMA2, finalMat_inv);

          curveStartPoint = pointOnMA2;
        }
      }

      // println(i);
      if (contineue_flag)
      {
        if (i < point_number -1)
        {

          pointset[i] = pointOnMA;

          //Calculate all coordiates when x = ....;
          LocalCoorArea oneCol = new LocalCoorArea();
          oneCol.startPoint = localCoor[i];

          pt [] tempPointSet = new pt[point_number];
          GetGlobalYInHat(tempPointSet, point, pointOnMA, pointOnArcB);
          CalculateLocalY(oneCol.allPointsInSameX, tempPointSet, oneCol.startPoint);

          CoordinateR.add(oneCol);
        } else
          curveStartPoint = pointOnMA;

        i++;


        if (i == point_number)
        {
          contineue_flag = false;
        }
        
        if (test == 1 && i - 1 < point_number -1)
        {
          line(point.x, point.y, pointOnMA.x, pointOnMA.y);
          line(pointOnArcB.x, pointOnArcB.y, pointOnMA.x, pointOnMA.y);
        }
      }
    }
    //println(i);
    beginShape();
    for (int j = start_i; j < i - 1; j++)
      vertex(pointset[j].x, pointset[j].y);
    endShape();

    return i;

  } else
  {
    println("Special Condition");
    return start_i;
  }
}


void drawArc(pt A, pt S, pt B, float b)
{
  pt O = new pt(0, 0);
  float r = (b*b-d(B, S)*d(B, S))/(2*dot(V(B, S), U(R(V(A, S)))));
  O = P(S, (U(R(V(A, S))).scaleBy(r)));
  pt E = new pt(0, 0);
  E = P(O, U(R(V(O, B), -acos(r/d(O, B)))).scaleBy(r));
  drawCircleArcInHat(S, O, E);
}

void drawArcFromPoint(pt A, pt S, pt B, float b, int leftOrRight)
{
  pt O = new pt(0, 0);
  float r = (b*b-d(B, S)*d(B, S))/(2*dot(V(B, S), U(V(A, S))));
  O = P(S, (U(V(A, S)).scaleBy(r)));
  pt E = new pt(0, 0);
  E = P(O, U(R(V(O, B), -acos(r/d(O, B)))).scaleBy(r));
  // drawCircleArcInHat(S, O, E);

  pt CircleCenter;
  CircleCenter = crossPoint(-(S.x - O.x) / (S.y - O.y), S.y - S.x * (-(S.x - O.x) / (S.y - O.y)), -(E.x - O.x) / (E.y - O.y), E.y - E.x * (-(E.x - O.x) / (E.y - O.y)));

  if (leftOrRight == 0)
  {
    Circle_ML = new CIRCLE(CircleCenter, d(CircleCenter, S));
    tangentPointL = E;

  } else if (leftOrRight == 1)
  {
    Circle_NR = new CIRCLE(CircleCenter, d(CircleCenter, S));
    tangentPointR = E;
  }
}



pt crossPoint(float k1, float m1, float k2, float m2)
{
  float x = (m2-m1)/(k1-k2);
  float y = k1*x+m1;
  pt cp = new pt(x, y);
  return cp;
}