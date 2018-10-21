
/* --------------------------------------------------------------------------
 * SimpleOpenNI User Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
 * date:  02/16/2011 (m/d/y)
 * ----------------------------------------------------------------------------
 */


import SimpleOpenNI.*;
import processing.serial.*; 

SimpleOpenNI  context;
boolean       autoCalib=true;
Serial port; 
float pos2l;
float pos2r;
int currUser = -1;
long time2;

void setup()
{
  context = new SimpleOpenNI(this);
  println(Serial.list()); 
  port = new Serial(this, Serial.list()[4], 9600);


  // enable depthMap generation 
  if (context.enableDepth() == false)
  {
    println("Can't open the depthMap, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  background(200, 0, 0);

  stroke(0, 0, 255);
  strokeWeight(3);
  smooth();

  size(context.depthWidth(), context.depthHeight());
}

void draw()
{
  background(200, 0, 0);
  // update the cam
  context.update();

  // draw depthImageMap
  image(context.depthImage(), 0, 0);




  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  if (userList.length < 1) currUser = -1;
  if (currUser == -1) {
//---------Send a character to arduino when no user is detected to enable the sleeping mode of the steucture(see the report for more information)-----------//
      port.write('N');
    for (int i=0;i<userList.length;i++)
    {
      if (context.isTrackingSkeleton(userList[i])) {
        drawSkeleton(userList[i]);
        currUser = i;
        println("setting user: " + i);
      }
      else {
      }
    }
  }
  else {
    if (userList.length>0)
      if (context.isTrackingSkeleton(userList[currUser])) 
        drawSkeleton(userList[currUser]);
  }
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
 
  // to get the 3d joint data
  //Define the vector for each joint to be able to use them
  PVector jointPosHand_L = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, jointPosHand_L);

  PVector jointPosHand_R = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, jointPosHand_R);

  PVector jointPosElbow_L = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, jointPosElbow_L);

  PVector jointPosElbow_R = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, jointPosElbow_R);

  PVector jointPosShoulder_L = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, jointPosShoulder_L);

  PVector jointPosShoulder_R = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, jointPosShoulder_R);

  PVector jointPosHead = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, jointPosHead);

  PVector jointPosTorso = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_TORSO, jointPosTorso);

  //----------------------------------------------convert real world point to projective space--------------------------------------------------------------//

  PVector jointPosHead_Proj = new PVector(); 
  context.convertRealWorldToProjective(jointPosHead, jointPosHead_Proj);
  jointPosHead_Proj.z =0;

  PVector jointPos_ProjShoulder_L = new PVector(); 
  context.convertRealWorldToProjective(jointPosShoulder_L, jointPos_ProjShoulder_L);
  jointPos_ProjShoulder_L.z =0;

  PVector jointPos_ProjShoulder_R = new PVector(); 
  context.convertRealWorldToProjective(jointPosShoulder_R, jointPos_ProjShoulder_R);
  jointPos_ProjShoulder_R.z =0;

  PVector jointPos_ProjElbow_L = new PVector(); 
  context.convertRealWorldToProjective(jointPosElbow_L, jointPos_ProjElbow_L);
  jointPos_ProjElbow_L.z = 0;

  PVector jointPos_ProjElbow_R = new PVector(); 
  context.convertRealWorldToProjective(jointPosElbow_R, jointPos_ProjElbow_R);
  jointPos_ProjElbow_R.z =0;

  PVector jointPos_ProjHand_L = new PVector(); 
  context.convertRealWorldToProjective(jointPosHand_L, jointPos_ProjHand_L);
  jointPos_ProjHand_L.z =0;

  PVector jointPos_ProjHand_R = new PVector(); 
  context.convertRealWorldToProjective(jointPosHand_R, jointPos_ProjHand_R);
  jointPos_ProjHand_R.z =0;

  //Try to draw a circle on the head just to test the projected vectore
  stroke(255, 0, 0);
  strokeWeight(5);

  float headsize = 200;
  // create a distance scalar related to the depth (z dimension)
  float distanceScalar = (525/jointPosHead_Proj.z);

  fill(255, 0, 255); 

  ellipse(jointPosHead_Proj.x, jointPosHead_Proj.y, headsize*distanceScalar, headsize*distanceScalar);
  
  //Define two new vectors, 200 pixels lower of the Yaxis of the shoulder, to be able to use later for the angle calculation.
  
  PVector ProjShoulderLplus = new PVector(jointPos_ProjShoulder_L.x, jointPos_ProjShoulder_L.y+200);
  PVector ProjShoulderRplus = new PVector(jointPos_ProjShoulder_R.x, jointPos_ProjShoulder_R.y+200);
  
  //Draw the lines from the shoulders(left & right) to the new extended vectors calculated above
  
  line(jointPos_ProjShoulder_L.x, jointPos_ProjShoulder_L.y, ProjShoulderLplus.x, ProjShoulderLplus.y);
  line(jointPos_ProjShoulder_R.x, jointPos_ProjShoulder_R.y, ProjShoulderRplus.x, ProjShoulderRplus.y);

 
  //Substract the shoulder vector to move the center to the shoulder

  PVector ShoulderPlusL_New = PVector.sub(ProjShoulderLplus, jointPos_ProjShoulder_L);
  PVector ShoulderPlusR_New = PVector.sub(ProjShoulderRplus, jointPos_ProjShoulder_R);

  PVector ElbowL_New = PVector.sub(jointPos_ProjElbow_L, jointPos_ProjShoulder_L);
  PVector ElbowR_New = PVector.sub(jointPos_ProjElbow_R, jointPos_ProjShoulder_R);

  PVector HandL_New = PVector.sub( jointPos_ProjHand_L, jointPos_ProjElbow_L);
  PVector HandR_New = PVector.sub( jointPos_ProjHand_R, jointPos_ProjElbow_R);


  PVector ShoulderL_New = PVector.sub( jointPos_ProjShoulder_L, jointPos_ProjElbow_L);
  PVector ShoulderR_New = PVector.sub( jointPos_ProjShoulder_R, jointPos_ProjElbow_R);





  //-------------------------------------------------------Calculate the angles------------------------------------------------------------------------------//
  
  float theta1L =degrees(PVector.angleBetween(ShoulderPlusL_New, ElbowL_New));//angle between the left shoulder and the new vector(calculated above)
  float theta1R =degrees(PVector.angleBetween(ShoulderPlusR_New, ElbowR_New));//angle between the right shoulder and the new vector(calculated above)

  float theta2L =degrees(PVector.angleBetween(HandL_New, ShoulderL_New));//angle between the left shoulder and and the left hand
  float theta2R =degrees(PVector.angleBetween(HandR_New, ShoulderR_New));//angle between the rigth shoulder and and the right hand

  
  //calculate the angles to be able to draw and arc 
  float theta1La= degrees(atan2(ShoulderPlusL_New.x, ShoulderPlusL_New.y));
  float theta1Lb= degrees(atan2(ElbowL_New.x, ElbowL_New.y));

  float theta1Ra= degrees(atan2(ShoulderPlusR_New.x, ShoulderPlusR_New.y));
  float theta1Rb= degrees(atan2(ElbowR_New.x, ElbowR_New.y));

  float theta2La=degrees(atan2(HandL_New.x, HandL_New.y));
  float theta2Lb=degrees(atan2(ShoulderL_New.x, ShoulderL_New.y));

  float theta2Ra=degrees(atan2(HandR_New.x, HandR_New.y));
  float theta2Rb=degrees(atan2(ShoulderR_New.x, ShoulderR_New.y));



  fill(255, 128, 0);
  arc(jointPos_ProjShoulder_L.x, jointPos_ProjShoulder_L.y, 150, 150, radians(theta1La)+HALF_PI, HALF_PI-radians(theta1Lb), PIE);
  arc(jointPos_ProjShoulder_R.x, jointPos_ProjShoulder_R.y, 150, 150, HALF_PI-radians(theta1Rb), radians(theta1Ra)+HALF_PI, PIE);


//Printing the values on the screen
  text(String.valueOf(theta1L), 10, 10, 200, 200);
  text(String.valueOf(theta1R), 100, 10, 200, 200);
  text(String.valueOf(theta2L), 200, 10, 200, 200);
  text(String.valueOf(theta2R), 300, 10, 200, 200);

//-----------------------------------------Write data on the port (communication with Arduino)------------------------------------------------------------------//

   try {
 port.write('A'); //Sending a character in the begining to avoid confusion in the order of the angle values(see the report for more info) 
 //Sending the angle values, separating them with a space
  port.write(theta1L + " ");//Sending the 1st angle 
  port.write(theta2L + " ");//Sending the 2nd angle
  port.write(theta1R + " ");//Sending the 3rd angle
  port.write(theta2R + " ");//Sending the 4th angle
   } 
  catch (Exception e) {
   e.printStackTrace();
  }


 
  //Draw the skeleton

  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);


  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
}


void serialEvent(Serial port) { 
  String myString = port.readStringUntil('\n');
  if (myString != null) print(myString);
}


//----------------------------------------------------SimpleOpenNI events----------------------------------------------------------------------------------//


void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");

  if (autoCalib)
    context.requestCalibrationSkeleton(userId, true);

  else    
    context.startPoseDetection("Psi", userId);
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
  //  port.write('L');
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
}

void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);

  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId);
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");

  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose, int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

