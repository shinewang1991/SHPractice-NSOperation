//
//  ViewController.m
//  SHPractice-NSOperation
//
//  Created by shine on 21/03/2018.
//  Copyright © 2018 shine. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self demo4];
}


//NSOperation是个抽象类，不能直接使用。应该使用它的子类NSInvocationOperation 和 NSBlockOperation

//Operation可以直接使用，不关联队列。但一般很少这么用
- (void)demo1{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:@"invacation"];
    [operation start];
}

//NSInvocationOperation
- (void)demo2{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:@"invacation"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
}


//NSBlockOperation
- (void)demo3{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@",[NSThread currentThread]);
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
}


//NSOperationQueue 会开启多个线程，不会顺序执行.
//所以NSOperationQueue 是GCD异步+并发队列 的封装。
- (void)demo4{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        for(int i = 0; i < 10; i++){
            NSLog(@"第1个任务%@",[NSThread currentThread]);
        }
    }];
    
    [queue addOperationWithBlock:^{
        NSLog(@"第2个任务%@",[NSThread currentThread]);
    }];
    
    [queue addOperationWithBlock:^{
        NSLog(@"第3个任务%@",[NSThread currentThread]);
    }];
}

- (void)downloadImage:(id)obj{
    NSLog(@"%@",[NSThread currentThread]);
}

@end
