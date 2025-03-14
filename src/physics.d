import std.stdio;
import std.random;
import core.thread;

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
}

// global settings
const int GRID_WIDTH = 40;
const int GRID_HEIGHT = 47;
// this sets up the size of grid each frame
const float SCALE = 17.5; // shows grid size (1 '.' = 17.5u)
const NUM_PARTICLES = 1; // particles in frame (note: add ability for more :3)
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
        row[] = '.';
    }

    // place particles
    foreach (i, particle; particles) {
        int x = cast(int)(particle.position.x / SCALE);
        int y = GRID_HEIGHT - 1 - cast(int)(particle.position.y / SCALE); 
        // inverts Y for terminal display bc i couldn't think of how to fix it any other way

        // ensures particle is within bounds
        if (x >= 0 && x < GRID_WIDTH && y >= 0 && y < GRID_HEIGHT) {
            // determine symbol based on velocity
            char symbol = '*';
            if (particle.velocity.x > 0) symbol = '*';
            if (particle.velocity.x < 0) symbol = '*';
            if (particle.velocity.y > 0) symbol = '*';
            if (particle.velocity.y < 0) symbol = '*';

            grid[y][x] = symbol;
        }
    }

    // clears screen again
    clearScreen();

    //pPrints the grid
    foreach (row; grid) {
        writeln(row);
    }

    writeln();
    stdout.flush();
}

// initializes all particles with velocity and a high starting position.
void initializeParticles() {
    for (int i = 0; i < NUM_PARTICLES; ++i) {
        particles[i].position = Vector2(200, 780); // Start higher up
        particles[i].velocity = Vector2(20, -10);   // Move right (5 m/s) and up (-10 m/s)
        particles[i].mass = 1;
    }
}

// applies earth's gravity force (mass * gravity acceleration g(0) m/s^2) to each particle.
Vector2 computeForce(ref Particle particle) {
    return Vector2(0, particle.mass * -9.76063); // gravity assuming h=15 from atlantic or smth
}

void runSimulation() {
    float totalSimulationTime = 10; // Run for 10 seconds.
    float currentTime = 0; // Accumulates the time that has passed.
    float dt = 0.5; // Each step will take 0.5 seconds.

    writeln("Initializing particles...");
    initializeParticles();
    stdout.flush();

    while (currentTime < totalSimulationTime) {
        writeln("Time: ", currentTime, " seconds");
        stdout.flush();

        // Sleep to simulate real-time physics
        Thread.sleep(dur!"usecs"(cast(long)(dt * 1_000_000)));

        for (int i = 0; i < NUM_PARTICLES; ++i) {
            Particle* particle = &particles[i];
            Vector2 force = computeForce(*particle);
            Vector2 acceleration = Vector2(force.x / particle.mass, force.y / particle.mass);
            particle.velocity.x += acceleration.x * dt;
            particle.velocity.y += acceleration.y * dt;
            particle.position.x += particle.velocity.x * dt;
            particle.position.y += particle.velocity.y * dt;

            // Prevent the particle from falling below the grid
            if (particle.position.y < 0) {
                particle.position.y = 0;
                particle.velocity.y = 0; // Stop movement when it hits the ground
            }
        }

        // Print the updated particle positions visually
        printParticles();
        currentTime += dt;
    }
}

void main() {
    writeln("Program started.");
    stdout.flush();
    runSimulation();
    writeln("Simulation finished.");
    stdout.flush();
}
