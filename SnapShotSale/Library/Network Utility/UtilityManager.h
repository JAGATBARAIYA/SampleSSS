
#include <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface UtilityManager : NSObject
{
	BOOL				isRunning;
	BOOL				locationServicesEnabled;
}

@property BOOL isRunning;
@property (nonatomic, retain) UIView *activityView;

+ (void)hideActivityViewer:(UIView *)view;
+ (void)showActivityViewer:(UIView *)window withString:(NSString *) text;
+ (void)showActivityViewer:(UIView *)window;
+ (BOOL)isDataSourceAvailable;
+ (void) setAlert:(NSString *)title withMessage:(NSString *)message 
	 withDelegate:(UIViewController*)delegate withTag:(NSInteger)tag 
	   andButtons:(NSString *)buttons, ... NS_REQUIRES_NIL_TERMINATION ;

//test
+ (BOOL) isConnectedToNetwork;


@end

