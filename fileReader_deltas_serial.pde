import processing.serial.*;
Serial myPort;

void setup() {
  size(100, 100);
  myPort = new Serial(this, "/dev/tty.usbserial", 9600);
  myPort.write("EcE");
  myPort.write("Ec%0B");
  
  parseFile();
}

void parseFile() {
  // Open the file from the createWriter() example
  BufferedReader reader = createReader("faceplot.plt");
  String line = null;
  try {
    while ((line = reader.readLine()) != null) {
      String[] pieces = split(line, ';');
      for(int i=0;i<pieces.length; i++){
        
        if(pieces[i].length() > 2){
          String firstTwo = pieces[i].substring(0,2);
          
          if(firstTwo.equals("PD")||firstTwo.equals("PU")){ //check if pen up or pen down
            if(pieces[i].length() > 2){ //check is command contains coords 
              String coords = pieces[i].substring(2); //strip pu and pd commands
              String point[] = split(coords,','); // divide to x and y values
              //println("pos:"+ i + "/" + pieces.length + " point x:"+point[0]+" point y:"+point[1]);
              print("pos:"+ i + "/" + pieces.length + " " + pieces[i]);
              myPort.write(pieces[i]+";");
              if(i>3&&i<pieces.length-1){ // set delay based on delta
                //previous point delta
                String oldCoords = pieces[i-1].substring(2);
                String oldPoint[] = split(oldCoords,',');
                float d = dist(float(point[0]),float(point[1]),float(oldPoint[0]),float(oldPoint[1]));
                println(" delta: "+int(d) + "; "  );
                if(int(d)>500)
                  delay(int(d*0.1));
                else{
                  if(int(d)>100){
                    delay(int(d*0.3));
                  }else{
                    delay(int(30));
                  }
                }// delay based on delta
              }else{
                println(";"); // delay based on default
                delay(200);
              }
            }
          }
        }else{
          // command doesn't contain coords
          println("pos:"+i+ "/" + pieces.length + " normal commands:"+pieces[i]);
          
          myPort.write(pieces[i]);
          myPort.write("VS1;");
          delay(100);
        }
      }
    }
    reader.close();
  } catch (IOException e) {
    e.printStackTrace();
  }
} 