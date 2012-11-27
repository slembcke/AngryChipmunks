//
//  TrajectoryNode.h
//  AngryChipmunks
//
//  Created by Scott Lembcke on 11/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "ObjectiveChipmunk.h"

@class ChipmunkCage;

// Now lets do something fancy. This is more advanced Chipmunk usage than most people will do.
// This class will show you can easily drop back to the Chipmunk C-API for performance critical sections.
// We'll draw the predicted path of the chipmunk cage and it's first impact point.
@interface TrajectoryNode : CCDrawNode {
	CCTexture2D *textureAtlas;
	ChipmunkSpace *space;
	
	ChipmunkCage *cage;
}

@property(retain) ChipmunkCage *cage;

-(id)initWithSpace:(ChipmunkSpace*)theSpace;
-(void)setAimPoint:(cpVect)aimPoint;

@end
