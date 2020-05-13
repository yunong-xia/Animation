


void burn() {
  for(int i = 1; i <= N; i++) {
    for(int j = 1; j <= N; j++) {
      float O = oxy[IX(i,j)]; float F = fuel[IX(i,j)];
      float H = heat[IX(i,j)] + 30;  // 30 is the ambient heat
      float reactionRate = (O*F*H - energyBarrier) * rateConst;
      constrain(reactionRate, 0, maxRate);
      oxy[IX(i,j)] -= reactionRate * dt;
      fuel[IX(i,j)] -= reactionRate * dt;
      heat[IX(i,j)] += reactionRate * dt * exothermicness;
      
      if(oxy[IX(i,j)] < 0)
        oxy[IX(i,j)] = 0;
        
      if(fuel[IX(i,j)] < 0)
        fuel[IX(i,j)] = 0;
    }
  }
}

void upwardConvection(float[] u, float[] v) {
  for(int i = 1; i <=N ; i++) {
    for(int j = 1; j <=N ; j++) {
      v[IX(i,j)] = heat[IX(i,j)] * convectiveness;
      
      u[IX(i,j)] *= .90;
      v[IX(i,j)] *= .90;
      
      if(u[IX(i,j)] > 0) u[IX(i,j)] = -u[IX(i,j)];
      if(v[IX(i,j)] > 0) v[IX(i,j)] = -v[IX(i,j)];
    }
  }
}

void cooling() {
  for(int i = 1; i <=N ; i++) {
    for(int j = 1; j <=N ; j++) {
      float deltaH= coolRate* pow(heat[IX(i,j)],4);
      heat[IX(i,j)] -= deltaH*dt;
      if (heat[IX(i,j)] < 0) heat[IX(i,j)] = 0;
    }
  }
}

void fireRGB() {
  for(int i = 1; i <= N; i ++) {
    for(int j = 1; j <= N; j ++) {
      float t = heat[IX(i,j)] / maxT;
      t = expose(t,35);
      if(t < .4) r[IX(i,j)] = g[IX(i,j)] = b[IX(i,j)] = t;
      if(t > .4){
        r[IX(i,j)] = .4 + .6*(t-.4)/.05;
        g[IX(i,j)] = .3;
        b[IX(i,j)] = .3;
      }
      if(t > .45) {  
        r[IX(i,j)] = 1;
        g[IX(i,j)] = (t - .45)/.15;
      }
      if(t > .6) {
        r[IX(i,j)] = g[IX(i,j)] = 1;
        b[IX(i,j)] = (t - .6) / .1;
      }
    }
  }
}

float expose(float l, float expLvl) {
  return (1 - exp(- l * expLvl));
}



void fireStep() {
  burn();
  upwardConvection(vx, vy);
  cooling();
}
