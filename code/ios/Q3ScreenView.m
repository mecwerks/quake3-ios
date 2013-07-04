/*
 * Quake3 -- iOS Port
 *
 * Seth Kingsley, January 2008.
 */

#import	"Q3ScreenView.h"
#import "ios_local.h"
#import	<QuartzCore/QuartzCore.h>
#import	<OpenGLES/ES1/glext.h>
#import	<UIKit/UITouch.h>
#import <UIKit/UIImageView.h>
#import <UIKit/UIScreen.h>

#include "../ui/keycodes.h"
#include "../renderer/tr_local.h"
#include "../client/client.h"

#define kColorFormat  kEAGLColorFormatRGB565
#define kNumColorBits 16
#define kDepthFormat  GL_DEPTH_COMPONENT16_OES
#define kNumDepthBits 16


@implementation Q3ScreenView

+ (Class)layerClass
{
	return [CAEAGLLayer class];
}

- (void) _checkJoypads {
    int i;
    int width, height;
    CGPoint newLocation;
    
    for (i = 0; i < NUM_JOYPADS; i++) {
        newLocation = CGPointMake(
                                  Joypad[i].oldLocation.x - Joypad[i].distanceFromCenter/4 * cosf(Joypad[i].touchAngle),
                                  Joypad[i].oldLocation.y - Joypad[i].distanceFromCenter/4 * sinf(Joypad[i].touchAngle));
        width = roundf((Joypad[i].oldLocation.y - newLocation.y) * _mouseScale.x);
        height = roundf((newLocation.x - Joypad[i].oldLocation.x) * _mouseScale.y);
        
        if (Joypad[i].distanceFromCenter > 8)
        {
			if (i == 0 && joypadCap0.hidden) break;
			else if (i == 1 && joypadCap1.hidden) break;
			
			if ((cls.keyCatchers & KEYCATCH_UI) && !(Sys_Milliseconds() - lastKeyTime >= 180))
				goto skipkeys;
			
            if (height < -5)
            {
                cl_joyscale_x[0] = abs(height);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[UP_KEY], 1, 0, NULL);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[DOWN_KEY], 0, 0, NULL);
            }
            else if (height > 5)
            {
                cl_joyscale_x[1] = height;
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[UP_KEY], 0, 0, NULL);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[DOWN_KEY], 1, 0, NULL);
            }
            else
            {
                cl_joyscale_x[0] = cl_joyscale_x[1] = 0;
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[UP_KEY], 0, 0, NULL);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[DOWN_KEY], 0, 0, NULL);
            }
            
            if (i != 0) cl_joyscale_x[0] = cl_joyscale_x[1] = 0;
            if (cl_joyscale_x[0] > 60) cl_joyscale_x[0] = 60;
            if (cl_joyscale_x[1] > 60) cl_joyscale_x[1] = 60;
            
            if (width < -5)
            {
                cl_joyscale_y[1] = abs(width);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[LEFT_KEY], 1, 0, NULL);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[RIGHT_KEY], 0, 0, NULL);
            }
            else if (width > 5)
            {
                cl_joyscale_y[0] = width;
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[LEFT_KEY], 0, 0, NULL);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[RIGHT_KEY], 1, 0, NULL);
            }
            else
            {
                cl_joyscale_y[0] = cl_joyscale_y[1] = 0;
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[LEFT_KEY], 0, 0, NULL);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[RIGHT_KEY], 0, 0, NULL);
            }
            
            if (i != 0) cl_joyscale_y[0] = cl_joyscale_y[1] = 0;
            if (cl_joyscale_y[0] > 60) cl_joyscale_y[0] = 60;
            if (cl_joyscale_y[1] > 60) cl_joyscale_y[1] = 60;
            lastKeyTime = Sys_Milliseconds();
            
        }
        else
        {
			skipkeys:
            if (i == 0) cl_joyscale_x[0] = cl_joyscale_x[1] = cl_joyscale_y[0] = cl_joyscale_y[1] = 0;
            Sys_QueEventEx(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[UP_KEY], 0, 0, 0, NULL);
            Sys_QueEventEx(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[DOWN_KEY], 0, 0, 0, NULL);
            Sys_QueEventEx(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[LEFT_KEY], 0, 0, 0, NULL);
            Sys_QueEventEx(Sys_Milliseconds(), SE_KEY, Joypad[i].keys[RIGHT_KEY], 0, 0, 0, NULL);
        }
    }
}

- (void)_showMenuView {
    joypadCap0.hidden = NO;
    joypadCap1.hidden = YES;
    _enterButton.hidden = NO;
    _escapeButton.hidden = NO;
    _newControlView.hidden = YES;
}

- (void)_showInGameView {
    joypadCap0.hidden = NO;
    joypadCap1.hidden = NO;
    _enterButton.hidden = NO;
    _escapeButton.hidden = NO;
    _newControlView.hidden = NO;
}

- (void)_hideView {
    joypadCap0.hidden = YES;
    joypadCap1.hidden = YES;
    _enterButton.hidden = YES;
    _escapeButton.hidden = YES;
    _newControlView.hidden = YES;
}

- (void)_mainGameLoop {
    if (cls.keyCatchers & KEYCATCH_UI) [self _showMenuView];
	else if (cls.state == CA_ACTIVE) [self _showInGameView];
	else [self _hideView];

	[self _checkJoypads];
}

- (BOOL)_commonInit
{
	CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;

	[layer setDrawableProperties:[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
			kColorFormat, kEAGLDrawablePropertyColorFormat, nil]];

	if (!(_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1]))
		return NO;

	if (![self _createSurface])
		return NO;

	[self setMultipleTouchEnabled:YES];

    _GUIMouseLocation = CGPointMake(0, 0);

	_gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 60
                target:self selector:@selector(_mainGameLoop) userInfo:nil repeats:YES];

    // Joypad UP, DOWN, LEFT, and RIGHT keys
    Joypad[0].keys[0] = K_UPARROW;
    Joypad[0].keys[1] = K_DOWNARROW;
    Joypad[0].keys[2] = K_LEFTARROW;
    Joypad[0].keys[3] = K_RIGHTARROW;
    Joypad[1].keys[0] = K_PGDN;
    Joypad[1].keys[1] = K_DEL;
    Joypad[1].keys[2] = K_SHIFT;
    Joypad[1].keys[3] = K_CTRL;
	    
	return YES;
}

- initWithCoder:(NSCoder *)coder
{
	if ((self = [super initWithCoder:coder]))
	{
		if (![self _commonInit])
		{
			[self release];
			return nil;
		}
	}

	return self;
}

- initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		if (![self _commonInit])
		{
			[self release];
			return nil;
		}
	}

	return self;
}

- (void)dealloc
{
	[self _destroySurface];

	[_context release];

	[super dealloc];
}

- (void)awakeFromNib {
    int i;
    CGRect joypadCapFrame;
	CGRect newControlFrame = [_newControlView frame];
	_shootButtonArea = CGRectMake(CGRectGetMinX(newControlFrame) + 4, CGRectGetMinY(newControlFrame) + 40, 68, 68);

    for (i = 0; i < NUM_JOYPADS; i++)
    {
        // Joypad caps
        if (i == 0) joypadCapFrame = [joypadCap0 frame];
        else joypadCapFrame = [joypadCap1 frame];

        Joypad[i].joypadArea = CGRectMake(CGRectGetMinX(joypadCapFrame),
                                          CGRectGetMinY(joypadCapFrame), 250, 250);
        Joypad[i].joypadCenterx = CGRectGetMidX(joypadCapFrame);
        Joypad[i].joypadCentery = CGRectGetMidY(joypadCapFrame);
        Joypad[i].joypadMaxRadius = 60;
    }
}

- (BOOL)_createSurface
{
	CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;

	GLint oldFrameBuffer, oldRenderBuffer;

	if (![EAGLContext setCurrentContext:_context])
		return NO;

	_size = layer.bounds.size;
	_size.width = roundf(_size.width);
	_size.height = roundf(_size.height);
	if (_size.width > _size.height)
	{
		_GUIMouseOffset.width = _GUIMouseOffset.height = 0;
		_mouseScale.x = 640 / _size.width;
		_mouseScale.y = 480 / _size.height;
	}
	else
	{
		float aspect = _size.height / _size.width;

		_GUIMouseOffset.width = -roundf((480 * aspect - 640) / 2.0);
		_GUIMouseOffset.height = 0;
		_mouseScale.x = (480 * aspect) / _size.height;
		_mouseScale.y = 480 / _size.width;
	}

	qglGetIntegerv(GL_RENDERBUFFER_BINDING_OES, &oldRenderBuffer);
	qglGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &oldFrameBuffer);

	glGenRenderbuffersOES(1, &_renderBuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _renderBuffer);

	if (![_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer])
	{
		glDeleteRenderbuffersOES(1, &_renderBuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_BINDING_OES, oldRenderBuffer);
		return NO;
	}

	glGenFramebuffersOES(1, &_frameBuffer);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, _frameBuffer);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _renderBuffer);
	glGenRenderbuffersOES(1, &_depthBuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _depthBuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, kDepthFormat, _size.width, _size.height);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, _depthBuffer);

	glBindRenderbufferOES(GL_FRAMEBUFFER_OES, oldFrameBuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, oldRenderBuffer);
	
	return YES;
}

- (void)_destroySurface
{
	EAGLContext *oldContext = [EAGLContext currentContext];

	if (oldContext != _context)
		[EAGLContext setCurrentContext:_context];

	glDeleteRenderbuffersOES(1, &_depthBuffer);
	glDeleteRenderbuffersOES(1, &_renderBuffer);
	glDeleteFramebuffersOES(1, &_frameBuffer);

	if (oldContext != _context)
		[EAGLContext setCurrentContext:oldContext];
}

- (void)layoutSubviews
{
	CGSize boundsSize = self.bounds.size;

	if (roundf(boundsSize.width) != _size.width || roundf(boundsSize.height) != _size.height)
	{
		[self _destroySurface];
		[self _createSurface];
	}
}

- (void)_reCenter {
	if(!_isLooking) {
		Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_END, 1, 0, NULL);
		Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_END, 0, 0, NULL);
	}
}

- (void)_handleMenuDragToPoint:(CGPoint)point
{
	CGPoint mouseLocation, GUIMouseLocation;
	int deltaX, deltaY;
    
	if (glConfig.vidRotation == 90)
	{
		mouseLocation.x = _size.height - point.y;
		mouseLocation.y = point.x;
	}
	else if (glConfig.vidRotation == 0)
	{
		mouseLocation.x = point.x;
		mouseLocation.y = point.y;
	}
	else if (glConfig.vidRotation == 270)
	{
		mouseLocation.x = point.y;
		mouseLocation.y = _size.width - point.x;
	}
	else
	{
		mouseLocation.x = _size.width - point.x;
		mouseLocation.y = _size.height - point.y;
	}
    
	GUIMouseLocation.x = roundf(_GUIMouseOffset.width + mouseLocation.x * _mouseScale.x);
	GUIMouseLocation.y = roundf(_GUIMouseOffset.height + mouseLocation.y * _mouseScale.y);
    
	GUIMouseLocation.x = MIN(MAX(GUIMouseLocation.x, 0), 640);
	GUIMouseLocation.y = MIN(MAX(GUIMouseLocation.y, 0), 480);
    
	deltaX = GUIMouseLocation.x - _GUIMouseLocation.x;
	deltaY = GUIMouseLocation.y - _GUIMouseLocation.y;
	_GUIMouseLocation = GUIMouseLocation;
    
	ri.Printf(PRINT_DEVELOPER, "%s: deltaX = %d, deltaY = %d\n", __PRETTY_FUNCTION__, deltaX, deltaY);
	if (deltaX || deltaY)
		Sys_QueEvent(0, SE_MOUSE, deltaX, deltaY, 0, NULL);
}

// handleDragFromPoint rotates the camera based on a touchedMoved event
- (void)_handleDragFromPoint:(CGPoint)location toPoint:(CGPoint)previousLocation
{
	if (glConfig.vidRotation == 90)
	{
		CGSize mouseDelta;

		mouseDelta.width = roundf((previousLocation.y - location.y) * _mouseScale.x);
		mouseDelta.height = roundf((location.x - previousLocation.x) * _mouseScale.y);

		Sys_QueEvent(Sys_Milliseconds(), SE_MOUSE, mouseDelta.width, mouseDelta.height, 0, NULL);
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    int i;

    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInView:self];
        for (i = 0; i < NUM_JOYPADS; i++) {
            if (CGRectContainsPoint(Joypad[i].joypadArea, touchLocation) &&
                !Joypad[i].isJoypadMoving)
            {
                Joypad[i].isJoypadMoving = YES;
                Joypad[i].joypadTouchHash = [touch hash];
                if (i == 0) lastKeyTime = Sys_Milliseconds();
                else _isLooking = YES;
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    int i;

    for (UITouch *touch in touches)
    {
        for (i = 0; i < NUM_JOYPADS; i++) {
            if ([touch hash] == Joypad[i].joypadTouchHash && Joypad[i].isJoypadMoving)
            {
                CGPoint touchLocation = [touch locationInView:self];
                float dx = (float)Joypad[i].joypadCenterx - (float)touchLocation.x;
                float dy = (float)Joypad[i].joypadCentery - (float)touchLocation.y;
                
                Joypad[i].distanceFromCenter = sqrtf(
                                (Joypad[i].joypadCenterx - touchLocation.x) * (Joypad[i].joypadCenterx - touchLocation.x) +
                                (Joypad[i].joypadCentery - touchLocation.y) * (Joypad[i].joypadCentery - touchLocation.y));
                
                Joypad[i].touchAngle = atan2(dy, dx);
                
                if (i == 0) {
                    if (Joypad[i].distanceFromCenter > Joypad[i].joypadMaxRadius)
                        joypadCap0.center = CGPointMake(
                                        Joypad[i].joypadCenterx - cosf(Joypad[i].touchAngle) * Joypad[i].joypadMaxRadius,
                                        Joypad[i].joypadCentery - sinf(Joypad[i].touchAngle) * Joypad[i].joypadMaxRadius);
                    else
                        joypadCap0.center = touchLocation;
                } else {
                    if (Joypad[i].distanceFromCenter > Joypad[i].joypadMaxRadius)
                        joypadCap1.center = CGPointMake(
                                        Joypad[i].joypadCenterx - cosf(Joypad[i].touchAngle) * Joypad[i].joypadMaxRadius,
                                        Joypad[i].joypadCentery - sinf(Joypad[i].touchAngle) * Joypad[i].joypadMaxRadius);
                    else
                        joypadCap1.center = touchLocation;
                }
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    int i;
    
    for (UITouch *touch in touches)
    {
        for (i = 0; i < NUM_JOYPADS; i++) {
            if ([touch hash] == Joypad[i].joypadTouchHash)
            {
                Joypad[i].isJoypadMoving = NO;
                Joypad[i].joypadTouchHash = 0;
                Joypad[i].distanceFromCenter = 0;
                Joypad[i].touchAngle = 0;
                // Joypad caps
                if (i == 0) joypadCap0.center = CGPointMake(Joypad[i].joypadCenterx, Joypad[i].joypadCentery);
                else joypadCap1.center = CGPointMake(Joypad[i].joypadCenterx, Joypad[i].joypadCentery);
            }
        }
    }
}

@dynamic numColorBits;

- (NSUInteger)numColorBits
{
	return kNumColorBits;
}

- (NSUInteger)numDepthBits
{
	return kNumDepthBits;
}

@synthesize context = _context;

- (void)swapBuffers
{
	EAGLContext *oldContext = [EAGLContext currentContext];
	GLuint oldRenderBuffer;

	if (oldContext != _context)
		[EAGLContext setCurrentContext:_context];

	qglGetIntegerv(GL_RENDERBUFFER_BINDING_OES, (GLint *)&oldRenderBuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _renderBuffer);

	if (![_context presentRenderbuffer:GL_RENDERBUFFER_OES])
		NSLog(@"Failed to swap renderbuffer");

	if (oldContext != _context)
		[EAGLContext setCurrentContext:oldContext];
}

- (IBAction)startJumping:(id)sender
{
	Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_SPACE, 1, 0, NULL);
}

- (IBAction)stopJumping:(id)sender
{
	Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_SPACE, 0, 0, NULL);
}

- (IBAction)changeWeapon:(id)sender
{
	Sys_QueEvent(Sys_Milliseconds(), SE_KEY, '/', 1, 0, NULL);
	Sys_QueEvent(Sys_Milliseconds(), SE_KEY, '/', 0, 0, NULL);
}

- (IBAction)startShooting:(id)sender
{
	Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_MOUSE1, 1, 0, NULL);
}

- (IBAction)stopShooting:(id)sender
{
	Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_MOUSE1, 0, 0, NULL);
}

- (IBAction)escape:(id)sender
{
	Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_ESCAPE, 1, 0, NULL);
	Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_ESCAPE, 0, 0, NULL);
}

- (IBAction)enter:(id)sender
{
	Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_ENTER, 1, 0, NULL);
	Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_ENTER, 0, 0, NULL);
}

@end
