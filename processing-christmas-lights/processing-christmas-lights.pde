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

float spectrum_height = 40.0; // determines range of dB shown

int max_freq = 16000;
int bands = 25;
int hz_per_band = max_freq / bands;

float[] band_cutoffs = {0,31.5,40,50,63,80,100,125,160,200,250,315,400,500,630,800,1000,1250,1600,2000,2500,3150,4000,5000,6300,8000,10000,30000};

int[] freq_array = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int i,g;
float f;


float[] freq_height = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};  //avg amplitude of each freq band

void setup()
{
  size(200, 200);

  minim = new Minim(this);
  port = new Serial(this, Serial.list()[3],19200); //set baud rate
 
  player = minim.loadFile("raiders.mp3");
 
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
  
  player.play();
  
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
  for(int k=0; k<bands; k++){
    freq_height[k] = fft.calcAvg(band_cutoffs[bands-k-1], band_cutoffs[bands-k]) * spectrum_height;
  }
   

// Amplitude Ranges  if else tree
  for(int j=0; j<bands; j++){    
    float freq_item = freq_height[j]; 
    /*
    if (freq_item > 200){freq_array[j] = 15;}
    else if (freq_item > 120){freq_array[j] = 14;}
    else if (freq_item > 110){freq_array[j] = 13;}
    else if (freq_item > 100){freq_array[j] = 12;}
    else if (freq_item > 90){freq_array[j] = 11;}
    else if (freq_item > 80){freq_array[j] = 10;}
    else if (freq_item > 70){freq_array[j] = 9;}
    else if (freq_item > 60){freq_array[j] = 8;}
    else if (freq_item > 50){freq_array[j] = 7;}
    else if (freq_item > 40){freq_array[j] = 6;}
    else if (freq_item > 30){freq_array[j] = 5;}
    else if (freq_item > 25){freq_array[j] = 4;}
    else if (freq_item > 10){freq_array[j] = 3;}
    else if (freq_item > 5){freq_array[j] = 2;}
    else if (freq_item > 1 ){freq_array[j] = 1;}
    else {freq_array[j] = 0;}  
    */
    
    freq_array[j] = max(0, min(254, (int)freq_item));
  }
  
  //send to serial
  port.write(0xff); //write marker (0xff) for synchronization
  
  for(i=0; i<bands; i++){
    port.write((byte)(freq_array[i]));
  }
  printArray(freq_array);
  //delay(2); //delay for safety
}
 
 
void stop()
{
  // always close Minim audio classes when you finish with them
  //in.close();
  player.close();
  minim.stop();
 
  super.stop();
}