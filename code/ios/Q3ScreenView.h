/*
 * Quake3 -- iOS Port
 *
 * Seth Kingsley, January 2008.
 */

#import	<UIKit/UIView.h>
#import	<OpenGLES/EAGL.h>
#import	<OpenGLES/EAGLDrawable.h>
#import	<OpenGLES/ES1/gl.h>

#define NUM_JOYPADS 2

@class UIImageView;

enum {
    UP_KEY,
    DOWN_KEY,
    LEFT_KEY,
    RIGHT_KEY
};

typedef struct joyPad_s {
    BOOL isJoypadMoving;
	CGRect joypadArea;
	uint joypadCenterx, joypadCentery, joypadMaxRadius, joypadWidth, joypadHeight;
	int joypadTouchHash;
	CGPoint joypadCapLocation;
    CGPoint oldLocation;
    float touchAngle;
    float distanceFromCenter;
    int keys[4];
} joyPad_t;

@interface Q3ScreenView : UIView
{
	IBOutlet UIImageView *joypadCap0;
    IBOutlet UIImageView *joypadCap1;
	IBOutlet UIView *_newControlView;
    IBOutlet UIView *_escapeButton;
    IBOutlet UIView *_enterButton;

@protected
	EAGLContext *_context;
	GLuint _frameBuffer;
	GLuint _renderBuffer;
	GLuint _depthBuffer;
	CGSize _size;
	CGPoint _GUIMouseLocation;
	CGSize _GUIMouseOffset;
	CGPoint _mouseScale;
	NSUInteger _numTouches;
#ifdef TODO
	unsigned int _bitMask;
#endif // TODO
	NSTimer *_gameTimer;
    joyPad_t Joypad[NUM_JOYPADS];
	CGRect _shootButtonArea;
	BOOL _isShooting;
	BOOL _isLooking;
    int lastKeyTime;
    BOOL _inGame;
}

- initWithFrame:(CGRect)frame;
@property (assign, readonly, nonatomic) NSUInteger numColorBits;
@property (assign, readonly, nonatomic) NSUInteger numDepthBits;
@property (assign, readonly, nonatomic) EAGLContext *context;
- (void)swapBuffers;
- (IBAction)startJumping:(id)sender;
- (IBAction)stopJumping:(id)sender;
- (IBAction)startShooting:(id)sender;
- (IBAction)stopShooting:(id)sender;
- (IBAction)changeWeapon:(id)sender;
- (IBAction)escape:(id)sender;
- (IBAction)enter:(id)sender;

@end
