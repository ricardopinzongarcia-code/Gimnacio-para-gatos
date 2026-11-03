import processing.serial.*;
import processing.video.*;

Serial myPort;

Movie[] videos = new Movie[3];

String[] archivos = {
  "NWTD.mp4",
  "TAME.mp4",
  "TRACK.mp4"
};

int distancia = 999;
int UMBRAL = 100;

int videoActual = -1;

boolean personaPresente = false;

void setup() {
  size(1280, 720);
  pixelDensity(1);

  // Cargar los tres vídeos
  for (int i = 0; i < videos.length; i++) {
    videos[i] = new Movie(this, archivos[i]);
    videos[i].pause();
  }

  // Conectar Arduino
  printArray(Serial.list());

  myPort = new Serial(this, "/dev/cu.usbmodem21101", 9600);
  myPort.bufferUntil('\n');
}

// Leer los vídeos
void movieEvent(Movie m) {
  m.read();
}

// Leer distancia del sensor
void serialEvent(Serial p) {

  String dato = p.readStringUntil('\n');

  if (dato != null) {

    dato = trim(dato);

    try {

      distancia = int(dato);

      println("Distancia: " + distancia + " cm");

      // Detectar acercamiento
      if (distancia > 0 &&
          distancia != 999 &&
          distancia <= UMBRAL) {

        // Solo cambiar cuando alguien acaba de acercarse
        if (!personaPresente) {

          personaPresente = true;

          // Pasar al siguiente vídeo
          videoActual++;

          if (videoActual >= videos.length) {
            videoActual = 0;
          }

          // Reproducir vídeo seleccionado
          videos[videoActual].play();

          println("Reproduciendo: " + archivos[videoActual]);
        }

      } else {

        // Detectar cuando alguien se aleja
        if (personaPresente) {

          personaPresente = false;

          // Pausar el vídeo actual
          if (videoActual >= 0) {
            videos[videoActual].pause();
          }

          println("Vídeo pausado");
        }
      }

    } catch (Exception e) {
      println("Error leyendo distancia");
    }
  }
}

// Mostrar vídeo
void draw() {

  background(0);

  if (videoActual >= 0) {

    if (videos[videoActual].width > 0) {
      image(videos[videoActual], 0, 0, width, height);
    }
  }
}
