#include <Adafruit_NeoPixel.h>

#define PIN 4
#define SECTION_MULT 2
#define LED_COUNT 25*SECTION_MULT
#define BANDS 25

// Create an instance of the Adafruit_NeoPixel class called "leds".
// That'll be what we refer to from here on...
Adafruit_NeoPixel leds = Adafruit_NeoPixel(LED_COUNT, PIN, NEO_GRB + NEO_KHZ800);

// 32
//int array[BANDS] =    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
//int arraytemp[BANDS] ={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
// 25
byte array[BANDS+1] =    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
byte arraytemp[BANDS+1] ={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

int i,j,k,r;

int incomingByte = 0;

void setup ()
{  
  Serial.begin(19200);
  leds.begin();  // Call this to start up the LED strip.
  clearLEDs();   // This function, defined below, turns all LEDs off...
  leds.show();   // ...but the LEDs don't actually update until you call this.

  setColor(0x003300);
  leds.show();
}

void loop() {
  // put your main code here, to run repeatedly:

  if (Serial.readBytesUntil(0xff, array, BANDS+1) == BANDS+1) {
      //switch case statement
      for (j=0; j<BANDS; j++) {
        if(array[j]!= arraytemp[j]){ 
          uint32_t color = 0;
  
          if (array[j] < 0xff) {
            color = Wheel(array[j]);
            leds.setPixelColor((j*SECTION_MULT)+0, color);
            leds.setPixelColor((j*SECTION_MULT)+1, color);
          } else {
            color = 0x001100;
          }
        }
        arraytemp[j] = array[j];
      }
      leds.show();      
  }

  //delay(1);
}


void setColor(int color)
{
  for (int i=0; i<LED_COUNT; i++)
  {
    leds.setPixelColor(i, color);
  }
}


uint32_t Wheel(byte WheelPos) {
  if(WheelPos < 64) {
   return leds.Color(0, 255, WheelPos*4);
  } else if(WheelPos < 128) {
   WheelPos -= 64;
   return leds.Color(0, 255-(WheelPos*4), 255);
  } else if(WheelPos < 192) {
   WheelPos -= 128;
   return leds.Color(WheelPos*4, 0, 255);
  } else {
   WheelPos -= 192;
   return leds.Color(255, 0, 255-(WheelPos*4));
  }
}

// Sets all LEDs to off, but DOES NOT update the display;
// call leds.show() to actually turn them off after this.
void clearLEDs()
{
  for (int i=0; i<LED_COUNT; i++)
  {
    leds.setPixelColor(i, 0);
  }
}

