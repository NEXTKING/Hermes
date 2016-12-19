//
//  PersonalDataViewController.m
//  Technopark
//
//  Created by Denis Kurochkin on 07/10/15.
//  Copyright © 2015 Denis Kurochkin. All rights reserved.
//

#import "DSPF_PersonalData_technopark.h"
#import "User.h"

@interface DSPF_PersonalData_technopark () <UITextFieldDelegate>

@end

@implementation DSPF_PersonalData_technopark

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Данные";
    // Do any additional setup after loading the view from its nib.
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    Tour *tour = [Tour tourWithTourID:[NSUserDefaults currentTourId] inCtx:ctx()];
    
    NSString *jsonString = tour.description_text;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    id obj = [jsonObject objectForKey:@"speedometer"];
    if (obj && [obj isKindOfClass:[NSString class]])
        _speedometerField.text = obj;
    obj = [jsonObject objectForKey:@"fuel"];
    if (obj && [obj isKindOfClass:[NSString class]])
        _departureFuelField.text = obj;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void) dealloc
{
    [_speedometerField release];
    [_departureFuelField release];
    [super dealloc];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
