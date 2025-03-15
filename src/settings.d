module settings;
import std.math;

// 2d vector with basic operations
struct Vector2 {
    float x;
    float y;

    // get the length of the vector
    @property float magnitude() const {
        return sqrt(x * x + y * y);
    }

    // return a normalized version of the vector
    Vector2 normalize() const {
        float mag = magnitude;
        return Vector2(x / mag, y / mag);
    }

    // overload operators for vector-vector operations
    Vector2 opBinary(string op)(in Vector2 other) const {
        return Vector2(mixin("x " ~ op ~ " other.x"), mixin("y " ~ op ~ " other.y"));
    }

    // overload operators for vector-scalar operations
    Vector2 opBinary(string op)(float scalar) const {
        return Vector2(mixin("x " ~ op ~ " scalar"), mixin("y " ~ op ~ " scalar"));
    }
}

// global simulation settings
const int GRID_WIDTH = 50;
const int GRID_HEIGHT = 50;
const float SCALE = 1;
const int NUM_PARTICLES = 2;

// air density for drag force calculation
const float AIR_DENSITY = 1.225;

// gravity point with position and strength
struct GravityPoint {
    Vector2 position;
    float strength;
}

// predefined gravity points
const GravityPoint[] GRAVITY_POINTS = [
    GravityPoint(Vector2(0, 50), 5.00),
    GravityPoint(Vector2(50, 25), 5.05),
];
