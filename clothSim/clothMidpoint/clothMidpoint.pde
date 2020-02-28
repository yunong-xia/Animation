//
//Modified from CSCI 5611 Thread Sample Code
//Credit to Stephen J. Guy <sjguy@umn.edu>


// Camera Class
// Created for CSCI 5611 by Liam Tyler and Stephen Guy

class Camera
{
  Camera()
  {
    position      = new PVector( 0, 0, 0 ); // initial position
    theta         = 0; // rotation around Y axis. Starts with forward direction as ( 0, 0, -1 )
    phi           = 0; // rotation around X axis. Starts with up direction as ( 0, 1, 0 )
    moveSpeed     = 50;
    turnSpeed     = 1.57; // radians/sec
    
    // dont need to change these
    negativeMovement = new PVector( 0, 0, 0 );
    positiveMovement = new PVector( 0, 0, 0 );
    negativeTurn     = new PVector( 0, 0 ); // .x for theta, .y for phi
    positiveTurn     = new PVector( 0, 0 );
    fovy             = PI / 4;
    aspectRatio      = width / (float) height;
    nearPlane        = 0.1;
    farPlane         = 10000;
  }
  
  void Update( float dt )
  {
    theta += turnSpeed * (negativeTurn.x + positiveTurn.x) * dt;
    
    // cap the rotation about the X axis to be less than 90 degrees to avoid gimble lock
    float maxAngleInRadians = 85 * PI / 180;
    phi = min( maxAngleInRadians, max( -maxAngleInRadians, phi + turnSpeed * ( negativeTurn.y + positiveTurn.y ) * dt ) );
    
    // re-orienting the angles to match the wikipedia formulas: https://en.wikipedia.org/wiki/Spherical_coordinate_system
    // except that their theta and phi are named opposite
    float t = theta + PI / 2;
    float p = phi + PI / 2;
    PVector forwardDir = new PVector( sin( p ) * cos( t ),   cos( p ),   -sin( p ) * sin ( t ) );
    PVector upDir      = new PVector( sin( phi ) * cos( t ), cos( phi ), -sin( t ) * sin( phi ) );
    PVector rightDir   = new PVector( cos( theta ), 0, -sin( theta ) );
    PVector velocity   = new PVector( negativeMovement.x + positiveMovement.x, negativeMovement.y + positiveMovement.y, negativeMovement.z + positiveMovement.z );
    position.add( PVector.mult( forwardDir, moveSpeed * velocity.z * dt ) );
    position.add( PVector.mult( upDir,      moveSpeed * velocity.y * dt ) );
    position.add( PVector.mult( rightDir,   moveSpeed * velocity.x * dt ) );
    
    aspectRatio = width / (float) height;
    perspective( fovy, aspectRatio, nearPlane, farPlane );
    camera( position.x, position.y, position.z,
            position.x + forwardDir.x, position.y + forwardDir.y, position.z + forwardDir.z,
            upDir.x, upDir.y, upDir.z );
  }
  
  // only need to change if you want difrent keys for the controls
  void HandleKeyPressed()
  {
    if ( key == 'w' ) positiveMovement.z = 1;
    if ( key == 's' ) negativeMovement.z = -1;
    if ( key == 'a' ) negativeMovement.x = -1;
    if ( key == 'd' ) positiveMovement.x = 1;
    if ( key == 'q' ) positiveMovement.y = 1;
    if ( key == 'e' ) negativeMovement.y = -1;
    
    if ( keyCode == LEFT )  negativeTurn.x = 1;
    if ( keyCode == RIGHT ) positiveTurn.x = -1;
    if ( keyCode == UP )    positiveTurn.y = 1;
    if ( keyCode == DOWN )  negativeTurn.y = -1;
  }
  
  // only need to change if you want difrent keys for the controls
  void HandleKeyReleased()
  {
    if ( key == 'w' ) positiveMovement.z = 0;
    if ( key == 'q' ) positiveMovement.y = 0;
    if ( key == 'd' ) positiveMovement.x = 0;
    if ( key == 'a' ) negativeMovement.x = 0;
    if ( key == 's' ) negativeMovement.z = 0;
    if ( key == 'e' ) negativeMovement.y = 0;
    
    if ( keyCode == LEFT  ) negativeTurn.x = 0;
    if ( keyCode == RIGHT ) positiveTurn.x = 0;
    if ( keyCode == UP    ) positiveTurn.y = 0;
    if ( keyCode == DOWN  ) negativeTurn.y = 0;
  }
  
  // only necessary to change if you want different start position, orientation, or speeds
  PVector position;
  float theta;
  float phi;
  float moveSpeed;
  float turnSpeed;
  
  // probably don't need / want to change any of the below variables
  float fovy;
  float aspectRatio;
  float nearPlane;
  float farPlane;  
  PVector negativeMovement;
  PVector positiveMovement;
  PVector negativeTurn;
  PVector positiveTurn;
};

// Camera finished ----------------------------------------------


















//Simulation Parameters
float floor = 500;
float gravity = 400;
float radius = 10;
float restLen = 20;
float diagRestLen = restLen*sqrt(2);
float mass = 1;
float k = 1900; 
float kv = 1100;

//Inital positions and velocities of masses
int numNodes = 30;

// balls are those nodes on the cloth
float ballX[][] = new float[30][30];
float ballY[][] = new float[30][30];
float ballZ[][] = new float[30][30];
float velX[][] = new float[30][30];
float velY[][] = new float[30][30];
float velZ[][] = new float[30][30];
float accX[][] = new float[30][30];
float accY[][] = new float[30][30];
float accZ[][] = new float[30][30];


// sphere position initialization
float sphereX = 0;
float sphereY = 500;
float sphereZ = -1500;
float sphereRadius = 200;


Camera camera;

//Create Window
void setup() {
  size(800, 600, P3D);
  camera = new Camera();
  img = loadImage("texture.jpg");
  surface.setTitle("Cloth");
  initialize();
}

void keyPressed()
{
  camera.HandleKeyPressed();
}

void keyReleased()
{
  camera.HandleKeyReleased();
}


void initialize() {
  
  // set up all the anchors
  for(int k = 0; k < numNodes; k++) {
    ballX[0][k] = -300 + k*20;
    ballZ[0][k] = -2000;
  }
  
  // set up rest of the nodes
  for(int i = 1; i < numNodes; i++) {
    for(int j = 0; j < numNodes; j++) {
      ballX[i][j] = ballX[i-1][j] + 20 + random(-10,10);
      ballY[i][j] = ballY[i-1][j] + 20 + random(-10,10);
      ballZ[i][j] = ballZ[i-1][j] + 20 + random(-10,10);
    }
  }
}


void computePhysics() {
  float sx, sy, sz;
  float stringLen;
  float dirx,diry,dirz;
  
  float stringF;
  
  float projVel, prevProjVel;
  float dampF;
  
  float springForceX, springForceY, springForceZ;
  
  
  // Based on our implementation method, we must intialized the most left thread acc
  for(int i = 1; i < numNodes; i ++) {
    accX[i][0] = 0;
    accY[i][0] = 0;
    accZ[i][0] = 0;
  }
  
  // horizontal. Since no anchors, we only need to care about spring forces on horizontal strings.
  for(int i = 1; i < numNodes; i++) {
    for(int j = 1; j < numNodes; j++){
      sx = ballX[i][j] - ballX[i][j-1];
      sy = ballY[i][j] - ballY[i][j-1];
      sz = ballZ[i][j] - ballZ[i][j-1];
      stringLen = sqrt(sx*sx + sy*sy + sz*sz);
      stringF = -k*(stringLen - restLen);
      dirx = sx/stringLen;
      diry = sy/stringLen;
      dirz = sz/stringLen;
      
      projVel = velX[i][j]*dirx + velY[i][j]*diry + velZ[i][j]*dirz;
      
      prevProjVel = velX[i][j-1]*dirx  + velY[i][j-1]*diry + velZ[i][j-1]*dirz;
      
      dampF = -kv*(projVel - prevProjVel);
      
      springForceX = (stringF+dampF)*dirx;
      springForceY = (stringF+dampF)*diry;
      springForceZ = (stringF+dampF)*dirz;
      
      accX[i][j] = (.5*springForceX/mass);
      accY[i][j] = (.5*springForceY/mass);
      accZ[i][j] = (.5*springForceZ/mass);
    
      accX[i][j-1] -= (.5*springForceX/mass);
      accY[i][j-1] -= (.5*springForceY/mass);
      accZ[i][j-1] -= (.5*springForceZ/mass);
    }
  }
  
  
  // verticle; we dont need to update those anchor. 
  for(int i = 1; i < numNodes; i++) {
    for(int j = 0; j < numNodes; j++){
      sx = ballX[i][j] - ballX[i-1][j];
      sy = ballY[i][j] - ballY[i-1][j];
      sz = ballZ[i][j] - ballZ[i-1][j];
      stringLen = sqrt(sx*sx + sy*sy + sz*sz);
      stringF = -k*(stringLen - restLen);
      dirx = sx/stringLen;
      diry = sy/stringLen;
      dirz = sz/stringLen;
      
      projVel = velX[i][j]*dirx + velY[i][j]*diry + velZ[i][j]*dirz;
      
      prevProjVel = velX[i-1][j]*dirx  + velY[i-1][j]*diry + velZ[i-1][j]*dirz;
      
      dampF = -kv*(projVel - prevProjVel);
      
      springForceX = (stringF+dampF)*dirx;
      springForceY = (stringF+dampF)*diry;
      springForceZ = (stringF+dampF)*dirz;
      
      
      accX[i][j] += (.5*springForceX/mass);
      accY[i][j] += ((.5*springForceY+gravity)/mass);
      accZ[i][j] += (.5*springForceZ/mass);
    
      accX[i-1][j] -= (.5*springForceX/mass);
      accY[i-1][j] -= (.5*springForceY/mass);
      accZ[i-1][j] -= (.5*springForceZ/mass);
    }
  }
  
  // diagnal string: top left to bot right
  for(int i = 1; i < numNodes; i++) {
    for(int j = 1; j < numNodes; j++){
      sx = ballX[i][j] - ballX[i-1][j-1];
      sy = ballY[i][j] - ballY[i-1][j-1];
      sz = ballZ[i][j] - ballZ[i-1][j-1];
      stringLen = sqrt(sx*sx + sy*sy + sz*sz);
      stringF = -k*(stringLen - diagRestLen);
      dirx = sx/stringLen;
      diry = sy/stringLen;
      dirz = sz/stringLen;
      
      projVel = velX[i][j]*dirx + velY[i][j]*diry + velZ[i][j]*dirz;
      
      prevProjVel = velX[i-1][j-1]*dirx  + velY[i-1][j-1]*diry + velZ[i-1][j-1]*dirz;
      
      dampF = -kv*(projVel - prevProjVel);
      
      springForceX = (stringF+dampF)*dirx;
      springForceY = (stringF+dampF)*diry;
      springForceZ = (stringF+dampF)*dirz;
      
      accX[i][j] += (.5*springForceX/mass);
      accY[i][j] += (.5*springForceY/mass);
      accZ[i][j] += (.5*springForceZ/mass);
    
      accX[i-1][j-1] -= (.5*springForceX/mass);
      accY[i-1][j-1] -= (.5*springForceY/mass);
      accZ[i-1][j-1] -= (.5*springForceZ/mass);
    }
  }
  
  // diagnal string: top right to bot left
  for(int i = 1; i < numNodes; i++) {
    for(int j = 0; j < numNodes-1; j++){
      sx = ballX[i][j] - ballX[i-1][j+1];
      sy = ballY[i][j] - ballY[i-1][j+1];
      sz = ballZ[i][j] - ballZ[i-1][j+1];
      stringLen = sqrt(sx*sx + sy*sy + sz*sz);
      stringF = -k*(stringLen - diagRestLen);
      dirx = sx/stringLen;
      diry = sy/stringLen;
      dirz = sz/stringLen;
      
      projVel = velX[i][j]*dirx + velY[i][j]*diry + velZ[i][j]*dirz;
      
      prevProjVel = velX[i-1][j+1]*dirx  + velY[i-1][j+1]*diry + velZ[i-1][j+1]*dirz;
      
      dampF = -kv*(projVel - prevProjVel);
      
      springForceX = (stringF+dampF)*dirx;
      springForceY = (stringF+dampF)*diry;
      springForceZ = (stringF+dampF)*dirz;
      
      accX[i][j] += (.5*springForceX/mass);
      accY[i][j] += (.5*springForceY/mass);
      accZ[i][j] += (.5*springForceZ/mass);
    
      accX[i-1][j+1] -= (.5*springForceX/mass);
      accY[i-1][j+1] -= (.5*springForceY/mass);
      accZ[i-1][j+1] -= (.5*springForceZ/mass);
    }
  }
}



void collision() {
  float d;
  float sx, sy, sz;
  float dirx, diry, dirz;
  float bounceX, bounceY, bounceZ;
  for(int i = 0; i < numNodes; i ++) {
    for(int j = 0; j < numNodes; j ++) { 
      sx = ballX[i][j] - sphereX;
      sy = ballY[i][j] - sphereY;
      sz = ballZ[i][j] - sphereZ;
      
      d = sqrt(sx*sx + sy*sy + sz*sz);
      if(d < sphereRadius + .09) {
        dirx = sx/d;
        diry = sy/d;
        dirz = sz/d;
        
        bounceX = (velX[i][j]*dirx + velY[i][j]*diry + velZ[i][j]*dirz)*dirx;
        bounceY = (velX[i][j]*dirx + velY[i][j]*diry + velZ[i][j]*dirz)*diry;
        bounceZ = (velX[i][j]*dirx + velY[i][j]*diry + velZ[i][j]*dirz)*dirz;
        
        velX[i][j] -= 1.5*bounceX;
        velY[i][j] -= 1.5*bounceY;
        velZ[i][j] -= 1.5*bounceZ;
        
        ballX[i][j] += (.1 + sphereRadius - d)*dirx;
        ballY[i][j] += (.1 + sphereRadius - d)*diry;
        ballZ[i][j] += (.1 + sphereRadius - d)*dirz;
      }
    }
  }
}





void update(float dt) {
  for(int i = 1; i < numNodes; i++) {
    for(int j = 0; j < numNodes; j++) {
      velX[i][j] += accX[i][j]*dt;
      velY[i][j] += accY[i][j]*dt;
      velZ[i][j] += accZ[i][j]*dt;
      
      ballX[i][j] += velX[i][j]*dt;
      ballY[i][j] += velY[i][j]*dt;
      ballZ[i][j] += velZ[i][j]*dt;
    }
  }
}


String projectTitle = "cloth Midpoint ";
PImage img;

  float vOldX[][] = new float[30][30];
  float vOldY[][] = new float[30][30];
  float vOldZ[][] = new float[30][30];
void draw() {
  float startFrame = millis(); //Time how long various components are taking
  
  background(255,255,255);
  pushMatrix();
  lights();
  noStroke();
  fill(50, 155, 55);
  translate(sphereX,sphereY,sphereZ);
  sphere(sphereRadius);
  popMatrix();
  
  //Compute the physics update
  camera.Update( 5.0/frameRate );
  
  if(keyPressed){
    if(key == 'z') {
      sphereZ -= 10;
    }  
    if(key == 'x') {
      sphereZ += 10;
    }
  }
  
  //float vOldX[][] = new float[30][30];
  //float vOldY[][] = new float[30][30];
  //float vOldZ[][] = new float[30][30];
  
  for (int i = 0; i < 90; i++){
    // firstly, store the original velocity
    for(int j = 1; j < numNodes; j++) {
      for(int k = 0; k < numNodes; k++) {
        vOldX[j][k] = velX[j][k];
        vOldY[j][k] = velY[j][k];
        vOldZ[j][k] = velZ[j][k];
      }
    }
    computePhysics();
    update(.5/(90.0*frameRate)); // update to half step
    println("hello");
    computePhysics();// get the half step acc
    // restore velocity
    for(int j = 1; j < numNodes; j++) {
      for(int k = 0; k < numNodes; k++) {
        velX[j][k] = vOldX[j][k];
        velY[j][k] = vOldY[j][k];
        velZ[j][k] = vOldZ[j][k];
      }
    }
    update(1/(90.0*frameRate)); // update velocity using half step acc
    collision();
  }
  
  
  noStroke();
  float endPhysics = millis();
  
  
  float pieceWidth = img.width/29;
  float pieceHeight = img.height/29;
  for (int i = 0; i < numNodes-1; i++){
    for(int j = 0; j < numNodes-1; j++){
      beginShape();
      texture(img);
      //line(ballX[i][j],ballY[i][j],ballZ[i][j],ballX[i+1][j],ballY[i+1][j],ballZ[i+1][j]);
      //line(ballX[i][j],ballY[i][j],ballZ[i][j],ballX[i][j+1],ballY[i][j+1],ballZ[i][j+1]);
      
      vertex(ballX[i][j], ballY[i][j], ballZ[i][j], i*pieceWidth, j*pieceHeight);
      vertex(ballX[i+1][j], ballY[i+1][j], ballZ[i+1][j], (i+1)*pieceWidth, j*pieceHeight);
      vertex(ballX[i+1][j+1], ballY[i+1][j+1], ballZ[i+1][j+1], (i+1)*pieceWidth, (j+1)*pieceHeight);
      vertex(ballX[i][j+1], ballY[i][j+1], ballZ[i][j+1], i*pieceWidth, (j+1)*pieceHeight);
      endShape();
      
      //point(ballX[i][j],ballY[i][j],ballZ[i][j]);
    }
  }

  
  //Draw the scene
  float endFrame = millis();
  
  String runtimeReport = "Frame: "+str(endFrame-startFrame)+"ms,"+
        " Physics: "+ str(endPhysics-startFrame)+"ms,"+
        " FPS: "+ str(round(frameRate)) +"\n";
  surface.setTitle(projectTitle+ "  -  " +runtimeReport);
  //print(runtimeReport);

}
