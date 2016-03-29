//
//  AddressListVC.m
//  SnapShotSale
//
//  Created by Manish on 04/01/16.
//  Copyright © 2016 E2M. All rights reserved.
//

#import "AddressListVC.h"
#import "SQLiteManager.h"
#import <objc/runtime.h>

#define kScreenBounds                           ([[UIScreen mainScreen] bounds])
#define kScreenWidth                            (kScreenBounds.size.width)
#define kScreenHeight                           (kScreenBounds.size.height)
#define kIndex                                  @"Index"

CGFloat  firstX, firstY;
int intLastPanIndex;

@interface AddressListVC ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tblList;
@property (strong, nonatomic) IBOutlet UILabel *lblNoRecordFound;
@property (strong, nonatomic) NSMutableArray *arrList;

@end

@implementation AddressListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _arrList = [[NSMutableArray alloc]init];
    _tblList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self getAddressList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Click Event

- (IBAction)btnBackTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Get Address List

- (void)getAddressList{
    NSArray *data  = [[SQLiteManager singleton]executeSql:@"SELECT * from address"];
    [_arrList removeAllObjects];
    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Address *address = [Address dataWithInfo:obj];
        [_arrList addObject:address];
    }];
    _lblNoRecordFound.hidden = _arrList.count!=0;
    [_tblList reloadData];
}

#pragma mark - UITableView delegate methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 125.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"AddressCell";
    AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AddressCell" owner:self options:nil] objectAtIndex:0];

    Address *address = _arrList[indexPath.row];
    cell.lblName.text = [[NSString stringWithFormat:@"%@ ",address.strFirstName ] stringByAppendingString:address.strLastName];
    cell.lblPhone.text = address.strPhone;
    cell.lblAddress.text = address.strAddress;
    [cell setBackgroundColor:[UIColor clearColor]];

    [cell.btnDelete addTarget:self action:@selector(btnDeleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnDelete.tag = indexPath.row;

    for (UIGestureRecognizer *aRecognizer in cell.roundedView.gestureRecognizers) {
        [cell.roundedView removeGestureRecognizer:aRecognizer];
    }

    UIPanGestureRecognizer *aPanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panCellViewAction:)];
    [cell.roundedView addGestureRecognizer:aPanGestureRecognizer];
    aPanGestureRecognizer.delegate = self;

    objc_setAssociatedObject(cell.roundedView, kIndex, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Address *address = _arrList[indexPath.row];

    if([_delegate respondsToSelector:@selector(addressListVC:addressList:)]){
        [_delegate addressListVC:self addressList:address];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)btnDeleteClicked:(UIButton *)sender{
    Address *address = _arrList[sender.tag];
    [[SQLiteManager singleton]deleteRowWithId:(int)address.intAddressID from:@"address"];

    [_arrList removeObjectAtIndex:sender.tag];
    [_tblList beginUpdates];
    [_tblList deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [_tblList endUpdates];
    [_tblList reloadData];
    _lblNoRecordFound.hidden = _arrList.count!=0;
}

#pragma mark - Event

- (IBAction)panCellViewAction:(id)sender {
    UIPanGestureRecognizer *aRecognizer = (UIPanGestureRecognizer *)sender;

    UIView *aPanView = aRecognizer.view;

    NSIndexPath *aTblViewIndexPath = [NSIndexPath indexPathForItem:intLastPanIndex inSection:0];

    AddressCell *aCellTblView = (AddressCell *)[self.tblList cellForRowAtIndexPath:aTblViewIndexPath];

    [UIView animateWithDuration:0.2 animations:^{
        [aCellTblView.roundedView setCenter:CGPointMake(kScreenWidth/2, aCellTblView.roundedView.center.y)];
    }];

    NSIndexPath *aTblViewCurrentIndexPath = objc_getAssociatedObject(aPanView, kIndex);

    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:aCellTblView.roundedView];
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstX = [[sender view] center].x;
        firstY = [[sender view] center].y;
    }
    CGFloat finalX ;

    finalX =  firstX+translatedPoint.x;

    float aMaxPos = (kScreenWidth/2);
    float aMinPos = (kScreenWidth/2)-55;

    if (finalX >= aMaxPos)
        finalX = aMaxPos;
    else if (finalX<=aMinPos)
        finalX = aMinPos;
    else
        finalX = aMinPos;


    translatedPoint = CGPointMake(finalX, firstY);

    [UIView animateWithDuration:0.2 animations:^{
        [[sender view] setCenter:translatedPoint];

    }];


    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {

        translatedPoint = CGPointMake(finalX, firstY);

        [[sender view] setCenter:translatedPoint];

    }
    intLastPanIndex = (int)aTblViewCurrentIndexPath.row;
}

#pragma mark UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {

    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:self.view];
        BOOL shouldBegin = fabs(velocity.x) > fabs(velocity.y);

        return shouldBegin;
    }

    return YES;
}

@end
