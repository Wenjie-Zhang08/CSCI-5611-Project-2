
/////////
// Point Intersection Tests
/////////

// Name: Wenjie Zhang
// ID: 5677291



//Returns true iff the point, pointPos, is inside the box defined by boxTopLeft, boxW, and boxH
boolean pointInBox(Vec2 boxTopLeft, float boxW, float boxH, Vec2 pointPos){
  Vec2 deltaBtw = pointPos.minus(boxTopLeft);
  if(deltaBtw.x < boxW && deltaBtw.x > 0 
    && deltaBtw.y < boxH && deltaBtw.y > 0)
    return true;
  return false;
}

//Returns true iff the point, pointPos, is inside a circle defined by center and radius r
// If eps is non-zero, count the point as "inside" the circle if the point is outside, but within the distance eps of the edge
boolean pointInCircle(Vec2 center, float r, Vec2 pointPos, float eps){
  if(pointPos.distanceTo(center) -  r <  eps)  return true;
  return false;
}

//Returns true if the point is inside any of the circles defined by the list of centers,"centers", and corisponding radii, "radii".
// As above, count point within "eps" of the circle as inside the circle
//Only check the first "numObstacles" circles.
boolean pointInCircleList(Vec2[] centers, float[] radii, int numObstacles, Vec2 pointPos, float eps){
  for(int i = 0; i < numObstacles; i++){
    if(pointInCircle(centers[i],radii[i],pointPos,eps)) return true;
  }
  return false;
}


/////////
// Ray Intersection Tests
/////////

//This struct is used for ray-obstaclce intersection.
//It store both if there is a collision, and how far away it is (int terms of distance allong the ray)
class hitInfo{
  public boolean hit = false;
  public float t = 9999999;
}

//Constuct a hitInfo that records if and when the ray starting at "ray_start" and going in the direction "ray_dir"
// hits the circle centered at "center", with a radius "radius".
//If the collision is further away than "max_t" don't count it as a collision.
//You may assume that "ray_dir" is always normalized
hitInfo rayCircleIntersect(Vec2 center, float radius, Vec2 ray_start, Vec2 ray_dir, float max_t){
  hitInfo hit = new hitInfo();
  float time = rayCircleIntersectTime(center,radius,ray_start,ray_dir);
  if(time >= 0 &&  time <= max_t){
    hit.hit = true;
    hit.t = time;
  }
  return hit;
}

hitInfo raySphereIntersect(PVector center, float radius, PVector ray_start, PVector ray_dir, float max_t){
  hitInfo hit = new hitInfo();
  float time = raySphereIntersectTime(center,radius,ray_start,ray_dir);
  if(time >= 0 &&  time <= max_t){
    hit.hit = true;
    hit.t = time;
  }
  return hit;
}



//Constuct a hitInfo that records if and when the ray starting at "ray_start" and going in the direction "ray_dir"
// hits any of the circles defined by the list of centers,"centers", and corisponding radii, "radii"
//If the collision is further away than "max_t" don't count it as a collision.
//You may assume that "ray_dir" is always normalized
//Only check the first "numObstacles" circles.
hitInfo rayCircleListIntersect(Vec2[] centers, float[] radii, int numObstacles, Vec2 l_start, Vec2 l_dir, float max_t){
  hitInfo hit = new hitInfo();
  for(int i = 0; i < numObstacles; i++){
   hitInfo curr_hit = rayCircleIntersect(centers[i],radii[i],l_start,l_dir,max_t );
   if(curr_hit.hit && curr_hit.t <= hit.t){
     hit = curr_hit;
   }
    
  }
  return hit;
}


float rayCircleIntersectTime(Vec2 center, float r, Vec2 l_start, Vec2 l_dir){
 
  //Compute displacement vector pointing from the start of the line segment to the center of the circle
  Vec2 toCircle = center.minus(l_start);
 
  //Solve quadratic equation for intersection point (in terms of l_dir and toCircle)
  float a = l_dir.lengthSqr();
  float b = -2*dot(l_dir,toCircle); //-2*dot(l_dir,toCircle)
  float c = toCircle.lengthSqr() - (r*r); //different of squared distances
 
  float d = b*b - 4*a*c; //discriminant
 
  if (d >=0 ){
    //If d is positive we know the line is colliding
    float t = (-b - sqrt(d))/(2*a); //Optimization: we typically only need the first collision!
    if (t >= 0) return t;
    return -1;
  }
 
  return -1; //We are not colliding, so there is no good t to return
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
