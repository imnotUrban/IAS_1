// PSO de acuerdo a Talbi (p.247 ss)

PImage surf; // imagen que entrega el fitness

// ===============================================================
int puntos = 2000;
Particle[] fl; // arreglo de partículas
float d = 15; // radio del círculo, solo para despliegue
float gbestx, gbesty, gbest; // posición y fitness del mejor global
float w = 1000; // inercia: baja (~50): explotación, alta (~5000): exploración (2000 ok)
float C1 = 30, C2 =  10; // learning factors (C1: own, C2: social) (ok)
int evals = 0, evals_to_best = 0; //número de evaluaciones, sólo para despliegue
float maxv = 0.025; // max velocidad (modulo)

//Dominio de la funcion
float min = -4.5; //-3
float max = 4.5; // 7

float BestValues[] = new float[100];
int BestValues_i[] = new int[100];

class Particle{
  float x, y, fit; // current position(x-vector)  and fitness (x-fitness)
  float px, py, pfit; // position (p-vector) and fitness (p-fitness) of best solution found by particle so far
  float vx, vy; //vector de avance (v-vector)
  
  // ---------------------------- Constructor
  Particle(){
    
    x = random (min,max); y = random(min,max);
    vx = random(-1,1) ; vy = random(-1,1);

    pfit = pow(10,5); fit = pow(10,5); //Numero menor inicial (nunca hay uno menor que este)
    //pfit = -1; fit = -1; //asumiendo que no hay valores menores a -1 en la función de evaluación
  }
  
  // ---------------------------- Evalúa partícula


  float Eval(){
    evals++;
    //color c=surf.get(int(x),int(y)); // obtiene color de la imagen en posición (x,y)
    //fit = red(c); //evalúa por el valor de la componente roja de la imagen
    fit = 10*2 + pow(x,2) - 10*cos(2*PI*x) + pow(y,2) - 10*cos(2*PI*y);

    if(fit < pfit){ // actualiza local best si es mejor
      pfit = fit;
      px = x;
      py = y;
    }
    if (fit < gbest){ // actualiza global best
      gbest = fit;
      gbestx = x;
      gbesty = y;
      evals_to_best = evals;
      println(str(gbest));
    };
    return fit; //retorna la componente roja
  }
  
  // ------------------------------ mueve la partícula
  void move(){
    //actualiza velocidad (fórmula con factores de aprendizaje C1 y C2)

    //Creo que debemos usar esta
    vx = vx + random(0,1)*C1*(px - x) + random(0,1)*C2*(gbestx - x);
    vy = vy + random(0,1)*C1*(py - y) + random(0,1)*C2*(gbesty - y);
    //actualiza velocidad (fórmula con inercia, p.250)
    //vx = w * vx + random(0,1)*(px - x) + random(0,1)*(gbestx - x);
    //vy = w * vy + random(0,1)*(py - y) + random(0,1)*(gbesty - y);
    //actualiza velocidad (fórmula mezclada)
    //vx = w * vx + random(0,1)*C1*(px - x) + random(0,1)*C2*(gbestx - x);
    //vy = w * vy + random(0,1)*C1*(py - y) + random(0,1)*C2*(gbesty - y);
    // trunca velocidad a maxv
    float modu = sqrt(vx*vx + vy*vy);
    if (modu > maxv){
      vx = vx/modu*maxv;
      vy = vy/modu*maxv;
    }
    // update position
    x = x + vx;
    y = y + vy;
    // rebota en murallas
    if (x > max || x < min) vx = - vx;
    if (y > max || y < min) vy = - vy;
  }
  
  // ------------------------------ despliega partícula
  void display(){

    //Esto no lo entiendo
    int ejeX = int( (max+x)/(2*max) * width );
    int ejeY = int( abs(y-min)/(2*max) * height );
    
    color c=surf.get(ejeX, ejeY);
    fill(c);
    ellipse (ejeX,ejeY,d,d); 
    // dibuja vector
    stroke(#ff0000);
    // dibuja vector
    line(ejeX,ejeY, ejeX - 1000*vx, ejeY + 1000*vy );
  }
} //fin de la definición de la clase Particle


// dibuja punto azul en la mejor posición y despliega números
void despliegaBest(){
  
  int bestEjeX = int( (max+gbestx)/(2*max) * width );
  //Quizas aca es abs(gbesty-min)
  int bestEjeY = int( abs(gbesty-min)/(2*max) * height);
  
  fill(#0000ff);
  ellipse(bestEjeX,bestEjeY,d,d);
  PFont f = createFont("Arial",16,true);
  textFont(f,15);
  fill(#00ff00);
  text("Best fitness: "+str(gbest)+"\nEvals to best: "+str(evals_to_best)+"\nEvals: "+str(evals),10,20);
}

// ===============================================================

void setup(){  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //size(1440,720); //setea width y height
  //surf = loadImage("marscyl2.jpg");
  
  size(575,321); //setea width y height (de acuerdo al tamaño de la imagen)
  surf = loadImage("rastrigin.png");
  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  smooth();
  // crea arreglo de objetos partículas
  fl = new Particle[puntos];
  //Se inicializa por defecto a la primera particula como la mejor
  fl[0] = new Particle();
  gbest = fl[0].fit;
  gbestx = fl[0].x;
  gbesty = fl[0].y;
  
  for(int i = 1;i < puntos;i++)
    fl[i] = new Particle();

  //Inicializamos en -1 los mejores valores
  for(int i=0; i<100; i++)
    BestValues_i[i] = -1;
}

void draw(){
  //background(200);
  //despliega mapa, posiciones  y otros
  image(surf,0,0);
  for(int i = 0;i<puntos;i++){
    fl[i].display();
  }
  despliegaBest();
  //mueve puntos
  for(int i = 0;i<puntos;i++){
    fl[i].move();
    fl[i].Eval();
    
  }
  
}
