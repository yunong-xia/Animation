//
//Modified from CSCI 5611 Thread Sample Code
//Credit to Stephen J. Guy <sjguy@umn.edu>



//Simulation Parameters
float floor = 500;
float gravity = 700;
float radius = 10;
float restLen = 40;
float mass = 1;
float k = 800; 
float kv = 400;

//Inital positions and velocities of masses
int numNodes = 6;

float ballX[] = new float[300];
float ballY[] = new float[300];
float velX[] = new float[300];
float velY[] = new float[300];
float accX[] = new float[300];
float accY[] = new float[300];

float anchorX = 200;
float anchorY = 0;


//Create Window
void setup() {
  size(400, 500, P3D);
  surface.setTitle("Balls on Spring!");
  initialize();
}

void initialize() {
  ballX[0] = 250;
  ballY[0] = 50;
  for(int i = 1; i < numNodes; i++) {
    ballX[i] = ballX[i-1] + 20;
    ballY[i] = ballY[i-1] + 40;
  }
}


void computePhysics() {
  float sx = (ballX[0] - anchorX);  
  float sy = (ballY[0] - anchorY);
  float stringLen = sqrt(sx*sx + sy*sy);
  float stringF = -k*(stringLen - restLen);
  float dirX = sx/stringLen;  
  float dirY = sy/stringLen;
  float projVel = velX[0]*dirX + velY[0]*dirY;
  float dampF = -kv*(projVel - 0);
  
  float springForceX = (stringF+dampF)*dirX;
  float springForceY = (stringF+dampF)*dirY;
  
  accX[0] = (.5*springForceX/mass);
  accY[0] = ((.5*springForceY+gravity)/mass);
  
  float prevProjVel;
  
  for(int i = 1; i < numNodes; i ++) {
    sx = ballX[i] - ballX[i-1];
    sy = ballY[i] - ballY[i-1];
    stringLen = sqrt(sx*sx + sy*sy);
    stringF = -k*(stringLen - restLen);
    dirX = sx/stringLen;
    dirY = sy/stringLen;
    
    projVel = velX[i]*dirX + velY[i]*dirY;
    prevProjVel = velX[i-1]*dirX  + velY[i-1]*dirY;
    
    dampF = -kv*(projVel - prevProjVel);
    springForceX = (stringF+dampF)*dirX;
    springForceY = (stringF+dampF)*dirY;
    
    accX[i] = (.5*springForceX/mass);
    accY[i] = ((.5*springForceY+gravity)/mass);
    
    accX[i-1] -= (.5*springForceX/mass);
    accY[i-1] -= (.5*springForceY/mass);
  }
}

void update(float dt) {
  for(int i = 0; i < numNodes; i ++) {
    velX[i] += accX[i]*dt;
    velY[i] += accY[i]*dt;
    
    ballX[i] += velX[i]*dt;
    ballY[i] += velY[i]*dt;
  }
}





void draw() {
  background(255,255,255);
  fill(0,0,0);
  pushMatrix();
  stroke(5);
  line(anchorX,anchorY,ballX[0],ballY[0]);
  translate(ballX[0],ballY[0]);
  noStroke();
  fill(0,200,10);
  sphere(radius);
  popMatrix();
  for (int i = 0; i < 10; i++){
    computePhysics();
    update(1/(10.0*frameRate));
  }
  
  for (int i = 0; i < numNodes-1; i++){
    pushMatrix();
    stroke(5);
    line(ballX[i],ballY[i],ballX[i+1],ballY[i+1]);
    translate(ballX[i+1],ballY[i+1]);
    noStroke();
    sphere(radius);
    popMatrix();
  }
}
