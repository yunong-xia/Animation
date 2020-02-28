
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












int nx = 20;
float dx = 35.0;
float[] h = new float[nx];
float[] uh = new float[nx];
float totlen = nx*dx;
float[] hm = new float[nx]; 
float[] uhm = new float[nx];
float g = 20;
float damp = .9;
Camera camera;



void setup() {
  size(800, 600, P3D);
  camera = new Camera();
  init();
}


void init() {
  for(int i = 0; i < nx; i++) {
    h[i] = totlen*.7 - i*10;
  }
}


void keyPressed()
{
  camera.HandleKeyPressed();
}

void keyReleased()
{
  camera.HandleKeyReleased();
}




void computePhysics(float dt) {
  for(int i = 0; i < nx-1; i++)  {
    hm[i] = (h[i]+h[i+1])/2.0 -(dt/2.0)*(uh[i+1]-uh[i])/dx;

    uhm[i] = (uh[i]+uh[i+1])/2.0 -(dt/2.0)*(uh[i+1]*uh[i+1]/h[i+1] + .5*g*h[i+1]*h[i+1] -uh[i]*uh[i]/h[i] -.5*g*h[i]*h[i])/dx;
    
  }
  
  for(int i = 0; i < nx-2 ; i++) { 
    h[i+1] -= dt*(uhm[i+1]-uhm[i])/dx;
    uh[i+1] -= dt*(damp*uh[i+1] + uhm[i+1]*uhm[i+1]/hm[i+1] + .5*g*hm[i+1]*hm[i+1] - uhm[i]*uhm[i]/hm[i] -.5*g*hm[i]*hm[i])/dx;
  }
  
  h[0] = h[1];
  h[nx-1] = h[nx-2];
  uh[0] = -uh[1];
  uh[nx-1] = -uh[nx-2];
}

float left = -totlen/2;
float dt = 0.0001;

void draw() { 
  background(255,255,255);
  lights();
  
  pushMatrix();
  translate(0,0,-2000);
  stroke(154);
  noFill();
  box(totlen,totlen,totlen);
  popMatrix();
  
  camera.Update( 1.0/frameRate );
  
  for (int i = 0; i < 1/dt; i++){
    computePhysics(4*dt/frameRate);
  }
  
  
  float x1,x2;
  for(int i = 0; i < nx ; i++) {
    pushMatrix();
    x1 = left+i*dx;
    x2 = left+(i+1)*dx;
    translate((x1+x2)/2, (-h[i]/2) + totlen*.5, -2000);
    fill(50, 55, 100);
    noStroke(); 
    box(dx,h[i],totlen);
    
    popMatrix();
  }
  
}
