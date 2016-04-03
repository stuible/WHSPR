/**
* Read the state of the button from the Digital In pin and 
* then switch off the LED when the button is pressed and communicate 
* the button state over the Serial interface
*/

#define LEDPIN 13
#define INPIN 2

int state = LOW;

void setup() {
  Serial.begin(9600); // setup serial connection speed
  pinMode(LEDPIN, OUTPUT);
  pinMode(INPIN, INPUT);
}

void loop() {
  delay(10); // debounces switch
  int sensorValue = digitalRead(INPIN);
  if(state != sensorValue) {
    state = sensorValue; 
    digitalWrite(LEDPIN, sensorValue); // turns the LED on or off
    
    unsigned int state = sensorValue ;
    Serial.print(state, BIN);
    //Serial.println(sensorValue, DEC);
  }
}
