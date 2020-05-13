//grids
int N = 128;
int scale = 4;
//constants
float diff = 0;
float visc = 0.000001;

float dt = 0.1;

//density
float[] density = new float[(N+2) * (N+2)];
float[] density_prev = new float[(N+2) * (N+2)];

//velocity
float[] vx = new float[(N+2) * (N+2)];
float[] vy = new float[(N+2) * (N+2)];
float[] vx_prev = new float[(N+2) * (N+2)];
float[] vy_prev = new float[(N+2) * (N+2)];



//For fire
float[] heat = new float[(N+2) * (N+2)];
float[] fuel = new float[(N+2) * (N+2)];
float[] oxy = new float[(N+2) * (N+2)];
float[] oxy_prev = new float[(N+2) * (N+2)];
float energyBarrier = 7000;
float rateConst = 0.001;
float maxRate = 1;
float exothermicness = 2;
float convectiveness = 3;
float maxT = 46;
float coolRate = .1;
float[] r = new float[(N+2) * (N+2)]; 
float[] g = new float[(N+2) * (N+2)];
float[] b = new float[(N+2) * (N+2)];

int IX(int x, int y) {
  x = constrain(x, 0, N-1);
  y = constrain(y, 0, N-1);
  return x + (y * N);
}




void addDens(int x, int y, int amount) {
  density[IX(x, y)] += amount;
}

void addOxy(int x, int y, int amount) {
  oxy[IX(x, y)] += amount;
}


void addVel(int x, int y, int amountX, int amountY) {
  vx[IX(x, y)] += amountX;
  vy[IX(x, y)] += amountY;
}

void addFuel(int x, int y, int amount) {
  fuel[IX(x,y)] += amount;
}

void renderUI() {
  for(int i = 1; i <= N; i ++) {
    for(int j = 1; j <= N; j ++) {
      float x = (i-1) * scale;
      float y = (j-1) * scale;
      float d = oxy[IX(i, j)];
      fill(d);
      noStroke();
      square(x,y,scale);
    }
  }
}

void fireRender() {
  fireRGB();
  for(int i = 1; i <= N; i ++) {
    for(int j = 1; j <= N; j ++) {
      float x = (i-1) * scale;
      float y = (j-1) * scale;
      fill(255*r[IX(i,j)],255*g[IX(i,j)],255*b[IX(i,j)]);
      noStroke();
      square(x,y,scale);
    }
  }
}

void settings() {
  size(scale * N, scale * N);
}

void setup() {
  for(int i = 1; i <= N; i ++) {
    for(int j = 1; j <= N; j ++) {
      oxy[IX(i,j)] = 1;
    }
  }
}

char mode;

void draw() {
   float startFrame = millis();
  if(keyPressed) {
    if(key == 'o' || key == 'O' || key == 'f' || key == 'F')
      mode = key;
  }
  if(mousePressed == true) {
    if(key == 'o' || key == 'O'){
      addOxy(mouseX/scale+1, mouseY/scale+1, 10);
      addVel(mouseX/scale+1, mouseY/scale+1, mouseX-pmouseX, mouseY-pmouseY);
    }
    if(key == 'f' || key == 'F') {
      addFuel(mouseX/scale+1, mouseY/scale+1, 100);
    }
  }
  
  
  
  velStep();
  oxyStep();
  fireStep();
  
  //renderUI();
  fireRender();
float endFrame = millis();
 String runtimeReport = "Frame: "+str(endFrame-startFrame)+"ms,"+
        " FPS: "+ str(round(frameRate)) + " N: " + str(N) + "\n";
  surface.setTitle("Fire"+ "  -  " +runtimeReport);


}
