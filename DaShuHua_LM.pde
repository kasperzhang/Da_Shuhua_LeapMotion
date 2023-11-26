import de.voidplus.leapmotion.*;
LeapMotion leap;

int numParticles = 20;
color getSparkColor() {
  if(frameCount % 3 ==0){
   return color(255, 235, 145);
  }
  else if(frameCount % 7 ==0){
    return color(255, 235,183);
  }
  else{
    return color(255, 130, 0);
  }
}
void setup() {
  size(1920,1680);
  ps = new ParticleSystem(new PVector(width / 2, height / 2));
  background(0);
  leap = new LeapMotion(this);
}

class Particle {
  PVector position;
  PVector velocity;
  PVector gravity;
  float lifespan;
  color col;
  ArrayList<PVector> trail;
  boolean hasTrail;
  float size;
  int trailLength;

  Particle(PVector start, boolean hasTrail) {
    position = start.copy();
    this.hasTrail = hasTrail;
    float angle = random(TWO_PI);
    size = random(1, 3);
    float speed = random(1, 6 - size);
    velocity = new PVector(cos(angle), sin(angle));
    velocity.mult(speed);
    gravity = new PVector(0, 0.01 * size);
    lifespan = 255.0;
    col = getSparkColor();
    trail = new ArrayList<PVector>();
    trailLength = (int) random(80,100);
  }
 
  void applyForce(PVector force) {
    velocity.add(force);
  }

  void update() {
    if (hasTrail) {
      trail.add(position.copy());
      if (trail.size() > trailLength) {
        trail.remove(0);
      }
    }
    applyForce(gravity);
    position.add(velocity);
    lifespan -= 1.0;
    velocity.mult(0.99); 
  }

  void display() {
    if (hasTrail) {
      for (PVector spot : trail) {
        noStroke();
        fill(col, lifespan / 2); 
        ellipse(spot.x, spot.y, size, size); 
      }
    }
    noStroke();
    fill(col, lifespan);
    ellipse(position.x, position.y, size, size);
  }

  boolean isDead() {
    return lifespan < 0;
  }
}

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;

  ParticleSystem(PVector position) {
    origin = position.copy();
    particles = new ArrayList<Particle>();
  }
  
  void addParticle() {
    boolean hasTrail = random(1) < 0.5; 
    particles.add(new Particle(origin, hasTrail));
  }

  void run() {
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      p.display();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}

ParticleSystem ps;

void draw() {
  for (Hand hand : leap.getHands ()) {
    PVector handPosition       = hand.getPosition();
    float[] handPositionArray  = handPosition.array();            
    float   handGrab           = hand.getGrabStrength();
    background(0,25);
    if (handGrab <= 0.3 ) {
      ps.origin = new PVector(handPositionArray[0], handPositionArray[1]);
      for (int i = 0; i < numParticles; i++) { 
        ps.addParticle();
    }
  }
  ps.run();
  }
}
