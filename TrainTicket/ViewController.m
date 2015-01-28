//
//  ViewController.m
//  TrainTicket
//
//  Created by 李韧 on 15/1/28.
//  Copyright (c) 2015年 百姓网. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_resultLabel setText:@"余票0张"];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(refreshTicket) userInfo:nil repeats:YES];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh:(id)sender {
    
}

- (void)refreshTicket{
    NSURL *url = [NSURL URLWithString:@"https://kyfw.12306.cn/otn/lcxxcx/query?purpose_codes=ADULT&queryDate=2015-02-13&from_station=AOH&to_station=ZEK"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingAllowFragments | NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves) error:&error];
    NSArray *result = [[json objectForKey:@"data"] objectForKey:@"datas"];
    __block NSInteger resultValue = 0;
    
    [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = (NSDictionary *)obj;
        NSString *result = [dict objectForKey:@"ze_num"];
        if (![result isEqualToString:@"无"] && ![result isEqualToString:@"--"]) {
            resultValue += [result integerValue];
        }
    }];
    NSDate *myDate = [NSDate date];
    if (resultValue != 0) {
        [_resultLabel setText:[NSString stringWithFormat:@"现在有%@张余票%@",@(resultValue),myDate]];
    } else {
        
        [_resultLabel setText:[NSString stringWithFormat:@"还是没票%@",myDate]];
        
    }
    if (json == nil) {
        NSLog(@"json parse failed \r\n");
        return;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if([challenge.protectionSpace.host isEqualToString:@"kyfw.12306.cn"]/*check if this is host you trust: */)
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}
@end
