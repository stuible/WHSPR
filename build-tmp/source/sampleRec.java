import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import pitaru.sonia_v2_9.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class sampleRec extends PApplet {

// Sample-recording example for Processing V90
// Description: Records sound from the active input device into a sample object.
// Instructions: Press the mouse to start recording. The recording will play back once upon mouse-release
// For PC: use the 'Sounds & Audio Devices' menu in the control panel to choose your input; Mic, wave, etc.
// For Mac: the current microphone device will be used as input.
// By: Amit Pitaru,  July 16th 2005

//http://sonia.pitaru.com/

 // added automatically when Sonia is imported from the processing menu.

Sample yourSecret; // The Sonia Sample object which we'll record into
Sample theirSecret;
int recTimeSec = 5; // number of seconds to record, determines the sample's max size. 
int recordCount = 1;
float pitchShiftTime;
float rate;
int pitchTimer = 0;
int fileCount;
String dataFolder = "WHSPR Recordings";

public void setup(){ 
  
  background(80,80,80);
  
  pitchShiftTime = random(0.9f, 5);
  Sonia.start(this); 
  LiveInput.start();  // start the liveInput engine (see liveInput example)
  yourSecret = new Sample(44100*recTimeSec); // Create an empty Sample object with 44100*10 frames (ten seconds of data). 
  
  //create Recordings Directory
  File theDir = new File(dataFolder);

  // if the directory does not exist, create it
  if (!theDir.exists()) {
      System.out.println("creating directory: " + theDir);
      boolean result = false;
  
      try{
          theDir.mkdir();
          result = true;
      } 
      catch(SecurityException se){
          //handle it
      }        
      if(result) {    
          System.out.println("DIR created");  
      }
  }
  fileCount = new File(dataFolder).list().length;
  println("There are " + fileCount + " secrets so far");
} 
 
public void draw(){
 background(80,80,80);
 strokeWeight(1); 
 // If sample is playing (or looping), do this...
           
 setRate(); // use mouseY to control sample-rate playback
 //setPan(); // use mouseX to control sample Panning
 //setVolume(); // use mouseX to control sample volume
 drawScroller();
 textSize(24);
 text("TELL ME YOUR SECRET", width / 2 - 125, height / 2);
} 

public void mousePressed(){ 
  yourSecret = new Sample(44100*recTimeSec);
  LiveInput.startRec(yourSecret); // Record LiveInput data into the Sample object. 
  // The recording will automatically end when all of the Sample's frames are filled with data. 
  println("REC");
} 

public void mouseReleased(){ 
  LiveInput.stopRec(yourSecret); 
  println("SAVEFILE");
    
  String basePath = new File("").getAbsolutePath();
  System.out.println(basePath);
  yourSecret.saveFile("WHSPR Recordings/secret" + recordCount);
  fileCount++;
  println("There are " + fileCount + " secrets so far");
  theirSecret = new Sample("WHSPR Recordings/secret" + random(1, recordCount) + ".wav"); 
  theirSecret.play();
  //yourSecret.play();
  println("PLAY");
  recordCount += 1;
} 
 
public void stop(){ 
  Sonia.stop(); 
  super.stop(); 
} 

public void setRate(){
   // set the speed (sampling rate) of the sample.
   // Values:
   // 0 -> very low pitch (slow playback).
   // 88200 -> very high pitch (fast playback).
   //float rate = (height - mouseY)*88200/(height);
   changePitch();
   yourSecret.setRate(rate);
}

public void drawScroller(){
 strokeWeight(2);
 stroke(235,0,0);

 // figure out which percent of the sample has been played.
 float percent = yourSecret.getCurrentFrame() *100f / yourSecret.getNumFrames();
 // calculate the marker position
 float marker = percent*width/100f;
 // draw...
 line(marker,0,marker,20);
 line(0,10, width,10);
}

public void changePitch(){
  //if (pitchTimer >= pitchShiftTime){
  //  if (random(0, 2) > 1){
  //    rate = (random(70, 80))*88200/(height);
  //  }
  //  else {
  //    rate = (random(120, 150))*88200/(height);
  //  }
    
      if (pitchTimer >= pitchShiftTime){
    if (pitchShiftTime < 2.6f){
      rate = (random(70, 80))*88200/(height);
    }
    else {
      rate = (random(130, 150))*88200/(height);
    }
  pitchTimer = 0;
  pitchShiftTime = random(0.9f, 3.4f);
  }
  else{
    pitchTimer++;
  }
}
  public void settings() {  size(400,200);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "sampleRec" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
