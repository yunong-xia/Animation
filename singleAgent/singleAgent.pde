
int sampleTimes = 20;
float mapSize = 500;


float circle_center_x = 0;
float circle_center_y = 0;
float circle_radius = 100;


float agent_radius = 20;
int numAgent = 0;

float start_x = -250+agent_radius;
float start_y = 250-agent_radius;

float goal_x = 250-agent_radius;
float goal_y = -250+agent_radius;



ArrayList<Float> C_x = new ArrayList();
ArrayList<Float> C_y = new ArrayList();








void init() { // sampling. Initialize and set the first and the last element of "config" as start and goal.

  for(int i = 0; i < sampleTimes; i ++) {
    float x = random(-(mapSize-agent_radius)/2,(mapSize-agent_radius)/2);
    float y = random(-(mapSize-agent_radius)/2,(mapSize-agent_radius)/2);
    if(x*x+y*y > (agent_radius + circle_radius)*(agent_radius + circle_radius)){ // check if the configuration is free.
      C_x.add(x);
      C_y.add(y);
      numAgent ++;
    }
  }
  
  // then initialize the start and goal.
  C_x.set(0,start_x);
  C_y.set(0,start_y);
  
  C_x.set(numAgent-1, goal_x);
  C_y.set(numAgent-1, goal_y);
}


// represent V
ArrayList<Float> V_x = new ArrayList();
ArrayList<Float> V_y = new ArrayList();

// represent E by adjacency list
ArrayList<Integer>[] neighbors;



void constructRoadmap() { // construct roadmap
  neighbors = new ArrayList[numAgent];
  for(int i = 0; i < numAgent; i ++) {
    neighbors[i] = new ArrayList();
  }

  float dist_thre = 500;
  for(int i = 0; i < numAgent; i++) {
    float cx = C_x.get(i);
    float cy = C_y.get(i);
    V_x.add(cx);
    V_y.add(cy);
    for(int k = 0 ; k < numAgent; k ++){
      if(k != i && !neighbors[i].contains(k)) {
        if((C_x.get(k)-cx)*(C_x.get(k)-cx)+(C_y.get(k)-cy)*(C_y.get(k)-cy) <= dist_thre*dist_thre){
          PVector v1_2 = new PVector(C_x.get(k)-cx, C_y.get(k)-cy);
          PVector v1_center = new PVector(0 - cx, 0 - cy);
          PVector v2_center = new PVector(0 - C_x.get(k), 0 - C_y.get(k));
          
          float dist_line_to_center;
          PVector v1_2_normalized = v1_2.copy().normalize();
          PVector v1_center_temp = v1_center.copy();
          v1_2_normalized.mult(v1_center_temp.dot(v1_2_normalized));
          PVector v1_center_proj_on_12 = v1_2_normalized.copy();
          v1_center.sub(v1_center_proj_on_12);
          dist_line_to_center = v1_center.mag();
          
          
          float sign_of_angle = v1_2.dot(v2_center);
          
          if((dist_line_to_center > agent_radius + circle_radius) || (dist_line_to_center < agent_radius+circle_radius && sign_of_angle > 0)){
            neighbors[i].add(k);
            //neighbors[k].add(i);
          }
        }
      }
    }
  }
}



void search() {
  bfs();
}


Boolean[] visited;//A list which store if a given node has been visited
int[] parent; //A list which stores the best previous node on the optimal path to reach this node
int[] next;
ArrayList<Integer> path = new ArrayList();

void bfs() {
  visited = new Boolean[numAgent];
  parent = new int[numAgent];  
  for (int i = 0; i < numAgent; i++) { 
    visited[i] = false;
    parent[i] = -1; //No partent yet
  }
  ArrayList<Integer> fringe = new ArrayList(); 
  int start = 0;
  int goal = numAgent-1;
  
  path.add(goal);
  
  visited[start] = true;
  fringe.add(start);
  
  while (fringe.size() > 0){
    int currentNode = fringe.get(0);
    fringe.remove(0);
    if (currentNode == goal){
      println("Goal found!");
      break;
    }
    for (int i = 0; i < neighbors[currentNode].size(); i++){
      int neighborNode = neighbors[currentNode].get(i);
      if (!visited[neighborNode]){
        visited[neighborNode] = true;
        parent[neighborNode] = currentNode;
        fringe.add(neighborNode);
        println("Added node", neighborNode, "to the fringe.");
        println(" Current Fringe: ", fringe);
      }
    } 
  }
  print("\nReverse path: ");
  int prevNode = parent[goal];
  print(goal, " ");
  while (prevNode >= 0){
    print(prevNode," ");
    path.add(0,prevNode);
    prevNode = parent[prevNode];
  }
  print("\n");
  
  print("path: ", path);
}










void setup() {
  init();
  constructRoadmap();
  search();
  size(700, 700);
}


float agentX = start_x;
float agentY = start_y;
float agentSpeed = 100;

int roadMapReached = 0;


void update(float dt) {
  int start = 0;
  int goal = numAgent-1 ;
  
  if(roadMapReached != goal) {
    int next = path.get(path.indexOf(roadMapReached)+1);
    float sx = V_x.get(next) - agentX;
    float sy = V_y.get(next) - agentY;
    float segLen = sqrt(sx*sx+sy*sy);
    float dirX = sx/segLen;
    float dirY = sy/segLen;    
    
    // if the agent is inside a small circle at the center of a roadmap, then consider it as reached. Set the agent's position at the roadmap
    float r_threshold = 5;
    if(segLen <= r_threshold){
      agentX = V_x.get(next);
      agentY = V_y.get(next);
      roadMapReached = next;
    }
    else {
      agentX += dirX*agentSpeed*dt;
      agentY += dirY*agentSpeed*dt;
    }
  }
  
}

void drawScene() {
  background(255,255,255);
  translate(350,350);
  
  
  fill(255, 204, 0);
  for(int i = 0; i < path.size(); i++) {
    ellipse(V_x.get(path.get(i)), V_y.get(path.get(i)), agent_radius, agent_radius);
    if(i != path.size()-1) {
      line(V_x.get(path.get(i)), V_y.get(path.get(i)), V_x.get(path.get(i+1)), V_y.get(path.get(i+1)));
    }
  }
  
  
  noFill();
  
  ellipse(0,0,agent_radius + circle_radius,agent_radius + circle_radius);
  
  beginShape();
  vertex(-250,-250);
  vertex(-250,250);
  vertex(250,250);
  vertex(250,-250);
  vertex(-250,-250);
  endShape();
  
  fill(0,0,0);
  ellipse(agentX,agentY,agent_radius,agent_radius);
 
}

void draw() {
  //Draw the scene
  drawScene();
  update(1/frameRate);
  
}
