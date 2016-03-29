//
//  SettingViewController.m
//  SnapShotSale
//
//  Created by Manish on 19/05/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "SettingViewController.h"
#import "REFrostedViewController.h"
#import "SettingCell.h"
#import "Helper.h"
#import "User.h"
#import "SignUpViewController.h"
#import "FeedBackViewController.h"
#import "RemoveAdsViewController.h"
#import "SubscribeView.h"
#import "AdMobViewController.h"
#import "EditProfileViewController.h"
#import "LegalViewController.h"

@interface SettingViewController ()<SubscribeViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tblList;
@property (strong, nonatomic) IBOutlet UIButton *btnLogout;
@property (strong, nonatomic) NSMutableArray *arrList;
@property (strong, nonatomic) SubscribeView *guideView;

@end

@implementation SettingViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Common Init

- (void)commonInit{
    _arrList = [[NSMutableArray alloc]initWithObjects:@"App Version",@"Edit Profile",@"Snaps Plan",@"Feedback",@"Legal", nil];
    _tblList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    User *user = [Helper getCustomObjectToUserDefaults:kUserInformation];
    if (!user.login) {
        _btnLogout.hidden = YES;
        [_arrList removeObjectAtIndex:1];
        [_arrList removeObjectAtIndex:2];
        [_tblList reloadData];
    }else{
        _btnLogout.hidden = NO;
    }
    if ([Helper getIntFromNSUserDefaults:@"subscribe"] == 1) {
        _guideView = [[NSBundle mainBundle] loadNibNamed:@"SubscribeView" owner:self options:nil][0];
        _guideView.delegate = self;
        [self.view addSubview:_guideView];
        _guideView.frame = self.view.bounds;
    }
    if ([Helper getIntFromNSUserDefaults:kRemove_BannerAds] == 1) {
        [AdMobViewController removeBanner:self];
    }else{
        [AdMobViewController createBanner:self];
    }
}

#pragma mark - Button Click event

- (IBAction)btnMenuTapped:(id)sender{
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)btnLogOutTapped:(id)sender{
    _btnLogout.hidden = YES;
    [_arrList removeObjectAtIndex:1];
    [_arrList removeObjectAtIndex:2];
    [_tblList reloadData];
    [User sharedUser].login = NO;
    [Helper addCustomObjectToUserDefaults:[User sharedUser] key:kUserInformation];
    [_tblList reloadData];
}

#pragma mark - UITableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"SettingCell";
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:self options:nil] objectAtIndex:0];
    if (indexPath.row == 0) {
        cell.imgView.hidden = YES;
        cell.lblVersion.hidden = NO;
        cell.lblVersion.text = [NSString stringWithFormat:@"Version %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    }
    if ([User sharedUser].login) {
        if (indexPath.row == 2) {
            cell.imgView.hidden = YES;
            cell.lblCount.hidden = NO;

            NSLog(@"%ld",(long)[Helper getIntFromNSUserDefaults:@"TotalQty"]);
            NSLog(@"%ld",(long)[Helper getIntFromNSUserDefaults:@"TotalCount"]);

            NSInteger count = [Helper getIntFromNSUserDefaults:@"TotalQty"] - [Helper getIntFromNSUserDefaults:@"TotalCount"];
            cell.lblCount.text = [NSString stringWithFormat:@"%ld/%ld remaining",(long)count,(long)[Helper getIntFromNSUserDefaults:@"TotalQty"]];
        }
        
         cell.lblName.text = _arrList[indexPath.row];
    }else {
        if (indexPath.row == 0) {
            cell.lblName.text = _arrList[indexPath.row];
        }else if (indexPath.row == 1){
            cell.lblName.text = @"Feedback";
        }else{
            cell.lblName.text = @"Legal";
        }
    }
   
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([User sharedUser].login) {
        if (indexPath.row == 1) {
            EditProfileViewController *editProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
            [self.navigationController pushViewController:editProfileViewController animated:YES];
        }
        if (indexPath.row == 3) {
            FeedBackViewController *feedbackViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedBackViewController"];
            [self.navigationController pushViewController:feedbackViewController animated:YES];
        }
        if (indexPath.row == 4) {
            LegalViewController *legalViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"LegalViewController"];
            [self.navigationController pushViewController:legalViewController animated:YES];
        }
        if (indexPath.row == 2) {
            [Helper addIntToUserDefaults:0 forKey:@"subscribe"];

            _guideView = [[NSBundle mainBundle] loadNibNamed:@"SubscribeView" owner:self options:nil][0];
            _guideView.delegate = self;
            [self.view addSubview:_guideView];
            _guideView.frame = self.view.bounds;
        }
    }else{
        if (indexPath.row == 1) {
            FeedBackViewController *feedbackViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedBackViewController"];
            [self.navigationController pushViewController:feedbackViewController animated:YES];
        }
        if (indexPath.row == 2) {
            LegalViewController *legalViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"LegalViewController"];
            [self.navigationController pushViewController:legalViewController animated:YES];
        }
    }
}

- (void)subView:(SubscribeView *)view{
    [view removeFromSuperview];
    [self commonInit];
    [_tblList reloadData];
}

@end
