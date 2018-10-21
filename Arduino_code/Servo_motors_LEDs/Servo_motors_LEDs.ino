
// Sweep
// by BARRAGAN <http://barraganstudio.com> 
// This example code is in the public domain.




//Add the library for the LED strips
#include <Adafruit_NeoPixel.h>
#include "WS2812_Definitions.h"

//Add the library for the servo motors
#include <Servo.h> 

//Define the pins that the 2 LED strips are attached
#define PIN 11
#define PIN1 12

//Define the number of LEDs we have on each strip
#define LED_COUNT 30
#define LED_COUNT1 30

int incomingByte;  


Adafruit_NeoPixel leds0 = Adafruit_NeoPixel(LED_COUNT, PIN, NEO_GRB + NEO_KHZ800);
Adafruit_NeoPixel leds1 = Adafruit_NeoPixel(LED_COUNT, PIN1, NEO_GRB + NEO_KHZ800);

Servo myservo1;  // create servo object to control the 1st servo 
Servo myservo2;  // create servo object to control the 2nd servo 
Servo myservo3;  // create servo object to control the 3rd servo 
Servo myservo4;  // create servo object to control the 4th servo 

long myservo_movetime = 0; // next time in millis servo next moves

int pos1 = 0; // variable to store the position of the 1st servo 
int pos2=0; // variable to store the position of the 2nd servo 
int pos3=0; // variable to store the position of the 3rd servo 
int pos4=0; // variable to store the position of the 4th servo 

//the variables above are used for the sleeming mode
float speed1=2.2;//speed of the 1st servo
float speed2=2.2;//speed of the 2nd servo
float speed3=2.2;//speed of the 3rd servo
float speed4=2.2;//speed of the 4th servo



float theta1L; // varialble to store the angle between the left arm and 
float theta2L; // varialble to store the angle between the left arm and the left hand  
float theta1R;// varialble to store the angle between the left arm and the left hand  
float theta2R;// varialble to store the angle between the right arm and the right hand  

void setup() {
  Serial.begin(9600); //opens serial port, sets data rate to 9600 bps

  leds0.begin(); 
  leds1.begin();





  myservo1.attach(2);  // attaches the servo on pin 2 to the servo object 
  myservo2.attach(6);  // attaches the servo on pin 6 to the servo object 
  myservo3.attach(4);  // attaches the servo on pin 4 to the servo object 
  myservo4.attach(8);  // attaches the servo on pin 8 to the servo object 


} 


void loop() 
{ 


  if (Serial.available() > 0  ) { //Check if the serial is available
    incomingByte = Serial.read(); // read the incoming byte:


    if (incomingByte == 'A') { //If the incoming byte is the character A
      //We are sending first the character A and then the desired data to avoid confusion between them


      theta1R=Serial.parseFloat();//returns the first valid floating point number from the Serial buffer
      theta2L=Serial.parseFloat();
      theta1L=Serial.parseFloat();
      theta2R=Serial.parseFloat();
    } 
    if (incomingByte == 'N') {//If the incoming byte is the character N, do the sleeping mode

      if(theta2R>90) {
        theta2R = 89;
        speed1*=-1;
      }
      else if(theta2R<0) {
        theta2R = 1;
        speed1*=-1;
      }
      myservo2.write(pos1);              // tell servo to go to position in variable 'pos' 

      theta2R+=speed1;

      if(theta2R>90) {
        theta2R = 89;
        speed2*=-1;        
      }
      else if(theta2R<0) {
        theta2R = 1;
        speed2*=-1;
      }
      myservo4.write(pos2);              // tell servo to go to position in variable 'pos' 


      theta2L+=speed2;

    }

    //Map the two angles to a smaller range 
    float a= map(theta2L,0,180,0,120);
    float b= map(theta2R,0,180,0,120);


    //Move each servo motor depending on the data received from processing
    myservo1.write(180-theta1L); 
    myservo2.write(180-theta2L); 
    myservo3.write(theta1R);
    myservo4.write(theta2R);  






    //map the LED two angles in relation to LEDs position on the LED strip
    int m=map(theta2R,0,180,0,LED_COUNT1);
    int l=map(theta2L,0,180,0,LED_COUNT1);

    //Call the rainbow function to generate the desired effect for the LEDs strips
    rainbow(leds0,m);
    rainbow(leds1,l);

  }

}


//The function below where taken from : https://github.com/adafruit/Adafruit_NeoPixel 
//Some modifications were done to acquire the desired effect and add a second LED strip

//Functions to light up the LED strips 
void rainbow(Adafruit_NeoPixel leds,byte startPosition) 
{
  // Need to scale our rainbow. We want a variety of colors, even if there
  // are just 10 or so pixels.
  int rainbowScale = 192 / LED_COUNT1;

  //    Serial.println( rainbowScale * ((LED_COUNT1 + startPosition)) % 192);
  // Next we setup each pixel with the right color
  for (int i=0; i<LED_COUNT1; i++)
  {
    // There are 192 total colors we can get out of the rainbowOrder function.
    // It'll return a color between red->orange->green->...->violet for 0-191.
    leds.setPixelColor(i, rainbowOrder(leds,(rainbowScale * (i + startPosition)/2) % 192));


  }
  // Finally, actually turn the LEDs on:
  leds.show();

}

uint32_t rainbowOrder(Adafruit_NeoPixel leds,byte position) 
{
  // 6 total zones of color change:
  if (position < 31)  // Red -> Yellow (Red = FF, blue = 0, green goes 00-FF)
  {
    //    return leds.Color(0xFF, position * 8, 0);

    return leds.Color(0, 0xFF - position * 4, 0xFF);
  }
  else if (position < 63)  // Yellow -> Green (Green = FF, blue = 0, red goes FF->00)
  {
    position -= 31;
    //    return leds.Color(0xFF - position * 8, 0xFF, 0);
    return leds.Color(0, 0xFF - 127 - position * 4, 0xFF);
  }
  else if (position < 95)  // Green->Aqua (Green = FF, red = 0, blue goes 00->FF)
  {
    position -= 63;
    return leds.Color(position * 4, 0, 0xFF);
    //    return leds.Color(0, 0xFF, position * 8);
  }
  else if (position < 127)  // Aqua->Blue (Blue = FF, red = 0, green goes FF->00)
  {
    position -= 95;
    return leds.Color(127+position * 4, 0, 0xFF);
    //    return leds.Color(0, 0xFF - position * 8, 0xFF);
  }
  else if (position < 159)  // Blue->Fuchsia (Blue = FF, green = 0, red goes 00->FF)
  {
    position -= 127;
    return leds.Color(0xFF, 0x00, 0xFF - position * 4);
    //    return leds.Color(position * 8, 0, 0xFF);
  }
  else  //160 <position< 191   Fuchsia->Red (Red = FF, green = 0, blue goes FF->00)
  {
    position -= 159;
    return leds.Color(0xFF, 0x00, 0xFF - 127 - position * 4);
  }
}












