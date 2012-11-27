//
//  GameWorld.m
//  AngryChipmunks
//
//  Created by Scott Lembcke on 11/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameWorld.h"

#import "Physics.h"

#import "BreakableBox.h"
#import "BrokenBox.h"
#import "GoalBox.h"
#import "ChipmunkCage.h"
#import "TrajectoryNode.h"

@interface GameWorld()

-(void)addCollisionHandlers;

@end

@implementation GameWorld

+(id) scene
{
	return [GameWorld node];
}


// Add an entire GameObject to  GameWorld, physics, sprites, everthing.
-(void) add:(GameObject *)gameObject{
	// Adding a gameobject that implements the ChipmunkObject protocol is easy
	// Using smartAdd: instead of just add: makes it safe from within a callback.
	// Just make sure you understand that smartAdd: will delay the addition when used in a callback.
  [space smartAdd:gameObject];
	
	// Add all the sprites
  for(CCSprite *sprite in gameObject.sprites){
    [self addChild:sprite];
  }
	
	[gameObjects addObject:gameObject];
	gameObject.world = self;
}

// Should be no surprises here.
-(void) remove:(GameObject *)gameObject{
  [space smartRemove:gameObject];
	
  for(CCSprite* sprite in gameObject.sprites){
    [self removeChild:sprite cleanup:TRUE];
  }
	
	[gameObjects removeObject:gameObject];
	gameObject.world = nil;
}

-(void) step: (ccTime) delta
{
	// Update the physics using the fixed time step.
	// Here the fixed timestep should match the framerate.
	// A slightly better solution is to decouple your updates and drawing.
	// That is beyond the scope of this example, but a good tutorial can be found here: http://gafferongames.com/game-physics/fix-your-timestep/
	[space step:FIXED_TIMESTEP];
}

-(id) init
{
	if((self = [super init])){
		self.touchEnabled = YES;
		
		gameObjects = [[NSMutableArray alloc] init];

		
		space = [[ChipmunkSpace alloc] init];
		space.gravity = cpv(0, -600);
		
		// Even ChipmunkSpace objects have a user data pointer!
		space.data = self;
		
		// Add callbacks for collision events.
		// Chipmunk drives our entire gamestate along through these.
		[self addCollisionHandlers];
		
		// Create a static ground using the autorelease constructor.
		// Using Objective-Chipmunk, you can just set a shape and forget it.
		// The space will manage all the memory for you, and you don't need to keep a reference around just so you can free it later.
		ChipmunkShape *ground = [space add:[ChipmunkSegmentShape segmentWithBody:space.staticBody from:cpv(-1000, 42) to:cpv(1000, 42) radius:20]];
		ground.friction = 1.0f;
		ground.elasticity = 1.0f;
		
		// Load some misc Cocos2D things.
    CCSprite *background = [CCSprite spriteWithFile:@"levelBG.png"];
    background.position = ccp(240, 160);
		[self addChild:background z:-1];
    
		trajectoryNode = [[TrajectoryNode alloc] initWithSpace:space];
		[self addChild:trajectoryNode];
		
		// This is a handy utility node that you can use to draw all the collision shapes for Chipmunk.
//		[self addChild:[CCPhysicsDebugNode debugNodeForChipmunkSpace:space] z:100];
		
		// This is the 'level definition' if you will. Add a couple boxes and the goal box.
		[self add:[BreakableBox squareBox:cpv(240, 95)]];
		[self add:[BreakableBox squareBox:cpv(240, 95 + 64)]];
		[self add:[BreakableBox squareBox:cpv(240, 95 + 128)]];
		[self add:[GoalBox goalBox:cpv(240, 95 + 176)]];
		
		[self schedule:@selector(step:)];
	}
	
	return self;
}

- (cpVect)touchLocation:(NSSet *)touches {
	UITouch *touch = [touches anyObject];
	return [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	trajectoryNode.cage = [[ChipmunkCage alloc] init];
	[trajectoryNode setAimPoint:[self touchLocation:touches]];
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[trajectoryNode setAimPoint:[self touchLocation:touches]];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(trajectoryNode.cage){
		[trajectoryNode setAimPoint:[self touchLocation:touches]];
		[self add:trajectoryNode.cage];
	}
}

- (void)restart
{
	[[CCScheduler sharedScheduler] unscheduleSelector:_cmd forTarget:self];
	[[CCDirector sharedDirector] replaceScene:[GameWorld scene]];
}

- (void)scheduleRestart
{
	if(!restarting){
		[[CCScheduler sharedScheduler] scheduleSelector:@selector(restart) forTarget:self	interval:1.0f paused:FALSE];
		restarting = TRUE;
	}
}

#pragma mark Collision Handler Helper Functions/Methods

// Apply collision damage to a breakable box and maybe schedule it to be destroyed.
static inline void BreakableApplyDamage(BreakableBox *box, cpArbiter *arb, GameWorld *self){
	if(cpArbiterIsFirstContact(arb)){
		// Divide the impulse by the timestep to get the collision force.
		cpFloat impact = cpvlength(cpArbiterTotalImpulse(arb))/FIXED_TIMESTEP;
		
		if(impact > 1.0f){
			box.strength -= impact/500.0f;
			if(box.strength < 0.0f) {
				// We only want to break the box once, even if a second impact puts the damage even farther below zero.
				// Fortunately, Chipmunk post-step callbacks make that easy.
				// They only run once for a given key, so let's use that.
				
				[self->space addPostStepBlock:^{
					// Create the broken chunks and add them to the GameWorld.
					BrokenBox *broken = [[BrokenBox alloc] initFromBox:box];
					[self add:broken];
					
					// If you broke the goal box you lose!
					if([box isKindOfClass:[GoalBox class]]) [self scheduleRestart];
					
					[self remove:box];
				} key:box];
			}
		}
	}
}

// It will make most sense to read the rest of these methods from the bottom up.
#pragma mark Collision Handler Methods

- (bool)Begin_ChipmunkCage_Default:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
{
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, cageShape, unused);
	
	// We set the ChipmunkCage game object on it's shape's data pointer so we could use it here in the callback.
	ChipmunkCage *cage = cageShape.data;
	
	// Reset the trajectory node so it can fire again, and start the cage fading out.
	if(trajectoryNode.cage == cage) trajectoryNode.cage = nil;
	if(!cage.fading) [cage fadeOut:2.0f];
	
	return TRUE;
}

// When a breakable box touches ground (which is set to the default/nil collision type) you win.
- (void)PostSolve_Default_BreakableBox:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
{
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, unused, box);
	BreakableApplyDamage(box.data, arbiter, self);
}

// When the GoalBox touches ground (which is set to the default/nil collision type) you win.
// Restart the game.
- (bool)Begin_Default_GoalBox:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
{
	[self scheduleRestart];
	return TRUE;
}

// When two breakable boxes collide, apply damage to both of them.
- (void)PostSolve_BreakableBox_BreakableBox:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
{
	CHIPMUNK_ARBITER_GET_SHAPES(arbiter, a, b);
	BreakableApplyDamage(a.data, arbiter, self);
	BreakableApplyDamage(b.data, arbiter, self);
}

// Add all the different collision interaction events that we want to know about.
// I like to use class pointers or static NSStrings as collision types because they are convenient, but any object reference will work.
// Collision default to having a collision type of 'nil' and it's perfectly fine to register callbacks using 'nil'.
// Currently you cannot schedule more than one handler to a single type pair, nor can you use wildcards.
// If you need more flexibility you can set the default handler to get all collision events and dispatch them in your own way.
-(void)addCollisionHandlers;
{
	[space addCollisionHandler:self
		typeA:[ChipmunkCage class] typeB:nil
		begin:@selector(Begin_ChipmunkCage_Default:space:) preSolve:nil postSolve:nil separate:nil
	];
	
	[space addCollisionHandler:self
		typeA:[ChipmunkCage class] typeB:[BreakableBox class]
		begin:@selector(Begin_ChipmunkCage_Default:space:) preSolve:nil postSolve:@selector(PostSolve_Default_BreakableBox:space:) separate:nil
	];
	
	[space addCollisionHandler:self
		typeA:[ChipmunkCage class] typeB:[GoalBox class]
		begin:@selector(Begin_ChipmunkCage_Default:space:) preSolve:nil postSolve:@selector(PostSolve_Default_BreakableBox:space:) separate:nil
	];
	
	[space addCollisionHandler:self
		typeA:nil typeB:[BreakableBox class]
		begin:nil preSolve:nil postSolve:@selector(PostSolve_Default_BreakableBox:space:) separate:nil
	];
	
	[space addCollisionHandler:self
		typeA:nil typeB:[GoalBox class]
		begin:@selector(Begin_Default_GoalBox:space:) preSolve:nil postSolve:@selector(PostSolve_Default_BreakableBox:space:) separate:nil
	];
	
	[space addCollisionHandler:self
		typeA:[BreakableBox class] typeB:[BreakableBox class]
		begin:nil preSolve:nil postSolve:@selector(PostSolve_BreakableBox_BreakableBox:space:) separate:nil
	];
	
	[space addCollisionHandler:self
		typeA:[GoalBox class] typeB:[GoalBox class]
		begin:nil preSolve:nil postSolve:@selector(PostSolve_BreakableBox_BreakableBox:space:) separate:nil
	];
}

@end
