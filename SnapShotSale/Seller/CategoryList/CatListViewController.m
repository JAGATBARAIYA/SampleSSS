//
//  CatListViewController.m
//  SnapShotSale
//
//  Created by Manish on 08/06/15.
//  Copyright (c) 2015 E2M. All rights reserved.
//

#import "CatListViewController.h"
#import "CategoryCell.h"
#import "WebClient.h"
#import "TKAlertCenter.h"
#import "Common.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "SQLiteManager.h"

#define kCountryTableName                @"country"
#define kZoneTableName                   @"zone"

@interface CatListViewController ()
{
    AppDelegate *app;
}

@property (strong, nonatomic) IBOutlet UITableView *tblList;
@property (strong, nonatomic) IBOutlet UILabel *lblNoRecordFound;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;

@end

@implementation CatListViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)viewWillAppear:(BOOL)animated{
    app.pullRefresh = NO;
    if ([_strTitle isEqualToString:@"Select Category"])
        [self getCategoryList];
    else if ([_strTitle isEqualToString:@"Select Country"])
        [self getCountryList];
    else if ([_strTitle isEqualToString:@"Select State"])
        [self getZoneList];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Common Init

- (void)commonInit{
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.pullRefresh = NO;
    _lblTitle.text = _strTitle;
    _arrCat = [[NSMutableArray alloc]init];
    _tblList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Get Category List

- (void)getCategoryList{
    [_arrCat removeAllObjects];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[WebClient sharedClient]getCategory:nil success:^(NSDictionary *dictionary) {
        NSLog(@"Dictionary : %@",dictionary);
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        if(dictionary){
            if([dictionary[@"success"] boolValue]){
                NSArray *listResult = dictionary[@"categories"];
                if(listResult.count!=0){
                    [listResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        Cat *catList = [Cat dataWithInfo:obj];
                        [_arrCat addObject:catList];
                    }];
                }
                [_tblList reloadData];
            }else {
                // [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kErrorImage];
                _lblNoRecordFound.hidden = _arrCat.count!=0;
            }
            [_tblList reloadData];
        }
        _lblNoRecordFound.hidden = _arrCat.count!=0;
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
    }];
}

#pragma mark - Get Country List

- (void)getCountryList{
    NSArray *data  = [[SQLiteManager singleton]executeSql:@"SELECT * from country"];
    [_arrCat removeAllObjects];
    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Country *country = [Country dataWithInfo:obj];
        [_arrCat addObject:country];
    }];
    [_tblList reloadData];
}

#pragma mark - Get Zone List

- (void)getZoneList{
    NSArray *data  = [[SQLiteManager singleton]executeSql:[NSString stringWithFormat:@"SELECT * from zone where country_id = 223"]];
    [_arrCat removeAllObjects];
    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Zone *zone = [Zone dataWithInfo:obj];
        [_arrCat addObject:zone];
    }];
    [_tblList reloadData];
}

#pragma mark - UITableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrCat.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CategoryCell";
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CategoryCell" owner:self options:nil] objectAtIndex:0];

    if ([_strTitle isEqualToString:@"Select Category"]) {
        Cat *cat = _arrCat[indexPath.row];
        cell.lblCatName.text = cat.strCatName;
    }else if ([_strTitle isEqualToString:@"Select Country"]){
        Country *country = _arrCat[indexPath.row];
        cell.lblCatName.text = country.strCountryName;
    }else if ([_strTitle isEqualToString:@"Select State"]){
        Zone *zone = _arrCat[indexPath.row];
        cell.lblCatName.text = zone.strZoneName;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_strTitle isEqualToString:@"Select Category"]) {
        Cat *catList = _arrCat[indexPath.row];

        if([_delegate respondsToSelector:@selector(catListViewController:categoryList:)]){
            [_delegate catListViewController:self categoryList:catList];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if ([_strTitle isEqualToString:@"Select Country"]){
        Country *country = _arrCat[indexPath.row];

        if([_delegate respondsToSelector:@selector(catListViewController:countryList:)]){
            [_delegate catListViewController:self countryList:country];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if ([_strTitle isEqualToString:@"Select State"]){
        Zone *zone = _arrCat[indexPath.row];

        if([_delegate respondsToSelector:@selector(catListViewController:zoneList:)]){
            [_delegate catListViewController:self zoneList:zone];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Button click event

- (IBAction)btnBackTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
