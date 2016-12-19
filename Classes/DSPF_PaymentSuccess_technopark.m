//
//  DSPF_PaymentSuccess_technopark.m
//  dphHermes
//
//  Created by Denis Kurochkin on 30.12.15.
//
//

#import "DSPF_PaymentSuccess_technopark.h"

@interface DSPF_PaymentSuccess_technopark ()

@end

@implementation DSPF_PaymentSuccess_technopark

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) finishButtonAction
{
    
    NSMutableArray *newVCs = [[[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers] autorelease];
    [newVCs removeLastObject];
    [newVCs removeLastObject];
    
    [self.navigationController setViewControllers:newVCs animated:YES];
    [_tableDataSource shouldLeaveTourLocation];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_finishButton release];
    [super dealloc];
}
@end
