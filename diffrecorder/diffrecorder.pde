import java.util.concurrent.ArrayBlockingQueue;
import processing.video.*;

int numPixels;
int[] previousFrame;
Capture video;
int diffsum = 0;
PImage saveimg = createImage(640, 480, RGB);

void setup() {
  size(640, 480);
  video = new Capture(this, width, height);
  video.start(); 
  numPixels = video.width * video.height;
  previousFrame = new int[numPixels];
  for (int x = 0; x < saveimg.width; x++) {
    for (int y = 0; y < saveimg.height; y++) {
      saveimg.set(x, y, 0);
    }
  }
  loadPixels();
}

void captureEvent(Capture c) {
  c.read();
  c.updatePixels();
  int movementSum = 0;
  for (int i = 0; i < numPixels; i++) {
    color currColor = video.pixels[i];
    color prevColor = previousFrame[i];
    int currR = (currColor >> 16) & 0xFF;
    int currG = (currColor >> 8) & 0xFF;
    int currB = currColor & 0xFF;
    int prevR = (prevColor >> 16) & 0xFF;
    int prevG = (prevColor >> 8) & 0xFF;
    int prevB = prevColor & 0xFF;
    int diffR = abs(currR - prevR);
    int diffG = abs(currG - prevG);
    int diffB = abs(currB - prevB);
    movementSum += diffR + diffG + diffB;
    previousFrame[i] = currColor;
  }
  push(new Dframe(previousFrame, movementSum));
}

void draw() {
  image(video, 0, 0);
  if (diffsum > thre) {
    fill(255, 0, 0);
    ellipse(100, 100, 100, 100);
    if (queue.size() >= 10) {
      saveframes();
    }
  }
}

ArrayBlockingQueue<Dframe> queue = new ArrayBlockingQueue<Dframe>(10);
void push(Dframe frame) {
  if (queue.size() >= 10) {
    Dframe f = queue.poll();
    diffsum -= f.diff;
  }
  queue.add(frame);
  diffsum += frame.diff;
}

int cnt = 0;
String prefix = "";
void saveframes() {
  for (Dframe f : queue) {
    for (int i = 0; i < saveimg.width * saveimg.height; i++) {
      saveimg.pixels[i] = f.frame[i];
    }
    saveimg.updatePixels();
    prefix = "";
    for (int i = 0; i < (10 - cnt / 10); i++) {
      prefix += "0";
    }
    saveimg.save("/users/yuikita/desktop/imgs/" + prefix + cnt++ + ".png");
  }
}

class Dframe {
  Dframe(int[] in_frame, int in_diff) {
    frame = in_frame;
    diff = in_diff;
  }
  int[] frame;
  int diff;
}

int thre = 40000000;
void keyPressed() {
  if (key == 'a') {
    thre += 5000000;
  } else if (key == 'A') {
    thre -= 5000000;
  }
  println(thre);
}

