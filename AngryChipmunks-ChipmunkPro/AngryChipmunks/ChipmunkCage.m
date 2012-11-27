//
//  ChipmunkCage.m
//  AngryChipmunks
//
//  Created by Scott Lembcke on 11/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Physics.h"

#import "ChipmunkCage.h"

@implementation ChipmunkCage

@synthesize body;
@synthesize shape;

static ChipmunkShape *
MakeCageSegment(ChipmunkBody *body, cpVect a, cpVect b)
{
	ChipmunkShape *seg = [ChipmunkSegmentShape segmentWithBody:body from:a to:b radius:3];
	seg.layers = PhysicsLayerCage;
	seg.friction = 0.7f;
	seg.elasticity = 1.0f;
	
	return seg;
}

- (id)init
{
  if((self = [super init])){
		// To make the cage, we will need to make a shape for the outside of the box as well as shapes for the inside of the box.
		// By putting these shapes on separate layers, we can prevent them from colliding with each other.
		
		// All of the shapes, inside or out, will attach to the same body.
		cpFloat size = 38;
    body = [[ChipmunkBody alloc] initWithMass:1.0f andMoment:cpMomentForBox(1.0f, size, size)];
    body.pos = CANNON_POSITION;
		body.angVel = 10.0f;
		body.vel = cpv(30, 0);
    
		// First we'll make the outside shape of the box be on the default layer so it collides with normal objects.
    shape = [[ChipmunkPolyShape alloc] initBoxWithBody:body width:size height:size];
		shape.friction = 0.7f;
		shape.elasticity = 0.5f;
		shape.layers = PhysicsLayerDefault;
		// The collision type controls what callbacks are called for this shape.
		// See GameWorld.m for more information.
		shape.collisionType = [ChipmunkCage class];
    shape.data = self;
		
		// Make the chipmunk and cage inside shape be on the "cage" layer so they only collide with each other and not normal objects.
    // Start by making segments for the inside of the box to hold the little chipmunk.
		cpFloat hs = size/2.0f;
		ChipmunkShape *cage1 = MakeCageSegment(body, cpv(-hs, -hs), cpv(-hs,  hs));
		ChipmunkShape *cage2 = MakeCageSegment(body, cpv( hs, -hs), cpv(-hs, -hs));
		ChipmunkShape *cage3 = MakeCageSegment(body, cpv( hs,  hs), cpv( hs, -hs));
		ChipmunkShape *cage4 = MakeCageSegment(body, cpv(-hs,  hs), cpv( hs,  hs));
		
		// Now we create a second body for the chipmunk.
		cpFloat rodentMass = 0.01f;
		cpFloat rodentSize = 17.0f;
		rodentBody = [[ChipmunkBody alloc] initWithMass:rodentMass andMoment:cpMomentForBox(rodentMass, rodentSize, rodentSize)];
		rodentBody.pos = body.pos;
		rodentBody.vel = body.vel;
		rodentBody.angVel = body.angVel;
		
    // Since chipmunks are approximately square in real life, we create a square to represent the chipmunk. Use the cage layer, so
    // it collides with the segements forming the inside of the box.
		ChipmunkShape *rodentShape = [ChipmunkPolyShape boxWithBody:rodentBody width:rodentSize height:rodentSize];
		rodentShape.layers = PhysicsLayerCage;
		rodentShape.friction = 0.7f;
		rodentShape.elasticity = 0.3f;
    
		// And now our sprites.
		CCPhysicsSprite *cageSprite = [CCPhysicsSprite spriteWithFile:@"Sprites.png" rect:CGRectMake(0, 64, 64, 64)];
		cageSprite.chipmunkBody = body;
		
		CCPhysicsSprite *rodentSprite = [CCPhysicsSprite spriteWithFile:@"Sprites.png" rect:CGRectMake(192, 32, 32, 32)];
		rodentSprite.chipmunkBody = rodentBody;
		
		// Now like before to make all the physics magic happen, all we have to do is add them to the chipmunkObjects set
		// and the ChipmunkObject protocol will make all the magic happen.
		// You'll notice that you don't even need to make instance variables for most of the physics objects unless you need to modify them later.
    chipmunkObjects = [[NSArray alloc] initWithObjects:body, shape, cage1, cage2, cage3, cage4, rodentBody, rodentShape, nil];
  	
    // The sprites are always added in the order they appear in the array.
		// This is convenient as we haven't added them to a parent node yet, and that is the only way to set the z-order in Cocos2D.
    sprites = [[NSArray alloc] initWithObjects:rodentSprite, cageSprite, nil];
  }
	
  return self;
}

- (void)setMuzzleVelocity:(cpVect)muzzleVelocity;
{
	body.vel = muzzleVelocity;
	rodentBody.vel = muzzleVelocity;
}

@end
