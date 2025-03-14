import std.stdio;
import std.random;
import core.thread;

// Two-dimensional vector.
struct Vector2 {
    float x;
    float y;
}

// Two-dimensional particle.
struct Particle {
    Vector2 position;
    Vector2 velocity;
    float mass;
}

// Global settings
const int GRID_WIDTH = 20;
const int GRID_HEIGHT = 20;
const float SCALE = 20.0; // Each grid cell represents 20x20 units in real space
const NUM_PARTICLES = 1;
Particle[NUM_PARTICLES] particles;

// Clears the terminal screen (works on most Unix-based systems and Windows)
void clearScreen() {
    writefln("\033[2J\033[H"); // ANSI escape sequence to clear screen
}

// Prints all particles' positions on a scaled grid.
void printParticles() {
    char[GRID_HEIGHT][GRID_WIDTH] grid;

    // Fill grid with empty space
    foreach (ref row; grid) {
        row[] = '.';
    }

    // Place particles
    foreach (i, particle; particles) {
        int x = cast(int)(particle.position.x / SCALE);
        int y = GRID_HEIGHT - 1 - cast(int)(particle.position.y / SCALE); // Invert Y for terminal display

        // Ensure the particle is within bounds
        if (x >= 0 && x < GRID_WIDTH && y >= 0 && y < GRID_HEIGHT) {
            grid[y][x] = '*'; // Place the particle
        }
    }

    // Clear the screen
    clearScreen();

    // Print the grid
    foreach (row; grid) {
        writeln(row);
    }

    writeln();
    stdout.flush();
}

// Initializes all particles with zero velocity and a high starting position.
void initializeParticles() {
    for (int i = 0; i < NUM_PARTICLES; ++i) {
        particles[i].position = Vector2(200, 300); // Start higher up
        particles[i].velocity = Vector2(0, 0);
        particles[i].mass = 1;
    }
}

// Applies Earth's gravity force (mass * gravity acceleration 9.81 m/s^2) to each particle.
Vector2 computeForce(ref Particle particle) {
    return Vector2(0, particle.mass * -9.81);
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