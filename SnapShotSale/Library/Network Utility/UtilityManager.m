
#import "UtilityManager.h"

#define ActivityIndicatorTag 99999

@implementation UtilityManager

@synthesize activityView;
@synthesize isRunning;

UIView * activityView;

//hide Activity Indicator.
+ (void)hideActivityViewer:(UIView *) view
{
    [[[activityView subviews] objectAtIndex:0] stopAnimating];
    [activityView removeFromSuperview];
    activityView = nil;
}


+ (void)showActivityViewer:(UIView *)window
{
	if( ![window viewWithTag:ActivityIndicatorTag] )
	{
        [UtilityManager showActivityViewer:window  withString:@"Loading..."];
    }
}



//Show Activity Indicator.
/*
+ (void)showActivityViewer:(UIView *)currentView withString:(NSString *) text
{

	NSLog(@"showActivityViewer");
	UIWindow* window = [DelegateObject window];
	
	// Added the check that if activityView object is present or not.
	if (activityView == nil)
		activityView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, window.bounds.size.width, window.bounds.size.height)];
	
	activityView.backgroundColor = [UIColor clearColor];
	activityView.center = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
	activityView.tag = ActivityIndicatorTag;
	
	UIActivityIndicatorView *activityWheel = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(window.bounds.size.width / 2 - 12, window.bounds.size.height / 2 - 12, 24, 24)];
	activityWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
	activityWheel.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
									  UIViewAutoresizingFlexibleWidth);
	activityWheel.backgroundColor=[UIColor clearColor];
	activityWheel.center=CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
	[activityView insertSubview:activityWheel atIndex:1];
	[activityWheel release];
	
	UIImageView *imageView = [[UIImageView alloc] init];
	imageView.backgroundColor = [UIColor darkGrayColor];
	imageView.layer.shadowOffset = CGSizeMake(0, 2);
	imageView.layer.shadowOpacity = 70;
	imageView.frame=CGRectMake(window.bounds.size.width / 2 - 64, window.bounds.size.height / 2 - 64, 128, 128);
	imageView.center=activityWheel.center;
	[imageView.layer setCornerRadius:5];
	imageView.center=CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
	[activityView insertSubview:imageView atIndex:0];
	[[[activityView subviews] objectAtIndex:1] startAnimating];
	
	UILabel *lodingLbl = [[UILabel alloc] initWithFrame:CGRectMake(activityView.frame.size.width/2-64, activityView.frame.size.height/2+24 , 128, 40)];
	[lodingLbl setText:text];
	lodingLbl.backgroundColor = [UIColor clearColor];
	lodingLbl.textAlignment = NSTextAlignmentCenter;
	lodingLbl.font = [UIFont fontWithName:@"Heiti TC" size:17];
	lodingLbl.textColor = [UIColor whiteColor];
	[activityView insertSubview:lodingLbl atIndex:2];
	
	[activityView.layer setCornerRadius:5];
	[window.rootViewController.view addSubview: activityView];
	
	[imageView release];
	[lodingLbl release];	
}
*/
#pragma mark -
#pragma mark AlertView.

// set alert method to show alert view.
+ (void) setAlert:(NSString *)title withMessage:(NSString *)message withDelegate:(UIViewController*)delegate withTag:(NSInteger)tag andButtons:(NSString *)buttons, ... {
	
//	UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:nil otherButtonTitles:nil];
	
	va_list args;
	va_start(args, buttons);
    for (NSString *arg = buttons; arg != nil; arg = va_arg(args, NSString*))
    {
        //[alertView addButtonWithTitle:arg];
    }
	va_end(args);
	
	//alertView.tag = tag;
	//[alertView show];

	
}

#pragma mark -
#pragma mark check internet capability.

// check to internet connetion avability
+ (BOOL)isDataSourceAvailable {
	
	static BOOL _isDataSourceAvailable = NO;
	
	// Create zero addy
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	// Recover reachability flags
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
	SCNetworkReachabilityFlags flags;
	
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);
	
	if (!didRetrieveFlags)
	{
		printf("Error. Could not recover network reachability flags\n");
		return 0;
	}
	
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	
	_isDataSourceAvailable = (isReachable && !needsConnection) ? YES : NO;
	
    return _isDataSourceAvailable;
	
}


//test
+ (BOOL) isConnectedToNetwork
{
    // Create zero addy
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	// Recover reachability flags
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
	SCNetworkReachabilityFlags flags;
	
	// synchronous model
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);
	
	if (!didRetrieveFlags)
	{
		return 0;
	}
	
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	
	return (isReachable && !needsConnection);
}

@end
