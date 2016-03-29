//
//  MenuViewController.m
//  Vetted-Intl
//
//  Created by Manish Dudharejia on 20/02/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuCell.h"
#import "Helper.h"
#import "User.h"
#import "ViewController.h"
#import "DEMONavigationController.h"
#import "ProductListViewController.h"
#import "ItemListViewController.h"
#import "ProductDetailViewController.h"
#import "AddItemViewController.h"
#import "RemoveAdsViewController.h"
#import "SettingViewController.h"
#import "AppDelegate.h"
#import "WebClient.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"


@interface MenuViewController ()
{
    AppDelegate *app;
}

@property (strong, nonatomic) IBOutlet UITableView *tblList;
@property (strong, nonatomic) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) IBOutlet UIImageView *imgProfile;

@property (strong, nonatomic) NSArray *arrMenuItems;

@end

@implementation MenuViewController

#pragma mark - View life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated{
    [self commonInit];
    if ([User sharedUser].login){
        //        NSString *sellerName = [NSString stringWithFormat:@"%@%@",[[[User sharedUser].strFullName substringToIndex:1] uppercaseString],[[[User sharedUser].strFullName substringFromIndex:1] lowercaseString] ];

        NSMutableString *userName = [[User sharedUser].strFullName mutableCopy];
        [userName enumerateSubstringsInRange:NSMakeRange(0, [userName length])
                                        options:NSStringEnumerationByWords
                                     usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                         [userName replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                                    withString:[[substring substringToIndex:1] uppercaseString]];
                                     }];

        _lblUserName.text = userName;
        _imgProfile.layer.borderWidth = 1;
        _imgProfile.layer.cornerRadius = 17.0;
        _imgProfile.layer.borderColor = [UIColor whiteColor].CGColor;
        _imgProfile.layer.masksToBounds = YES;
        
        NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",[User sharedUser].strFBID]];

        if ([[User sharedUser].strFBID isEqualToString:@""]) {
            _imgProfile.image = [UIImage imageNamed:@"menu_logo"];
        }else {
            if (app.appFBImg == nil) {
                UIImage *fbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:pictureURL]];
                _imgProfile.image = fbImage;
                app.appFBImg = fbImage;
            }else{
//                [_imgProfile setImageWithURL:pictureURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                _imgProfile.image = app.appFBImg;
            }
        }
    }else{
        _lblUserName.text = @"Guest";
        UIImage *fbImage = [UIImage imageNamed:@"menu_logo"];
        _imgProfile.image = fbImage;
    }
    [_tblList reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Common Init

- (void)commonInit{
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([User sharedUser].login){
        _arrMenuItems = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Menu1" ofType:@"plist"]];
    }else{
        _arrMenuItems = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Menu" ofType:@"plist"]];
    }
    _tblList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - UITableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IPHONE6PLUS) {
        return 65;
    }else if (IPHONE6){
        return 60;
    }else {
        return 58;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrMenuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"MenuCell";
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:self options:nil] objectAtIndex:0];
    
    NSDictionary *dict = _arrMenuItems[indexPath.row];
    cell.lblMenuName.text = dict[@"name"];
    cell.imgMenu.image = [UIImage imageNamed:dict[@"ImgName"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DEMONavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    switch (indexPath.row) {
        case 0:
        {
            if ([User sharedUser].login) {
                AddItemViewController *addItemViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddItemViewController"];
                navigationController.viewControllers = @[addItemViewController];
            }else{
                ViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                navigationController.viewControllers = @[viewController];
                app.flag = NO;
            }
        }
            break;
        case 1:
        {
            ProductListViewController *productListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductListViewController"];
            navigationController.viewControllers = @[productListViewController];
        }
            break;
        case 2:
        {
            if ([User sharedUser].login) {
                ItemListViewController *itemListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemListViewController"];
                navigationController.viewControllers = @[itemListViewController];
            }else{
                ViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                navigationController.viewControllers = @[viewController];
                app.flag = YES;
            }
        }
            break;
        case 3:
        {
            RemoveAdsViewController *removeAdsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RemoveAdsViewController"];
            
            removeAdsViewController.strType =@"ads";
            navigationController.viewControllers = @[removeAdsViewController];
        }
            break;
        case 4:
        {
            SettingViewController *settingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
            navigationController.viewControllers = @[settingViewController];
        }
            break;
        case 5:
        {
            [User sharedUser].login = NO;
            [Helper addCustomObjectToUserDefaults:[User sharedUser] key:kUserInformation];
            [_tblList reloadData];
        }
            break;
            
        default:
            break;
    }
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
}

@end
