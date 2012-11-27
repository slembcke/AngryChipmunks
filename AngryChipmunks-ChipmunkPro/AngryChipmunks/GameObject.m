//
//  GameObject.m
//  AngryChipmunks
//
//  Created by Scott Lembcke on 11/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameObject.h"
#import "GameWorld.h"


@implementation GameObject

@synthesize fading, world, chipmunkObjects, sprites;

-(void)destroy;
{
	[world remove:self];
}

- (void)fadeOut:(ccTime)interval;
{
	fading = true;
	
	for(CCSprite *sprite in sprites){
		[sprite runAction:[CCSequence actions:
			[CCFadeOut actionWithDuration:interval],
			[CCCallFunc actionWithTarget:self selector:@selector(destroy)],
			nil
		]];
	}
}


@end
