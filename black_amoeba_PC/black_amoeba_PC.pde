

import processing.opengl.*;
import SimpleOpenNI.*;
import processing.serial.*;
import controlP5.*;
import processing.video.*;

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

// The kinect stuff is happening in another class
KinectTracker tracker;
Kinect kinect;

SimpleOpenNI simpleOpenNI;
SimpleOpenNI simpleOpenNI2;
ControlP5 cp5;
Accordion accordion;


long lastTime = 0;
long lastTime2 = 0;

int time = 2000;
int timeList = 0;



int dTime = 1000;
int emptyTime = 500;
boolean empty = false;

ArrayList<PVector> circle = new ArrayList<PVector>();
ArrayList<PVector> square = new ArrayList<PVector>();
ArrayList<PVector> morph = new ArrayList<PVector>();
boolean state = false;
boolean alphaBatMODE = false;


//boolean recordFlag = false;
boolean recordFlag = true;
boolean depthIMG = false;
boolean dotIMG = true;
boolean blackFish = false;

int briUPstep= 85;
int briDOWNstep= 15;
int magnetForce= 0;
int mForceVal= 0;





int MODE=0;
int Ccir=480;


// DISTANCE RANGE IN MILLIMETERS (FOR THE FILTER)
int minDistance  = 2000;  // 50cm
int maxDistance  = 2500; // 1.5m


int NUM_BOIDS = 0;
int lastBirthTimecheck = -5000;                // birth time interval
int addKoiCounter = 0;

ArrayList wanderers = new ArrayList();     // stores wander behavior objects
PVector mouseAvoidTarget;                  // use mouse location as object to evade
boolean press = false;                     // check is mouse is press
int mouseAvoidScope = 640;    

String[] skin = new String[10];

PImage canvas;
Ripple ripples;
boolean isRipplesActive = false;

PImage rocks;
PImage innerShadow;

// IMAGES
PImage maskImage;
PImage fishImage;

PImage rgbImage;
PImage pixImage;


String        recordPath = "test4.oni";
String        recordPath2 = "test1.oni";


// KINECT DEPTH VALUES
int[] depthValues;
int[] valA = new int[1000000];


// RADIUS FOR BLUR (PIXELS)
int currentRadius = 3;
Capture video;


// SIZES
int canvasWidth  = 480;
int canvasHeight = 480;

int kinectWidth  = 640;
int kinectHeight = 480;

boolean showFrameRate = false;
boolean first = true;

// FOR TAKING AUTOMATIC SCREEN GRABS
int     startTime        = millis();
boolean saved            = false;
// TAKE AN AUTOMATIC SCREENGRAB AFTER screenGrabMillis MILLIS

boolean takeScreenGrab   = false;

// TIME BEFORE THE AUTOMATIC SCREENGRAB WILL BE TAKEN
int     screenGrabMillis = 40000;


float blurBri=0;
color blurC;
float blurBriH=0;
color blurCH;





Serial myPort;


int pin;
int cellNum=0;
// Size of each cell in the grid
int cellSize = 40;
// Number of columns and rows in our system
int cols, rows;
// Variable for capture device
int val;

PImage depthImg;

// Which pixels do we care about?
int minDepth =  60;
int maxDepth = 860;



void setup() {
  size(480, 480, OPENGL);
  kinect = new Kinect(this);
  tracker = new KinectTracker();
  //kinect.initDepth();
  //depthImg = new PImage(kinect.width, kinect.height);


  lastTime = millis();


  // Create a circle using vectors pointing from center
  for (int angle = 0; angle < 360; angle += 9) {
    // Note we are not starting from 0 in order to match the
    // path of a circle.  
    PVector v = PVector.fromAngle(radians(angle-135));
    v.mult(100);
    circle.add(v);
    // Let's fill out morph ArrayList with blank PVectors while we are at it
    morph.add(new PVector());
  }

  // A square is a bunch of vertices along straight lines
  // Top of square
  for (int x = -50; x < 50; x += 10) {
    square.add(new PVector(x, -50));
  }
  // Right side
  for (int y = -50; y < 50; y += 10) {
    square.add(new PVector(50, y));
  }
  // Bottom
  for (int x = 50; x > -50; x -= 10) {
    square.add(new PVector(x, 50));
  }
  // Left side
  for (int y = 50; y > -50; y -= 10) {
    square.add(new PVector(-50, y));
  }


  // smooth();
  background(0);
  //frameRate(30);
  //frameRate(3000);

  rocks = loadImage("rocks.jpg");
  innerShadow = loadImage("pond.png");

  initKinect();
  maskImage  = createImage(kinectWidth, kinectHeight, RGB); 
  fishImage  = createImage(480, 480, RGB);



  //textSize(20);
  //frameRate(60);

  println(Serial.list());
  String portName = Serial.list()[3];
  myPort = new Serial(this, portName, 250000);


  // Set up columns and rows
  cols =  width / cellSize;
  rows = height / cellSize;
  colorMode(RGB, 255, 255, 255, 100);
  //background(0);
  ellipseMode(CENTER);



  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    video = new Capture(this, 640, 480);
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }


    noStroke();
    //smooth();
    gui();
    // video = new Capture(this, 640, 480);
    // video = new Capture(this, cameras[20]);
    video = new Capture(this, 640, 480, "FaceTime HD Camera", 1);
    // video = new Capture(this, 640, 480, "Logitech Webcam C930e", 1);
    //video.start(); 

    // init skin array images
    for (int n = 0; n < 10; n++) skin[n] = "skin-" + n + ".png";

    // this is the ripples code
    canvas = createImage(width, height, ARGB);
    ripples = new Ripple(canvas);
  }
}

void draw() {

  if ( millis() - lastTime > time ) {

emptyCell();
    lastTime = millis();

    /*  
     if(alphaBatMODE == false)
     {
     simpleOpenNI2.seekPlayer(10); 
     alphaBatMODE = true;
     }else{
     simpleOpenNI.seekPlayer(10);
     alphaBatMODE = false;
     }
     */

    MODE = 9;
    timeList = timeList + 1;

    //println("time");
  }







  background(0);

  /*
  if (simpleOpenNI.curFramePlayer() > 1100)
   {
   alphaBatMODE = true;
   initKinect();
   //simpleOpenNI.seekPlayer(10);
   
   println("true");
   }
   
   
   if (simpleOpenNI2.curFramePlayer() > 2400) {
   alphaBatMODE = false;
   initKinect();
   //simpleOpenNI2.seekPlayer(10);
   
   println("false");
   }
   
   */




  //fish move mode;
  if (MODE == 1) {
    // background(0);
    image(rocks, 0, 0);

    // adds new koi on a interval of time
    if (millis() > lastBirthTimecheck + 500) {
      lastBirthTimecheck = millis();
      if (addKoiCounter <=  NUM_BOIDS) addKoi();
    }

    // fish motion wander behavior
    for (int n = 0; n < wanderers.size (); n++) {
      Boid wanderBoid = (Boid)wanderers.get(n);
      // if mouse is press pick objects inside the mouseAvoidScope
      // and convert them in evaders
      if (press) {
        if (dist(mouseX, mouseY, wanderBoid.location.x, wanderBoid.location.y) <= mouseAvoidScope) {
          wanderBoid.timeCount = 0;
          wanderBoid.evade(mouseAvoidTarget);
        }
      } else {
        wanderBoid.wander();
      }
      wanderBoid.run();
    }


    // ripples code
    if (isRipplesActive == true) {
      refreshCanvas();
      ripples.update();
    }

    // image(innerShadow, 0, 0);


    minDistance = (int)cp5.getController("depth range").getArrayValue(0);
    maxDistance = (int)cp5.getController("depth range").getArrayValue(1);

    briUPstep = (int)cp5.getController("fade in speed").getValue();
    briDOWNstep = (int)cp5.getController("fade out speed").getValue();

    magnetForce = (int)cp5.getController("magnetForce").getValue();



    // BLACK BACKGROUND



    this.loadPixels();


    //fishImage.updatePixels();

    // BLUR THE B/W IMAGE
    if (currentRadius > 0) superFastBlur(currentRadius);

    // COMPENSATE FOR alternativeViewPointDepthToImage

    if (depthIMG == true) {
      image(fishImage, 0, 0, canvasWidth, canvasHeight);
    }


    for (int i = 0; i < rows; i++) {

      for (int j = 0; j < cols; j++) {

        // Where are we, pixel-wise?
        int x = j * cellSize;
        int y = i * cellSize;
        int loc = (this.width + x - 1) + y*this.width; // Reversing x to mirror the image
        //int loc = (rgbImage.width - x - 1) + y*rgbImage.width; // Reversing x to mirror the image

        // Each rect is colored white with a size determined by brightness
        color c = this.pixels[loc+40];

        val = (int)brightness(c);
        // val = (int)map(val, 0, 255, 0, 128);

        // blurCH = maskImage.pixels[loc];
        //blurBriH = (int)brightness(blurCH);

        fishImage.pixels[loc] = val;
        /*
if(val == 255){
         fishImage.pixels[loc] = 255;
         }else{
         fishImage.pixels[loc] = 0;
         }
         
        /*
         if (val == 255) {
         maskImage.pixels[loc] = 255;
         //maskImage.pixels[loc] = color(val);
         } else{
         maskImage.pixels[loc] = 0;
         }
         */
      }
    }

    fishImage.updatePixels();



    for (int i = 0; i < rows; i++) {

      for (int j = 0; j < cols; j++) {

        // Where are we, pixel-wise?
        int x = j * cellSize;
        int y = i * cellSize;
        int loc = (fishImage.width + x - 1) + y*fishImage.width; // Reversing x to mirror the image
        //int loc = (rgbImage.width - x - 1) + y*rgbImage.width; // Reversing x to mirror the image




        // Each rect is colored white with a size determined by brightness
        color cc = fishImage.pixels[loc];

        val = (int)brightness(cc);

        fishImage.pixels[loc] = color(val);
        /*
    if (val == 255) {
         // if (valA[loc] < 255 ) {
         //   valA[loc] = valA[loc] + briUPstep;
         //   fishImage.pixels[loc] = color(valA[loc]);
         //  } else {
         fishImage.pixels[loc] = color(255);
         // }
         }else{
         
         
         // if (valA[loc] > 0) {
         //  valA[loc] = valA[loc] - briDOWNstep;
         //  fishImage.pixels[loc] = color(valA[loc]);
         // } else {
         fishImage.pixels[loc] = color(0);
         // }
         
         }
         
         */
        if (dotIMG == true) {

          fill(fishImage.pixels[loc]);
          noStroke();
          ellipse(x + cellSize/2, y + cellSize/2, cellSize-4, cellSize-4);
        }

        myPort.write( "$LED" + "," + str(cellNum) + "," + str(val) + "\n");
        print("cellNum:"+cellNum + ", ");
        println("val:"+ val);

        cellNum++;
      }
    }
    cellNum=0;
  } else if (MODE == 2) {




    minDistance = (int)cp5.getController("depth range").getArrayValue(0);
    maxDistance = (int)cp5.getController("depth range").getArrayValue(1);

    briUPstep = (int)cp5.getController("fade in speed").getValue();
    briDOWNstep = (int)cp5.getController("fade out speed").getValue();

    magnetForce = (int)cp5.getController("magnetForce").getValue();
    //magnetForce = 55;

    stroke(255);
    strokeWeight(50);
    fill(0);


    //for(float i=480; i > 10; i=i-0.1){
    //ellipse(240, 220, mouseX, mouseX);

    if (Ccir > 0 ) {
      Ccir = Ccir - 10;
      ellipse(240, 220, Ccir, Ccir);
    } 


    //}



    this.loadPixels();

    background(0);

    // BLUR THE B/W IMAGE
    if (currentRadius > 0) superFastBlur(currentRadius);


    for (int i = 0; i < rows; i++) {

      for (int j = 0; j < cols; j++) {

        // Where are we, pixel-wise?
        int x = j * cellSize;
        int y = i * cellSize;
        int loc = (this.width + x - 1) + y*this.width; // Reversing x to mirror the image
        //int loc = (rgbImage.width - x - 1) + y*rgbImage.width; // Reversing x to mirror the image

        // Each rect is colored white with a size determined by brightness
        color c = this.pixels[loc+20];




        val = (int)brightness(c);


        fishImage.pixels[loc] = val;
      }
    }

    fishImage.updatePixels();



    for (int i = 0; i < rows; i++) {

      for (int j = 0; j < cols; j++) {

        // Where are we, pixel-wise?
        int x = j * cellSize;
        int y = i * cellSize;
        int loc = (fishImage.width + x - 1) + y*fishImage.width; // Reversing x to mirror the image
        //int loc = (rgbImage.width - x - 1) + y*rgbImage.width; // Reversing x to mirror the image




        // Each rect is colored white with a size determined by brightness

        color cc = fishImage.pixels[loc];

        mForceVal = 255 - magnetForce;

        if ((int)brightness(cc) - mForceVal >= 0) {
          val = (int)brightness(cc) - mForceVal;
          //  val = (int)map(val, 0, 255, 0, 128);
        } else {

          val = 0;
        }


        //val = (int)brightness(cc);

        fishImage.pixels[loc] = color(val);


        if (dotIMG == true) {
          fill(fishImage.pixels[loc]);
          noStroke();
          ellipse(x + cellSize/2, y + cellSize/2, cellSize-4, cellSize-4);
        }

        myPort.write( "$LED" + "," + str(cellNum) + "," + str(val) + "\n");
        print("cellNum:"+cellNum + ", ");
        println("val:"+ val);

        //  println("loc:"+ loc);

        cellNum++;
      }
    }
    cellNum=0;
  } else if (MODE == 3) {

    minDistance = (int)cp5.getController("depth range").getArrayValue(0);
    maxDistance = (int)cp5.getController("depth range").getArrayValue(1);

    briUPstep = (int)cp5.getController("fade in speed").getValue();
    briDOWNstep = (int)cp5.getController("fade out speed").getValue();

    magnetForce = (int)cp5.getController("magnetForce").getValue();

    morph1();
  } else if (MODE == 4) {

    minDistance = (int)cp5.getController("depth range").getArrayValue(0);
    maxDistance = (int)cp5.getController("depth range").getArrayValue(1);

    briUPstep = (int)cp5.getController("fade in speed").getValue();
    briDOWNstep = (int)cp5.getController("fade out speed").getValue();

    magnetForce = (int)cp5.getController("magnetForce").getValue();

    morph2();
  } else if (MODE == 5) {

    minDistance = (int)cp5.getController("depth range").getArrayValue(0);
    maxDistance = (int)cp5.getController("depth range").getArrayValue(1);

    briUPstep = (int)cp5.getController("fade in speed").getValue();
    briDOWNstep = (int)cp5.getController("fade out speed").getValue();

    magnetForce = (int)cp5.getController("magnetForce").getValue();

    morph3();
  } else if (MODE == 6) {

    minDistance = (int)cp5.getController("depth range").getArrayValue(0);
    maxDistance = (int)cp5.getController("depth range").getArrayValue(1);

    briUPstep = (int)cp5.getController("fade in speed").getValue();
    briDOWNstep = (int)cp5.getController("fade out speed").getValue();

    magnetForce = (int)cp5.getController("magnetForce").getValue();

    morph4();
  } else if (MODE == 7) {

    minDistance = (int)cp5.getController("depth range").getArrayValue(0);
    maxDistance = (int)cp5.getController("depth range").getArrayValue(1);

    briUPstep = (int)cp5.getController("fade in speed").getValue();
    briDOWNstep = (int)cp5.getController("fade out speed").getValue();

    magnetForce = (int)cp5.getController("magnetForce").getValue();

    averageP();
  }else if (MODE == 9) {

    minDistance = (int)cp5.getController("depth range").getArrayValue(0);
    maxDistance = (int)cp5.getController("depth range").getArrayValue(1);

    briUPstep = (int)cp5.getController("fade in speed").getValue();
    briDOWNstep = (int)cp5.getController("fade out speed").getValue();

    magnetForce = (int)cp5.getController("magnetForce").getValue();


    //sensor()220
   // sensor2();
    morphABC();
    
   
  }else if (MODE == 0) {

    sensor();


    minDistance = (int)cp5.getController("depth range").getArrayValue(0);
    maxDistance = (int)cp5.getController("depth range").getArrayValue(1);

    briUPstep = (int)cp5.getController("fade in speed").getValue();
    briDOWNstep = (int)cp5.getController("fade out speed").getValue();

    magnetForce = (int)cp5.getController("magnetForce").getValue();






    // BLACK BACKGROUND
    background(50);
    //fill(0,10);
    //rect(640,480,0,0);

    // UPDATE THE KINECT IMAGES

    if (alphaBatMODE == true)
    {
      simpleOpenNI2.update();
      depthValues = simpleOpenNI2.depthMap();
    } else {
      simpleOpenNI.update();
      depthValues = simpleOpenNI.depthMap();
    }

    // GET DEPTH VALUES IN MILLIMETERS
    //depthValues = simpleOpenNI.depthMap();

    maskImage.loadPixels();



    for (int pic = 0; pic < depthValues.length; pic++) {



      if (depthValues[pic] > minDistance && depthValues[pic] < maxDistance) {
        // IN RANGE: WHITE PIXEL


        blurCH = maskImage.pixels[pic];
        blurBriH = (int)brightness(blurCH);

        if (blurBriH < 255 ) {

          blurBriH = blurBriH + briUPstep;
          maskImage.pixels[pic] = color(blurBriH);
        } else {
          maskImage.pixels[pic] = color(255);
        }
      } else {

        //if(maskImage.pixels[pic] == color(0)){

        blurC = maskImage.pixels[pic];



        blurBri = (int)brightness(blurC);

        if (blurBri > 0) {

          blurBri = blurBri - briDOWNstep;
          maskImage.pixels[pic] = color(blurBri);
        } else {
          maskImage.pixels[pic] = color(0);
        }
      }
    }




    maskImage.updatePixels();

    // BLUR THE B/W IMAGE
    if (currentRadius > 0) superFastBlur(currentRadius);

    // MASK THE RGB CAM IMAGE
    //rgbImage = simpleOpenNI.depthImage();
    //rgbImage.mask(maskImage);

    //rgbImage.updatePixels();



    // COMPENSATE FOR alternativeViewPointDepthToImage

    if (depthIMG == true) {
      image(maskImage, 0, 0, canvasWidth, canvasHeight);
      tint(magnetForce);
    }



    for (int i = 0; i < rows; i++) {

      for (int j = 0; j < cols; j++) {

        // Where are we, pixel-wise?
        int x = j * cellSize;
        int y = i * cellSize;
        int loc = (maskImage.width + x - 1) + (y)*maskImage.width; // Reversing x to mirror the image
        //int loc = (rgbImage.width - x - 1) + y*rgbImage.width; // Reversing x to mirror the image

        // Each rect is colored white with a size determined by brightness
        color c = maskImage.pixels[loc+40];

        mForceVal = 255 - magnetForce;

        if (empty == true)
        {
          fill(0);
          rect(0, 0, canvasWidth, canvasHeight);
        } else {

          if ((int)brightness(c) - mForceVal >= 0) {
            val = (int)brightness(c) - mForceVal;
            //  val = (int)map(val, 0, 255, 0, 128);
          } else {

            val = 0;
          }
        }

        if (dotIMG == true) {
          fill(val);
          noStroke();
          ellipse(x + cellSize/2, (y) + cellSize/2, cellSize-4, cellSize-4);
        }

        /*
      myPort.write( "$LED");
         myPort.write(",");
         myPort.write(str(cellNum));
         myPort.write(",");
         myPort.write(str(val));
         myPort.write("\n");  
         */

        myPort.write( "$LED" + "," + str(cellNum) + "," + str(val) + "\n");
        //print("cellNum:"+cellNum + ", ");
        //println("val:"+ val);


        cellNum++;
      }
    }
    cellNum=0;
  } else if (MODE == 8) {

    sensor();
  }



  fill(50);
  ;
  // strokeWeight(1);
  //stroke(0);
  ellipse(0 + cellSize/2, 0 + cellSize/2, cellSize-4, cellSize-4);
  ellipse(40 + cellSize/2, 0 + cellSize/2, cellSize-4, cellSize-4);
  ellipse(80 + cellSize/2, 0 + cellSize/2, cellSize-4, cellSize-4);

  ellipse(360 + cellSize/2, 0 + cellSize/2, cellSize-4, cellSize-4);
  ellipse(400 + cellSize/2, 0 + cellSize/2, cellSize-4, cellSize-4);
  ellipse(440 + cellSize/2, 0 + cellSize/2, cellSize-4, cellSize-4);



  ellipse(0 + cellSize/2, 40 + cellSize/2, cellSize-4, cellSize-4);
  ellipse(40 + cellSize/2, 40 + cellSize/2, cellSize-4, cellSize-4);

  ellipse(400 + cellSize/2, 40 + cellSize/2, cellSize-4, cellSize-4);
  ellipse(440 + cellSize/2, 40 + cellSize/2, cellSize-4, cellSize-4);



  ellipse(0 + cellSize/2, 80 + cellSize/2, cellSize-4, cellSize-4);

  ellipse(440 + cellSize/2, 80 + cellSize/2, cellSize-4, cellSize-4);



  ellipse(0 + cellSize/2, 360 + cellSize/2, cellSize-4, cellSize-4);

  ellipse(440 + cellSize/2, 360 + cellSize/2, cellSize-4, cellSize-4);



  ellipse(0 + cellSize/2, 400 + cellSize/2, cellSize-4, cellSize-4);
  ellipse(40 + cellSize/2, 400 + cellSize/2, cellSize-4, cellSize-4);

  ellipse(400 + cellSize/2, 400 + cellSize/2, cellSize-4, cellSize-4);
  ellipse(440 + cellSize/2, 400 + cellSize/2, cellSize-4, cellSize-4);



  ellipse(0 + cellSize/2, 440 + cellSize/2, cellSize-4, cellSize-4);
  ellipse(40 + cellSize/2, 440 + cellSize/2, cellSize-4, cellSize-4);
  ellipse(80 + cellSize/2, 440 + cellSize/2, cellSize-4, cellSize-4);

  ellipse(360 + cellSize/2, 440 + cellSize/2, cellSize-4, cellSize-4);
  ellipse(400 + cellSize/2, 440 + cellSize/2, cellSize-4, cellSize-4);
  ellipse(440 + cellSize/2, 440 + cellSize/2, cellSize-4, cellSize-4);
}







// increments number of koi by 1
void addKoi() {
  int id = int(random(1, 11)) - 1;
  wanderers.add(new Boid(skin[id], 
  new PVector(random(100, width - 100), random(100, height - 100)), 
  random(0.8, 1.9), 0.2));
  Boid wanderBoid = (Boid)wanderers.get(addKoiCounter);
  // sets opacity to simulate deepth
  wanderBoid.maxOpacity = int(map(addKoiCounter, 0, NUM_BOIDS - 1, 255, 255));

  addKoiCounter++;
}


// use for the ripple effect to refresh the canvas
void refreshCanvas() {
  loadPixels();
  System.arraycopy(pixels, 0, canvas.pixels, 0, pixels.length);
  updatePixels();
}



void mousePressed() {
  press = true;
  mouseAvoidTarget = new PVector(mouseX, mouseY);

  if (isRipplesActive == true) ripples.makeTurbulence(mouseX, mouseY);
}

void mouseDragged() {
  mouseAvoidTarget.x = mouseX;
  mouseAvoidTarget.y = mouseY;

  if (isRipplesActive == true) ripples.makeTurbulence(mouseX, mouseY);
}

void mouseReleased() {
  press = false;
}
void gui() {

  cp5 = new ControlP5(this);

  // group number 1, contains 2 bangs
  /*
  Group g1 = cp5.addGroup("myGroup1")
   .setBackgroundColor(color(0, 64))
   .setBackgroundHeight(150)
   ;
   
   cp5.addBang("bang")
   .setPosition(10,20)
   .setSize(100,100)
   .moveTo(g1)
   .plugTo(this,"shuffle");
   ;
   
   // group number 2, contains a radiobutton
   Group g2 = cp5.addGroup("myGroup2")
   .setBackgroundColor(color(0, 64))
   .setBackgroundHeight(150)
   ;
   
   cp5.addRadioButton("radio")
   .setPosition(10,20)
   .setItemWidth(20)
   .setItemHeight(20)
   .addItem("black", 0)
   .addItem("red", 1)
   .addItem("green", 2)
   .addItem("blue", 3)
   .addItem("grey", 4)
   .setColorLabel(color(255))
   .activate(2)
   .moveTo(g2)
   ;
   */

  // group number 3, contains a bang and a slider
  Group g3 = cp5.addGroup("Black amoeba v0.1")
    .setBackgroundColor(color(255, 20))
      .setBackgroundHeight(130)
        ;

  cp5.addRange("depth range")
    .setPosition(10, 10)
      .setSize(400, 20)
        .setRange(0, 4000)
          .setRangeValues(0, 1000)
            .moveTo(g3)
              ; 

  cp5.addSlider("fade in speed")
    .setPosition(10, 40)
      .setSize(150, 20)
        .setRange(0, 255)
          .setValue(255)
            .moveTo(g3)
              ;

  cp5.addSlider("fade out speed")
    .setPosition(10, 70)
      .setSize(150, 20)
        .setRange(0, 255)
          .setValue(255)
            .moveTo(g3)
              ;

  cp5.addSlider("magnetForce")
    .setPosition(10, 100)
      .setSize(150, 20)
        .setRange(0, 255)
          .setValue(70)
            .moveTo(g3)
              ;



  // create a new accordion
  // add g1, g2, and g3 to the accordion.
  accordion = cp5.addAccordion("acc")
    .setPosition(0, 0)
      .setWidth(480)
        //.addItem(g1)
        //.addItem(g2)
        .addItem(g3)
          ;

  cp5.mapKeyFor(new ControlKey() {
    public void keyEvent() {
      accordion.open(0, 1, 2);
    }
  }
  , 'o');
  cp5.mapKeyFor(new ControlKey() {
    public void keyEvent() {
      accordion.close(0, 1, 2);
    }
  }
  , 'c');



  /*
  cp5.mapKeyFor(new ControlKey() {
   public void keyEvent() {
   accordion.setWidth(300);
   }
   }
   
   
   , '1');
   cp5.mapKeyFor(new ControlKey() {
   public void keyEvent() {
   accordion.setPosition(0, 0);
   accordion.setItemHeight(190);
   }
   }
   , '2'); 
   cp5.mapKeyFor(new ControlKey() {
   public void keyEvent() {
   accordion.setCollapseMode(ControlP5.ALL);
   }
   }
   , '3');
   cp5.mapKeyFor(new ControlKey() {
   public void keyEvent() {
   accordion.setCollapseMode(ControlP5.SINGLE);
   }
   }
   , '4');
   //cp5.mapKeyFor(new ControlKey() {public void keyEvent() {cp5.remove("myGroup1");}}, '0');
   
   //accordion.open(0);
   
   // use Accordion.MULTI to allow multiple group 
   // to be open at a time.
   accordion.setCollapseMode(Accordion.MULTI);
   
   // when in SINGLE mode, only 1 accordion  
   // group can be open at a time.  
   // accordion.setCollapseMode(Accordion.SINGLE);
   */
}

void initKinect()
{

  if (recordFlag)
  {
depthImg = new PImage(kinect.width, kinect.height);
    // NEW OPENNI CONTEXT INSTANCE
    simpleOpenNI = new SimpleOpenNI(this, recordPath);
    simpleOpenNI2 = new SimpleOpenNI(this, recordPath2);
    println("curFramePlayer: " + simpleOpenNI.curFramePlayer());
  } else
  { 
    simpleOpenNI = new SimpleOpenNI(this);
    if (simpleOpenNI.isInit() == false)
    {
      println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
      exit();
      return;
    }
  }   

  // MIRROR THE KINECT IMAGE
  simpleOpenNI.setMirror(true);
  simpleOpenNI2.setMirror(true);

  // ENABLE THE DEPTH MAP
  if (simpleOpenNI.enableDepth() == false)
  { // COULDN'T ENABLE DEPTH MAP
    println("Can't open the depthMap, maybe the Kinect is not connected!"); 
    exit();
    return;
  }

  // ENABLE THE RGB IMAGE
  if (simpleOpenNI.enableRGB() == false)
  { // COULDN'T ENABLE DEPTH MAP
    println("Can't open the Kinect cam, maybe the Kinect is not connected!"); 
    exit();
    return;
  }

  // ALIGN DEPTH DATA TO IMAGE DATA
  //simpleOpenNI.alternativeViewPointDepthToImage();
} // initKinect()

void keyPressed()
{
  boolean validKey = false;

  int t = tracker.getThreshold();
  if (key == CODED) {
    if (keyCode == UP) {
      t+=5;
      tracker.setThreshold(t);
    } else if (keyCode == DOWN) {
      t-=5;
      tracker.setThreshold(t);
    }
  }

  // KEY HANDLER
  switch(key)
  {
  case ' ':
    // sample play

    if (recordFlag == true) {
      recordFlag = false;
      initKinect();
    } else {
      recordFlag = true;
      initKinect();
    }

    return;






  case 'a':

    if (alphaBatMODE == true) {
      alphaBatMODE = false;
      initKinect();
    } else {
      alphaBatMODE = true;
      initKinect();
    }

    break;






  case '=':
    briDOWNstep = briDOWNstep + 5;
    break;
  case '-':
    briUPstep = briUPstep + 5;
    break;
  case '+':
    briDOWNstep = briDOWNstep - 5;
    break;
  case '_': 
    briUPstep = briUPstep - 5;
    break;

  case 'I':
  case 'i':
    // SHOW CURRENT SETTINGS
    validKey = true;    
    break;
  case 'M':
    // INCREASE THE MINIMUM DISTANCE BY 100mm
    minDistance += 100;
    validKey = true;    
    break;
  case 'm':
    // DECREASE THE MINIMUM DISTANCE BY 100mm
    minDistance -= 100;
    validKey = true;
    break;
  case 'X':
    // INCREASE THE MAXIMUM DISTANCE BY 100mm
    maxDistance += 100;
    validKey = true;    
    break;
  case 'x':
    // DECREASE THE MAXIMUM DISTANCE BY 100mm
    maxDistance -= 100;
    validKey = true;    
    break;

  case 'd':
    // depth image view
    if (depthIMG==false) {
      depthIMG = true;
    } else {
      depthIMG = false;
    }
    break;

  case 'f':
    // dot image view
    if (dotIMG==false) {
      dotIMG = true;
    } else {
      dotIMG = false;
    }
    break;

  case 'e':
    // empty image
    if (empty==false) {
      empty = true;
    } else {
      empty = false;
    }

    break;


  case '0':
    // black fish movie play
    //simpleOpenNI.seekPlayer(10);
    MODE = 0;
    break;

  case '1':
    // black fish movie play
    MODE = 1;
    break;

  case '2':
    // center reset
    MODE = 2;
    Ccir=480;
    break;

  case '3':
    // morphing
    MODE = 3;
    break;

  case '4':
    // morphing
    MODE = 4;
    break;

  case '5':
    // morphing
    MODE = 5;
    break;

  case '6':
    // morphing
    MODE = 6;
    break;
  case '`':
    // averagePoint
    //kinect = new Kinect(this);
    //tracker = new KinectTracker();
    MODE = 7;
    break;
  case '8':

    MODE = 8;
    break;

  case '9':

    MODE = 9;
    break;
  }
  // SHOW CURRENT SETTINGS
  if (validKey) showSettings();
} // keyPressed()

void showSettings()
{
  println("Blur: "+currentRadius+" Min: "+minDistance+" Max: "+maxDistance);
} // showSettings()


/*************************************************************
 
 MAKE A SCREENGRAB
 
 *************************************************************/
void takePicture()
{
  save("capture_"+timestamp()+".png");
  println("Picture taken...");
} // takePicture()


/*****************************************************************************************
 *
 * CREATE A TIME STAMP (YYYYMMDDHHMMSS)
 * 
 *****************************************************************************************/
String timestamp()
{
  return year()+nf(month(), 2)+nf(day(), 2)+nf(hour(), 2)+nf(minute(), 2)+nf(second(), 2);
} // timestamp()


/*************************************************************
 
 FINISH
 
 *************************************************************/
void stop()
{
  simpleOpenNI.dispose();
  simpleOpenNI2.dispose();

  super.stop();
} // stop()


void morph1()
{

  fill(magnetForce);
  noStroke();
  ellipse((5 * cellSize) + cellSize/2, (5 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((6 * cellSize) + cellSize/2, (5 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((7 * cellSize) + cellSize/2, (5 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((5 * cellSize) + cellSize/2, (6 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((7 * cellSize) + cellSize/2, (6 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((5 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((6 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((7 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);

  myPort.write( "$LED" + "," + str(52) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(53) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(54) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(64) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(66) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(76) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(77) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(78) + "," + str(magnetForce) + "\n");
}



void morph2()
{
  fill(magnetForce);
  noStroke();
  ellipse((6 * cellSize) + cellSize/2, (5 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((7 * cellSize) + cellSize/2, (5 * cellSize) + cellSize/2, cellSize-4, cellSize-4);

  ellipse((5 * cellSize) + cellSize/2, (6 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((8 * cellSize) + cellSize/2, (6 * cellSize) + cellSize/2, cellSize-4, cellSize-4);

  ellipse((5 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((8 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);

  ellipse((6 * cellSize) + cellSize/2, (8 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((7 * cellSize) + cellSize/2, (8 * cellSize) + cellSize/2, cellSize-4, cellSize-4);



  myPort.write( "$LED" + "," + str(53) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(54) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(64) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(67) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(89) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(90) + "," + str(magnetForce) + "\n");
}


void morph3()
{
  fill(magnetForce);
  noStroke();
  ellipse((7 * cellSize) + cellSize/2, (5 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((7 * cellSize) + cellSize/2, (6 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((7 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((7 * cellSize) + cellSize/2, (8 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((7 * cellSize) + cellSize/2, (9 * cellSize) + cellSize/2, cellSize-4, cellSize-4);

  myPort.write( "$LED" + "," + str(54) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(66) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(78) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(90) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(102) + "," + str(magnetForce) + "\n");
}

void morph4()
{
  fill(magnetForce);
  noStroke();
  ellipse((5 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((6 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((7 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((8 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((9 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);

  myPort.write( "$LED" + "," + str(76) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(77) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(78) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(79) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(80) + "," + str(magnetForce) + "\n");
}

void morphHi()
{
  fill(magnetForce);
  noStroke();
  ellipse((5 * cellSize) + cellSize/2, (5 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((6 * cellSize) + cellSize/2, (5 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((7 * cellSize) + cellSize/2, (5 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((5 * cellSize) + cellSize/2, (6 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((7 * cellSize) + cellSize/2, (6 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((5 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((6 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((7 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);

  myPort.write( "$LED" + "," + str(52) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(53) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(54) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(64) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(66) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(76) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(77) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(78) + "," + str(magnetForce) + "\n");
}

void averageP()
{
  sensor();
  background(0);

  // Run the tracking analysis
  tracker.track();
  // Show the image
  //tracker.display();

  // Let's draw the raw location
  PVector v1 = tracker.getPos();
  fill(255);
  noStroke();
  ellipse(v1.x, v1.y, 60, 60);

  // Let's draw the "lerped" location

  /*
  PVector v2 = tracker.getLerpedPos();
   fill(100, 250, 50, 200);
   noStroke();
   ellipse(v2.x, v2.y, 20, 20);
   */
  // Display some info
  int t = tracker.getThreshold();
  fill(0);
  text("threshold: " + t + "    " +  "framerate: " + int(frameRate) + "    " + 
    "UP increase threshold, DOWN decrease threshold", 10, 500);









  this.loadPixels();


  //fishImage.updatePixels();

  // BLUR THE B/W IMAGE
  if (currentRadius > 0) superFastBlur(currentRadius);

  // COMPENSATE FOR alternativeViewPointDepthToImage

  if (depthIMG == true) {
    image(fishImage, 0, 0, canvasWidth, canvasHeight);
  }


  for (int i = 0; i < rows; i++) {

    for (int j = 0; j < cols; j++) {

      // Where are we, pixel-wise?
      int x = j * cellSize;
      int y = i * cellSize;
      int loc = (this.width + x - 1) + y*this.width; // Reversing x to mirror the image
      //int loc = (this.width - x - 1) + y*this.width; // Reversing x to mirror the image

      // Each rect is colored white with a size determined by brightness
      color c = this.pixels[loc+40];

      val = (int)brightness(c);
      // val = (int)map(val, 0, 255, 0, 128);

      // blurCH = maskImage.pixels[loc];
      //blurBriH = (int)brightness(blurCH);

      fishImage.pixels[loc] = val;
      /*
if(val == 255){
       fishImage.pixels[loc] = 255;
       }else{
       fishImage.pixels[loc] = 0;
       }
       
      /*
       if (val == 255) {
       maskImage.pixels[loc] = 255;
       //maskImage.pixels[loc] = color(val);
       } else{
       maskImage.pixels[loc] = 0;
       }
       */
    }
  }

  fishImage.updatePixels();



  for (int i = 0; i < rows; i++) {

    for (int j = 0; j < cols; j++) {

      // Where are we, pixel-wise?
      int x = j * cellSize;
      int y = i * cellSize;
      int loc = (fishImage.width + x - 1) + y*fishImage.width; // Reversing x to mirror the image
      //int loc = (fishImage.width - x - 1) + y*fishImage.width; // Reversing x to mirror the image

      // Each rect is colored white with a size determined by brightness
      color cc = fishImage.pixels[loc];

      val = (int)brightness(cc);

      fishImage.pixels[loc] = color(val);

      if (dotIMG == true) {

        fill(fishImage.pixels[loc]);
        noStroke();
        ellipse(x + cellSize/2, y + cellSize/2, cellSize-4, cellSize-4);
      }

      myPort.write( "$LED" + "," + str(cellNum) + "," + str(val) + "\n");
      print("cellNum:"+cellNum + ", ");
      println("val:"+ val);

      cellNum++;
    }
  }
  cellNum=0;
}

void sensor()
{
  int sensorP=0; 
  //background(100);
  // Threshold the depth image
  int[] rawDepth = kinect.getRawDepth();
  for (int i=0; i < rawDepth.length; i++) {
    if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
      depthImg.pixels[i] = color(255);
      sensorP = sensorP + 1;
    } else {
      depthImg.pixels[i] = color(0);
    }
  }

  if (sensorP > 90000) {
    MODE = 7;
  } else if (sensorP < 30000) {
    MODE = 0;
  }



  // Draw the thresholded image
  depthImg.updatePixels();
  image(depthImg, 0, 0);
}

void sensor2()
{
  int sensorP=0; 
  //background(100);
  // Threshold the depth image
  int[] rawDepth = kinect.getRawDepth();
  for (int i=0; i < rawDepth.length; i++) {
    if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
      depthImg.pixels[i] = color(255);
      sensorP = sensorP + 1;
    } else {
      depthImg.pixels[i] = color(0);
    }
  }

  if (sensorP > 90000) {
    MODE = 7;
  } else if (sensorP < 30000) {
    MODE = 9;
  }



  // Draw the thresholded image
  depthImg.updatePixels();
  image(depthImg, 0, 0);
}





void morphABC()
{
  

  if (timeList == 1){
  fill(magnetForce);
  noStroke();
  ellipse((4 * cellSize) + cellSize/2, (5 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((5 * cellSize) + cellSize/2, (5 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((6 * cellSize) + cellSize/2, (5 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((4 * cellSize) + cellSize/2, (6 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((6 * cellSize) + cellSize/2, (6 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((4 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((5 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((6 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);

  myPort.write( "$LED" + "," + str(64) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(65) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(66) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(76) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(78) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(88) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(89) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(90) + "," + str(magnetForce) + "\n");
  println("timeList 2");
   time = 2000; 
  }
 

  else if (timeList == 2){
  fill(magnetForce);
  noStroke();
  ellipse((5 * cellSize) + cellSize/2, (4 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((5 * cellSize) + cellSize/2, (5 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((5 * cellSize) + cellSize/2, (6 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((5 * cellSize) + cellSize/2, (7 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((5 * cellSize) + cellSize/2, (8 * cellSize) + cellSize/2, cellSize-4, cellSize-4);

  myPort.write( "$LED" + "," + str(53) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(65) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(77) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(89) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(101) + "," + str(magnetForce) + "\n");
    println("timeList 4");
     time = 2000; 
  }





  else if (timeList == 3){
  fill(magnetForce);
  noStroke();
  ellipse((3 * cellSize) + cellSize/2, (6 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((4 * cellSize) + cellSize/2, (6 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((5 * cellSize) + cellSize/2, (6 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((6 * cellSize) + cellSize/2, (6 * cellSize) + cellSize/2, cellSize-4, cellSize-4);
  ellipse((7 * cellSize) + cellSize/2, (6 * cellSize) + cellSize/2, cellSize-4, cellSize-4);

  myPort.write( "$LED" + "," + str(75) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(76) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(77) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(78) + "," + str(magnetForce) + "\n");
  myPort.write( "$LED" + "," + str(79) + "," + str(magnetForce) + "\n");
    println("timeList 5");
     time = 2000; 
  }
 
   else if (timeList == 4){
     time = 41000;
  timeList = 0;
      MODE = 0;
  simpleOpenNI.seekPlayer(10);
   }
  

}

void emptyCell()
{
  
  for(int i=0 ; i <= 144 ; i++)
  {
      myPort.write( "$LED" + "," + str(i) + "," + str(0) + "\n");
  }
  
}