//
//  LegalViewController.m
//  SnapShotSale
//
//  Created by Manish on 09/12/15.
//  Copyright © 2015 E2M. All rights reserved.
//

#import "LegalViewController.h"
#import "SettingCell.h"
#import "Helper.h"
#import "AdMobViewController.h"
#import "PandPViewController.h"
#import "TandCViewController.h"

@interface LegalViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tblList;
@property (strong, nonatomic) NSMutableArray *arrList;

@end

@implementation LegalViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Common Init

- (void)commonInit{
    _arrList = [[NSMutableArray alloc]initWithObjects:@"Privacy Policy",@"Terms and Conditions", nil];
    _tblList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if ([Helper getIntFromNSUserDefaults:kRemove_BannerAds] == 1) {
        [AdMobViewController removeBanner:self];
    }else{
        [AdMobViewController createBanner:self];
    }
}

#pragma mark - Button Click Event

- (IBAction)btnBackTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
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

    cell.lblName.text = _arrList[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        PandPViewController *pandpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PandPViewController"];
        [self.navigationController pushViewController:pandpViewController animated:YES];
    }
    if (indexPath.row == 1) {
        TandCViewController *tandcViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"TandCViewController"];
        [self.navigationController pushViewController:tandcViewController animated:YES];
    }
}

@end
