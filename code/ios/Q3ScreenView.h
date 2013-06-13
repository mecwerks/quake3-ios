/*
 * Quake3 -- iOS Port
 *
 * Seth Kingsley, January 2008.
 */

#import	<UIKit/UIView.h>
#import	<OpenGLES/EAGL.h>
#import	<OpenGLES/EAGLDrawable.h>
#import	<OpenGLES/ES1/gl.h>

#define moveScale_x 0.69818182
#define moveScale_y 3.24050633

@class UIImageView;

@interface Q3ScreenView : UIView
{
	IBOutlet UIImageView *joypad0Cap;
	IBOutlet UIImageView *joypad1Cap;
	IBOutlet UIView *_newControlView;

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
	BOOL _isJoypad0Moving;
	CGRect _joypad0Area;
	uint joypad0Centerx, joypad0Centery, joypad0MaxRadius, joypad0Width, joypad0Height;
	int joypad0TouchHash;
	CGPoint _joypad0CapLocation;
	BOOL _isJoypad1Moving;
	CGRect _joypad1Area;
	uint joypad1Centerx, joypad1Centery, joypad1MaxRadius, joypad1Width, joypad1Height;
	int joypad1TouchHash;
	CGPoint _joypad1CapLocation;
    CGPoint _oldLocation0;
    CGPoint _oldLocation1;
	CGRect _shootButtonArea;
	BOOL _isShooting;
	BOOL _isLooking;
	float _touch0Angle;
	float _distance0FromCenter;
	float _touch1Angle;
	float _distance1FromCenter;
    int lastKeyTime;
}

- initWithFrame:(CGRect)frame;
@property (assign, readonly, nonatomic) NSUInteger numColorBits;
@property (assign, readonly, nonatomic) NSUInteger numDepthBits;
@property (assign, readonly, nonatomic) EAGLContext *context;
- (void)swapBuffers;
- (IBAction)startJumping:(id)sender;
- (IBAction)stopJumping:(id)sender;
- (IBAction)changeWeapon:(id)sender;
- (IBAction)escape:(id)sender;
- (IBAction)enter:(id)sender;

@end
