//
//  BillingAddressVC.m
//  SnapShotSale
//
//  Created by Manish on 14/12/15.
//  Copyright © 2015 E2M. All rights reserved.
//

#import "BillingAddressVC.h"
#import "CatListViewController.h"
#import "OrderPlacedVC.h"
#import "MSTextField.h"
#import "Common.h"
#import "TKAlertCenter.h"
#import "AddressListVC.h"
#import "SQLiteManager.h"
#import "PayPalMobile.h"
#import "MBProgressHUD.h"

#define kPayPalEnvironment  PayPalEnvironmentProduction
//#define kPayPalEnvironment  PayPalEnvironmentSandbox

@interface BillingAddressVC ()<CatListViewControllerDeleagate,AddressListVCDeleagate,PayPalPaymentDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet MSTextField *txtFirstName;
@property (strong, nonatomic) IBOutlet MSTextField *txtLastName;
@property (strong, nonatomic) IBOutlet MSTextField *txtAddress;
@property (strong, nonatomic) IBOutlet MSTextField *txtCity;
@property (strong, nonatomic) IBOutlet MSTextField *txtCountry;
@property (strong, nonatomic) IBOutlet MSTextField *txtState;
@property (strong, nonatomic) IBOutlet MSTextField *txtZipCode;
@property (strong, nonatomic) IBOutlet MSTextField *txtPhoneNumber;
@property (strong, nonatomic) IBOutlet MSTextField *txtEmail;

@property (strong, nonatomic) IBOutlet MSTextField *txtSelectAddress;
@property (strong, nonatomic) IBOutlet MSTextField *txtSFirstName;
@property (strong, nonatomic) IBOutlet MSTextField *txtSLastName;
@property (strong, nonatomic) IBOutlet MSTextField *txtSAddress;
@property (strong, nonatomic) IBOutlet MSTextField *txtSCity;
@property (strong, nonatomic) IBOutlet MSTextField *txtSCountry;
@property (strong, nonatomic) IBOutlet MSTextField *txtSState;
@property (strong, nonatomic) IBOutlet MSTextField *txtSZipCode;
@property (strong, nonatomic) IBOutlet MSTextField *txtSPhoneNumber;
@property (strong, nonatomic) IBOutlet MSTextField *txtSEmail;

@property (strong, nonatomic) UITextField *activeTextField;

@property (strong, nonatomic) IBOutlet UIButton *btnCheckBox;
@property (strong, nonatomic) IBOutlet UIButton *btnBSelectAddress;
@property (strong, nonatomic) IBOutlet UIButton *btnBState;
@property (strong, nonatomic) IBOutlet UIButton *btnSSelectAddress;
@property (strong, nonatomic) IBOutlet UIButton *btnSState;

@property (strong, nonatomic) IBOutlet UIImageView *imgArrow1,*imgArrow2,*imgArrow3;

@property (assign, nonatomic) NSInteger intBCountryID;
@property (assign, nonatomic) NSInteger intSCountryID;

@property (assign, nonatomic) BOOL isAdded;
@property (assign, nonatomic) BOOL isBilling;

@property(nonatomic, strong, readwrite) NSString *environment;
@property(nonatomic, strong, readwrite) NSString *resultText;

@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;

@end

@implementation BillingAddressVC

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setPayPalEnvironment:self.environment];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Common Init

- (void)commonInit{
    if (IPHONE5) {
        _scrollView.contentSize = CGSizeMake(0, 550);
    }else if (IPHONE6){
        _scrollView.contentSize = CGSizeMake(0, 650);
    }else if (IPHONE6PLUS){
        _scrollView.contentSize = CGSizeMake(0, 750);
    }else{
        _scrollView.contentSize = CGSizeMake(0, 450);
    }
    _isBilling = YES;
    _btnCheckBox.selected = YES;

    _payPalConfig = [[PayPalConfiguration alloc] init];

    _payPalConfig.acceptCreditCards = YES;

    _payPalConfig.merchantName = @"Awesome Shirts, Inc.";
    _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    _payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
    _payPalConfig.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
    self.environment = kPayPalEnvironment;

    NSLog(@"PayPal iOS SDK version: %@", [PayPalMobile libraryVersion]);
}

#pragma mark - Button Click Event

- (IBAction)btnBackTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnCheckBoxTapped:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        _isBilling = YES;
        _btnSSelectAddress.hidden = _txtSelectAddress.hidden = _txtSFirstName.hidden = _txtSLastName.hidden = _txtSAddress.hidden = _txtSCity.hidden = _txtSCountry.hidden = _txtSState.hidden = _txtSZipCode.hidden = _txtSPhoneNumber.hidden = _txtSEmail.hidden = _imgArrow1.hidden = _imgArrow3.hidden = _btnSState.hidden = YES;
        if (IPHONE5){
            _scrollView.contentSize = CGSizeMake(0, 550);
        }else if (IPHONE6) {
            _scrollView.contentSize = CGSizeMake(0, 650);
        }else if (IPHONE6PLUS){
            _scrollView.contentSize = CGSizeMake(0, 750);
        }else{
            _scrollView.contentSize = CGSizeMake(0, 450);
        }

    }else{
        _isBilling = NO;
        _txtSFirstName.text = _txtSLastName.text = _txtSAddress.text = _txtSCity.text = _txtSState.text = _txtSPhoneNumber.text = _txtSZipCode.text = _txtSEmail.text = @"";
        _btnSSelectAddress.hidden = _txtSelectAddress.hidden = _txtSFirstName.hidden = _txtSLastName.hidden = _txtSAddress.hidden = _txtSCity.hidden = _txtSCountry.hidden = _txtSState.hidden = _txtSPhoneNumber.hidden = _txtSZipCode.hidden = _txtSEmail.hidden = _imgArrow1.hidden = _imgArrow3.hidden = _btnSState.hidden = NO;

        if (IPHONE5){
            _scrollView.contentSize = CGSizeMake(0, 1030);
        }else if (IPHONE6){
            _scrollView.contentSize = CGSizeMake(0, 1250);
        }else if (IPHONE6PLUS){
            _scrollView.contentSize = CGSizeMake(0, 1390);
        }else{
            _scrollView.contentSize = CGSizeMake(0, 850);
        }
    }
}

- (IBAction)btnAddressTapped:(UIButton *)sender{
    [self doneClicked:nil];
    [self deselectAllButtons];
    sender.selected = YES;
    AddressListVC *addressListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressListVC"];
    addressListVC.delegate = self;
    [self.navigationController pushViewController:addressListVC animated:YES];
}

- (IBAction)btnCountryTapped:(UIButton *)sender{
    [self deselectAllButtons];
    sender.selected = YES;
    CatListViewController *catListViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"CatListViewController"];
    catListViewController.strTitle = @"Select Country";
    catListViewController.delegate = self;
    [self.navigationController pushViewController:catListViewController animated:YES];
}

- (IBAction)btnStateTapped:(UIButton *)sender{
    [self deselectAllButtons];
    sender.selected = YES;

    if (_btnBState.selected) {
        if ([_txtCountry.text isEqualToString:@""]) {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBCountry image:kErrorImage];
        }else{
            [self doneClicked:nil];

            CatListViewController *catListViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"CatListViewController"];
            catListViewController.strTitle = @"Select State";
            catListViewController.intCountryID = _intBCountryID;
            catListViewController.delegate = self;
            [self.navigationController pushViewController:catListViewController animated:YES];
        }
    }else if(_btnSState.selected){
        if ([_txtSCountry.text isEqualToString:@""]) {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterSCountry image:kErrorImage];
        }else{
            [self doneClicked:nil];

            CatListViewController *catListViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"CatListViewController"];
            catListViewController.strTitle = @"Select State";
            catListViewController.intCountryID = _intSCountryID;
            catListViewController.delegate = self;
            [self.navigationController pushViewController:catListViewController animated:YES];
        }
    }
}

- (IBAction)btnOrderPlaced:(id)sender{
    [self resignFields];

    if ([self isValidBillingAddress]) {
        if (!_isBilling) {

            if ([self isValidAddressDetails]) {
                [self saveIntoDB];
            }
        }else{
            [self saveIntoDB];
        }
    }
}

- (void)saveIntoDB{
    if (!_isAdded) {
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO address (fname,lname,address,city,country,state,phone,email,is_billing,zipcode) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%d','%@')",_txtFirstName.text,_txtLastName.text,_txtAddress.text,_txtCity.text,_txtCountry.text,_txtState.text,_txtPhoneNumber.text,_txtEmail.text,_isBilling,_txtZipCode.text];
        [[SQLiteManager singleton] executeSql:insertSQL];
    }
    self.resultText = nil;

    PayPalItem *item1 = [PayPalItem itemWithName:_strTitle
                                    withQuantity:1
                                       withPrice:[NSDecimalNumber decimalNumberWithString:_productDetail.strPrice]
                                    withCurrency:@"USD"
                                         withSku:@"abc123"];
    NSArray *items = @[item1];
    NSDecimalNumber *subtotal = [PayPalItem totalPriceForItems:items];

    // Optional: include payment details
    NSDecimalNumber *shipping = [[NSDecimalNumber alloc] initWithString:_productDetail.strShippingPrice];
    NSDecimalNumber *tax = [[NSDecimalNumber alloc] initWithString:@"0.00"];
    PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subtotal
                                                                               withShipping:shipping
                                                                                    withTax:tax];

    NSDecimalNumber *total = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@.00",[[subtotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax]]];

    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = total;
    payment.currencyCode = @"USD";
    payment.shortDescription = _strTitle;
    payment.items = items;
    payment.paymentDetails = paymentDetails;
    if (!payment.processable) {

    }

    self.payPalConfig.acceptCreditCards = self.acceptCreditCards;

    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                configuration:self.payPalConfig
                                                                                                     delegate:self];
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

- (void)setPayPalEnvironment:(NSString *)environment {
    self.environment = environment;
    [PayPalMobile preconnectWithEnvironment:environment];
}

- (BOOL)acceptCreditCards {
    return self.payPalConfig.acceptCreditCards;
}

- (void)setAcceptCreditCards:(BOOL)acceptCreditCards {
    self.payPalConfig.acceptCreditCards = acceptCreditCards;
}

#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    self.resultText = [completedPayment description];

    [self sendCompletedPaymentToServer:completedPayment];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    self.resultText = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {

    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);

    OrderPlacedVC *orderPlacedVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderPlacedVC"];
    [self.navigationController pushViewController:orderPlacedVC animated:YES];

    NSString *strTransactionID = completedPayment.confirmation[@"response"][@"id"];
    [self placeOrder:strTransactionID];
}

- (void)placeOrder:(NSString *)strTransactionID{
    [self resignFields];

    if ([self isValidBillingAddress]) {
        if (!_isBilling) {

            if ([self isValidAddressDetails]) {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                NSString *strTotal = [NSString stringWithFormat:@"%ld",[_productDetail.strPrice integerValue]+[_productDetail.strShippingPrice integerValue]];

                [[WebClient sharedClient] placeOrder:@{@"selleraccountid":[NSNumber numberWithInteger:_productDetail.intSellerID],@"firstname":@"",@"lastname":@"",@"billing_firstname":_txtFirstName.text,@"billing_lastname":_txtLastName.text,@"email":@"",@"telephone":@"",@"billing_address":_txtAddress.text,@"billing_city":_txtCity.text,@"billing_country":_txtCountry.text,@"billing_zone":_txtState.text,@"billing_phone":_txtPhoneNumber.text,@"payment_method":@"PayPal",@"shipping_address":_txtSAddress.text,@"shipping_city":_txtSCity.text,@"shipping_country":_txtSCountry.text,@"shipping_zone":_txtSState.text,@"total":strTotal,@"transactionid":strTransactionID,@"selleritemid":[NSNumber numberWithInteger:_productDetail.intProductID],@"item_name":_productDetail.strName,@"quantity":@1,@"price":_productDetail.strPrice,@"shipping_price":_productDetail.strShippingPrice,@"billing_email":_txtEmail.text,@"shipping_phone":_txtSPhoneNumber.text,@"shipping_email":_txtSEmail.text,@"shipping_firstname":_txtSFirstName.text,@"shipping_lastname":_txtSLastName.text,@"billing_postcode":_txtZipCode.text,@"shipping_postcode":_txtSZipCode.text} success:^(NSDictionary *dictionary) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];

                    if ([dictionary[@"success"] boolValue]) {

                    }else{
                        [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kRightImage];
                    }
                } failure:^(NSError *error) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
                }];
            }
        }else{

            _txtSFirstName.text = _txtFirstName.text;
            _txtSLastName.text = _txtLastName.text;
            _txtSAddress.text = _txtAddress.text;
            _txtSCity.text = _txtCity.text;
            _txtSState.text = _txtState.text;
            _txtSPhoneNumber.text = _txtPhoneNumber.text;
            _txtSEmail.text = _txtEmail.text;
            _txtSZipCode.text = _txtZipCode.text;

            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSString *strTotal = [NSString stringWithFormat:@"%d",[_productDetail.strPrice integerValue]+[_productDetail.strShippingPrice integerValue]];

            [[WebClient sharedClient] placeOrder:@{@"selleraccountid":[NSNumber numberWithInteger:_productDetail.intSellerID],@"firstname":@"",@"lastname":@"",@"billing_firstname":_txtFirstName.text,@"billing_lastname":_txtLastName.text,@"email":@"",@"telephone":@"",@"billing_address":_txtAddress.text,@"billing_city":_txtCity.text,@"billing_country":_txtCountry.text,@"billing_zone":_txtState.text,@"billing_phone":_txtPhoneNumber.text,@"payment_method":@"PayPal",@"shipping_address":_txtSAddress.text,@"shipping_city":_txtSCity.text,@"shipping_country":_txtSCountry.text,@"shipping_zone":_txtSState.text,@"total":strTotal,@"transactionid":strTransactionID,@"selleritemid":[NSNumber numberWithInteger:_productDetail.intProductID],@"item_name":_productDetail.strName,@"quantity":@1,@"price":_productDetail.strPrice,@"shipping_price":_productDetail.strShippingPrice,@"billing_email":_txtEmail.text,@"shipping_phone":_txtSPhoneNumber.text,@"shipping_email":_txtSEmail.text,@"shipping_firstname":_txtSFirstName.text,@"shipping_lastname":_txtSLastName.text,@"billing_postcode":_txtZipCode.text,@"shipping_postcode":_txtSZipCode.text} success:^(NSDictionary *dictionary) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];

                if ([dictionary[@"success"] boolValue]) {

                }else{
                    [[TKAlertCenter defaultCenter] postAlertWithMessage:dictionary[@"message"] image:kRightImage];
                }
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:error.localizedDescription image:kErrorImage];
            }];
        }
    }
}

- (BOOL)isValidBillingAddress{
    if ([_txtFirstName.text isEmptyString]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBFirstname image:kErrorImage];
        return NO;
    }else if ([_txtLastName.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBLastname image:kErrorImage];
        return NO;
    }else if ([_txtAddress.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBAddress image:kErrorImage];
        return NO;
    }else if ([_txtCity.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBCity image:kErrorImage];
        return NO;
    }else if ([_txtState.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBState image:kErrorImage];
        return NO;
    }else if ([_txtZipCode.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBZipCode image:kErrorImage];
        return NO;
    }else if ([_txtPhoneNumber.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBPhoneNo image:kErrorImage];
        return NO;
    }else if ([_txtEmail.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBEmail image:kErrorImage];
        return NO;
    }
    if(![_txtEmail.text isValidEmail]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidEmail image:kErrorImage];
        return NO;
    }

    if (_txtPhoneNumber.text.length < 8 || _txtPhoneNumber.text.length > 15) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidPhoneNo image:kErrorImage];
        return NO;
    }

    NSString *postcodeRegex = @"(^[0-9]{5}(-[0-9]{4})?$)";
    NSPredicate *postcodeValidate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", postcodeRegex];

    if ([_txtZipCode.text isEmptyString]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBZipCode image:kErrorImage];
        return NO;
    }else{
        if ([postcodeValidate evaluateWithObject:_txtZipCode.text] == YES) {
            NSLog (@"Postcode is Valid");
        } else {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgZipCode image:kErrorImage];
            return NO;
        }
    }
    return YES;
}

- (BOOL)isValidAddressDetails{
    if ([_txtFirstName.text isEmptyString]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBFirstname image:kErrorImage];
        return NO;
    }else if ([_txtLastName.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBLastname image:kErrorImage];
        return NO;
    }else if ([_txtAddress.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBAddress image:kErrorImage];
        return NO;
    }else if ([_txtCity.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBCity image:kErrorImage];
        return NO;
    }else if ([_txtState.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBState image:kErrorImage];
        return NO;
    }else if ([_txtZipCode.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBZipCode image:kErrorImage];
        return NO;
    }else if ([_txtPhoneNumber.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBPhoneNo image:kErrorImage];
        return NO;
    }else if ([_txtEmail.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBEmail image:kErrorImage];
        return NO;
    }else if ([_txtSFirstName.text isEmptyString]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterSFirstname image:kErrorImage];
        return NO;
    }else if ([_txtSLastName.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterSLastname image:kErrorImage];
        return NO;
    }else if ([_txtSAddress.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterSAddress image:kErrorImage];
        return NO;
    }else if ([_txtSCity.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterSCity image:kErrorImage];
        return NO;
    }else if ([_txtSState.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterSState image:kErrorImage];
        return NO;
    }else if ([_txtSPhoneNumber.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterSPhoneNo image:kErrorImage];
        return NO;
    }else if ([_txtSZipCode.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterSZipCode image:kErrorImage];
        return NO;
    }else if ([_txtSEmail.text isEmptyString]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterSEmail image:kErrorImage];
        return NO;
    }

    if(![_txtEmail.text isValidEmail]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidEmail image:kErrorImage];
        return NO;
    }

    if(![_txtSEmail.text isValidEmail]){
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidEmail image:kErrorImage];
        return NO;
    }

    if (_txtPhoneNumber.text.length < 8 || _txtPhoneNumber.text.length > 15) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidPhoneNo image:kErrorImage];
        return NO;
    }

    if (_txtSPhoneNumber.text.length < 8 || _txtSPhoneNumber.text.length > 15) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterValidPhoneNo image:kErrorImage];
        return NO;
    }

    NSString *postcodeRegex = @"(^[0-9]{5}(-[0-9]{4})?$)";
    NSPredicate *postcodeValidate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", postcodeRegex];

    if ([_txtZipCode.text isEmptyString]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterBZipCode image:kErrorImage];
        return NO;
    }else{
        if ([postcodeValidate evaluateWithObject:_txtZipCode.text] == YES) {
            NSLog (@"Postcode is Valid");
        } else {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgZipCode image:kErrorImage];
            return NO;
        }
    }

    if ([_txtSZipCode.text isEmptyString]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:msgEnterSZipCode image:kErrorImage];
        return NO;
    }else{
        if ([postcodeValidate evaluateWithObject:_txtZipCode.text] == YES) {
            NSLog (@"Postcode is Valid");
        } else {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:msgZipCode image:kErrorImage];
            return NO;
        }
    }

    return YES;
}

#pragma mark - Deselect All Button

- (void)deselectAllButtons{
    _btnBSelectAddress.selected = _btnBState.selected = _btnSSelectAddress.selected = _btnSState.selected = NO;
}

#pragma mark - UITextField Delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self doneClicked:nil];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    textField.inputAccessoryView = keyboardDoneButtonView;

    if (IPHONE5 || IPHONE4) {
        if (textField == _txtAddress) {
            CGPoint scrollPoint = CGPointMake(0, 50);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }
    }
    if (textField == _txtCity){
        if (IPHONE5 || IPHONE4) {
            CGPoint scrollPoint = CGPointMake(0, 140);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else{
            CGPoint scrollPoint = CGPointMake(0, 120);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }
    }else if (textField == _txtZipCode){
        CGPoint scrollPoint = CGPointMake(0, 230);
        [_scrollView setContentOffset:scrollPoint animated:YES];
    }else if (textField == _txtPhoneNumber){
        CGPoint scrollPoint = CGPointMake(0, 260);
        [_scrollView setContentOffset:scrollPoint animated:YES];
    }else if (textField == _txtEmail){
        CGPoint scrollPoint = CGPointMake(0, 300);
        [_scrollView setContentOffset:scrollPoint animated:YES];
    }else if (textField == _txtSFirstName) {
        if (IPHONE4) {
            CGPoint scrollPoint = CGPointMake(0, 460);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else{
            CGPoint scrollPoint = CGPointMake(0, 510);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }
    }else if (textField == _txtSLastName){
        if (IPHONE4) {
            CGPoint scrollPoint = CGPointMake(0, 480);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else{
            CGPoint scrollPoint = CGPointMake(0, 580);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }
    }else if (textField == _txtSAddress){
        if (IPHONE4) {
            CGPoint scrollPoint = CGPointMake(0, 510);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else{
            CGPoint scrollPoint = CGPointMake(0, 630);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }
    }else if (textField == _txtSCity){
        if (IPHONE4) {
            CGPoint scrollPoint = CGPointMake(0, 580);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else if (IPHONE5) {
            CGPoint scrollPoint = CGPointMake(0, 660);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else if (IPHONE6PLUS){
            CGPoint scrollPoint = CGPointMake(0, 780);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else{
            CGPoint scrollPoint = CGPointMake(0, 750);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }
    }else if (textField == _txtSZipCode){
        if (IPHONE4) {
            CGPoint scrollPoint = CGPointMake(0, 630);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else if (IPHONE5) {
            CGPoint scrollPoint = CGPointMake(0, 730);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else if (IPHONE6PLUS){
            CGPoint scrollPoint = CGPointMake(0, 910);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else{
            CGPoint scrollPoint = CGPointMake(0, 830);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }
    }else if (textField == _txtSPhoneNumber){
        if (IPHONE4) {
            CGPoint scrollPoint = CGPointMake(0, 670);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else if (IPHONE5) {
            CGPoint scrollPoint = CGPointMake(0, 780);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else if (IPHONE6PLUS){
            CGPoint scrollPoint = CGPointMake(0, 970);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else{
            CGPoint scrollPoint = CGPointMake(0, 900);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }
    }else if (textField == _txtSEmail){
        if (IPHONE4) {
            CGPoint scrollPoint = CGPointMake(0, 690);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else if (IPHONE5) {
            CGPoint scrollPoint = CGPointMake(0, 820);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else if (IPHONE6PLUS){
            CGPoint scrollPoint = CGPointMake(0, 980);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else{
            CGPoint scrollPoint = CGPointMake(0, 930);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }
    }
    if (IPHONE6){
        if (_isBilling)
            _scrollView.contentSize = CGSizeMake(0, 860);
        else
            _scrollView.contentSize = CGSizeMake(0, 1500);
    }else if (IPHONE6PLUS){
        if (_isBilling)
            _scrollView.contentSize = CGSizeMake(0, 960);
        else
            _scrollView.contentSize = CGSizeMake(0, 1620);
    }else if (IPHONE5){
        if (_isBilling)
            _scrollView.contentSize = CGSizeMake(0, 750);
        else
            _scrollView.contentSize = CGSizeMake(0, 1270);
    }else{
        if (_isBilling)
            _scrollView.contentSize = CGSizeMake(0, 670);
        else
            _scrollView.contentSize = CGSizeMake(0, 1070);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

}

- (IBAction)doneClicked:(id)sender{
    if (_isBilling) {
        if (IPHONE5){
            _scrollView.contentSize = CGSizeMake(0, 550);
        }else if (IPHONE6) {
            _scrollView.contentSize = CGSizeMake(0, 650);
        }else if (IPHONE6PLUS){
            _scrollView.contentSize = CGSizeMake(0, 750);
        }else{
            _scrollView.contentSize = CGSizeMake(0, 450);
        }
        CGPoint scrollPoint = CGPointMake(0, 0);
        [_scrollView setContentOffset:scrollPoint animated:YES];
    }else{
        if (IPHONE5){
            _scrollView.contentSize = CGSizeMake(0, 1030);
            CGPoint scrollPoint = CGPointMake(0, 550);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else if (IPHONE6){
            _scrollView.contentSize = CGSizeMake(0, 1250);
            CGPoint scrollPoint = CGPointMake(0, 650);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else if (IPHONE6PLUS){
            _scrollView.contentSize = CGSizeMake(0, 1390);
            CGPoint scrollPoint = CGPointMake(0, 760);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }else{
            _scrollView.contentSize = CGSizeMake(0, 850);
            CGPoint scrollPoint = CGPointMake(0, 450);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }
    }

    [self.view endEditing:YES];
    [self resignFields];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _txtFirstName || textField == _txtLastName) {
        if ([textField.text length] > 0)
        {
            textField.text = [textField.text stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[textField.text substringToIndex:1] uppercaseString]];
        }
    }
    if (textField == _txtPhoneNumber || textField == _txtSPhoneNumber) {
        NSInteger length = [self getLength:textField.text];

        if(length == 10)
        {
            if(range.length == 0)
                return NO;
        }

        if(length == 3)
        {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"%@-",num];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 6)
        {
            NSString *num = [self formatNumber:textField.text];

            textField.text = [NSString stringWithFormat:@"%@-%@-",[num  substringToIndex:3],[num substringFromIndex:3]];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@- %@",[num substringToIndex:3],[num substringFromIndex:3]];
        }
    }
    if (textField == _txtZipCode || textField == _txtSZipCode) {

        NSInteger length;

        if (textField == _txtZipCode) {
            length = [_txtZipCode.text length];
        }else if (textField == _txtSZipCode){
            length = [_txtSZipCode.text length];
        }

        if(length == 5)
        {
            if(range.length == 0)
                return NO;
        }

        NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterNoStyle];

        NSString * newString = [NSString stringWithFormat:@"%@%@",textField.text,string];
        NSNumber * number = [nf numberFromString:newString];

        if (number)
            return YES;
        else
            return NO;
    }

    return YES;
}

-(NSString*)formatNumber:(NSString*)mobileNumber {

    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];

    NSInteger length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }

    return mobileNumber;
}

-(NSInteger)getLength:(NSString*)mobileNumber {

    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];

    NSInteger length = [mobileNumber length];

    return length;
}

- (void)resignFields{
    [_txtFirstName resignFirstResponder];
    [_txtLastName resignFirstResponder];
    [_txtAddress resignFirstResponder];
    [_txtCity resignFirstResponder];
    [_txtCountry resignFirstResponder];
    [_txtState resignFirstResponder];
    [_txtPhoneNumber resignFirstResponder];
    [_txtEmail resignFirstResponder];
    [_txtZipCode resignFirstResponder];

    [_txtSFirstName resignFirstResponder];
    [_txtSLastName resignFirstResponder];
    [_txtSAddress resignFirstResponder];
    [_txtSCity resignFirstResponder];
    [_txtSCountry resignFirstResponder];
    [_txtSState resignFirstResponder];
    [_txtSPhoneNumber resignFirstResponder];
    [_txtSEmail resignFirstResponder];
    [_txtSZipCode resignFirstResponder];
}

//#pragma mark - Keyboard Notification Method
//
//- (void)keyboardWasShown:(NSNotification *)notification{
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
//    _scrollView.contentInset = contentInsets;
//    _scrollView.scrollIndicatorInsets = contentInsets;
//
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= keyboardSize.height;
//    if (!CGRectContainsPoint(aRect, _activeTextField.frame.origin) ) {
//        CGPoint scrollPoint = CGPointMake(0.0, _activeTextField.frame.origin.y - (keyboardSize.height-15));
//        [_scrollView setContentOffset:scrollPoint animated:YES];
//    }
//}

- (void) keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Delegate Method

- (void)catListViewController:(CatListViewController *)controller countryList:(Country *)countryList{

}

- (void)catListViewController:(CatListViewController *)controller zoneList:(Zone *)zoneList{
    if (_btnBState.selected) {
        _txtState.text = zoneList.strZoneName;
    }else if (_btnSState.selected){
        _txtSState.text = zoneList.strZoneName;
    }
}

- (void)addressListVC:(AddressListVC *)controller addressList:(Address *)addressList{
    _isAdded = YES;
    if (_btnBSelectAddress.selected) {
        _txtFirstName.text = addressList.strFirstName;
        _txtLastName.text = addressList.strLastName;
        _txtAddress.text = addressList.strAddress;
        _txtCity.text = addressList.strCity;
        _txtCountry.text = addressList.strCountry;
        _txtState.text = addressList.strState;
        _txtPhoneNumber.text = addressList.strPhone;
        _txtEmail.text = addressList.strEmail;
        _txtZipCode.text = addressList.strZipCode;
    }else if (_btnSSelectAddress.selected){
        _txtSFirstName.text = addressList.strFirstName;
        _txtSLastName.text = addressList.strLastName;
        _txtSAddress.text = addressList.strAddress;
        _txtSCity.text = addressList.strCity;
        _txtSCountry.text = addressList.strCountry;
        _txtSState.text = addressList.strState;
        _txtSPhoneNumber.text = addressList.strPhone;
        _txtSEmail.text = addressList.strEmail;
        _txtSZipCode.text = addressList.strZipCode;
    }
}

@end
