module physics;

import std.stdio;
import std.random;
import core.thread;
import std.math;
import settings;

alias Vector2 = settings.Vector2;

// particle with position, velocity, mass, drag coefficient, and area
struct Particle {
    Vector2 position;
    Vector2 velocity;
    float mass;
    float dragCoefficient;
    float area;
}

Particle[NUM_PARTICLES] particles;

// clear the terminal screen
void clearScreen() {
    writefln("\033[2J\033[H");
}

// print particles on the grid
void printParticles() {
    char[GRID_HEIGHT][GRID_WIDTH] grid = '.';

    foreach (particle; particles) {
        int x = cast(int)(particle.position.x / SCALE);
        int y = GRID_HEIGHT - 1 - cast(int)(particle.position.y / SCALE);
        if (x >= 0 && x < GRID_WIDTH && y >= 0 && y < GRID_HEIGHT) {
            grid[y][x] = '#';
        }
    }

    clearScreen();
    foreach (row; grid) writeln(row);
}

// initialize particles with starting positions and velocities
void initializeParticles() {
    particles = [
        Particle(Vector2(10, 50), Vector2(20, -25), 1.5, 1.37, 0.1),
        Particle(Vector2(10, 50), Vector2(10, -15), 1, 1.05, 0.1)
    ];
}

// compute gravitational force on a particle
Vector2 computeGravityForce(in Particle particle) {
    Vector2 totalForce = Vector2(0, 0);
    foreach (gravityPoint; GRAVITY_POINTS) {
        Vector2 direction = gravityPoint.position - particle.position;
        float distanceSq = direction.x * direction.x + direction.y * direction.y;
        if (distanceSq < 1e-6) continue;
        float forceMagnitude = gravityPoint.strength * particle.mass / distanceSq;
        totalForce = totalForce + direction.normalize() * forceMagnitude;
    }
    return totalForce;
}

// compute drag force on a particle
Vector2 computeDragForce(in Particle particle) {
    float speed = particle.velocity.magnitude;
    if (speed == 0) return Vector2(0, 0);
    float dragMagnitude = 0.5 * particle.dragCoefficient * AIR_DENSITY * particle.area * speed * speed;
    return particle.velocity.normalize() * -dragMagnitude;
}

// run the simulation
void runSimulation() {
    float totalSimulationTime = 10;
    float currentTime = 0;
    float dt = 0.125;
    long sleepTime = cast(long)(dt * 1_000_000);

    writeln("initializing particles...");
    initializeParticles();

    while (currentTime < totalSimulationTime) {
        writeln("time: ", currentTime, " seconds");
        Thread.sleep(dur!"usecs"(sleepTime));

        foreach (ref particle; particles) {
            Vector2 gravityForce = computeGravityForce(particle);
            Vector2 dragForce = computeDragForce(particle);
            Vector2 netForce = gravityForce + dragForce;
            particle.velocity = particle.velocity + (netForce / particle.mass) * dt;
            particle.position = particle.position + particle.velocity * dt;
            if (particle.position.y < 0) {
                particle.position.y = 0;
                particle.velocity.y = 0;
            }
        }

        printParticles();
        currentTime += dt;
    }
}

void main() {
    writeln("program started.");
    runSimulation();
    writeln("simulation finished.");
}
