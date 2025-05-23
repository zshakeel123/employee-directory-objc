//
//  ViewController.m
//  EmployeeDirectoryApp
//
//  Created by Zeeshan Shakeel on 21/05/2025.
//

#import "ViewController.h"
#import <EmployeeNetworking/EmployeeService.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    EmployeeService *service = [[EmployeeService alloc] initWithBaseURLString:@"https://s3.amazonaws.com/sq-mobile-interview/employees.json" andSession: [NSURLSession sharedSession]];
    
    [service fetchEmployeesWithCompletion:^(EmployeeListResponse * _Nullable employeeList, NSError * _Nullable error) {
        NSLog(@"Employees count %lu", employeeList.employees.count);
    }];
}


@end
