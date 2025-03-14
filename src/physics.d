import std.stdio;
import std.random;
import core.thread;
import std.math; // Needed for sqrt()

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
    float dragCoefficient; // New: Drag coefficient (e.g., 0.47 for a sphere)
    float area;            // New: Cross-sectional area (m²)
}

// global settings
const int GRID_WIDTH = 50;
const int GRID_HEIGHT = 50;
// this sets up the size of grid each frame
const float SCALE = 2; // shows grid size (1 '.' = 5u)
const int NUM_PARTICLES = 3; // Updated: Now supports 2 particles
Particle[NUM_PARTICLES] particles;

// Constants for air resistance
const float AIR_DENSITY = 1.225; // kg/m³ (at sea level)

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
            particles[i].position = Vector2(10, 60);  // First particle
            particles[i].velocity = Vector2(20, -10);   // Moving right and up
        } else {
            particles[i].position = Vector2(50, 100);  // Second particle
            particles[i].velocity = Vector2(2, -9);   // Moving left and slightly up
        }
        particles[i].mass = 1;          // Same mass for all particles
        particles[i].dragCoefficient = 1.05; // Drag coefficient for a square
        particles[i].area = 0.1;        // Approximate cross-sectional area (m²)
    }
}

// applies earth's gravity force (mass * gravity acceleration g(0) m/s^2) to each particle.
Vector2 computeGravityForce(ref Particle particle) {
    return Vector2(0, particle.mass * -9.76063); // gravity assuming h=15 from atlantic or smth
}

// applies wind resistance force based on drag equation
Vector2 computeDragForce(ref Particle particle) {
    // Compute velocity magnitude (speed)
    float speed = sqrt(particle.velocity.x * particle.velocity.x + 
                       particle.velocity.y * particle.velocity.y);

    if (speed == 0) return Vector2(0, 0); // No drag force if not moving

    // Compute drag magnitude
    float dragMagnitude = 0.5 * particle.dragCoefficient * AIR_DENSITY * particle.area * speed * speed;

    // Compute drag direction (opposite to velocity)
    Vector2 dragDirection = Vector2(-particle.velocity.x / speed, -particle.velocity.y / speed);

    // Compute final drag force
    return Vector2(dragDirection.x * dragMagnitude, dragDirection.y * dragMagnitude);
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

            // Compute gravitational force
            Vector2 gravityForce = computeGravityForce(*particle);

            // Compute air resistance force
            Vector2 dragForce = computeDragForce(*particle);

            // Compute net force (Gravity + Drag)
            Vector2 netForce = Vector2(
                gravityForce.x + dragForce.x,
                gravityForce.y + dragForce.y
            );

            // Compute acceleration using Newton's Second Law (F = ma)
            Vector2 acceleration = Vector2(netForce.x / particle.mass, netForce.y / particle.mass);

            // Update velocity (v = v0 + at)
            particle.velocity.x += acceleration.x * dt;
            particle.velocity.y += acceleration.y * dt;

            // Update position (x = x0 + vt)
            particle.position.x += particle.velocity.x * dt;
            particle.position.y += particle.velocity.y * dt;

            // Prevent the particle from falling below the grid
            if (particle.position.y < 0) {
                particle.position.y = 0;
                particle.velocity.y = 0; // Stop downward motion
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
