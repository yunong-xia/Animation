int mapSize = 800;
float agentRad = 20;
float obstRad = 80;

//configuration space
float cSpaceSide = mapSize - 2*agentRad;
int numConfig = 200;
float[] config_x = new float[numConfig];
float[] config_y = new float[numConfig];

//obstacles
int numObst = 3;
float[] obst_x = new float[numObst]; // circle obstacles
float[] obst_y = new float[numObst]; 

int numVWall = 2;
int numHWall = 2;
float[] vWall = new float[numVWall]; // vertical, (e.g. right wall and left wall)
float[] hWall = new float[numHWall]; // horizontal wall. (e.g. top wall and bottom wall)

//////////////////////////////////////////////////////////////////////////////////////////////////////
//start and goal information(can be modified)
float start_x = agentRad;//(-mapSize/2)+agentRad;
float start_y = (mapSize/2)-agentRad;

float goal_x = -agentRad;//(mapSize/2)-agentRad;
float goal_y = (-mapSize/2)+agentRad;

int globalStart = 0;
int globalGoal = numConfig-1;

// graph properties. Constructed by prm
ArrayList<Integer>[] neighbors = new ArrayList[numConfig];
//////////////////////////////////////////////////////////////////////////////////////////////////////
// boids variables
int numAgent = 9;
float[] px = new float[numAgent];
float[] py = new float[numAgent];
float[] vx = new float[numAgent];
float[] vy = new float[numAgent];
//float[] gvx = new float[numAgent];
//float[] gvy = new float[numAgent];

// acceleration
float[] ax = new float[numAgent];
float[] ay = new float[numAgent];

int[] nextTarget = new int[numAgent];
int[] prevTarget = new int[numAgent];

// expected speed
float expectedSpeed = 300;

// formula constants 
float gfk = 2; // goal force K
float sfk = 9000; // seperation force K

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void initObstacles() {
  obst_x[0] = -250;
  obst_y[0] = 0;
  obst_x[1] = 250;
  obst_y[1] = 0;
  obst_x[2] = 0;
  obst_y[2] = 0;
  
  vWall[0] = -0;
  vWall[1] = 400;
  hWall[0] = -400;
  hWall[1] = 400;
}





void samplingConfig() {
  int counter = 0;
  while(counter < numConfig){
    float x = random(-(cSpaceSide)/2, cSpaceSide/2);
    float y = random(-(cSpaceSide)/2, cSpaceSide/2);
    
    // then check whether the (x,y) is obstacle-free
    boolean free = true;
    for(int i = 0; i < numObst; i++) {
      float distSqr = (x-obst_x[i])*(x-obst_x[i]) + (y-obst_y[i])*(y-obst_y[i]);
      free = free && (distSqr > obstRad*obstRad);
    }
    if(free){
      config_x[counter] = x;
      config_y[counter] = y;
      counter ++;
    }
  }
  
  config_x[0] = start_x; config_y[0] = start_y;
  config_x[numConfig-1] = goal_x; config_y[numConfig-1] = goal_y;
}
void constructRoadamp() {
  float threshold = 400; // threshold distance for a single configuration. 
  
  for(int i = 0; i < numConfig; i++) {
    neighbors[i] = new ArrayList();
  }
  
  for(int i = 0; i < numConfig; i ++) {
    for(int j = i+1; j < numConfig; j++) {
      float distSqr = (config_x[i]-config_x[j])*(config_x[i]-config_x[j]) +  (config_y[i]-config_y[j])*(config_y[i]-config_y[j]);
      if(distSqr < threshold*threshold){
        if(localPlanner(i,j)) {
           neighbors[i].add(j);
           neighbors[j].add(i);
        }
      }
    }
  }
}
boolean localPlanner(int i, int j) {
  float vx, vy;
  vx = config_x[j] - config_x[i];
  vy = config_y[j] - config_y[i];
  float vlen = sqrt(vx*vx+vy*vy);
  vx = vx/vlen;
  vy = vy/vlen;
  
  boolean colliding = false;
  
  for(int k = 0; k < numObst; k++) {
    float wx, wy;
    wx = obst_x[k] - config_x[i];
    wy = obst_y[k] - config_y[i];
    
    float a = 1;  //Lenght of V (we noramlized it)
    float b = -2*(vx*wx + vy*wy); //-2*dot(V,W)
    float c = wx*wx + wy*wy - obstRad*obstRad; //different of squared distances
    
    float d = b*b - 4*a*c; //discriminant
    
    if (d >=0 ){ 
      //If d is positive we know the line is colliding, but we need to check if the collision line within the line segment
      //  ... this means t will be between 0 and the lenth of the line segment
      float t = (-b - sqrt(d))/(2*a); //Optimization: we only need the first collision
      if (t > 0 && t < vlen){
        colliding = true;
      }
    }
  }
  return !colliding;
}

void PRM() {
  samplingConfig();
  constructRoadamp();
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// search algorithm, here we use forward A*



float[] h = new float[numConfig];

void initHeuristic(int goal) {
  for(int i = 0; i < numConfig; i++) {
      float x = config_x[i];
      float y = config_y[i];
      float gx = config_x[goal];
      float gy = config_y[goal];
      float heuristic = sqrt((x-gx)*(x-gx) + (y-gy)*(y-gy));
      h[i] = heuristic;
  }
}


int[] AStar(int start, int goal) {  // return an optimal path according to start and goal
  // first, initialize d[]
  //A* variables
  float[] d = new float[numConfig]; // store the cost from start to vertex i
  float[] f = new float[numConfig]; // f = d + h
  int parent[] = new int[numConfig];
  boolean[] closed = new boolean[numConfig];
  boolean[] inQueue = new boolean[numConfig];
  initHeuristic(goal);
  d[start] = 0;
  f[start] = d[start] + h[start];
  for(int i = 0; i < numConfig; i++) {
    parent[i]= -1;
    closed[i] = false;
    inQueue[i] = false;
    if(start != i) {
      d[i] = 100000;
      f[i] = d[i] + h[i];
    }
  }
  //then, use pq to traverse the graph
  ArrayList<Integer> frontier = new ArrayList();
  
  enqueue(frontier, start);
  
  // now we enter the search loop
  while(frontier.size() != 0) {
    int current = dequeue(frontier, f); // current vertex index
    //println(current+", Goal is: ", goal);
    //if(current == goal) {
    //  findGoal = true;
    //  break;
    //}
    float cx = config_x[current];
    float cy = config_y[current];
    closed[current] = true;
    inQueue[current] = false;
    ArrayList<Integer> currentNeighbor = neighbors[current];
    
    for(int i = 0; i < currentNeighbor.size(); i++) {
      int n = currentNeighbor.get(i); // n is the index of currentVertex's neighbor
      if(closed[n]) {
        continue;
      }
      float nx = config_x[n];
      float ny = config_y[n];
      float newCost = d[current] + sqrt((nx-cx)*(nx-cx) + (ny-cy)*(ny-cy));
      if(newCost < d[n]) {
        d[n] = newCost;
        f[n] = d[n] + h[n];
        parent[n] = current;
      }
      if(!inQueue[n] && !closed[n]) {
        enqueue(frontier,n);
        inQueue[n] = true;
      }
      
    }
  }
  //println(findGoal);
  //println(parent);
  //if(findGoal)
  //  return parent;
  //else
  //  return null;
  return parent;
}


int dequeue(ArrayList<Integer>A, float k[]) {
  int minIndex = -1;
  float minKey = MAX_INT;
  for(int i = 0; i < A.size(); i++) {
    if(k[A.get(i)] < minKey) {
      minIndex = i;
      minKey = k[A.get(i)];
    }
  }
  int retVal = A.get(minIndex);
  A.remove(minIndex);

  return retVal;
}

void enqueue(ArrayList<Integer>A, int vertex) {
  A.add(vertex);
}





///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// boids

void initAgent(int start) {
  for(int i = 0; i < numAgent; i++) {
    
    px[i] = agentRad*(2*(i%3)+1) - 150;
    py[i] = mapSize/2 - agentRad*(2*(i/3)+1);
    
    prevTarget[i] = start;
    nextTarget[i] = p[start];
    
  }
  
  // initialize positions of agents;
}











// ax,ay
// vx,vy

void computeForces() {
  for(int i = 0; i < numAgent; i++) {
    
    ax[i] = 0;
    ay[i] = 0;
    
    // goal force
    int tar = nextTarget[i]; // tar is a configuration, not agent.
    if(tar == -1)
      continue;
    float sx, sy;
    sx = config_x[tar] - px[i];
    sy = config_y[tar] - py[i];
    float dist = sqrt(sx*sx + sy*sy);
    float dx, dy; // direction if the vector
    dx = sx/dist;
    dy = sy/dist;
    float goalVx = dx*expectedSpeed;
    float goalVy = dy*expectedSpeed;
    
    float goalFx = gfk*(goalVx - vx[i]);
    float goalFy = gfk*(goalVy - vy[i]);
    
    ax[i] += goalFx;
    ay[i] += goalFy;
    // seperation force: away from 1. neighbors; 2. obstacles; 3. walls
    
    float dThreshold = 200;
    float avoidFx = 0;
    float avoidFy = 0;
    for(int j = 0; j < numAgent; j++) {  // neighbors
      if(j == i)
        continue;
      float awaySx, awaySy;
      awaySx = px[i] - px[j];
      awaySy = py[i] - py[j];
      
      
      float awayDistance = sqrt(awaySx*awaySx + awaySy*awaySy)-1.2*agentRad;
      if(awayDistance <= dThreshold) {
        float awayDx, awayDy; // away direction
        awayDx = awaySx/awayDistance;
        awayDy = awaySy/awayDistance;
        
        if (vx[i]*(-awayDx) + vy[i]*(-awayDy) < -sqrt(3)/2)
          continue;
          
        avoidFx += sfk*(1/awayDistance)*awayDx;
        avoidFy += sfk*(1/awayDistance)*awayDy;
      }     
    } 
    float awayObstSx, awayObstSy;
    for(int j = 0; j < numObst; j++) {   // obstacles
      awayObstSx = px[i] - obst_x[j];
      awayObstSy = py[i] - obst_y[j];
      if (vx[i]*(-awayObstSx) + vy[i]*(-awayObstSy) < 0)
        continue;
      float awayObstDistance = sqrt(awayObstSx*awayObstSx + awayObstSy*awayObstSy) - (obstRad + agentRad);
      if(awayObstDistance > 200)
        continue;
      float awayObstDx, awayObstDy;
      awayObstDx = awayObstSx/awayObstDistance;
      awayObstDy = awayObstSy/awayObstDistance;
      
      avoidFx += 2000*(1/awayObstDistance)*awayObstDx;
      avoidFy += 2000*(1/awayObstDistance)*awayObstDy;
    }
    float awayWallSx; // no force apply on y direction
    for(int j = 0; j < numVWall; j ++) {
      awayWallSx = px[i] - vWall[j] - 0.9*agentRad;
      avoidFx += 1000*(1/awayWallSx);
    }
    float awayWallSy; // no force apply on x direction
    for(int j = 0; j < numHWall; j ++) {
      awayWallSy = py[i] - hWall[j] - 0.9*agentRad;
      avoidFy += 1000*(1/awayWallSy);
      
    }
    ax[i] += avoidFx;
    ay[i] += avoidFy;
  }
}










///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





int p[];


void setup() {
  initObstacles();
  PRM(); 
  p = AStar(globalGoal, globalStart);  // here we use backward AStar. The AStar won't stop even if it finds the "goal" we set. So the p[i] is the next point an agent want to reach next. 
  initAgent(globalStart);
  size(800, 800);
}


void update(float dt) {
  for(int i = 0; i < numAgent; i ++) {
    
    
    int tar = nextTarget[i];
    
    if(tar == -1)
      continue;
    px[i] += vx[i]*dt;
    py[i] += vy[i]*dt;
    
    vx[i] += ax[i]*dt;
    vy[i] += ay[i]*dt;
    float farOff;
    float a,b,c;
    if(nextTarget[i] == -1)
      continue;
    a = config_y[nextTarget[i]] - config_y[prevTarget[i]];
    b = config_x[prevTarget[i]] - config_x[nextTarget[i]];
    c = config_x[nextTarget[i]]*config_y[prevTarget[i]] - config_x[prevTarget[i]]*config_y[nextTarget[i]];
    farOff = abs(a*px[i] + b*py[i] + c)/sqrt(a*a+b*b);
    if(farOff > 50) {
      for(int j = 0; j < numConfig; j++) {
        float distance;
        distance = sqrt((px[i] - config_x[j])*(px[i] - config_x[j]) + (py[i] - config_y[j])*(py[i] - config_y[j]));
        if(distance < 50) {
          nextTarget[i] = j;
          break;
        }
      }
    }
    float d = sqrt((config_x[tar]-px[i])*(config_x[tar]-px[i]) + (config_y[tar]-py[i])*(config_y[tar]-py[i]));
    float dThres = 50;
    if(d < dThres) {
      prevTarget[i] = nextTarget[i];
      nextTarget[i] = p[tar];
      
    }
    
  }
}


void mouseClicked() {
  float x = mouseX - 400;
  float y = mouseY - 400;
  int start = -1, goal;
  for(int i = 0; i < numConfig; i++) {
    float d = sqrt((config_x[i]-x)*(config_x[i]-x) + (config_y[i]-y)*(config_y[i]-y));
    if(d < 100) {
      goal = i;
      while(start != goal) {
        start = (int)random(0,numConfig);
      }
      p = AStar(goal,start); // backward
      break;
    }
  }
  for(int i = 0; i < numAgent; i ++) {
    nextTarget[i] = p[prevTarget[i]];
  }
}


void draw() {
  float startFrame = millis();
  computeForces();
  update(1/frameRate);
  float endPhysics = millis();
  
  
  background(255,255,255);
  translate(400,400);

  
  stroke(0,0,0);
  strokeWeight(1);
  fill(255, 204, 0);
  for(int i = 0; i < numObst; i++) {
    ellipse(obst_x[i],obst_y[i],obstRad*2,obstRad*2);

  }
  
  
  stroke(0,0,0);
  strokeWeight(3);
  
  for(int i = 0 ; i < p.length; i++) {
    if(p[i] != -1)
      line(config_x[i],config_y[i] , config_x[p[i]], config_y[p[i]]);
  }
  
  
  
  
  strokeWeight(1);
  fill(100, 255, 140);
  for(int i = 0; i < numAgent; i ++) {
    ellipse(px[i],py[i],agentRad*2,agentRad*2);
    float vlen = sqrt(vx[i]*vx[i] + vy[i]*vy[i]);
    float dx = vx[i]/vlen;
    float dy = vy[i]/vlen;
    line(px[i],py[i],px[i]+10*dx, py[i]+10*dy);
  }
  float endFrame = millis();
  String runtimeReport = "Frame: "+str(endFrame-startFrame)+"ms,"+
        " Physics: "+ str(endPhysics-startFrame)+"ms,"+
        " FPS: "+ str(round(frameRate)) + ", Num of agent: " + str(numAgent) + "\n";
  surface.setTitle("crowd"+ "  -  " +runtimeReport);
  
}
