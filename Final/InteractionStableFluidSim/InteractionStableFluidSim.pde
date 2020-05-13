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


int IX(int x, int y) {
  x = constrain(x, 0, N-1);
  y = constrain(y, 0, N-1);
  return x + (y * N);
}




void addDens(int x, int y, int amount) {
  density[IX(x, y)] += amount;
}


void addVel(int x, int y, int amountX, int amountY) {
  vx[IX(x, y)] += amountX;
  vy[IX(x, y)] += amountY;
}



void renderUI() {
  colorMode(RGB, 255);
  for(int i = 1; i <= N; i ++) {
    for(int j = 1; j <= N; j ++) {
      float x = (i-1) * scale;
      float y = (j-1) * scale;
      float d = density[IX(i, j)];
      fill(150,(d + 50) % 255,d);
      noStroke();
      square(x,y,scale);
    }
  }
}



void settings() {
  size(scale * N, scale * N);
}
void setup() {
}

void mouseDragged() {
  addDens(mouseX/scale +1, mouseY/scale +1, 1000);
  addVel(mouseX/scale +1, mouseY/scale +1, mouseX-pmouseX, mouseY-pmouseY);
}


void draw() {
  
  
  
  velStep();
  densStep();

  
  renderUI();

}
