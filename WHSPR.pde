//Import libraries
import pitaru.sonia_v2_9.*;
import java.io.*;
import processing.serial.*;

// Fonts
PFont helveticaFont;
PFont dinFont;
PFont futuraFont;

// Create Samples Objects
Sample yourSecret; // Object that will be recorded into
Sample theirSecret; // Object that will load a random previously recorded clip

// Global Variables
int recTimeSec = 5; // Maximum size of sample in seconds
int recordCount;
float pitchShiftTime;
float rate;
int pitchTimer = 0;
int fileCount;
String dataFolder = "WHSPR Recordings";  // Folder where the secrets will be stored
boolean mouseDown; //Gobal mouseDown boolean
int timeSinceRecStart;

//Serial Variables
Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
int state = 31;
int buttonDown = 1;

void setup(){ 
  size(400,150);
  background(80,80,80);
  smooth();
  pitchShiftTime = random(2, 8);
  Sonia.start(this); 
  LiveInput.start();  // start the liveInput engine
  yourSecret = new Sample(44100*recTimeSec); // Create an empty Sample object with sample rate * clip length in seconds
  
  //load font
  helveticaFont = loadFont("HelveticaNeue-UltraLight-24.vlw");
  dinFont = loadFont("DINPro-Light-24.vlw");
  futuraFont = loadFont("FuturaLT-Book-24.vlw");
  
  //setup serial
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);
  
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
  
  //check and display file count of our recordings folder OLD WAY
  //  fileCount = new File(dataFolder).list().length - 1;
  //  recordCount = fileCount;
  //  println("There are " + fileCount + " secrets so far");
  
    //check and display .wav file count of our recordings folder
    FilenameFilter ff = new FilenameFilter() {
      public boolean accept(File theDir, String name) {
         return name.endsWith(".wav");
          }
        };

     String[] theList = theDir.list(ff);
     int secretCount = theList.length;
     fileCount = secretCount;
     recordCount = fileCount;
     println("There are " + fileCount + " secrets so far");
} 
 
void draw(){
 background(80,80,80);
 strokeWeight(1);
 
 if(myPort.available() > 0) {
    state = myPort.read();;
    
    buttonDown = state & 1;
    
    if(buttonDown == 1){
      println("Button Down");
      mousePressed();
    }
    else {
      println("Button Up");
      mouseReleased();
    }
    
  }
 
 if(theirSecret != null && theirSecret.isPlaying()){
 setPitch();
 }
 
 textFont(helveticaFont, 24);
 fill(150);
 text("TELL ME YOUR SECRET", width / 2 - 125, height / 2);
 drawScroller();
} 

void mousePressed(){ 
  mouseDown = true;
  yourSecret = new Sample(44100*recTimeSec);
  theirSecret = yourSecret;
  LiveInput.startRec(yourSecret); // Record LiveInput data into the Sample object. 
  // The recording will automatically end when all of the Sample's frames are filled with data. 
  println("REC");
} 

void mouseReleased(){ 
  mouseDown = false;
  LiveInput.stopRec(yourSecret); 
  println("SAVEFILE");
    
  String basePath = new File("").getAbsolutePath();
  System.out.println(basePath);
  recordCount += 1;
  yourSecret.saveFile("WHSPR Recordings/secret" + recordCount);
  fileCount++;
  println("There are " + fileCount + " secrets so far");
  println("WHSPR Recordings/secret" + random(1, recordCount) + ".wav");
  if(recordCount != 1){
  theirSecret = new Sample("WHSPR Recordings/secret" + (int) random(1, recordCount) + ".wav"); 
  setPitch();
  theirSecret.play();
  }
  
  println("PLAY");
  println("There are " + recordCount + " secrets so far");
} 
 
public void stop(){ 
  Sonia.stop(); 
  super.stop(); 
} 

void setPitch(){
   // set the speed (sampling rate) of the sample.
   // Values:
   // 0 -> very low pitch (slow playback).
   // 88200 -> very high pitch (fast playback).
   //float rate = (height - mouseY)*88200/(height);
   changePitch();
   theirSecret.setRate(rate);
}

void drawScroller(){
 if(mouseDown){
 strokeWeight(2);
 stroke(235,0,0);
 
 // Figure out which percent of the sample has been played.
 float percent = map(timeSinceRecStart, 0, 100, 0 , recTimeSec);
 
 // Calculate the marker position
 float marker = map(timeSinceRecStart, 0, 60 * recTimeSec, 0, width);
 
 // Draw
 line(marker,0,marker,height);
 stroke(235,0,0,0);
 fill(235,0,0, 100);
 rect(0,0,marker,height);
 timeSinceRecStart++;
 }
 else if (theirSecret != null){
 strokeWeight(2);
 stroke(235,0,0);
 
 // Figure out which percent of the sample has been played.
 float percent = theirSecret.getCurrentFrame() *100f / theirSecret.getNumFrames();
 
 // Calculate the marker position
 float marker = percent*width/100f;
 
 // Draw
 line(marker,0,marker,height);
 stroke(235,0,0,0);
 fill(235,0,0, 100);
 rect(0,0,marker,height);
 timeSinceRecStart = 0; 
 }
}

void changePitch(){
    //modulate pitch
    if (pitchTimer >= pitchShiftTime){
      if (pitchShiftTime < 6){
        rate = (random(70, 80))*88200/(height);
      }
      else {
        //rate = (random(130, 140))*88200/(height);
        rate = (random(60, 80))*88200/(height);
      }
      
  pitchTimer = 0;
  pitchShiftTime = random(2, 8);
  //Bypass glitchy modulated pitch code, for now
  rate = (50)*88200/(height);
  }
  else{
  pitchTimer++;
  }
}

