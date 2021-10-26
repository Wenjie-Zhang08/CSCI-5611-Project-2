
// This is the water



//------------------------------------
// Water Parameters
//------------------------------------
int cols = 81;
int rows = 81;

float[][] h;
float[][] hu;
float[][] hv;
float[][] dhdt;
float[][] dhudt;
float[][] dhvdt;


float[][] h_mid;
float[][] h_mid_u;
float[][] h_mid_v;
float[][] hu_mid;
float[][] hv_mid;
float[][] dhudt_mid;
float[][] dhvdt_mid;
float[][] dhdt_mid;
float[][] dhdt_mid_u;
float[][] dhdt_mid_v;

PVector[][] centers;

float damp = 0.5;
float g = 250;

float dx = 2.5;
float dy = 2.5;

float fraction = 10;

float debugR = 1.0f;
float collR = 10.0;

//------------------------------------
// Init Water
//------------------------------------
void initWater(){
  h = new float[rows][cols];
  h_mid = new float[rows-1][cols-1];
  h_mid_u = new float[rows][cols-1];
  h_mid_v = new float[rows-1][cols];
  hu = new float[rows][cols];
  hu_mid = new float[rows][cols-1];
  hv = new float[rows][cols];
  hv_mid = new float[rows-1][cols];
  dhdt = new float[rows][cols];
  dhdt_mid = new float[rows-1][cols-1];
  dhdt_mid_u = new float[rows][cols-1];
  dhdt_mid_v = new float[rows-1][cols];
  dhudt = new float[rows][cols];
  dhudt_mid = new float[rows][cols-1];
  dhvdt = new float[rows][cols];
  dhvdt_mid = new float[rows-1][cols];
  centers = new PVector[rows][cols];
  initHHu();
}

void initHHu(){
  float hgt = 50;
  for(int i = 0; i < rows; i ++){
    for(int j = 0; j < cols; j++){
      h[i][j] = hgt;
      hu[i][j] = 0;
      hv[i][j] = 0;
      centers[i][j] = new PVector(dx * j, h[i][j], dy * i );
      //hu_mid[i][j] = 0;
    }
  }
  
  for(int i = 10; i < 15; i ++){
   for(int j = 10; j < 15; j ++){
    
    h[i][j] = 100; 
    //centers[i][j].y = h[i][j];
   }
  }
  
  //h[15][15] = 150;
}


//------------------------------------
// Update Water
//------------------------------------
void UpdateWater(float dt){
  //cal hmid and humid
  //float deltat = 0.01;
  //float sim_dt = 0.001;
  float deltat = dt/fraction;
  for(int i = 0; i < fraction; i++){
    
    //dt = dt / fraction;
    // generate midpoint h hu
    hnhu_mid();
    // update midpoint
    updatehnhu_mid(deltat);
    // update myself
    updatedhndhudt();
    updateH(deltat);
    /*
    updatedhndhudtV1();
    updateH(deltat);
    */
  }

}

// calculate h_mid and hu_mid
void hnhu_mid(){
  for(int i = 0; i < rows; i++){
   for(int j = 0; j < cols; j ++){
    if(i < rows - 1){
      h_mid_v[i][j] = (h[i][j] + h[i+1][j])/2; 
      hv_mid[i][j] = (hv[i+1][j] + hv[i][j])/2;
    }
    if(j < cols - 1){
      h_mid_u[i][j] = (h[i][j] + h[i][j+1])/2; 
      hu_mid[i][j] = (hu[i][j+1] + hu[i][j])/2;
    }
     
   }
  }
  /*
  for(int i = 0; i < rows - 1; i++){
    for(int j = 0; j < cols-1; j++){
       // center of square
       // h_mid[i][j] = (h[i][j+1] + h[i][j] + h[i+1][j])/3;
        h_mid[i][j] =  (h[i][j+1] + h[i][j] + h[i+1][j] + h[i+1][j+1])/4;
        //hu_mid[i][j] = (hu[i][j+1] + hu[i][j] + hu[i+1][j] + hu[i+1][j+1])/4;
        //hv_mid[i][j] = (hv[i][j] + hv[i+1][j] + hv[i][j+1] + hv[i+1][j+1])/4;
       hu_mid[i][j] = (hu[i][j+1] + hu[i][j])/2;
       hv_mid[i][j] = (hv[i+1][j] + hv[i][j])/2;
    } 
  }
  */
}



void updatehnhu_mid( float dt){
  for(int i = 0; i < rows; i ++){
    for(int j = 0; j < cols; j++){
      if(i < rows - 1){
         float dhuvdx_mid = 0;
         if(j < cols - 1){
           dhuvdx_mid = hu[i+1][j+1]*hv[i+1][j+1]/h[i+1][j+1];
           dhuvdx_mid -= hu[i][j]*hv[i][j]/h[i][j];
           dhuvdx_mid = dhuvdx_mid / dx;
         }

     
         // update v mid
         float dhvdy_mid =  (hv[i+1][j] - hv[i][j])/dy;
         dhdt_mid_v[i][j] = - dhvdy_mid; 
         
              // dhv/dt mid
         float dhv2dy_mid = hv[i+1][j]*hv[i+1][j]/h[i+1][j];
         dhv2dy_mid -= (hv[i][j] * hv[i][j] /h[i][j]);
         dhv2dy_mid = dhv2dy_mid / dy;
         
         float dgh2dy_mid = g* (h[i+1][j]*h[i+1][j] - h[i][j]*h[i][j])/dy;
         dhvdt_mid[i][j] = -(dhv2dy_mid + 0.5 * dgh2dy_mid + dhuvdx_mid);  
         //dhvdt_mid[i][j] = -(dhv2dy_mid + 0.5 * dgh2dy_mid);
        
      }
      if(j < cols - 1){
        
        float dhuvdy_mid = 0;
        if(i < rows - 1){
           dhuvdy_mid = hu[i+1][j+1]*hv[i+1][j+1]/h[i+1][j+1];
           dhuvdy_mid -= hu[i][j]*hv[i][j]/h[i][j];
           dhuvdy_mid = dhuvdy_mid / dy;
        }
         // update u mid
         float dhudx_mid = (hu[i][j+1] - hu[i][j])/dx;
         dhdt_mid_u[i][j] = - dhudx_mid;
         
         float dhu2dx_mid = hu[i][j+1]*hu[i][j+1]/h[i][j+1];
         dhu2dx_mid -= (hu[i][j] * hu[i][j] /h[i][j]);
         dhu2dx_mid = dhu2dx_mid / dx;
         
         float dgh2dx_mid = g* (h[i][j+1]*h[i][j+1] - h[i][j]*h[i][j])/dx;
         dhudt_mid[i][j] = -(dhu2dx_mid + 0.5 * dgh2dx_mid + dhuvdy_mid);
      }


      
      
      

     

     //dhudt_mid[i][j] = -(dhu2dx_mid + 0.5 * dgh2dx_mid + dhuvdy_mid);

     
      
    }
  }
  
   for (int i = 0; i < rows; i ++){
    for (int j = 0; j < cols; j ++){
      if(i < rows - 1){
        h_mid_v[i][j] += dhdt_mid_v[i][j] * dt / 2;
        hv_mid[i][j] += dhvdt_mid[i][j] * dt / 2;
      }
      if(j < cols-1){
        h_mid_u[i][j] += dhdt_mid_u[i][j] * dt / 2;
        hu_mid[i][j] += dhudt_mid[i][j] * dt / 2;
        
      }

      
    }
  }
  
  
  
  
  /*
  for (int i = 0; i < rows - 1; i ++){
    for (int j = 0; j < cols-1; j ++){
     float dhudx_mid = (hu[i][j+1] - hu[i][j])/dx;
     float dhvdy_mid =  (hv[i+1][j] - hv[i][j])/dy;
     dhdt_mid[i][j] = - dhudx_mid - dhvdy_mid;
    
     /*
     float dhuv_mid = hu[i+1][j+1]*hv[i+1][j+1]/h[i+1][j+1];
     dhuv_mid -= hu[i][j]*hv[i][j]/h[i][j];
     float dhuvdx_mid = dhuv_mid / dx;
     float dhuvdy_mid = dhuv_mid / dy;
     *
     
     float dhuvdx_mid = hu[i][j+1]*hv[i][j+1]/h[i][j+1];
     dhuvdx_mid -= hu[i][j]*hv[i][j]/h[i][j];
     dhuvdx_mid = dhuvdx_mid / dx;
     
     float dhuvdy_mid = hu[i+1][j]*hv[i+1][j]/h[i+1][j];
     dhuvdy_mid -= hu[i][j]*hv[i][j]/h[i][j];
     dhuvdy_mid = dhuvdy_mid / dy;
     
     
     
     
     //dhuvdx_mid = 0;
     //dhuvdy_mid = 0;
     // dhu/dt mid
     float dhu2dx_mid = hu[i][j+1]*hu[i][j+1]/h[i][j+1];
     dhu2dx_mid -= (hu[i][j] * hu[i][j] /h[i][j]);
     dhu2dx_mid = dhu2dx_mid / dx;
     
     float dgh2dx_mid = g* (h[i][j+1]*h[i][j+1] - h[i][j]*h[i][j])/dx;
     //dhudt_mid[i][j] = -(dhu2dx_mid + 0.5 * dgh2dx_mid + dhuvdy_mid);
      dhudt_mid[i][j] = -(dhu2dx_mid + 0.5 * dgh2dx_mid);
     
     // dhv/dt mid
     float dhv2dy_mid = hv[i+1][j]*hv[i+1][j]/h[i+1][j];
     dhv2dy_mid -= (hv[i][j] * hv[i][j] /h[i][j]);
     dhv2dy_mid = dhv2dy_mid / dy;
     
     float dgh2dy_mid = g* (h[i+1][j]*h[i+1][j] - h[i][j]*h[i][j])/dy;
     //dhvdt_mid[i][j] = -(dhv2dy_mid + 0.5 * dgh2dy_mid + dhuvdx_mid);  
     dhvdt_mid[i][j] = -(dhv2dy_mid + 0.5 * dgh2dy_mid);
      
      //dhvdt_mid[i][j] = 0;
    }
  }
  */
  
  /*
  for (int i = 0; i < rows - 1; i ++){
    for (int j = 0; j < cols - 1; j ++){
      h_mid[i][j] += dhdt_mid[i][j] * dt / 2;
      hu_mid[i][j] += dhudt_mid[i][j] * dt / 2;
      hv_mid[i][j] += dhvdt_mid[i][j] * dt / 2;
    }
  }
  */
  /*
  println("\n hmid");
  for(int i = 0; i < cols - 1; i++){
      print(h_mid[0][i],",");
    
  }
  println();
*/
}






void updatedhndhudt(){
  for(int i = 0; i < rows ; i++){
    for(int j = 0 ; j < cols; j++){
        // dh / dt
        if(i > 0 && j > 0 && i < rows-1 && j < cols-1){
            float dhudx = (hu_mid[i][j]- hu_mid[i][j-1])/dx;
            float dhvdy =  (hv_mid[i][j] - hv_mid[i-1][j])/dy;
            dhdt[i][j] = - dhudx  - dhvdy;
        }

        
        
       // dhuv / dx or dy 
       /*
       float dhuv = hu_mid[i][j]*hv_mid[i][j]/h_mid[i][j];
       dhuv -= hu_mid[i-1][j-1]*hv_mid[i-1][j-1]/h_mid[i-1][j-1];
       float dhuvdx = dhuv / dx;
       float dhuvdy = dhuv / dy;
       */
       
       /*
       float dhuvdx = hu_mid[i][j]*hv_mid[i][j]/h_mid[i][j];
       dhuvdx -= hu_mid[i][j-1]*hv_mid[i][j-1]/h_mid[i][j-1];
       dhuvdx = dhuvdx / dx;
       
       float dhuvdy = hu_mid[i][j]*hv_mid[i][j]/h_mid[i][j];
       dhuvdy -= hu_mid[i-1][j]*hv_mid[i-1][j]/h_mid[i-1][j];
       dhuvdy = dhuvdy / dy;
        */
        //dhuvdx = 0;
        //dhuvdy = 0;
        
        // dhu /dt
        if(j > 0 && j < cols - 1){
            float dhu2dx = hu_mid[i][j]*hu_mid[i][j]/h_mid_u[i][j];
            dhu2dx -= (hu_mid[i][j-1] * hu_mid[i][j-1] /h_mid_u[i][j-1]);
            dhu2dx = dhu2dx / dx;
            
            float dhuvdy = 0;
            /*
            if(i > 0 && i < rows - 1){
               dhuvdy = hu_mid[i][j] * hv_mid[i][j] / h_mid_u[i][j];
               dhuvdy -= hu_mid[i-1][j] * hv_mid[i-1][j] / h_mid_u[i-1][j];
               dhuvdy = dhuvdy / dy;
            }
            */
            float dgh2dx = g* (h_mid_u[i][j]*h_mid_u[i][j] - h_mid_u[i][j-1]*h_mid_u[i][j-1])/dx;
            //dhudt[i][j] = -(dhu2dx + 0.5 * dgh2dx + dhuvdy);
            dhudt[i][j] = -(dhu2dx + 0.5 * dgh2dx + dhuvdy);
        }
        if(i > 0 && i < rows - 1){
                  // dhv / dt
         float dhv2dy = hv_mid[i][j]*hv_mid[i][j]/h_mid_v[i][j];
         dhv2dy -= (hv_mid[i-1][j] * hv_mid[i-1][j] /h_mid_v[i-1][j]);
         dhv2dy = dhv2dy / dy;
         
         
          float dhuvdx = 0;
            /*
            if( j > 0 && j < cols - 1){
               dhuvdx = hu_mid[i][j] * hv_mid[i][j] / h_mid_v[i][j];
               dhuvdx -= hu_mid[i][j-1] * hv_mid[i][j-1] / h_mid_v[i][j-1];
               dhuvdx = dhuvdx / dx;
            }
            */
         
         
         
         
         
         float dgh2dy = g* (h_mid_v[i][j]*h_mid_v[i][j] - h_mid_v[i-1][j]*h_mid_v[i-1][j])/dy;
         //dhvdt[i][j] = -(dhv2dy + 0.5 * dgh2dy + dhuvdx);    
          dhvdt[i][j] = -(dhv2dy + 0.5 * dgh2dy + dhuvdx);
          
          
        }
    }
  }
  /*
  println("\n dhhdt");
  for(int i = 0; i < cols - 1; i++){
      print(dhdt[0][i],",");
    
  }
  println();
  */
}





void updateH(float dt){
  for(int i = 1; i < rows-1; i++){ 
    for(int j = 1; j < cols-1; j++){
     h[i][j] += damp * dhdt[i][j] * dt; 
     if(h[i][j] == 0 ) h[i][j] = 0.01;
     hu[i][j] += damp * dhudt[i][j] * dt; 
     hv[i][j] += damp * dhvdt[i][j] * dt;
     //centers[i][j].y = h[i][j];
    }
  }
  
  for(int j = 0; j < cols; j ++){
    h[0][j] = h[1][j];
    //centers[0][j].y = h[0][j];
    h[rows-1][j] = h[rows-2][j];
    //centers[rows-1][j].y = h[rows-1][j];
    //hv[0][j] = 0;
    hv[0][j] = -hv[1][j];
    //hu[0][j] = 0;
    //hu[0][j] = -hu[1][j];
    //hv[rows-1][j] = 0;
    hv[rows-1][j] = -hv[rows-2][j];
    //hu[rows-1][j] = 0;
    //hu[rows-1][j] = -hu[rows-2][j];
  }
  
  
  for(int i = 0; i < rows; i ++){
    h[i][0] = h[i][1];
    //centers[i][0].y = h[i][0];
    h[i][cols-1] = h[i][cols-2];
    //centers[i][cols-1].y = h[i][cols-2];
    //hu[i][0] = 0;
    hu[i][0] = -hu[i][1];
    //hv[i][0] = -hv[i][1];
    //hv[i][0] = 0;
    //hu[i][cols-1] = 0;
    //hv[i][cols-1] = 0;
    hu[i][cols-1] = -hu[i][cols-2];
    //hv[i][cols-1] = - hv[i][cols-2];
    
    
  }  
}


//------------------------------------
// Draw Water
//------------------------------------
void DrawWater(){

  DrawTank();
    DrawWaterMode();
  //DrawDebugMode();
  
}

void DrawTank(){

  float tHeight = 100;
  float cMax = (rows - 1)*dx;
  float rMax = (cols - 1)*dy;
  stroke(0,0,0);
  line(0,0,0,rMax,0,0);
  line(0,0,0,0,0,cMax);
  line(rMax,0,0,rMax,0,cMax);
  line(rMax,0,cMax,0,0,cMax);
  
  line(0,0,0,0,tHeight,0);
  line(rMax,0,0,rMax,tHeight,0);
  line(0,0,cMax,0,tHeight,cMax);
  line(rMax,0,cMax,rMax,tHeight,cMax);

  PImage image = images[textureNames.indexOf("Rock")];
  pushMatrix(); 
  beginShape();
  texture(image);
  noStroke();
  //stroke(1);
  strokeWeight(1);
  
  
  // vertex( x, y, z, u, v) where u and v are the texture coordinates in pixels
  vertex(0, 0, 0, 0, 0);
  vertex(rMax, 0, 0, image.width, 0);
  vertex(rMax, 0, cMax, image.width, image.height);
  vertex( 0, 0,cMax, 0, image.height);
  endShape();
  popMatrix(); 
  

}


void DrawDebugMode(){
  for(int i = 0; i < rows; i++){
    for(int j = 0; j < cols; j ++){
        pushMatrix();
        fill(200,0,0);
        noStroke();
        translate(dx*j,h[i][j], dy * i);
        sphere(debugR);
        popMatrix();
    }
  }
  
  
  
  
}


void DrawWaterMode(){
 fill(26,180,218,220);
 
  for(int i = 0; i < rows - 1 ; i ++){
   float startZ  = dy * i;
   float endZ = dy * (i + 1);
   beginShape();
   vertex(0,0,startZ);
   vertex(0,h[i][0], startZ);
   vertex(0,h[i+1][0],endZ);
   endShape();
   beginShape();
   vertex(0,0,startZ);
   vertex(0,h[i+1][0],endZ);
   vertex(0,0,endZ);
   endShape();
   
   // then we calculate the other side
   float endX = dx * (cols - 1);
   beginShape();
   vertex(endX,0,startZ);
   vertex(endX,h[i][cols-1], startZ);
   vertex(endX,h[i+1][cols-1],endZ);
   endShape();
   beginShape();
   vertex(endX,0,startZ);
   vertex(endX,h[i+1][cols-1],endZ);
   vertex(endX,0,endZ);
   endShape();
 }
 
 
 for(int j = 0; j < cols - 1 ; j ++){
   float startX  = dx * j;
   float endX = dx * (j + 1);
   beginShape();
   vertex(startX,0,0);
   vertex(startX,h[0][j], 0);
   vertex(endX,h[0][j+1],0);
   endShape();
   beginShape();
   vertex(startX,0,0);
   vertex(endX,h[0][j+1],0);
   vertex(endX,0,0);
   endShape();
   
   
   float endZ = dy * (rows - 1);
   beginShape();
   vertex(startX,0,endZ);
   vertex(startX,h[rows-1][j], endZ);
   vertex(endX,h[rows - 1][j+1],endZ);
   endShape();
   beginShape();
   vertex(startX,0,endZ);
   vertex(endX,h[rows - 1][j+1],endZ);
   vertex(endX,0,endZ);
   endShape();
 }
 
 
 for (int i = 0; i < rows-1; i ++){
  for(int j = 0; j < cols-1; j ++) {
    
       float startX = dx *j;
       float endX = dx *( j + 1);
       float startZ = dy * i;
       float endZ = dy * (i+1);
       //float midX = (startX + endX) / 2;
       //float midZ = (startZ + endZ) / 2;
       //float midY = (h[i][j] + h[i+1][j] + h[i+1][j+1] + h[i][j+1])/4;

       //fill(26,180,218);
       noStroke();
       /*
       beginShape();
       vertex(startX,h[i][j],startZ);
       vertex(startX,h[i+1][j],endZ);
       vertex(midX,midY,midZ);
       endShape();
       beginShape();
       vertex(startX,h[i][j],startZ);
       vertex(endX,h[i][j+1],startZ);
       vertex(midX,midY,midZ);
       endShape();
       beginShape();
       vertex(startX,h[i+1][j],endZ);
       vertex(endX,h[i+1][j+1],endZ);
       vertex(midX,midY,midZ);
       endShape();
       beginShape();

       vertex(endX,h[i+1][j+1],endZ);
       vertex(endX,h[i][j+1],startZ);
       vertex(midX,midY,midZ);
       endShape();
       */
       
       beginShape();
       vertex(startX,h[i][j],startZ);
       vertex(endX,h[i][j+1],startZ);
              
       vertex(startX,h[i+1][j],endZ);
       endShape();
       beginShape();
       vertex(startX,h[i+1][j],endZ);
       vertex(endX,h[i+1][j+1],endZ);
       vertex(endX,h[i][j+1],startZ);
       endShape();

  } 
 }

}
