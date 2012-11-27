#import "ObjectiveChipmunk.h"

// I like to throw all of my physics constants in a header so they are all in one place and easy to edit.

// You should always use a fixed timestep with a physics engine. (well, almost always)
// You are using a fixed timestep aren't you?!?!
static const double FIXED_TIMESTEP = 1.0/60.0;

// Position the cage is fired from
static const cpVect CANNON_POSITION = {0, 100};

// These are the layers we will be using in this game.
// You can have up to 32 layers (or more as a compile time option if you want)
// Each collision shape can be in any number of layers and will only collide with another shape if they are in
// at least 1 of the same layers.
enum {
	PhysicsLayerDefault = (1<<0),
	PhysicsLayerCage = (1<<1),
	PhysicsLayerDebris = (1<<2),
};
