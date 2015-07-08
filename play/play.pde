String root = "/users/kitayui/desktop/imgs/";
File dir = new File(root);

String[] str;
PImage img;
int cnt = 1;

void setup() {
  str = dir.list();
  println(str);
  img = loadImage(root + cnt + ".png");
  size(img.width, img.height);
}

void draw() {
  img = loadImage(root + cnt++ + ".png");
  image(img, 0, 0);
}
