// LecturesInGraphics: vector interpolation
// Template for sketches
// Author: Jarek ROSSIGNAC
PImage KimPix; // picture of author's face, should be: data/pic.jpg in sketch folder
PImage MartinPix; // picture of author's face, should be: data/pic.jpg in sketch folder

//**************************** global variables ****************************
pts P = new pts();
float t=0.5, f=0;
Boolean animate=true, linear=true, circular=true, beautiful=true;
boolean b1=true, b2=true, b3=true, b4=true;
float len=200; // length of arrows

//**************************** initialization ****************************
void setup() {               // executed once at the begining 
  size(800, 800, P2D);            // window size
  frameRate(30);             // render 30 frames per second
  smooth();                  // turn on antialiasing
  KimPix = loadImage("data/Kim.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  MartinPix = loadImage("data/Martin.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  P.declare().resetOnCircle(6);
  P.loadPts("data/pts");
  }

//**************************** display current frame ****************************
void draw() {      // executed at each frame
  background(white); // clear screen and paints white background
  if(snapPic) beginRecord(PDF,PicturesOutputPath+"/P"+nf(pictureCounter++,3)+".pdf"); // start recording for PDF image capture

  
  if(animating) {t+=0.01; if(t>=1) {t=1; animating=false;}} 

  strokeWeight(2);
  pt S=P.G[0], E=P.G[1], L=P.G[2], R=P.G[3]; // named points defined for convenience
  pt M=P.G[4], N=P.G[5];
  stroke(black); edge(S,L); edge(E,R);
  float s=d(S,L), e=d(E,R); // radii of control circles computged from distances
  CIRCLE Cs = C(S,s), Ce = C(E,e); // declares circles
  //stroke(green); Cs.drawCirc(); stroke(red); Ce.drawCirc(); // draws both circles in green and red
 

  strokeWeight(5);
  if(b1)
    {
      
      stroke(blue);
      pt O = crossPoint(-(L.x-S.x)/(L.y-S.y),L.x*(L.x-S.x)/(L.y-S.y)+L.y, -(N.x-L.x)/(N.y-L.y), (N.x+L.x)*(N.x-L.x)/(2*(N.y-L.y))+(N.y+L.y)/2); 
      drawArcFromPoint(O,N,E,e,1);

      pt Oprime = crossPoint(-(R.x-E.x)/(R.y-E.y),R.x*(R.x-E.x)/(R.y-E.y)+R.y, -(M.x-R.x)/(M.y-R.y), (M.x+R.x)*(M.x-R.x)/(2*(M.y-R.y))+(M.y+R.y)/2);
      drawArcFromPoint(Oprime,M,S,s,0);
      
      drawOriCircleArc();
      
      CreateCoordinateR();
      
    }
    
  if(b2)
    {
     // stroke(magenta);
    
    // your code for part 2
    }

   stroke(black);   strokeWeight(1);

   if(b3)
     {
     fill(black); scribeHeader("t="+nf(t,1,2),2); noFill();
     // your code for part 4
      strokeWeight(3); stroke(blue); 
     //    drawCircleInHat(Mr,M,Ml);  
     }
   strokeWeight(1);
  
  noFill(); stroke(black); P.draw(white); // paint empty disks around each control point
  fill(black); label(S,V(-1,-2),"S"); label(E,V(-1,-2),"E"); label(L,V(-1,-2),"L"); label(R,V(-1,-2),"R");label(M,V(-1,-2),"M");label(N,V(-1,-2),"N"); noFill(); // fill them with labels
  
  if(snapPic) {endRecord(); snapPic=false;} // end saving a .pdf of the screen

  fill(black); displayHeader();
  if(scribeText && !filming) displayFooter(); // shows title, menu, and my face & name 
  if(filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++,4)+".tif"); // saves a movie frame 
  change=false; // to avoid capturing movie frames when nothing happens
  }  // end of draw()

  
//**************************** user actions ****************************
void keyPressed() { // executed each time a key is pressed: sets the "keyPressed" and "key" state variables, 
                    // till it is released or another key is pressed or released
  if(key=='?') scribeText=!scribeText; // toggle display of help text and authors picture
  if(key=='!') snapPicture(); // make a picture of the canvas and saves as .jpg image
  if(key=='`') snapPic=true; // to snap an image of the canvas and save as zoomable a PDF
  if(key=='~') {filming=!filming; } // filming on/off capture frames into folder FRAMES 
  if(key=='a') {animating=true; f=0; t=0;}  
  if(key=='s') P.savePts("data/pts");   
  if(key=='l') P.loadPts("data/pts"); 
  if(key=='1') b1=!b1;
  if(key=='2') b2=!b2;
  if(key=='3') b3=!b3;
  if(key=='4') b4=!b4;
  if(key=='Q') exit();  // quit application
  change=true; // to make sure that we save a movie frame each time something changes
  }

void mousePressed() {  // executed when the mouse is pressed
  P.pickClosest(Mouse()); // used to pick the closest vertex of C to the mouse
  change=true;
  }

void mouseDragged() {
  if (!keyPressed || (key=='a')) P.dragPicked();   // drag selected point with mouse
  if (keyPressed) {
      if (key=='.') t+=2.*float(mouseX-pmouseX)/width;  // adjust current frame   
      if (key=='t') P.dragAll(); // move all vertices
      if (key=='r') P.rotateAllAroundCentroid(Mouse(),Pmouse()); // turn all vertices around their center of mass
      if (key=='z') P.scaleAllAroundCentroid(Mouse(),Pmouse()); // scale all vertices with respect to their center of mass
      }
  change=true;
  }  

//**************************** text for name, title and help  ****************************
String title ="6491 2017 P1: Caplets", 
       name ="Student: Luyao Huang, Han Zhang",
       menu="?:(show/hide) help, s/l:save/load control points, a: animate, `:snap picture, ~:(start/stop) recording movie frames, Q:quit",
       guide="click and drag to edit, press '1' or '2' to toggle LINEAR/CIRCULAR,"; // help info


  
float timeWarp(float f) {return sq(sin(f*PI/2));}