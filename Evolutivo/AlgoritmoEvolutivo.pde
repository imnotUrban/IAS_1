PImage surf;
PFont f;
PrintWriter TXTprom;
PrintWriter TXTmin;
float promedio;

//display
String display_text;
float d = 15;

int evals = 0;
int iterations = 0;
float bestofalltimes_value = pow(10,5);
float bestofalltimes_x;
float bestofalltimes_y;
int tamPoblacion = 100;
int tamPoblacionAct = tamPoblacion;
Particle[] poblacion = new Particle[tamPoblacionAct];
//Dominio de la funcion
float min = -4.5; //
float max = 4.5; //
//seleccion
boolean modoSeleccion = false; // true = seleccionMejores, false = seleccionTorneo
int numSeleccionados = 20 , tamTorneo = 5;
Particle[] seleccionados = new Particle[numSeleccionados];
Particle[] torneo = new Particle[tamTorneo];
float fit_total; // se utiliza por otras funciones
//cruzamiento
boolean modoCruzamiento = true; //false = cruzamiento, true = cruzamientoPorFit
float desvio = 0.3  ; // los genes que da un progenitor estarán entre [5-desvio, 5+desvio], donde el otro progenitor entrega el resto; por lo tanto desvio de 0  hace que ambos entregen 0.5
                    // desvio de 0.3 hace que un progenitor entregue entre 0.2 y 0.8 de sus datos, dejando el resto al otro progenitor
float razon_skew = 0.5;
//mutacion

float variacion = 0.4;

//mover rastringin
float fx=0, fy=0;
float value = 1.5;
float increment = 0.01;

class Particle {
  float x, y, fit; // current position(x-vector)  and fitness (x-fitness)
  // ---------------------------- Constructor
  Particle() {
    x = random (min, max);
    y = random(min, max);
    fit = pow(10, 5);
  }
  Particle(float x, float y) {
    this.x = x;
    this.y = y;
    fit = pow(10, 5);
  }
  float Eval() {
    evals++;
    fit = 20+pow(x+fx, 2) - 10*cos(2*PI*(x+fx)) + pow(y+fy, 2) - 10*cos(2*PI*(y+fy));
    return fit;
  }
   void display(){
    int ejeX = int( (max+x)/( abs(min) + max) * 1024 );
    int ejeY = int( abs(y-min)/( abs(min) + max) * 1024 );
    
    color c=surf.get(ejeX, ejeY);
    fill(c);
    ellipse (ejeX,ejeY,d,d); 
    
    stroke(#ff0000);
  }
}
void seleccionMejores(){
  Particle p;
  fit_total = 0;
  for (int step = 0; step < numSeleccionados; step++) {
    for (int i = tamPoblacionAct-1; i > step; i--) {
      if (poblacion[i].fit < poblacion[i - 1].fit) {
        p = poblacion[i];
        poblacion[i] = poblacion[i-1];
        poblacion[i - 1] = p;
      }
    }
    seleccionados[step] = poblacion[step];
    fit_total += poblacion[step].fit;
  }
  print("\n");
}
void seleccionTorneo() {
    Particle ganador;
    fit_total = 0;
    int i,j;
    for (i=0; i<numSeleccionados; i++){
      for(j=0; j<tamTorneo; j++)
        torneo[j] = poblacion[int(random(tamPoblacionAct))];
        
      ganador = torneo[0];
      for(j=0; j<tamTorneo; j++){
        if(torneo[j].fit<ganador.fit) ganador = torneo[j];}
      seleccionados[i] = ganador;
      fit_total += ganador.fit;
    }
}

void cruzamiento(){
  tamPoblacionAct =  int(random(tamPoblacion/2, tamPoblacion));
  int i;
  float factorX, factorY;
  Particle p1, p2;
  for(i=0; i<tamPoblacionAct; i++){
    factorX = random(0.5-desvio,0.5+desvio);
    factorY = random(0.5-desvio,0.5+desvio);
    p1 = seleccionados[int(random(numSeleccionados))];
    p2 = seleccionados[int(random(numSeleccionados))];
    poblacion[i] = new Particle(factorX*p1.x + (1.0-factorX)*p2.x, factorY*p1.y + (1.0-factorY)*p2.y);
  }
}

void cruzamientoPorFit(){
  //tamPoblacionAct =  int(random(tamPoblacion/2, tamPoblacion));
  int i,j;
  float razon;
  Particle partner;
  float ftnm1 = fit_total*((float)(numSeleccionados-1))/(float)tamPoblacion;
  int nHijos;
  tamPoblacionAct = 0;
  for(i=0; i<numSeleccionados; i++){
    nHijos = int((fit_total-seleccionados[i].fit)/(ftnm1)); // (s-x) * pobla / s*(n-1)
    for(j=0;j<nHijos;j++){
      partner = seleccionados[int(random(numSeleccionados))];
      if(seleccionados[i].fit<partner.fit) razon = (1-(seleccionados[i].fit/partner.fit))*razon_skew;
      else razon = (seleccionados[i].fit/partner.fit)*razon_skew;
      poblacion[tamPoblacionAct+j] = new Particle(razon*seleccionados[i].x+(1-razon)*partner.x,razon*seleccionados[i].y+(1-razon)*partner.y);
      poblacion[tamPoblacionAct+j].Eval();
    }
    tamPoblacionAct +=nHijos;
  }
}

void mutacion(){
  int i;
  for(i=0; i<tamPoblacionAct; i++){
    poblacion[i].x = poblacion[i].x + random(-variacion, variacion);
    poblacion[i].y = poblacion[i].y + random(-variacion, variacion);
  }
}


void setup() {
    randomSeed(225);
    print("init setup\n");
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    size(1024, 1024); //setea width y height (de acuerdo al tamaño de la imagen)
    surf = loadImage("rastrigin.jpg");
    f = createFont("Arial",16,true);

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    smooth();
    
    TXTprom = createWriter("TXTprom.txt");
    TXTmin = createWriter("TXTmin.txt");
    // crea arreglo de objetos partículas
    poblacion = new Particle[tamPoblacionAct];
    
    for (int i = 0; i < tamPoblacionAct; i++)
      poblacion[i] = new Particle();
}
void pintarOptimo(){
    int ejeX = int( (max-fx)/( abs(min) + max) * 1024 );
    int ejeY = int( abs(-fy-min)/( abs(min) + max) * 1024 );
    
    color c=color(255,255,255);
    fill(c);
    ellipse (ejeX,ejeY,d,d); 
    stroke(#ff0000);
}

void draw() {
    //value = value + increment;
    //despliega mapa, posiciones  y otros
    image(surf, 0, 0);
    int z = 0;
    for (int i = 0; i < tamPoblacionAct; i++){
      poblacion[i].Eval();
      poblacion[i].display();
      if(poblacion[i].fit<poblacion[z].fit) z = i;
    }
    if(poblacion[z].fit<bestofalltimes_value){
      bestofalltimes_value = poblacion[z].fit;
      bestofalltimes_x = poblacion[z].x;
      bestofalltimes_y = poblacion[z].y;
    }
    promedio = 0;
    for(int i = 0; i<tamPoblacionAct; i++){
      if(poblacion[i].fit<200)
        promedio = promedio + poblacion[i].fit;
    }
    promedio = promedio/tamPoblacionAct;
  
  //Escribe en cada iteracion
    TXTprom.println(promedio);
    TXTmin.println(str(bestofalltimes_value));
  if(iterations > 1000){
    //Termina con los textos
    TXTprom.flush(); // Writes the remaining data to the file
    TXTprom.close(); // Finishes the file
    TXTmin.flush(); // Writes the remaining data to the file
    TXTmin.close(); // Finishes the file
    exit();   //Termina a la iteración indicada
  }
    textFont(f,16);                  // STEP 3 Specify font to be used
    fill(0);                         // STEP 4 Specify font color
    display_text = "Iteraciones: " + iterations+"\n";
    display_text += "mejor actual: "+poblacion[z].fit+" en x="+ poblacion[z].x + ", y=" + poblacion[z].y + "\n";
    display_text += "mejor de todas las iteraciones: "+bestofalltimes_value+" en x="+ bestofalltimes_x +", y="+bestofalltimes_y;
    text(display_text,5,20);   // STEP 5 Display Text
    delay(0);
    if(modoSeleccion) seleccionMejores();
    else seleccionTorneo();
    
    if(modoCruzamiento) cruzamientoPorFit();
    else cruzamiento();
    
    mutacion();
    iterations++;
}
