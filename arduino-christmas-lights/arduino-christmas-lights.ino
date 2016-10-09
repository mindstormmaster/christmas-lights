#include <Adafruit_NeoPixel.h>

#define PIN 3
#define BANDS 25
#define SECTION_MULT 2
#define LED_COUNT BANDS*SECTION_MULT

#define SCREENSAVER_DELAY 10

// Create an instance of the Adafruit_NeoPixel class called "leds".
// That'll be what we refer to from here on...
Adafruit_NeoPixel leds = Adafruit_NeoPixel(LED_COUNT, PIN, NEO_RGB + NEO_KHZ800);

// 32
//int array[BANDS] =    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
//int arraytemp[BANDS] ={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
// 50
// byte array[BANDS+1] =    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
// byte arraytemp[BANDS+1] ={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

// 25
byte array[BANDS+1] =    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
byte arraytemp[BANDS+1] ={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

// 10
//byte array[BANDS+1] =    {0,0,0,0,0,0,0,0,0,0,0};
//byte arraytemp[BANDS+1] ={0,0,0,0,0,0,0,0,0,0,0};

int i,j,k,r;

int incomingByte = 0;

unsigned long lastDataTime = 0*1000;

void setup ()
{  
  Serial.begin(9600);
  leds.begin();  // Call this to start up the LED strip.
  clearLEDs();   // This function, defined below, turns all LEDs off...
  leds.show();   // ...but the LEDs don't actually update until you call this.

  setColor(0x003300);
  leds.show();
}

void loop() {
  // put your main code here, to run repeatedly:

  if (Serial.available() && Serial.readBytesUntil(0xff, array, BANDS+1) == BANDS+1) {
      lastDataTime = millis();
      
      //switch case statement
      for (j=0; j<BANDS; j++) {
        if(true || array[j] != arraytemp[j]){ 
          uint32_t color = 0;
  
          if (array[j] < 0xff) {
            color = rgb6levelWhite(array[j]);

            if (SECTION_MULT > 1) {
              for (k=0; k<SECTION_MULT; k++) {
                leds.setPixelColor((j*SECTION_MULT)+k, color);
              }
            } else {
              leds.setPixelColor(j, color);
            }            
          }
        }
        arraytemp[j] = array[j];
      }
      leds.show();      
  } else if (millis() - lastDataTime > SCREENSAVER_DELAY*1000) {
    int steps = (millis() - lastDataTime) / 10;
    wipe(steps);
  }
}


void setColor(int color)
{
  for (int i=0; i<LED_COUNT; i++)
  {
    leds.setPixelColor(i, color);
  }
}

void wipe(int startColor)
{
  for (int i=0; i<LED_COUNT; i++)
  {
    leds.setPixelColor(i, Wheel((startColor+i)%384));
  }
  leds.show();
}

void testPattern()
{
  for (byte color = 0; color < 216; color++) {
    for (int i=0; i<LED_COUNT; i++)
    {
      leds.setPixelColor(i, rgb6level(color));
    }
    leds.show();      
    delay(100);
  }
}

uint32_t rgb6level(byte WheelPos) {
  int r = min(255, floor(WheelPos/36) * 36);
  int g = min(255, floor((WheelPos/6)%6) * 36);
  int b = min(255, WheelPos%6 * 36);
  return leds.Color(r, g, b);
}

uint32_t rgb6levelWhite(byte WheelPos) {

  if (WheelPos < 10) {
    return leds.Color(0, 0, 0);
  } else if (WheelPos < 160) {
    return leds.Color(WheelPos, WheelPos, WheelPos);
  } else {
    return leds.Color(WheelPos*0.9, WheelPos*0.9, WheelPos*0.9);
  }

  
  if (WheelPos < 10) {
    return leds.Color(0, 0, 0);
  } else if (WheelPos < 90) {
    float pct = WheelPos-10/80.0;
    int color = 10*pct;
    return leds.Color(color, color, color);
  } else if (WheelPos < 120) {
    float pct = WheelPos-90/30.0;
    int color = 10+50*pct;
    return leds.Color(color, color, color);
  } else if (WheelPos < 160) {
    float pct = WheelPos-120/40.0;
    int color = 60+60*pct;
    return leds.Color(color, color, color);
  } else {
    float pct = WheelPos-160/80.0;
    int color = 120+100*pct;
    return leds.Color(color, color, color);
  }
}

/*
void setColorRgb6level(int pos, byte WheelPos) {
  int r = min(255, floor(WheelPos/36) * 36);
  int g = min(255, floor((WheelPos/6)%6) * 36);
  int b = min(255, WheelPos%6 * 36);
  leds.setPixelColor(pos, r, g, b);
}
*/


uint32_t convert8to24(byte WheelPos) {
  int r = ((WheelPos >> 4) & 3) * 64;
  int g = ((WheelPos >> 2) & 3) * 64;
  int b = ((WheelPos >> 0) & 3) * 64;
  
  return leds.Color(r, g, b);
}

uint32_t convert8to24fail(byte WheelPos) {
  uint32_t ret = 0;
  for (int i=0; i<8; i++) {
    if (WheelPos & (1 << i)) {
      ret |= (1 << (i*3)+0);
      ret |= (1 << (i*3)+1);
      ret |= (1 << (i*3)+2);
    }
  }
  return ret;
}

uint32_t Wheel(int WheelPos) {
  if(WheelPos < 64) {
   return leds.Color(0, 255, WheelPos*4);
  } else if(WheelPos < 128) {
   WheelPos -= 64;
   return leds.Color(0, 255-(WheelPos*4), 255);
  } else if(WheelPos < 192) {
   WheelPos -= 128;
   return leds.Color(WheelPos*4, 0, 255);
  } else if(WheelPos < 256) {
   WheelPos -= 192;
   return leds.Color(255, 0, 255-(WheelPos*4));
  } else if(WheelPos < 320) {
   WheelPos -= 256;
   return leds.Color(255, WheelPos*4, 0);
  } else if(WheelPos < 384) {
   WheelPos -= 320;
   return leds.Color(255-(WheelPos*4), 255, 0);
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

