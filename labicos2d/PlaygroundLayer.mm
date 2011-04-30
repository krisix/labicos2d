//
//  PlaygroundLayer.m
//  labicos2d
//
//  Created by Krzysztof Wolski on 11-04-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaygroundLayer.h"
#import "LvlMngr.h"

#define PTM_RATIO 32

@implementation PlaygroundLayer

+(CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PlaygroundLayer *layer = [PlaygroundLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init {
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;

		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(-1.0f, -1.0f);
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		_World = new b2World(gravity, doSleep);
		
		_World->SetContinuousPhysics(true);
		
		[self setupWorld:winSize];
		[self setupSprites];
//		[self setupLevel];
		
		[self schedule: @selector(tick:)];
		
		LvlMngr *lvlMngr = [LvlMngr instance];
		[lvlMngr loadLevel:1 intoLayer:self withBox2DBody:_World withTileFromFile:@"box-002.png"];
	}
	return self;
}

-(void) tick: (ccTime) dt {
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	_World->Step(dt, velocityIterations, positionIterations);
	
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = _World->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
}

- (void) setupSprites {
	_MetalBallSprite = [CCSprite spriteWithFile:@"ball-002.png"];
	_MetalBallSprite.position = CGPointMake(400, 280);
	_MetalBallSprite.tag = 1001;
	
	[self addChild:_MetalBallSprite];
	

	// Create ball body and shape
	b2BodyDef ballBodyDef;
	ballBodyDef.type = b2_dynamicBody;
	ballBodyDef.position.Set(400/PTM_RATIO, 280/PTM_RATIO);
	ballBodyDef.userData = _MetalBallSprite;
	b2Body *_body = _World->CreateBody(&ballBodyDef);
	
	b2CircleShape circle;
	circle.m_radius = 9.0 / PTM_RATIO;
	
	b2FixtureDef ballShapeDef;
	ballShapeDef.shape = &circle;
	ballShapeDef.density = 11300;
	ballShapeDef.friction = 0.2f;
	ballShapeDef.restitution = 0.2f;
	_body->CreateFixture(&ballShapeDef);

}

- (void) setupWorld:(CGSize)winSize {
	// Create edges around the entire screen
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0,0);
	b2Body *groundBody = _World->CreateBody(&groundBodyDef);
	b2PolygonShape groundBox;
	b2FixtureDef boxShapeDef;
	boxShapeDef.shape = &groundBox;
	groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
	groundBody->CreateFixture(&boxShapeDef);
	groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
	groundBody->CreateFixture(&boxShapeDef);
	groundBox.SetAsEdge(b2Vec2(0, winSize.height/PTM_RATIO), 
						b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
	groundBody->CreateFixture(&boxShapeDef);
	groundBox.SetAsEdge(b2Vec2(winSize.width/PTM_RATIO, 
							   winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
	groundBody->CreateFixture(&boxShapeDef);	
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
//    b2Vec2 gravity(-acceleration.y * 15, acceleration.x * 15);
//    _World->SetGravity(gravity);
	
//	CCLOG(@"acceleration.x: %f, acceleration.y: %f", acceleration.x, acceleration.y);

    for (b2Body *b = _World->GetBodyList(); b; b = b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *gSprite = (CCSprite *)b->GetUserData();
			
			if (gSprite.tag == 1001) {
                b2Vec2 curPos = b->GetPosition();
				
                b2Vec2 force = b2Vec2(-acceleration.y * 5000, acceleration.x * 5000);
                
                b->ApplyLinearImpulse(force, curPos);
			}
        }
    }
}


@end
