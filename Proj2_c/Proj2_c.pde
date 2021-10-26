//PDEs and Integration
//CSCI 5611 Swinging Rope [Exercise]
//Stephen J. Guy <sjguy@umn.edu>
// Name: Wenjie Zhang
// ID: 5677291




boolean round = true;
//load
String[] imageNames = {"Summer_Rocks.png"};
String[] tNames = {"Rock"};



String[] objNames = {};// Models coming from https://quaternius.com/index.html
String[] oNames = {};


ArrayList<String> textureNames = new ArrayList();
ArrayList<String> objectNames = new ArrayList();


PImage[] images;
PShape[] shapes  ;
Camera camera;


//PVector pointerCenter =new PVector(0,0,0);
//float pointerRad = 5;

void Update(float dt){
  camera.Update(dt);
  UpdateWater(dt);
}


//------------------------------------
// Init Scene
//------------------------------------
String windowTitle = "Water Simulation";
void setup() {
  size(1280, 720, P3D);
  surface.setTitle(windowTitle);
  loadScene();
  camera = new Camera();
  initWater();
}







//------------------------------------
// Draw Scene
//------------------------------------
boolean paused = true;
void draw() {
  background(128,128,128);
  lights();
  directionalLight(255, 255, 255, 0, -1.4142, -1.4142);
  
  Update(1.0/frameRate);
  
  DrawWater();
  
  /*
         pushMatrix();
        fill(200,0,0);
        noStroke();
        translate(pointerCenter.x,pointerCenter.y,pointerCenter.z);
        sphere(pointerRad);
        popMatrix();
        */
  surface.setTitle(windowTitle + " (" + frameRate + ")");
}





//------------------------------------
// Handle Key
//------------------------------------
void keyPressed(){
  if(key == 'r'){
    initWater();
  }
  camera.HandleKeyPressed();
}

void keyReleased()
{
  camera.HandleKeyReleased();
}

/*
float hightList[][] = {{60,90,60},
                       {90,100,90},
                       {60,90,60}};
*/


void mousePressed() {
  float x = mouseX; 
  float y = mouseY; 
  PVector[] ray = camera.getRay(x,y);
  //println(ray[0], ray[1]);
  hitInfo hit = raySphereListIntersect(centers,rows, cols, collR, ray[0], ray[1],9999);
  
  if(hit.hit ){
       for (int i = 0; i < 5; i ++){
         for(int j = 0; j < 5; j ++){
           int ri = hit.row - 2 + i;
           int ci = hit.col - 2 + j;
           if(ri > 0  && ri < rows && ci > 0 && ci < cols){
                        h[ri][ci] = 100;
                        //h[ri][ci] = hightList[i][j];
                        hv[ri][ci] = 0;
                        hu[ri][ci] = 0;
           }
         }     
       }

      //pointerCenter = centers[hit.row][hit.col];
  }

}


void loadScene(){
  images = new PImage[imageNames.length];
  shapes = new PShape[objNames.length];
  for(int i = 0; i < imageNames.length; i++){
       textureNames.add(tNames[i]);
       images[i] = loadImage( imageNames[i]); //What image to load, experiment with transparent images 
       noStroke();
      // println(loading);
    //drawloading();    
   }
  for(int i = 0; i < objNames.length; i++){
     shapes[i] = loadShape( objNames[i]);
     noStroke();
     objectNames.add(oNames[i]);
     //println(loading);
     
   }
}
