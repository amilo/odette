/**
 * Mouse 2D. 
 * 
 * Moving the mouse changes the position and size of each box. 
 * Moving the mouse also changes the pitch, the speed is detected and sent to SuperCollider 
 * together with other analysis
 */
 
import oscP5.*;  //import P5 OSC library
import netP5.*;


OscP5 osc;
NetAddress supercollider;  //set NetAddress

boolean PLAYX, PLAYY = false;   
boolean FLYUPX,FLYUPY= true;
float ntx, nty;
float vx, vy;
float tx,ty;
float threshold= 1.0;

 
void setup() 
{
  size(640, 360); 
  noStroke();
  rectMode(CENTER);
   osc=new OscP5(this,1200);
  supercollider=new NetAddress("127.0.0.1", 57120);
  
}

void draw() 
{   
  background(51); 
  fill(255, 204);
  rect(mouseX, height/2, mouseY/2+10, mouseY/2+10);
  fill(255, 204);
  int inverseX = width-mouseX;
  int inverseY = height-mouseY;
  rect(inverseX, height/2, (inverseY/2)+10, (inverseY/2)+10);
//  store();
//  check();
 
   

if (frameCount%3==0){
  tx=mouseX;   //store the angle t=0;
  ty=mouseY;
}
if (frameCount%3==2){
  ntx=mouseX;   //store the angle t=2;
  nty=mouseY;
  float vx = ntx-tx;
  float vy = nty-ty;
  
  if (vx>threshold) {     //treshold for speed, trigger sound
    FLYUPX = true;
    PLAYX = true;
      }
  else if (vx<-threshold) {
    FLYUPX = false;
    PLAYX = true;
    vx=-vx; //absolute value for sending
     }
     
      if (vy>threshold) {
    FLYUPY = true;
    PLAYY = true;
      }
  else if (vy<-threshold) {
    FLYUPY = false;
    PLAYY = true;
    vy=-vy; //absolute value for sending
         }
  
  if (PLAYX == true){
         println("PLAY " + "FLYUP = " + FLYUPX);
       
  OscMessage  msg = new OscMessage("/kinect");
  msg.add(map(mouseX,0,width,-6,6));
  msg.add(map(vx,0,30,0,1));
  msg.add(map(mouseY,0,height,-6,6));
  msg.add(map(vy,0,30,0,1));
  msg.add(map(mouseX,0,width,-2,2));
  msg.add(map(mouseY,0,height,-2,2));
  
  
  osc.send( msg,supercollider);
  println("messagex sent");
  if (FLYUPX = false){
  vx=-vx; //leave the speed as it was
  }
  PLAYX = false; //stop the trigger
  println("STOP_FLY");
  }
  
  
  if (PLAYY == true){
         println("PLAY " + "FLYUP = " + FLYUPY);
         
  OscMessage  msg = new OscMessage("/kinect");
  msg.add(map(mouseX,0,width,-6,6));
  msg.add(map(vx,0,30,0,1));
  msg.add(map(mouseY,0,height,-6,6));
  msg.add(map(mouseX,0,width,-2,2));
  msg.add(map(mouseY,0,height,-2,2));

  
  osc.send(msg,supercollider);
  println("messagey sent");
  if (FLYUPY = false){
  vy=-vy; //leave the speed as it was
  }
  PLAYY = false;
  println("STOP_FLY");
  }
 
}


  
}
  



