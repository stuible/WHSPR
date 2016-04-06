//Import libraries
import pitaru.sonia_v2_9.*;
import java.io.*;
import processing.serial.*;

// Fonts
PFont helveticaFont;
PFont dinFont;
PFont futuraFont;
PFont walkwayfontLarge;
PFont futurafontLarge;

// Create Samples Objects
Sample yourSecret; // Object that will be recorded into
Sample theirSecret; // Object that will load a random previously recorded clip
Sample yourSecretCropped;

// Global Variables
int recTimeSec = 30; // Maximum size of sample in seconds
float minRecTime = 0.7;
int recordCount;
float pitchShiftTime;
int tooShortWarningTimer;
boolean tooShortWarning;
int heardSecretCount;
float rate;
int pitchTimer = 0;
int secretBankSize = 10;
int fileCount;
String instructionString1;
String instructionString2;
String dataFolder = "WHSPR Recordings";  // Folder where the secrets will be stored
String dataFolderHeard = "WHSPR Recordings/Heard";
boolean mouseDown; //Gobal mouseDown boolean
int timeSinceRecStart;
int numberOfSecrtesThisSession;

ArrayList<PVector> points1 = new ArrayList<PVector>();
ArrayList<PVector> points2 = new ArrayList<PVector>();

//Serial Variables
Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
int state = 31;
int buttonDown = 1;

File location = null;
File newLocation = null;

void setup(){ 
  //size(400,150);
  size(displayWidth, displayHeight);
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
  walkwayfontLarge = loadFont("Walkway-100.vlw");
  futurafontLarge = loadFont("FuturaLT-Light-100.vlw");
  
  instructionString1 = "Press and Hold the Green Button";
  instructionString2 = "Tell me a secret then release the button";
  
  //setup serial
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);
  
  //create Recordings Directory
  File theDir = new File(dataFolder);
  File theHeardDir = new File(dataFolderHeard);

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
  
  if (!theHeardDir.exists()) {
      System.out.println("creating directory: " + theHeardDir);
      boolean result = false;
  
      try{
          theHeardDir.mkdir();
          result = true;
      } 
      catch(SecurityException se){
          //handle it
      }        
      if(result) {    
          System.out.println("Heard DIR created");  
      }
  }
  
    //check and display .wav file count of our recordings folder
    FilenameFilter ff = new FilenameFilter() {
      public boolean accept(File theDir, String name) {
         return name.endsWith(".wav");
          }
        };
    
    FilenameFilter ffh = new FilenameFilter() {
      public boolean accept(File theHeardDir, String name) {
         return name.endsWith(".wav");
          }
        };

     String[] theList = theDir.list(ff);
     int secretCount = theList.length;
     
     String[] theHeardList = theHeardDir.list(ffh);
     
     
     heardSecretCount = theHeardList.length;
     fileCount = secretCount;
     recordCount = fileCount;
     numberOfSecrtesThisSession = fileCount;
     println("There are " + fileCount + " secrets so far");
     
     points1.add(new PVector(random(25, width - 25), random(25, height - 25)));
     points2.add(new PVector(random(25, width - 25), random(25, height - 25)));
     
     for (int i = 1; i < fileCount; i++) {
      points1.add(points2.get(i - 1));
      points2.add(new PVector(random(25, width - 25), random(25, height - 25)));
  }
} 
 
void draw(){
 background(80,80,80);
 strokeWeight(1);
 
 for (int i = 0; i < points1.size(); i++) {
   ellipseMode(CENTER);
   stroke(#626262);
   fill(#626262);
  line(points1.get(i).x, points1.get(i).y, points2.get(i).x, points2.get(i).y);
  ellipse(points1.get(i).x, points1.get(i).y, 15, 15);
  }
 
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
 instructionString1 = "A Secret";
 instructionString2 = "";
 }
 if (theirSecret != null && !theirSecret.isPlaying() && !mouseDown && !tooShortWarning) {
  instructionString1 = "Press and Hold the Green Button";
  instructionString2 = "Tell me a secret then release the button";
 }
 if (tooShortWarning && tooShortWarningTimer < 5 * 30){
   instructionString1 = "Secret was too short,";
   instructionString2 = "surely you have more to say?";
   tooShortWarningTimer++;
 }
 else {
   tooShortWarning = false;
   tooShortWarningTimer = 0;
 }
 
 textFont(futurafontLarge, 75);
 fill(150);
 textAlign(CENTER, CENTER);
 text(instructionString1, width / 2, height / 2 - 50);
 text(instructionString2, width / 2, height / 2 + 50);
 textFont(futuraFont, 30);
 text(numberOfSecrtesThisSession + " Secrets have been shared", width / 2, 50);
 drawScroller();
 if(mouseDown){

   }
   
} 

void mousePressed(){ 
  if((yourSecret == null || !yourSecret.isPlaying()) && (theirSecret == null || !theirSecret.isPlaying()) && (yourSecretCropped == null|| !yourSecretCropped.isPlaying())){

  mouseDown = true;
  instructionString1 = "Recording Your Secret";
  instructionString2 = "";
  yourSecret = new Sample(44100*recTimeSec);
  theirSecret = yourSecret;
  LiveInput.startRec(yourSecret); // Record LiveInput data into the Sample object. 
  // The recording will automatically end when all of the Sample's frames are filled with data. 
  println("REC");
  }
} 

void mouseReleased(){ 
  if((yourSecret == null || !yourSecret.isPlaying()) && (theirSecret == null || !theirSecret.isPlaying()) && (yourSecretCropped == null|| !yourSecretCropped.isPlaying())){
  mouseDown = false;
  LiveInput.stopRec(yourSecret); 
  float[] frames = new float[yourSecret.getNumFrames()];
  yourSecret.read(frames); 
  int endframe = yourSecret.getNumFrames();
  int zeroCounter = 0;   
   for (int i = 0; i < frames.length; i++) {
     if (frames[i]==0)
       zeroCounter++;
     else 
       zeroCounter = 0;
     if (zeroCounter == 100) 
       endframe = i;
   }
   println("sample length: "+endframe/44100f);    

   float[] data = new float[endframe];
   System.arraycopy(frames, 0, data, 0, endframe);

   yourSecretCropped = new Sample(data.length);
   yourSecretCropped.write(data);
  
  if(yourSecretCropped.getNumFrames() > 44100 * minRecTime){
    println("SAVEFILE");
    String basePath = new File("").getAbsolutePath();
    System.out.println(basePath);
    recordCount += 1;
    addNewPoint();
    
    yourSecretCropped.saveFile("WHSPR Recordings/secret" + recordCount);
    
    fileCount++;
    numberOfSecrtesThisSession++;
    
    println("There are " + fileCount + " secrets so far");
    println("WHSPR Recordings/secret" + random(1, recordCount) + ".wav");
    int randomClip = (int) random(1, recordCount);
    if(recordCount != 1){
    theirSecret = new Sample("WHSPR Recordings/secret" + randomClip + ".wav"); 
    setPitch();
    theirSecret.play();
    if(fileCount >= secretBankSize){
    location = new File("WHSPR Recordings/secret" + randomClip + ".wav");
    newLocation = new File("WHSPR Recordings/Heard/secret" +  heardSecretCount + ".wav");
    location.renameTo(newLocation);
    
    location = new File("WHSPR Recordings/secret" + fileCount + ".wav");
    newLocation = new File("WHSPR Recordings/secret" + randomClip + ".wav");
    location.renameTo(newLocation);
    
    fileCount--;
    recordCount--;
    heardSecretCount++;
    }
    
    }
  
    println("PLAY");
    println("There are " + recordCount + " secrets so far");
  }
  else {
    println("Recording Too Short");
    tooShortWarning = true;
  }
  }
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

void addNewPoint(){
  points1.add(points2.get(points1.size() - 1));
  points2.add(new PVector(random(25, width - 25), random(25, height - 25)));
}

void changePitch(){
    //modulate pitch
    if (pitchTimer >= pitchShiftTime){
      if (pitchShiftTime < 6.5){
        rate = (random(60, 70))*88200/(100);
      }
      else {
        //rate = (random(130, 140))*88200/(height);
        rate = (random(40, 43))*88200/(100);
      }
  rate = (random(40, 43))*88200/(100);    
  pitchTimer = 0;
  pitchShiftTime = random(4, 9);
  //Bypass glitchy modulated pitch code, for now
  
  }
  else{
  pitchTimer++;
  }
}

