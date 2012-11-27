//
//  GameWorld.h
//  AngryChipmunks
//
//  Created by Scott Lembcke on 11/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ObjectiveChipmunk.h"
#import "cocos2d.h"

@class CCLayer;
@class GameObject;
@class ChipmunkSpace;

@class TrajectoryNode;

// Yay, the vaunted GameWorld class.
// This is where all the game logic goes and along with GameObject it binds Cocos2D and Chipmunk together nicely.
@interface GameWorld : CCLayer {
	NSMutableArray *gameObjects;
	
	ChipmunkSpace *space;	
	TrajectoryNode *trajectoryNode;
	
	bool restarting;
}

+(id) scene;

-(void) add:(GameObject *)gameObject;
-(void) remove:(GameObject *)gameObject;



@end
