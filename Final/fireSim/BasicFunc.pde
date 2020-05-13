

void diffuse (int b, float[] x, float[] x0, float diff, float dt) {
  float a = dt * diff * N * N;
  for (int k = 0; k < 20; k++) {
    for (int j = 1; j < N; j++) {
      for (int i = 1; i < N; i++) {
        x[IX(i, j)] = (x0[IX(i, j)] + 
                          a*(x[IX(i+1, j)]+x[IX(i-1, j)]+
                             x[IX(i, j+1)]+x[IX(i, j-1)]))/(1+4*a);
      }
    }

    set_bnd(b, x);
  }
}


void project(float[] u, float[] v, float[] p, float[] div) {
  float h = 1.0/N;
  for (int j = 1; j < N; j++) {
    for (int i = 1; i < N; i++) {
      //divergence
      div[IX(i, j)] = -0.5*h*(u[IX(i+1, j)]-u[IX(i-1, j)]+
                              v[IX(i, j+1)]-v[IX(i, j-1)]);
      p[IX(i, j)] = 0;
    }
  }

  set_bnd(0, div); 
  set_bnd(0, p);
  
  // poisson equation solver (Gauss-Seidel)
  for (int k = 0; k < 20; k++) {
    for (int j = 1; j < N; j++) {
      for (int i = 1; i < N; i++) {
        p[IX(i, j)] = (div[IX(i, j)] + 
                      (p[IX(i+1, j)]+p[IX(i-1, j)]+
                       p[IX(i, j+1)]+p[IX(i, j-1)]))/4;
      }
    }

    set_bnd(0, p);
  }
  //subtract gradient field
  for (int j = 1; j < N; j++) {
    for (int i = 1; i < N; i++) {
      u[IX(i, j)] -= 0.5 * (p[IX(i+1, j)]-p[IX(i-1, j)])/h;
      v[IX(i, j)] -= 0.5 * (p[IX(i, j+1)]-p[IX(i, j-1)])/h;
    }
  }
  set_bnd(1, u);
  set_bnd(2, v);
}


void advect(int b, float[] d, float[] d0, float[] u, float[] v, float dt) {
  int i0, j0, i1, j1;
  float x, y, s0, t0, s1, t1, dt0;
  dt0 = dt*N;
  for (int i=1 ; i<=N ; i++ ) {
    for (int j=1 ; j<=N ; j++ ) {
      x = i-dt0*u[IX(i,j)]; y = j-dt0*v[IX(i,j)];
      if (x<0.5) x=0.5; if (x>N+0.5) x=N+0.5; 
      i0=(int)x; i1=i0+1; 
      if (y<0.5) y=0.5; if (y>N+0.5) y=N+0.5; 
      j0=(int)y; j1=j0+1; 
      s1 = x-i0; s0 = 1-s1; 
      t1 = y-j0; t0 = 1-t1;
      d[IX(i,j)] = s0*(t0*d0[IX(i0,j0)]+t1*d0[IX(i0,j1)])+
                      s1*(t0*d0[IX(i1,j0)]+t1*d0[IX(i1,j1)]);
    }   
  }
  set_bnd (b, d); 
}


void velStep() {
  diffuse(1, vx_prev, vx, visc, dt);
  diffuse(2, vy_prev, vy, visc, dt);

  project(vx_prev, vy_prev, vx, vy);

  advect(1, vx, vx_prev, vx_prev, vy_prev, dt);
  advect(2, vy, vy_prev, vx_prev, vy_prev, dt);

  project(vx, vy, vx_prev, vy_prev);
}


void densStep() {
  diffuse(0, density_prev, density, diff, dt);
  advect(0, density, density_prev, vx, vy, dt);
}

void oxyStep() {
  diffuse(0, oxy_prev, oxy, diff, dt);
  advect(0, oxy, oxy_prev, vx, vy, dt);
}




void set_bnd(int b, float[] x) {
  for (int i = 1; i < N; i++) {
    x[IX(i, 0  )] = b == 2 ? -x[IX(i, 1  )] : x[IX(i, 1 )];
    x[IX(i, N-1)] = b == 2 ? -x[IX(i, N-2)] : x[IX(i, N-2)];
  }
  for (int j = 1; j < N; j++) {
    x[IX(0, j)] = b == 1 ? -x[IX(1, j)] : x[IX(1, j)];
    x[IX(N-1, j)] = b == 1 ? -x[IX(N-2, j)] : x[IX(N-2, j)];
  }

  x[IX(0, 0)] = 0.5 * (x[IX(1, 0)] + x[IX(0, 1)]);
  x[IX(0, N-1)] = 0.5 * (x[IX(1, N-1)] + x[IX(0, N-2)]);
  x[IX(N-1, 0)] = 0.5 * (x[IX(N-2, 0)] + x[IX(N-1, 1)]);
  x[IX(N-1, N-1)] = 0.5 * (x[IX(N-2, N-1)] + x[IX(N-1, N-2)]);
}
