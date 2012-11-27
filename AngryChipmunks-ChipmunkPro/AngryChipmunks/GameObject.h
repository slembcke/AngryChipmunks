//
//  GameObject.h
//  AngryChipmunks
//
//  Created by Scott Lembcke on 11/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ObjectiveChipmunk.h"
#import "cocos2d.h"

@class GameWorld;


// This is a sample GameObject implementation
// Basically the idea is to keep the physics and graphics code separate like you would using the MVC pattern.
// It also tries to help solve the problem of how to bind sprites to physics objects.
// A GameObject may have multiple sprites, shapes, bodies, joints, etc.
// Then you can easily add or remove an entire game object from a GameWorld in a single method call.
// For a car you would want to have a single object to manage the car,
// but it would need multiple physics parts and sprites for the body and wheels.
@interface GameObject : NSObject <ChipmunkObject> {
	__weak GameWorld *world;
	
	NSArray *chipmunkObjects;
  NSArray *sprites;
	
	bool fading;
}

// Use this method to create a non-copying dictionary of sprite/body pairs.
// Must be nil terminated.
// ex: [GameObject physicsSprites:sprite1, body1, sprite2, body2, nil]
//+ (NSDictionary *)physicsSprites:(id)firstSprite, ...;

// The game world this game object is currently added to
@property(nonatomic, weak) GameWorld *world;

// The chipmunk objects this gameobject is responsible for
@property(nonatomic, readonly) NSArray *chipmunkObjects;

// The CCSprites for this object
@property(nonatomic, readonly) NSArray *sprites;

// A helper method to fade out entire game objects.
// All of the sprites will fade out, and all of the physics objects will be removed at the end of the interval.
@property(nonatomic, readonly) bool fading;

- (void)fadeOut:(ccTime)interval;

// Remove the GameObject and all it's children from it's GameWorld
-(void)destroy;

@end
