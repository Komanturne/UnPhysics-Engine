module physics;
import std.stdio;
import std.random;
import core.thread;
import std.math; // needed for squares ig.
import settings; // import settings

// creates vector
struct Vector2 {
    float x;
    float y;
}

// creates particle
struct Particle {
    Vector2 position;
    Vector2 velocity;
    float mass;
    float dragCoefficient; //note: fix consistency
    float area;  //cross-sectional area or smth
}

// declare particles array
Particle[NUM_PARTICLES] particles;

// clears screen, read code.
void clearScreen() {
    writefln("\033[2J\033[H");
}

// prints the particles and screen
void printParticles() {
    char[GRID_HEIGHT][GRID_WIDTH] grid;

    // Fill grid with empty space
    foreach (ref row; grid) {
        row[] = ' ';
    }

    // place particles
    foreach (i, particle; particles) {
        int x = cast(int)(particle.position.x / SCALE);
        int y = GRID_HEIGHT - 1 - cast(int)(particle.position.y / SCALE); 
        // inverts Y for terminal display bc i couldn't think of how to fix it any other way

        // ensures particle is within bounds
        if (x >= 0 && x < GRID_WIDTH && y >= 0 && y < GRID_HEIGHT) {
            // Updated: Different symbol if two particles overlap
            if (grid[y][x] == '.') {
                grid[y][x] = '#'; // First particle
            } else {
                grid[y][x] = '#'; // Second particle (to differentiate)
            }
        }
    }

    // clears screen again
    clearScreen();

    // Prints the grid
    foreach (row; grid) {
        writeln(row);
    }

    writeln();
    stdout.flush();
}

// initializes all particles with velocity and a high starting position.
void initializeParticles() {
    for (int i = 0; i < NUM_PARTICLES; ++i) {
        if (i == 0) {
            particles[i].position = Vector2(10, 60);  // first particle position
            particles[i].velocity = Vector2(20, -10);
        } else {
            particles[i].position = Vector2(50, 100);  // second particle position
            particles[i].velocity = Vector2(2, -9);
        }
        particles[i].mass = 1;          // same mass bc i can't code it any other way
        particles[i].dragCoefficient = 1.05; // assuming it's a square
        particles[i].area = 0.1;        // cross-sectional area (idk)
    }
}

// applies earth's gravity force (mass * gravity acceleration g(0) m/s^2) to each particle.
Vector2 computeGravityForce(ref Particle particle) {
    return Vector2(0, particle.mass * GRAVITY); // use gravity from settings.d
}

// applies wind resistance force based on drag equation
Vector2 computeDragForce(ref Particle particle) {
    // compute velocity magnitude (speed)
    float speed = sqrt(particle.velocity.x * particle.velocity.x + 
                       particle.velocity.y * particle.velocity.y);

    if (speed == 0) return Vector2(0, 0); // mo drag force if not moving

    // compute drag magnitude
    float dragMagnitude = 0.5 * particle.dragCoefficient * AIR_DENSITY * particle.area * speed * speed;

    // compute drag direction (opposite to velocity)
    Vector2 dragDirection = Vector2(-particle.velocity.x / speed, -particle.velocity.y / speed);

    // compute final drag force
    return Vector2(dragDirection.x * dragMagnitude, dragDirection.y * dragMagnitude);
}

void runSimulation() {
    float totalSimulationTime = 10; //10 seconds, btw.
    float currentTime = 0; // time passed
    float dt = 0.5; // 0,5 -> 1,0 -> 1,5 -> 2,0 etc.

    writeln("Initializing particles...");
    initializeParticles();
    stdout.flush();

    while (currentTime < totalSimulationTime) {
        writeln("Time: ", currentTime, " seconds");
        stdout.flush();

        // sleep to simulate real-time physics
        Thread.sleep(dur!"usecs"(cast(long)(dt * 1_000_000)));

        for (int i = 0; i < NUM_PARTICLES; ++i) {
            Particle* particle = &particles[i];

            // compute gravitational force
            Vector2 gravityForce = computeGravityForce(*particle);

            // compute air resistance force
            Vector2 dragForce = computeDragForce(*particle);

            // compute net force (Gravity + Drag)
            Vector2 netForce = Vector2(
                gravityForce.x + dragForce.x,
                gravityForce.y + dragForce.y
            );

            // compute acceleration f=m*a
            Vector2 acceleration = Vector2(netForce.x / particle.mass, netForce.y / particle.mass);

            // update velocity
            particle.velocity.x += acceleration.x * dt;
            particle.velocity.y += acceleration.y * dt;

            // upd position
            particle.position.x += particle.velocity.x * dt;
            particle.position.y += particle.velocity.y * dt;

            // Prevent the particle from falling below the grid
            if (particle.position.y < 0) {
                particle.position.y = 0;
                particle.velocity.y = 0; // Stop downward motion
            }
        }

        // prints position
        printParticles();
        currentTime += dt;
    }
}


//running the program, obviously.
void main() {
    writeln("Program started.");
    stdout.flush();
    runSimulation();
    writeln("Simulation finished.");
    stdout.flush();
}
