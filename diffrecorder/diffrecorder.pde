import java.util.concurrent.ArrayBlockingQueue;
import processing.video.*;

int numPixels;
int[] previousFrame;
Capture video;

void setup() {
  size(640, 480);
  video = new Capture(this, width, height);
  video.start(); 
  numPixels = video.width * video.height;
  previousFrame = new int[numPixels];
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
  println(movementSum);
  push(new Dframe(previousFrame, movementSum));
}

int cnt = 0;
void draw() {
  image(video, 0, 0);
}

ArrayBlockingQueue<Dframe> queue = new ArrayBlockingQueue<Dframe>(10);
void push(Dframe frame) {
  if (queue.size() >= 10) {
    queue.poll();
  }
  queue.add(frame);
}

class Dframe {
  Dframe(int[] in_frame, int in_diff) {
    frame = in_frame;
    diff = in_diff;
  }
  int[] frame;
  int diff;
}

float framesdiff() {
  for (int 