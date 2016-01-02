/**
  * Live Spectrum to Arduino
  *
  * Run an FFT on live line-in input, splits into 16 frequency bands, and send this data to an Arduino in 16 byte packets.
  * Based on http://processing.org/learning/libraries/forwardfft.html by ddf.
  */
 
import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.serial.*; //library for serial communication
 
Serial port; //creates object "port" of serial class
 
Minim minim;
AudioPlayer player;
//AudioInput in;
FFT fft;
float[] peaks;

int peak_hold_time = 1;  // how long before peak decays
int[] peak_age;  // tracks how long peak has been stable, before decaying

// how wide each 'peak' band is, in fft bins
int binsperband = 5;
int peaksize; // how many individual peak bands we have (dep. binsperband)
float gain = 40; // in dB
float dB_scale = 2.0;  // pixels per dB

int buffer_size = 1024;  // also sets FFT size (frequency resolution)
float sample_rate = 44100;

String SONG = "running.mp3";

String[] songs = {
  "running.mp3",
  "lovedrug.mp3",
  "starwars.mp3",
  "raiders.mp3"
};
int songidx = 0;


float spectrum_height = 10.0; // determines range of dB shown

int max_freq = 16000;
int bands = 10;
int leds = 10;
int hz_per_band = max_freq / bands;

//float[] band_cutoffs = {20,25,31.5,40,50,63,80,100,125,160,200,250,315,400,500,630,800,1000,1250,1600,2000,2500,3150,4000,5000,6300,8000,12000};
//int[] freq_array = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};


float[] band_cutoffs = {20,63,125,200,315,500,800,1250,2000,4000,8000};
int[] freq_array = {0,0,0,0,0,0,0,0,0,0};


int[] color_array = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int i,g;
float f;


float[] freq_height = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};  //avg amplitude of each freq band

void setup()
{
  size(200, 200);

  minim = new Minim(this);
  port = new Serial(this, Serial.list()[3],38400); //set baud rate
 
  player = minim.loadFile(songs[songidx]);
 
  //in = minim.getLineIn(Minim.MONO,buffer_size,sample_rate);
 
  // create an FFT object that has a time-domain buffer 
  // the same size as line-in's sample buffer
  fft = new FFT(player.bufferSize(), player.sampleRate());
  // Tapered window important for log-domain display
  fft.window(FFT.HAMMING);

  // initialize peak-hold structures
  peaksize = 1+Math.round(fft.specSize()/binsperband);
  peaks = new float[peaksize];
  peak_age = new int[peaksize];
  
  sendToSerial(freq_array);
  sendToSerial(freq_array);
  sendToSerial(freq_array);
  
  player.play();
  sendToSerial(freq_array);

  //delay(320);
  //custom();

}

void setColors(int c1, int c2, int c3, int c4, int c5) 
{
  port.write((byte)c1);
  port.write((byte)c1);
  port.write((byte)c2);
  port.write((byte)c2);
  port.write((byte)c3);
  port.write((byte)c3);
  port.write((byte)c4);
  port.write((byte)c4);
  port.write((byte)c5);
  port.write((byte)c5);
  port.write(0xff); //write marker (0xff) for synchronization
  String joinedNumbers = join(nf(color_array, 2), " "); 
  println(joinedNumbers);  // Prints "8, 67, 5"
}

void custom()
{
setColors(215,0,0,0,0);delay(230);
setColors(215,215,0,0,0);delay(230);
setColors(0,0,0,0,0);delay(230);
setColors(215,0,0,0,0);delay(230);
setColors(215,215,0,0,0);delay(230);
setColors(215,215,215,0,0);delay(230);
setColors(0,0,0,0,0);delay(230);
setColors(215,0,0,0,0);delay(230);
setColors(215,215,0,0,0);delay(230);
setColors(215,215,215,0,0);delay(230);
setColors(0,0,0,0,0);delay(230);
setColors(215,0,0,0,0);delay(230);
setColors(215,215,0,0,0);delay(230);
setColors(215,215,215,0,0);delay(230);
setColors(0,0,0,0,0);delay(230);
setColors(215,0,0,0,0);delay(230);
setColors(215,215,0,0,0);delay(230);
setColors(215,215,215,0,0);delay(230);
setColors(0,0,0,0,0);delay(230);
setColors(215,0,0,0,0);delay(230);
setColors(215,215,0,0,0);delay(230);
setColors(215,215,215,0,0);delay(230);
setColors(0,0,0,0,0);delay(230);
setColors(0,0,0,0,0);delay(230);
setColors(215,0,0,0,0);delay(230);
setColors(0,215,0,0,0);delay(230);
setColors(0,215,0,0,0);delay(230);
setColors(0,0,0,0,0);delay(230);
setColors(215,0,0,0,0);delay(230);
setColors(215,215,0,0,0);delay(230);
setColors(215,215,215,0,0);delay(230);
setColors(0,0,0,0,0);delay(230);
setColors(0,215,0,0,0);delay(230);
setColors(0,0,215,0,0);delay(230);
setColors(0,0,215,0,0);delay(230);
setColors(0,0,0,215,0);delay(230);
setColors(0,0,0,0,215);delay(230);
setColors(0,0,0,0,215);delay(230);
setColors(215,0,0,0,0);delay(230);
setColors(215,0,0,0,0);delay(230);
setColors(0,215,0,0,0);delay(230);
setColors(0,0,215,0,0);delay(230);
setColors(0,0,0,215,0);delay(230);
setColors(0,0,0,215,0);delay(230);
setColors(0,0,0,215,0);delay(230);
setColors(215,0,0,0,0);delay(230);
setColors(215,0,0,0,0);delay(230);
setColors(0,215,0,0,0);delay(230);
setColors(0,0,0,215,0);delay(230);
setColors(0,0,0,215,0);delay(230);
setColors(0,0,0,215,0);delay(230);
exit();  
}




void draw2()
{
return;
}
  



void draw()
{
  background(0);
  stroke(255);
  
  // draw the waveforms
  // the values returned by left.get() and right.get() will be between -1 and 1,
  // so we need to scale them up to see the waveform
  // note that if the file is MONO, left.get() and right.get() will return the same value
  for(int i = 0; i < player.bufferSize() - 1; i++)
  {
    float x1 = map( i, 0, player.bufferSize(), 0, width );
    float x2 = map( i+1, 0, player.bufferSize(), 0, width );
    line( x1, 50 + player.left.get(i)*50, x2, 50 + player.left.get(i+1)*50 );
    line( x1, 150 + player.right.get(i)*50, x2, 150 + player.right.get(i+1)*50 );
  }
  
  // draw a line to show where in the song playback is currently located
  float posx = map(player.position(), 0, player.length(), 0, width);
  stroke(0,200,0);
  line(posx, 0, posx, height);
  
  
  
  for(int k=0; k<bands; k++){
    freq_array[k] = 0;
  }

  // perform a forward FFT on the samples in input buffer
  fft.forward(player.mix);
  
// Frequency Band Ranges      
  for(int j=0; j<bands; j++){
    freq_height[j] = fft.calcAvg(band_cutoffs[j], band_cutoffs[j+1]) * spectrum_height;
    float freq_item = freq_height[j]; 
    
    
    int wheelPos = max(0, min(240, (int)freq_item));
    //color_array[j] = Wheel(wheelPos);
    color_array[j] = wheelPos;
    freq_array[j] = wheelPos;
  }
  
  sendToSerial(freq_array);
  String joinedNumbers = join(nf(freq_array, 2), " "); 
  println(joinedNumbers);  // Prints "8, 67, 5"
  //delay(2); //delay for safety
  
  if (!player.isPlaying()) {
    songidx++;
    if (songidx < songs.length) {
      player = minim.loadFile(songs[songidx]);
      player.play();
    }
  }
}

void sendToSerial(int[] freq_array)
{
  //send to serial  
  for(i=0; i<leds; i++){
    port.write((byte)(freq_array[i]));
  }
  port.write(0xff); //write marker (0xff) for synchronization  
}

 
int Wheel(int WheelPos) {
  if(WheelPos < 60) {
   return encode6level(0, 5, WheelPos/10);
  } else if(WheelPos < 120) {
   WheelPos -= 60;
   return encode6level(0, 5-(WheelPos/10), 5);
  } else if(WheelPos < 180) {
   WheelPos -= 120;
   return encode6level(WheelPos/10, 0, 5);
  } else {
   WheelPos -= 180;
   return encode6level(5, 0, 5-(WheelPos/10));
  }
} 

int encode6level(int r, int g, int b) {
  return r*36+g*6+b; 
}
 
void stop()
{
  // always close Minim audio classes when you finish with them
  //in.close();
  player.close();
  minim.stop();
 
  super.stop();
}