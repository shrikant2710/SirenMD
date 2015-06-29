//
//  TermsVC.m
//  Application
//
//  Created by Shrikant  on 6/13/15.
//  Copyright (c) 2015 AppInventiv. All rights reserved.
//

#import "TermsVC.h"

@interface TermsVC ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)onClickDone:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

@implementation TermsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Terms" ofType:@"pdf"];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [self.webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark On Click Actions
- (IBAction)onClickDone:(id)sender {
    
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame=CGRectMake(0, APPDELEGATE.window.bounds.size.height+10, APPDELEGATE.window.bounds.size.width, APPDELEGATE.window.bounds.size.height);
        
    }completion:^(BOOL finished){
        [self dismissViewControllerAnimated:NO completion:nil];

    }];

}
@end
