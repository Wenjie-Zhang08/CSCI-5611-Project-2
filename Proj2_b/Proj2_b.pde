//PDEs and Integration
//CSCI 5611 Swinging Rope [Exercise]
//Stephen J. Guy <sjguy@umn.edu>
// Name: Wenjie Zhang
// ID: 5677291



boolean round = true;
//load
String[] imageNames = {"wood.bmp"};
String[] tNames = {"Floor"};
ArrayList<String> textureNames = new ArrayList();
PImage[] images;
Camera camera;
Cloth cloth;


PVector center = new PVector(35.0, 60.0, 30);
float rad = 20;

float clothRad = 0.5;
float clothLen = 3;
int col = 20;
int row = 20;

PVector vAir = new PVector(0,0,0);

void Update(float dt){
  camera.Update(dt);
  cloth.Update(dt);

  
}

//Create Window
String windowTitle = "Cloth Simulation";
void setup() {

  size(1280, 720, P3D);
  rad = rad + clothRad;
  surface.setTitle(windowTitle);
  loadScene();
  camera = new Camera();
  cloth = new Cloth(row,col,clothRad,clothLen);
}










//Draw the scene: one sphere per mass, one line connecting each pair
boolean paused = true;
void draw() {
  background(153,204,255);
  lights();
  directionalLight(255, 255, 255, 0, -1.4142, 1.4142);

  Update(1.0/frameRate);
  drawSceen();
  drawBall();
  cloth.Draw();

  surface.setTitle(windowTitle + " (" + frameRate + ")");
}

void drawSceen(){
   drawFloor(); 
   //drawWalls();
   //drawDoors();
}

void drawWalls(){
  float w = 100;
  float h = 1000;
  pushMatrix(); 
  beginShape();
  noStroke();
  //stroke(1);
  fill(128,128,128);
  // vertex( x, y, z, u, v) where u and v are the texture coordinates in pixels
  vertex(-w, 0, -w);
  vertex(-w,h,-w);
  vertex(-w,h,w);
  vertex(-w,0,w);
  endShape();
  popMatrix(); 
  
  pushMatrix(); 
  beginShape();
  noStroke();
  //stroke(1);
  fill(128,128,128);
  // vertex( x, y, z, u, v) where u and v are the texture coordinates in pixels
  vertex(-w, 0, w);
  vertex(-w,h,w);
  vertex(w,h,w);
  vertex(w,0,w);
  endShape();
  popMatrix(); 
  
}

void drawDoors(){
  
  
  
}


void drawBall(){
  pushMatrix();
  // draw the sphere
  fill(0,0,200);
  noStroke();
  translate(center.x,center.y,center.z);
  //sphere(rad);
  sphere(rad-clothRad);
  popMatrix();
  
}


void drawFloor(){
  float dw = 100;
  float dh = 100;
  int tw = 100;
  int th = 100;
  PImage image = images[textureNames.indexOf("Floor")];
  for(int i = -tw; i < tw; i+= dw ){
    for(int j = -th; j < th; j += dh){
        pushMatrix(); 
        beginShape();
        texture(image);
        noStroke();
        //stroke(1);
        strokeWeight(1);
        translate(i , 0, j );
        // vertex( x, y, z, u, v) where u and v are the texture coordinates in pixels
        vertex(0, 0, 0, 0, 0);
        vertex(dw, 0, 0, image.width, 0);
        vertex(dw,0, dh, image.width, image.height);
        vertex( 0, 0,dh, 0, image.height);
        endShape();
        popMatrix(); 
      
    }
  }
}
boolean modeCanChange = true;

void keyPressed(){
    camera.HandleKeyPressed();
  if (key == ' ')
    paused = !paused;
  if (key == 'r')
    cloth.init();
  if (key == 'm'){
    if(modeCanChange){
         cloth.changeMode(); 
         modeCanChange = false;
    }   
  }
  if (key == '='){
    if(vAir.x < 30){
       vAir.x += 5;
    }
  }

  if (key == '-')
    if(vAir.x > -30){
       vAir.x -= 5;
    }
    
}

void keyReleased()
{
  camera.HandleKeyReleased();
  //scene.HandleKeyReleased();
  if (key == 'm') modeCanChange = true;
}


void loadScene(){
  images = new PImage[imageNames.length];
  for(int i = 0; i < imageNames.length; i++){
       textureNames.add(tNames[i]);
       images[i] = loadImage( imageNames[i]); //What image to load, experiment with transparent images 
       noStroke();
      // println(loading);
    //drawloading();    
   }
}
