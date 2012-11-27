//
//  BreakableBox.h
//  AngryChipmunks
//
//  Created by Andy Korth on 11/19/10.
//  Copyright 2010 Howling Moon Software. All rights reserved.
//

#import "GameObject.h"

@class CCSprite;

// Create a box that can be broken.
// Callbacks in the GameWorld calculate the damage applied to the box.
@interface BreakableBox : GameObject {
	float strength;
	CCPhysicsSprite *sprite;
	ChipmunkBody *body;
}

+ (BreakableBox*)squareBox:(CGPoint)pos;

- (id)initWithPos:(CGPoint)pos andSpriteRect:(CGRect)rect collisionType:(cpCollisionType)type strength:(float)str;

@property(assign) float strength;
@property(readonly) CCSprite *sprite;
@property(readonly) ChipmunkBody *body;

@end
