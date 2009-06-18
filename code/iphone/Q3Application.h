/*
 * Quake3 -- iPhone Port
 *
 * Seth Kingsley, January 2008.
 */

#import	<UIKit/UIApplication.h>
#import	<UIKit/UINibDeclarations.h>
#import <UIKit/UIAccelerometer.h>

@class Q3ScreenView;

@interface Q3Application : UIApplication <UIAccelerometerDelegate>
{
@protected
	IBOutlet Q3ScreenView *_screenView;
	IBOutlet UIView *_loadingView;
	UIAccelerationValue _accelerationX, _accelerationY, _accelerationZ;
	int _accelPitch, _accelRoll, _accelYaw;
#if IPHONE_USE_THREADS
	NSThread *_frameThread;
#else
	NSTimer *_frameTimer;
#endif // IPHONE_USE_THREADS
}

@property (assign, readonly, nonatomic) Q3ScreenView *screenView;
@property (assign, readonly, nonatomic) float deviceRotation;
- (void)presentErrorMessage:(NSString *)errorMessage;
- (void)presentWarningMessage:(NSString *)warningMessage;

@end
