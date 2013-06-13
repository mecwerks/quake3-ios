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

- (void)_mainGameLoop
{
	CGPoint newLocation0 = CGPointMake(_oldLocation0.x - _distance0FromCenter/4 * cosf(_touch0Angle),
                                      _oldLocation0.y - _distance0FromCenter/4 * sinf(_touch0Angle));
	CGSize mouseDelta0;
	mouseDelta0.width = roundf((_oldLocation0.y - newLocation0.y) * _mouseScale.x);
	mouseDelta0.height = roundf((newLocation0.x - _oldLocation0.x) * _mouseScale.y);
    
	//Sys_QueEvent(Sys_Milliseconds(), SE_MOUSE, mouseDelta.width, mouseDelta.height, 0, NULL);
	//_oldLocation = newLocation;
	//Com_Printf("%f\n", mouseDelta.width);
    
    //Com_Printf("lastKeyTime: %d\n", lastKeyTime);
	if (_distance0FromCenter > 30 && (!lastKeyTime || (cls.keyCatchers && (Sys_Milliseconds() - lastKeyTime >= 200 ))))
	{
            if (mouseDelta0.height < -10)
            {
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_UPARROW, 1, 0, NULL);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_DOWNARROW, 0, 0, NULL);
                //Com_Printf("%f\n", mouseDelta.height);
            }
            else if (mouseDelta0.height > 10)
            {
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_UPARROW, 0, 0, NULL);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_DOWNARROW, 1, 0, NULL);
                //Com_Printf("Back: %f\n", mouseDelta.height);
            }
            else
            {
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_UPARROW, 0, 0, NULL);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_DOWNARROW, 0, 0, NULL);
            }
            
            if (mouseDelta0.width < -25)
            {
                //Com_Printf("Left: %f\n", mouseDelta.width);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, 'a', 1, 0, NULL);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, 'd', 0, 0, NULL);
            }
            else if (mouseDelta0.width > 25)
            {
                //Com_Printf("Right: %f\n", mouseDelta.width);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, 'a', 0, 0, NULL);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, 'd', 1, 0, NULL);
            }
            else
            {
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, 'a', 0, 0, NULL);
                Sys_QueEvent(Sys_Milliseconds(), SE_KEY, 'd', 0, 0, NULL);
            }
        lastKeyTime = Sys_Milliseconds();
	}
	else
	{
		Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_UPARROW, 0, 0, NULL);
		Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_DOWNARROW, 0, 0, NULL);
		Sys_QueEvent(Sys_Milliseconds(), SE_KEY, 'a', 0, 0, NULL);
		Sys_QueEvent(Sys_Milliseconds(), SE_KEY, 'd', 0, 0, NULL);
	}
    
    CGPoint newLocation1 = CGPointMake(_oldLocation1.x - _distance1FromCenter/4 * cosf(_touch1Angle),
                                      _oldLocation1.y - _distance1FromCenter/4 * sinf(_touch1Angle));
	//CGSize mouseDelta1;
	//mouseDelta1.width = roundf((_oldLocation1.y - newLocation1.y) * _mouseScale.x);
	//mouseDelta1.height = roundf((newLocation1.x - _oldLocation1.x) * _mouseScale.y);
    
    //if (_distance1FromCenter > 60)
    //    Sys_QueEvent(Sys_Milliseconds(), SE_MOUSE, mouseDelta1.width, mouseDelta1.height, 0, NULL);
    _oldLocation1 = newLocation1;
	//Com_Printf("%f\n", mouseDelta.width);
    
}

- (BOOL)_commonInit
{
	CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;

	[layer setDrawableProperties:[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
			kColorFormat, kEAGLDrawablePropertyColorFormat,
			nil]];

	if (!(_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1]))
		return NO;

	if (![self _createSurface])
		return NO;

	[self setMultipleTouchEnabled:YES];

    _GUIMouseLocation = CGPointMake(0, 0);

	_gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 60
												  target:self
												selector:@selector(_mainGameLoop)
												userInfo:nil
												 repeats:YES];

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

- (void)awakeFromNib
{
	CGRect newControlFrame = [_newControlView frame];
	_shootButtonArea = CGRectMake(CGRectGetMinX(newControlFrame) + 4, CGRectGetMinY(newControlFrame) + 40, 68, 68);

	CGRect joypad0CapFrame = [joypad0Cap frame];
	_joypad0Area = CGRectMake(CGRectGetMinX(joypad0CapFrame), CGRectGetMinY(joypad0CapFrame), 250, 250);
	joypad0Centerx = CGRectGetMidX(joypad0CapFrame);
	joypad0Centery = CGRectGetMidY(joypad0CapFrame);
	joypad0MaxRadius = 60;

    CGRect joypad1CapFrame = [joypad1Cap frame];
	_joypad1Area = CGRectMake(CGRectGetMinX(joypad1CapFrame), CGRectGetMinY(joypad1CapFrame), 250, 250);
	joypad1Centerx = CGRectGetMidX(joypad1CapFrame);
	joypad1Centery = CGRectGetMidY(joypad1CapFrame);
	joypad1MaxRadius = 60;
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // always let mouse move
    for (UITouch *touch in touches)
    {
        CGPoint touchLocation = [touch locationInView:self];
        if (CGRectContainsPoint(_joypad1Area, touchLocation) && !_isJoypad1Moving)
        {
            _isJoypad1Moving = YES;
            joypad1TouchHash = [touch hash];
            _isLooking = YES;
            CGPoint mousePoint = CGPointMake((joypad1Centerx - cosf(_touch1Angle) * joypad1MaxRadius) * moveScale_x,
                                           (joypad1Centery - sinf(_touch1Angle) * joypad1MaxRadius) * moveScale_y);
            [self _handleMenuDragToPoint:mousePoint];//:[touch locationInView:self]];
            
            //if (_numTouches > 1)
            //    Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_MOUSE1, 1, 0, NULL);
        }
    }
    
//	if (cls.keyCatchers == 0)
//	{
		for (UITouch *touch in touches)
		{
			CGPoint touchLocation = [touch locationInView:self];

			if (CGRectContainsPoint(_joypad0Area, touchLocation) && !_isJoypad0Moving)
			{
                        _isJoypad0Moving = YES;
                        joypad0TouchHash = [touch hash];
                        lastKeyTime = Sys_Milliseconds();
			}
			//else if (CGRectContainsPoint(_shootButtonArea, touchLocation) && !_isShooting)
			//{
			//	_isShooting = YES;
			//	_isLooking = YES;
			//	Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_MOUSE1, 1, 0, NULL);
			//	[self _handleMenuDragToPoint:[touch locationInView:self]];
			//}
			//else
			//{
			//	_isLooking = YES;
			//	[self _handleMenuDragToPoint:[touch locationInView:self]];
			//}
		}
//	}
	//else
	//{
	//	for (UITouch *touch in touches)
	//	{
	//		if (_numTouches == 0)
	//			[self _handleMenuDragToPoint:[touch locationInView:self]];
    //
	//		Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_MOUSE1 + _numTouches++, 1, 0, NULL);
	//	}
	//}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // always move mouse
    for (UITouch *touch in touches)
    {
        if ([touch hash] == joypad1TouchHash && _isJoypad1Moving)
        {
            CGPoint touchLocation = [touch locationInView:self];
            float dx = (float)joypad1Centerx - (float)touchLocation.x;
            float dy = (float)joypad1Centery - (float)touchLocation.y;
            
            _distance1FromCenter = sqrtf((joypad1Centerx - touchLocation.x) * (joypad1Centerx - touchLocation.x) +
                                         (joypad1Centery - touchLocation.y) * (joypad1Centery - touchLocation.y));
            _touch1Angle = atan2(dy, dx);
            
            if (_distance1FromCenter > joypad1MaxRadius)
                joypad1Cap.center = CGPointMake(joypad1Centerx - cosf(_touch1Angle) * joypad1MaxRadius,
                                                joypad1Centery - sinf(_touch1Angle) * joypad1MaxRadius);
            else
                joypad1Cap.center = touchLocation;
            
            CGPoint mousePoint = CGPointMake((joypad1Centerx - cosf(_touch1Angle) * joypad1MaxRadius) * moveScale_x,
                                           (joypad1Centery - sinf(_touch1Angle) * joypad1MaxRadius)  * moveScale_y);
            [self _handleMenuDragToPoint:mousePoint];
        }
    }
    
//	if (cls.keyCatchers == 0)
//	{
		for (UITouch *touch in touches)
		{
			if ([touch hash] == joypad0TouchHash && _isJoypad0Moving)
			{
				CGPoint touchLocation = [touch locationInView:self];
				float dx = (float)joypad0Centerx - (float)touchLocation.x;
				float dy = (float)joypad0Centery - (float)touchLocation.y;

				_distance0FromCenter = sqrtf((joypad0Centerx - touchLocation.x) * (joypad0Centerx - touchLocation.x) +
						(joypad0Centery - touchLocation.y) * (joypad0Centery - touchLocation.y));
				_touch0Angle = atan2(dy, dx);

				if (_distance0FromCenter > joypad0MaxRadius)
					joypad0Cap.center = CGPointMake(joypad0Centerx - cosf(_touch0Angle) * joypad0MaxRadius,
												   joypad0Centery - sinf(_touch0Angle) * joypad0MaxRadius);
				else
					joypad0Cap.center = touchLocation;
			}
 //       }
	}
//	else
		// TODO: Find the touch that started first.
//		[self _handleMenuDragToPoint:[[touches anyObject] locationInView:self]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        if ([touch hash] == joypad1TouchHash)
        {
            _isJoypad1Moving = NO;
            joypad1TouchHash = 0;
            _distance1FromCenter = 0;
            _touch1Angle = 0;
            joypad1Cap.center = CGPointMake(joypad1Centerx, joypad1Centery);
        }
    }
    
//	if (cls.keyCatchers == 0)
//	{
		for (UITouch *touch in touches)
		{
			if ([touch hash] == joypad0TouchHash)
			{
				_isJoypad0Moving = NO;
				joypad0TouchHash = 0;
				_distance0FromCenter = 0;
				_touch0Angle = 0;
				joypad0Cap.center = CGPointMake(joypad0Centerx, joypad0Centery);
			}
			//else
			//{
			//	_isShooting = NO;
			//	Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_MOUSE1, 0, 0, NULL);
			//	_isLooking = NO;
			//	[NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(_reCenter) userInfo:nil repeats:NO];
			//}
		}
//	}
//	else
    for (UITouch *touch in touches)
        if (_numTouches >= 2)
            Sys_QueEvent(Sys_Milliseconds(), SE_KEY, K_MOUSE1, 0, 0, NULL);
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
