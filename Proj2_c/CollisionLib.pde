
/////////
// Point Intersection Tests
/////////

// Name: Wenjie Zhang
// ID: 5677291






/////////
// Ray Intersection Tests
/////////

//This struct is used for ray-obstaclce intersection.
//It store both if there is a collision, and how far away it is (int terms of distance allong the ray)
class hitInfo{
  public boolean hit = false;
  public float t = 9999999;
  public int row = -1;
  public int col = -1;
}

//Constuct a hitInfo that records if and when the ray starting at "ray_start" and going in the direction "ray_dir"
// hits the circle centered at "center", with a radius "radius".
//If the collision is further away than "max_t" don't count it as a collision.
//You may assume that "ray_dir" is always normalized

hitInfo raySphereIntersect(PVector center, float radius, PVector ray_start, PVector ray_dir, float max_t, int i, int j){
  hitInfo hit = new hitInfo();
  float time = raySphereIntersectTime(center,radius,ray_start,ray_dir);
  if(time >= 0 &&  time <= max_t){
    hit.hit = true;
    hit.t = time;
    hit.row = i;
    hit.col = j;
  }
  return hit;
}



//Constuct a hitInfo that records if and when the ray starting at "ray_start" and going in the direction "ray_dir"
// hits any of the circles defined by the list of centers,"centers", and corisponding radii, "radii"
//If the collision is further away than "max_t" don't count it as a collision.
//You may assume that "ray_dir" is always normalized
//Only check the first "numObstacles" circles.
hitInfo raySphereListIntersect(PVector[][] centers,int rows, int cols, float radii, PVector l_start, PVector l_dir, float max_t){
  hitInfo hit = new hitInfo();
  for(int i = 0; i < rows; i++){
    for (int j = 0; j < cols; j ++){
       hitInfo curr_hit = raySphereIntersect(centers[i][j],radii,l_start,l_dir,max_t , i , j);
       if(curr_hit.hit && curr_hit.t <= hit.t){
           hit = curr_hit;
       } 
    }
  }
  return hit;
}



float raySphereIntersectTime(PVector center, float r, PVector l_start, PVector l_dir){
    //Compute displacement vector pointing from the start of the line segment to the center of the circle
  PVector toCircle = PVector.sub(center,l_start);
 
  //Solve quadratic equation for intersection point (in terms of l_dir and toCircle)
  float a = l_dir.mag();
  a = a * a;
  float b = -2*PVector.dot(l_dir,toCircle); //-2*dot(l_dir,toCircle)
  float c = toCircle.mag(); //different of squared distances
  c = c * c - (r*r);
 
  float d = b*b - 4*a*c; //discriminant
 
  if (d >=0 ){
    //If d is positive we know the line is colliding
    float t = (-b - sqrt(d))/(2*a); //Optimization: we typically only need the first collision!
    if (t >= 0) return t;
    return -1;
  }
 
  return -1; //We are not colliding, so there is no good t to return
}
