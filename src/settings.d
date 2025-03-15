// settings.d
module settings;

// global settings
const int GRID_WIDTH = 50;
const int GRID_HEIGHT = 50;
//settings grid-size, doesn't actually look 50x50
//looks like 25x50 bc of spacing

const float SCALE = 2; // shows grid size (1 '.' = 5u^2 i think)
const int NUM_PARTICLES = 2; // doesn't work for 3 particles, only loads 2

// other stuff ig
const float AIR_DENSITY = 1.225; // kg/m^3 from sea level, CREATE CONSISTENCY JESUS
const float GRAVITY = -9.76063; // gravity assuming h=15 from atlantic or smth