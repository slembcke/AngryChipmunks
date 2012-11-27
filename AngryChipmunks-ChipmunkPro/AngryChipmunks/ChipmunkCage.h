//
//  ChipmunkCage.h
//  AngryChipmunks
//
//  Created by Scott Lembcke on 11/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GameObject.h"

// Lets do something interesting for our projectile.
// Lets make it be a hollow box with something inside of it.
// Objective-Chipmunk makes this easy to manage!
@interface ChipmunkCage : GameObject {
	ChipmunkBody *body, *rodentBody;
	ChipmunkShape *shape;
}

@property(readonly) ChipmunkBody *body;
@property(readonly) ChipmunkShape *shape;

- (void)setMuzzleVelocity:(cpVect)muzzleVelocity;

@end
