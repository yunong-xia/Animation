// Vector Class
class Vector {
  float x;
  float y;
  float z;
  
  Vector(float xtemp,float ytemp,float ztemp) {
    x = xtemp;
    y = ytemp;
    z = ztemp;
  }
  
  Vector() {
  x = 0;
  y = 0;
  z = 0;
  }
  
  float getX() {
    return x;
  }
  
  float getY() {
    return y;
  }
  
  float getZ() {
    return z;
  }
  
  //dot product 
  float dot(Vector anotherV) {
    return x*anotherV.x + y*anotherV.y + z*anotherV.z;
  }
  
  float dot(float xtemp, float ytemp, float ztemp){
    return x*xtemp+y*ytemp+z*ztemp;
  }
  
  //subtraction
  void sub(Vector anotherV) {
    x -= anotherV.x;
    y -= anotherV.y;
    z -= anotherV.z;
  }
  
  void sub(float xtemp, float ytemp, float ztemp) {
    x -= xtemp;
    y -= ytemp;
    z -= ztemp;
  }
  
  //add
  void add(Vector anotherV) {
    x += anotherV.x;
    y += anotherV.y;
    z += anotherV.z;
  }
  
  void add(float xtemp, float ytemp, float ztemp) {
    x += xtemp;
    y += ytemp;
    z += ztemp;
  }
  
  //division by scalar
  void div(float scalar) {
    x /= scalar;
    y /= scalar;
    z /= scalar;
  }
  
  //multiplication by scalar
  void multi(float scalar) {
    x *= scalar;
    y *= scalar;
    z *= scalar;
  }
  
  
  Vector copy() {
    Vector newVec = new Vector();
    newVec.x = x;
    newVec.y = y;
    newVec.z = z;
    return newVec;
  }
  
  float mag() {
    return sqrt(x*x+y*y+z*z);
  }
  void normalize() {
    div(mag());
  }
  
  void reflect(Vector n, float alpha) {// n is the normal vector of a surface. When this vector hit the surface, the vector will be reflected
    n.normalize();
    n.multi((1+alpha)*(this.dot(n)));
    this.sub(n); // v - 2v*n/|n|, v and n are vectors.
  }
  
  float distanceTo(Vector v) {
    return sqrt((x-v.x)*(x-v.x) + (y-v.y)*(y-v.y) + (z-v.z)*(z-v.z));
  }
  
  float distanceTo(float x2, float y2, float z2) {
    return sqrt((x-x2)*(x-x2) + (y-y2)*(y-y2) + (z-z2)*(z-z2));
  }
  
  String toString() {
    return "("+x+","+y+","+z+")";
  
  }
  
  
}



String projectTitle = "Water Simulation";








int genRate = 2000;  // particles/sec

int maxSize = 20000;

//lifespan
float maxLife = 4;
int numParticles = 0;
//Global array

Vector[] posList = new Vector[0];
Vector[] velList = new Vector[0];
color[] colList = new color[0];
float[] lifeList = new float[0];

//gravity acceleration
float g = 9.8;


float startFrame;
float elapsedTime;
float endFrame;


Vector ballPos = new Vector(645,940,-300);
int ballRadius = 60;

Vector ballPos2 = new Vector(645,950,-250);
int ballRadius2 = 40;

Vector ballPos3 = new Vector(645,950, -350);
int ballRadius3 = 40;



void pointGenerate(Vector pos, float radius, float dt) {
  float r;
  float theta;
  Vector tempVec = pos.copy();
  println(dt);
  println(floor(genRate*dt));
  for(int i = 0; i < floor(genRate*dt); i ++) {
    r = radius*sqrt(random(1));
    theta = random(2*PI);
    tempVec.add(new Vector(0, r*sin(theta), -r*cos(theta)));
    posList = (Vector[])append(posList,tempVec);
    
    tempVec = new Vector(300, 0, 0);
    tempVec.add(new Vector(0.7*random(-50,50) , 0.2*random(-200,200), 0.1*random(-100,100)));
    velList = (Vector[])append(velList,tempVec);
    
    tempVec = pos.copy();
    
    colList = (color[])append(colList, color(244));
    
    
    lifeList = (float[])append(lifeList,0);
    println(i);
  }
  numParticles += floor(genRate*dt);// update total num of particles
  
}


void moveParticle(float dt) {
  Vector tempVec = new Vector();
  for(int i = 0; i < numParticles; i++) {
    tempVec = velList[i].copy();
    tempVec.multi(dt);
    posList[i].add(tempVec);
    velList[i].add(0,g,0);
    
    if(posList[i].distanceTo(ballPos) < ballRadius) {   // obstacle of man!!!!! I use three balls to roughly simulate man's collision
      Vector normal = posList[i].copy();
      normal.sub(ballPos);
      normal.normalize();
      normal.multi(ballRadius*1.01);
      Vector temp = ballPos.copy();
      temp.add(normal);
      posList[i] = temp;
    }
    if(posList[i].distanceTo(ballPos2) < ballRadius2) {
      Vector normal = posList[i].copy();
      normal.sub(ballPos2);
      normal.normalize();
      normal.multi(ballRadius2*1.01);
      Vector temp = ballPos2.copy();
      temp.add(normal);
      posList[i] = temp;
    }
    if(posList[i].distanceTo(ballPos3) < ballRadius3) {
      Vector normal = posList[i].copy();
      normal.sub(ballPos3);
      normal.normalize();
      normal.multi(ballRadius3*1.01);
      Vector temp = ballPos3.copy();
      temp.add(normal);
      posList[i] = temp;
    }
    
    
    if(posList[i].y > 1000){ // hit the ground, then bounce up
      velList[i].y *= - 0.2;
      posList[i].y = 1000;
    }
    
    
    if(lifeList[i] > 2 && lifeList[i] <= 3 ) {  // color change
      colList[i]= color(135,206,235);
    }
    
    if(lifeList[i] > 3) {
      colList[i] = color(0,191,255);
    }
   
    
    
    lifeList[i] += dt;
    
  }
}



void particleDeath() {  // particle death function
  int[] liveP = new int[0];
  for(int i = 0; i < numParticles; i ++) { // extract index of those who live
    if(lifeList[i] < maxLife) {
      liveP = append(liveP, i);
    }
  }
  int liveNum = liveP.length;
  
  Vector[] tempList1 = new Vector[liveNum];
  Vector[] tempList2 = new Vector[liveNum];
  float[] tempList3 = new float[liveNum];
  for(int j = 0; j < liveNum; j++) {    // cope the living particles' information to temp arrays
    tempList1[j] = posList[liveP[j]];
    tempList2[j] = velList[liveP[j]];
    tempList3[j] = lifeList[liveP[j]];
  }
  
  for(int k = 0; k < liveNum; k++) {
    posList[k] = tempList1[k];
    velList[k] = tempList2[k];
    lifeList[k] = tempList3[k];
  }
  
  for(int p = 0; p < numParticles - liveNum; p++) {
    posList = (Vector[])shorten(posList);
    velList = (Vector[])shorten(velList);
    lifeList = shorten(lifeList);
  }
  
  
  numParticles = liveNum;
}




PShape s;
PShape h;







void setup() {
  size(1600,1000,P3D);
  s = loadShape("Rock.obj");
  h = loadShape("basicman.obj");
  s.scale(0.0013);
  s.rotateX(PI);
  s.rotateY(-PI/2.0);
  s.setFill(color(85, 65, 36));
  //s.rotateX(PI);
  
  h.scale(12);
  h.rotateX(PI);
  h.rotateY(-PI/2.0);
  
  
  
  perspective(PI/4.0,(float)width/height,1,10000);
  noSmooth();
  strokeWeight(5);
}


void drawScene() {
  background(255,255,255);
  lights();
  
  pushMatrix();//human
  translate(645,1000,-300);
  shape(h);
  popMatrix();
  
  pushMatrix();//mountain
  translate(0,300,-300);
  shape(s);
  //rotateY(PI);
  popMatrix();
  
  
  
  
  Vector pos;
  
  for(int i = 0; i < numParticles; i++) {
    pos = posList[i];
    stroke(colList[i]);
    point(pos.getX(),pos.getY(),pos.getZ());
  }
  
  
  noStroke();
  fill(color(0,191,255));
  translate(1000,1050,-300);
  box(1200,50,300);
  
  
}


float z = 0;

void draw() {
  float startFrame = millis();
  //Compute the physics update
  pointGenerate(new Vector(200, 300, -300), 100, 0.015);
   
  moveParticle(0.015);  //Question: Should this be a fixed number?
  float endPhysics = millis();
  
  if(keyPressed && key == 'q') {
    z -= 10;
  }
  if(keyPressed && key == 'w') {
    z += 10;
  }
  camera(5*(mouseX-800)+800, 5*(mouseY-500)+800, z, 800, 500, -150, 
       0.0, 1.0, 0.0);
  
  //rotateX(map(mouseY, 0, height, -PI, PI));
  //rotateY(map(mouseX, 0, width, -PI, PI));
  //Draw the scene
  drawScene();

  float endFrame = millis();
  //pointGenerate(new Vector(200, 300, -300), 100);
  particleDeath();
  
  String runtimeReport = "Frame: "+str(endFrame-startFrame)+"ms,"+
        " Physics: "+ str(endPhysics-startFrame)+"ms,"+
        " FPS: "+ str(round(frameRate)) + ", Num of particles: " + str(numParticles) + "\n";
  surface.setTitle(projectTitle+ "  -  " +runtimeReport);
  //print(runtimeReport);
}  
