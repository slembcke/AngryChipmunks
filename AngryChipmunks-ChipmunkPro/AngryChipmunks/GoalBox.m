#import "GoalBox.h"

#import "Physics.h"
#import "BreakableBox.h"

#import "GameWorld.h"

@implementation GoalBox

+ (GoalBox *) goalBox:(CGPoint)pos;
{
    return [[GoalBox alloc]
			initWithPos:pos
			andSpriteRect:CGRectMake(4*32, 0, 32, 32)
			collisionType:[GoalBox class]
			strength:15.0f
		];
}

@end
