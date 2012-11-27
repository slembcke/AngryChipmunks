#import "Physics.h"

#import "BreakableBox.h"

@implementation BreakableBox

@synthesize sprite, body, strength;

- (id) initWithPos:(CGPoint) pos andSpriteRect:(CGRect)rect collisionType:(cpCollisionType)type strength:(float)str;
{
  if((self = [super init])){
		strength = str;
		
		// Build the physics objects as normal.
		// Technically you should retain the body when it's stored in an instance variable, but it's also being stored in the chipmunkObjects set on this object.
		cpFloat mass = rect.size.width*rect.size.height/4096.0f;
    body = [ChipmunkBody bodyWithMass:mass andMoment:cpMomentForBox(mass, rect.size.width, rect.size.height)];
    body.pos = pos;
    
    ChipmunkShape * shape = [ChipmunkPolyShape boxWithBody:body width:rect.size.width height:rect.size.height];
		shape.elasticity = 0.3f;
		shape.friction = 0.8f;
		shape.layers = PhysicsLayerDefault;
		// The collision type controls what collision callbacks will be triggered when this shape touches other shapes.
		// See more in GameWorld about how.
		shape.collisionType = type;
    shape.data = self;
    
		// Keep a reference to the sprite handy so we can split it up when it's broken.
		sprite = [CCPhysicsSprite spriteWithFile:@"Sprites.png" rect:rect];
		sprite.chipmunkBody = body;
		
		// Create a set with all the physics objects in it. This fullfils the ChipmunkObject protocol.
    chipmunkObjects = @[body, shape];
		sprites = @[sprite];
  }
	
  return self;
}

+ (BreakableBox*) squareBox:(CGPoint)pos
{
	return [[BreakableBox alloc] initWithPos:pos andSpriteRect:CGRectMake(0, 0, 64, 64) collisionType:[BreakableBox class] strength:100.0f];
}

@end
