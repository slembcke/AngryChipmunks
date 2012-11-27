//
//  TrajectoryNode.m
//  AngryChipmunks
//
//  Created by Scott Lembcke on 11/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Physics.h"
#import "TrajectoryNode.h"
#import "CCTextureCache.h"

#import "ChipmunkCage.h"

@implementation TrajectoryNode

@synthesize cage;

// Aim the arc so that it will pass through the player's finger.
-(void)setAimPoint:(cpVect)aimPoint;
{
	cpVect delta = cpvsub(aimPoint, CANNON_POSITION);
	cpFloat xVel = 300.0f;
	cpFloat t = delta.x/xVel;
	cpVect muzzleVelocity = cpv(xVel, (delta.y - space.gravity.y*t*t*0.5f)/t);
	
	[cage setMuzzleVelocity:muzzleVelocity];
}

-(id)initWithSpace:(ChipmunkSpace*)theSpace;
{
	if((self = [super init])){
		textureAtlas = [[CCTextureCache sharedTextureCache] addImage:@"Sprites.png"];
		space = theSpace;
	}
	
	return self;
}

-(void) draw;
{
	if(!cage) return;
	
	// We need a copy of the body and shape to simulate them forwards without doing a full step.
	// For performance sake, let's just copy them onto the stack using the C-API.
	cpBody body = *(cage.body.body);
	cpPolyShape shape = *((cpPolyShape *)cage.shape.shape);
	shape.shape.body = &body;
	
	cpVect gravity = space.gravity;
	
	// Check ahead up to 300 frames for a collision.
	for(int i=0; i<300; i++){
		// Manually update the position and velocity of the body
		cpBodyUpdatePosition(&body, FIXED_TIMESTEP);
		cpBodyUpdateVelocity(&body, gravity, 1.0f, FIXED_TIMESTEP);
		
		// Perform a shape query to see if the cage hit anything.
		if(cpSpaceShapeQuery(space.space, (cpShape *)&shape, NULL, NULL)){
			// If it did, draw the box's outline.
			cpVect verts[4];
			for(int i=0; i<4; i++){
				verts[i] = cpBodyLocal2World(&body, cpPolyShapeGetVert((cpShape *)&shape, i));
			}
			
			[self drawPolyWithVerts:verts count:4 fillColor:ccc4f(0, 0, 0, 0) borderWidth:1.0 borderColor:ccc4f(0, 0, 0, 1)];
			break;
		} else if(i%3==0){
			// Otherwise, just draw a dot every 10 frames along the path.
			[self drawDot:body.p radius:5.0 color:ccc4f(0, 0, 0, 0.5)];
		}
	}
	
	[super draw];
	[self clear];
}

@end
