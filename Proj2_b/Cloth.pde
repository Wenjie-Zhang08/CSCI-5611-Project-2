class Cloth
{
  //Simulation Parameters
  float floor = 500;
  float g = 20;
  boolean debug = false;
  
  Vec2 stringTop = new Vec2(200,50);
  float genRestLen;
  float diagRestLen;
  // Smaller mass -> smaller length
  float mass = 0.5; //TRY-IT: How does changing mass affect resting length of the rope?
  // Larger K -> smaller length
  //float k = 5000; //TRY-IT: How does changing k affect resting length of the rope?
  float kGen = 1000;
  float kDiagS = 100;
  float kDiagL = 100;
  
  float kv = 20; //TRY-IT: How big can you make kv?
  float kfloor =  0.6;
  float kball = 0.2;
  float kAir = 0.0004;
  float radC;
  //float kF = 2; // Friction
  
  
  
  //Initial positions and velocities of masses
  
  int rows;
  int cols;
  
  PVector pos[][];
  PVector vel[][];
  PVector aforce[][];// accumulated force  

//-----------------------------------
// initial
//-----------------------------------


  Cloth(int r, int c,float rc, float rl){
    rows = r;
    cols = c;
    radC = rc;
    genRestLen = rl;
    diagRestLen = genRestLen * sqrt(2);
    pos = new PVector[r][c];
    vel = new PVector[r][c];
    aforce = new PVector[r][c];
    init();
  }
  
  private void init(){
   float y = 100;
   float delta = genRestLen;
   PVector zzPos = new PVector(0, y, 0);
   print(rows, cols);
   for(int i = 0; i < rows; i++){
     for(int j = 0; j < cols; j++){
       //print(i,j);
       pos[i][j] = new PVector(zzPos.x + i*delta, zzPos.y , zzPos.z + j*delta);
       vel[i][j] = new PVector(0,0,0);
       
      
       
       
     }
   }
  }
  
  
//-----------------------------------
// update
//-----------------------------------  
  
  public void Update(float dt){
    int times  = 20;
    for(int i = 0; i < times; i ++){
       updateForces();
       applyForces(dt/times);
       solveCollisionUpdatePos(dt/times);
    }

  }
  
  private void updateForces(){
    // reset
    for(int i = 0; i < rows; i ++){
     for(int j = 0; j < cols; j ++){
       aforce[i][j] = new PVector(0,0,0);

     }
    }
    
    for(int i = 0; i < rows; i ++){
     for(int j = 0; j < cols; j ++){
      // add gravity
      PVector gravity = new PVector(0, -mass * g, 0);
      aforce[i][j] = PVector.add(aforce[i][j],gravity);

      
      // update verticle force 
      if(i > 0){
        addSpringForce(i,j,i-1,j,0);
      }
      
      // update horizontal force
      if(j > 0){
        addSpringForce(i,j,i,j-1,0);
      }
      
      // update diag force
      if(i > 0 && j > 0){
        addSpringForce(i,j,i-1,j-1,1);
      }
      
      
      if(i > 0 && j < (col-1)){
        addSpringForce(i,j,i-1,j+1,1);
      }
      
      if(i > 1 && j > 1){
        addSpringForce(i,j,i-2,j-2,2);
      }
      
      
      
      if(i > 1 && j < (col-2)){
        addSpringForce(i,j,i-2,j+2,2);
      }
      
      
      // apply airdrag
      if(i < (rows-1) && j < (cols-1)){
       // calculate the four points air force
       addAirForce(i,j,i+1,j,i+1,j+1);
       addAirForce(i,j,i+1,j+1,i,j+1);
       addAirForce(i,j,i+1,j,i,j+1);     
       addAirForce(i,j+1,i+1,j,i+1,j+1);       
      }
     }      
    }
  }
  
  
  private void addAirForce(int ri1,int rj1,int ri2,int rj2, int ri3, int rj3){
    PVector v = PVector.add(vel[ri1][rj1], vel[ri2][rj2]);
    v = PVector.add(v , vel[ri3][rj3]);
    v = PVector.div(v, 3.0f);
    v = PVector.sub(v, vAir);
    
    PVector dir1 = PVector.sub(pos[ri2][rj2], pos[ri1][rj1]);
    PVector dir2 = PVector.sub(pos[ri3][rj3], pos[ri1][rj1]);
    
    PVector nstar = dir1.cross(dir2);
    
    float dotp = PVector.dot(v,nstar);
    
    float para = dotp * v.mag() / 2.0 / nstar.mag();
    
    PVector airF = PVector.mult(nstar, -1 * para * kAir);
    
    aforce[ri1][rj1] = PVector.add(aforce[ri1][rj1], airF);
    aforce[ri2][rj2] = PVector.add(aforce[ri2][rj2], airF);
    aforce[ri3][rj3] = PVector.add(aforce[ri3][rj3], airF);
    
  }
  
  
  // using current i, current j, parent i, parent j
  private void addSpringForce(int ci,int cj,int pi,int pj,int diag){
    float kSpring = kGen;
    float rlen = genRestLen;
    if(diag == 1){
      kSpring = kDiagS;
      rlen = diagRestLen;
    }
    if(diag == 2){
      kSpring = kDiagL;
     rlen = 2 * diagRestLen; 
    }
    PVector diff = PVector.sub(pos[ci][cj],pos[pi][pj]);
    float stringF = -kSpring * (diff.mag() - rlen);
    
    PVector stringDir = diff.normalize();
    float projVbot = vel[pi][pj].dot(stringDir);
    float projVtop = vel[ci][cj].dot(stringDir);
    float dampF = -kv * (projVtop - projVbot);
    //println(stringF);
    PVector force = stringDir.mult(stringF + dampF);
    
    aforce[ci][cj] = PVector.add(aforce[ci][cj],force);
    aforce[pi][pj] = PVector.add(aforce[pi][pj],force.mult(-1));
  }
  
  
  private void applyForces(float dt){
    for(int i = 0; i < rows; i ++){
     for(int j = 0; j < cols; j++){

       PVector acc = PVector.div(aforce[i][j], mass);
       PVector deltaV = PVector.mult(acc,dt);
       vel[i][j] = PVector.add(vel[i][j],deltaV);
       // Solve collision here?
       //if(i == 0){
        
         
       
       if(i == 0 && (j == 0 || j ==( cols - 1 ))){
        vel[i][j] = new PVector(0,0,0);
        
        //continue;
       }
       
     }
    }
    
  }
  
  
  private void solveCollisionUpdatePos(float dt){
    for(int i = 0; i < rows; i ++){
      for(int j = 0; j < cols; j++){
        PVector deltaPos = PVector.mult(vel[i][j],dt);
        PVector np = PVector.add(pos[i][j],deltaPos);
        int ca = 0;
        hitInfo hit  = raySphereIntersect(center, rad, pos[i][j], vel[i][j], dt*1.1);
        
        // also check floor
        float ttf = (pos[i][j].y - radC)/vel[i][j].y;
        //print(ttf);
               
        if(hit.hit){
          if(ttf < hit.t && ttf > 0){
            ca = 1;
             np = new PVector(np.x,radC,np.z);
             vel[i][j].y = - kfloor * vel[i][j].y;
          }
          else{
            /*
            deltaPos = PVector.mult(vel[i][j],hit.t-0.05);
            np = PVector.add(pos[i][j],deltaPos);
            PVector dir = PVector.sub(np,center);
            dir.normalize();
            float av = PVector.dot(vel[i][j],dir);
            av *=  (-1.0-kball);
            PVector deltaV = PVector.mult(dir,av);
            vel[i][j] = PVector.add(vel[i][j] , deltaV);
            */
            ca = 2;
            deltaPos = PVector.mult(vel[i][j],hit.t);
            np = PVector.add(pos[i][j],deltaPos);
            PVector dir = PVector.sub(np,center);
            dir.normalize();
            np = PVector.add(center, PVector.mult(dir,rad + 0.01));
            
            // update velocity
            float av = PVector.dot(vel[i][j],dir);
            av *=  (-1.0-kball);
            PVector deltaV = PVector.mult(dir,av);
            vel[i][j] = PVector.add(vel[i][j] , deltaV);
          }
        }
        else{
          if(ttf < dt && ttf > 0){
            ca = 3;
             np = new PVector(np.x,radC+0.01,np.z);
             vel[i][j].y = - kfloor * vel[i][j].y;
          }
        }
        
        
        pos[i][j] = np;
        
        if(PVector.sub(pos[i][j],center).mag() < rad){
          print("\nCurrent V is ",vel[i][j]);
          print(PVector.sub(pos[i][j],center).mag(),ca);
        }
      }
    }  
  }
  
//-----------------------------------
// User Interaction
//-----------------------------------
  public void changeAirVelocity(boolean changer){
    if(changer)
      vAir.x += 10;
     else
      vAir.x -= 10;
  
  
  }  
  
  
    
   public void changeMode(){
    debug = !debug;
  }
//-----------------------------------
// draw
//-----------------------------------
  
  
  
  
  public void Draw(){
    if(debug)
    DebugMode();
    else
    ClothMode();
  }

  
  public void ClothMode(){
   for(int i = 0; i < rows-1; i++){
     for(int j = 0; j < cols-1; j ++){
      if((i+j) % 2 == 0)
        fill(0,128,0,220);
       else
        fill (10,10,10,220);
       beginShape();
       PVector position = pos[i][j];
       vertex(position.x,position.y,position.z);
       position = pos[i+1][j];
       vertex(position.x,position.y,position.z);
       position = pos[i+1][j+1];
       vertex(position.x,position.y,position.z);
       position = pos[i][j+1];
       vertex(position.x,position.y,position.z);
       endShape();
     }
   }
    
  }

  
  // draw the rope
  public void DebugMode(){
   float radius = 2;
   for (int i = 0; i < rows; i++){
      for(int j = 0; j < cols; j++){
        int nexti = i + 1;
        int nextj = j + 1;
        pushMatrix();
        stroke(0,0,0);
        if(nexti < rows)
          line(pos[i][j].x,pos[i][j].y,pos[i][j].z,pos[nexti][j].x,pos[nexti][j].y,pos[nexti][j].z);
        if(nextj < cols)
          line(pos[i][j].x,pos[i][j].y,pos[i][j].z,pos[i][nextj].x,pos[i][nextj].y,pos[i][nextj].z);
        if(nexti < rows && nextj < cols)
          line(pos[i][j].x,pos[i][j].y,pos[i][j].z,pos[nexti][nextj].x,pos[nexti][nextj].y,pos[nexti][nextj].z);
 
        nextj = j - 1;
        if(nexti < rows && nextj >= 0)
          line(pos[i][j].x,pos[i][j].y,pos[i][j].z,pos[nexti][nextj].x,pos[nexti][nextj].y,pos[nexti][nextj].z);
        
        // draw the sphere
        fill(200,0,0);
        noStroke();
        translate(pos[i][j].x,pos[i][j].y,pos[i][j].z);
        sphere(radius);
        popMatrix();
      }
   }
    
  }
}
