//
//  ViewController.m
//  SHPractice-NSOperation
//
//  Created by shine on 21/03/2018.
//  Copyright © 2018 shine. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self demo5];
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


//NSOperationQueue的挂起和取消
- (void)demo5{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;   //最大并发数，也就是最多线程数.
    NSMutableArray *tasks = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"第%d个任务开始了",i);
            [NSThread sleepForTimeInterval:1];
            NSLog(@"第%d个任务---%@",i,[NSThread currentThread]);
        }];
        [tasks addObject:operation];
    }
    [queue addOperations:tasks waitUntilFinished:NO];
    self.queue = queue;
}


/** 已经拿到线程中的任务是暂停不了的
    suspended:决定是否挂起状态
    operationCount:队列中的操作数
 **/
- (IBAction)pauseOrStart:(UIButton *)sender{
    if(self.queue.isSuspended){   //判断是否已经挂起
        self.queue.suspended = NO;
        NSLog(@"继续");
        [sender setTitle:@"start" forState:UIControlStateNormal];
    }
    else{
        self.queue.suspended = YES;
        NSLog(@"暂停---%lu",(unsigned long)self.queue.operationCount);
        [sender setTitle:@"pause" forState:UIControlStateNormal];
    }
}


//已经拿进线程中的任务也是取消不了的。只能操作还在队列中的任务.
- (IBAction)cancel:(UIButton *)sender{
    NSLog(@"取消队列中所有任务");
    [self.queue cancelAllOperations];
}


//队列的依赖Dependency. 队列中的任务会等待依赖的任务执行结束后才执行之后的任务.
- (void)demo6{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"第1个任务执行结束 ---%@",[NSThread currentThread]);
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"第2个任务执行结束 ---%@",[NSThread currentThread]);
    }];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"第3个任务执行结束 ---%@",[NSThread currentThread]);
    }];
    
    [op2 addDependency:op1];
    [op3 addDependency:op2];
    
    
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
}

@end
