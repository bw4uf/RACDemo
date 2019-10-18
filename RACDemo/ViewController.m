//
//  ViewController.m
//  RACDemo
//
//  Created by 启迪 on 2019/10/11.
//  Copyright © 2019 norman. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "RACReturnSignal.h"
//#import "RACModel.h"

@interface ViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (strong, nonatomic) RACSignal *flattenMapSignal;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // block中避免循环引用
//    @weakify(self)
//    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
//        @strongify(self)
//        NSLog(@"点击了按钮");
//        [self.textfield resignFirstResponder];
//    }];
//
//    [self.label setUserInteractionEnabled:YES];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
//    [self.label addGestureRecognizer:tap];
//    [tap.rac_gestureSignal subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
//        NSLog(@"点击了label");
//    }];
//
//    [self RAC_KVO];
//    self.label.text = @"新label";
//
//    [self RACTextFiledDelegate];
//    [self RACNotification];
//    [self RACTimer];
//    [self RACSequence];
//    [self RACBase];
//    [self RACFlattenMap];
//    [self RACMap];
//
//    // 信号过滤包含以下几种方法：filter、ignore、ignoreValue、distinctUntilChanged
//    [self RACFilter];
//    [self RACIgnoreAndIgnoreValues];
//    [self RACDistinctUntilChanged];
    
//    [self noMoreHard];
//    [self noMoreHard1];
    
//    [self multiSubscribe];
//    [self multiSubscribe1];
}

- (void)RAC_KVO
{
    [RACObserve(self.label, text) subscribeNext:^(id  _Nullable x) {
        NSLog(@"text变更为：%@", x);
    }];
}

- (void)RACTextFiledDelegate
{
    [[self rac_signalForSelector:@selector(textFieldDidBeginEditing:) fromProtocol:@protocol(UITextFieldDelegate)] subscribeNext:^(RACTuple * _Nullable x) {
        NSLog(@"%@", x);
    }];
    self.textfield.delegate = self;
}

- (void)RACNotification
{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidHideNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"%@", x);
    }];
}

- (void)RACTimer
{
    [[RACSignal interval:10.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
        NSLog(@"%@", x);
    }];
    
}

- (void)RACSequence
{
    // 遍历数组
    NSArray *racArray = @[@"rac1", @"rac2", @"rac3"];
    [racArray.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    // 遍历字典
    NSDictionary *dict = @{@"name" : @"dragon", @"type" : @"fire", @"age" : @"23"};
    [dict.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        RACTwoTuple *tuple = (RACTwoTuple *)x;
        NSLog(@"key == %@, value == %@", tuple[0], tuple[1]);
    }];
}

- (void)RACBase
{
    // RAC基本使用方法与流程
    // 创建signal信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        // subscriber并不是一个对象
        // 3.发送信号
        [subscriber sendNext:@"sendOneMessage"];
        // 发送error信号
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:1001 userInfo:@{@"errorMsg" : @"this is a error message"}];
        [subscriber sendError:error];
        
        // 4.销毁信号
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"signal已销毁");
        }];
    }];
    
    // 2.1 订阅信号
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    // 2.2 订阅error信号
    [signal subscribeError:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    }];
}

// map映射
- (void)RACFlattenMap
{
    [[self.textfield.rac_textSignal flattenMap:^__kindof RACSignal * _Nullable(NSString * _Nullable value) {
        return [RACReturnSignal return:[NSString stringWithFormat:@"自定义返回FlattenMap信号: %@", value]];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
}

// map映射
- (void)RACMap
{
    [[self.textfield.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return [NSString stringWithFormat:@"自定义返回MAP信号: %@", value];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
}

// filter
- (void)RACFilter
{
    @weakify(self);
    [[self.textfield.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        // 过滤判断条件
        @strongify(self)
        if (self.textfield.text.length >= 6) {
            self.textfield.text = [self.textfield.text substringToIndex:6];
            self.label.text = @"输入到6位了";
            self.label.textColor = [UIColor redColor];
        }
        return value.length <= 6;
        // 当block中的value为NO时，将映射成一个空信号
    }] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"filter过滤后的订阅内容: %@", x);
    }];
}

// ignore和ignoreValue是对filter的封装
- (void)RACIgnoreAndIgnoreValues
{
    [[self.textfield.rac_textSignal ignore:@"1"] subscribeNext:^(NSString * _Nullable x) {
        // 将textfield的textSignal中字符串为指定条件的信号过滤掉
    }];
    
    [[self.textfield.rac_textSignal ignoreValues] subscribeNext:^(NSString * _Nullable x) {
        // 将textfield所有的textSignal全部过滤掉
    }];
}

// 判断当前信号的值跟上一次的值是否相同，如果相同则不接收订阅信号
- (void)RACDistinctUntilChanged
{
    RACSubject *subject = [RACSubject subject];
    [[subject distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    [subject sendNext:@1111];
    [subject sendNext:@2222];
    [subject sendNext:@2222];
}

// https://upload-images.jianshu.io/upload_images/1243805-b92daa17b8a044a6.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200

// 销毁信号使用RACDisposable，RACCompoundDisposable、RACSerialDisposable、RACKVOTrampoline、RACScopedDisposable这几个类继承自RACDisposable父类

// 不再难blog
- (void)noMoreHard
{
    // 创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        // 发送信号
        [subscriber sendNext:@"发送的数据"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    // 接收信号
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"这里是接收到的数据: %@", x);
    }];
    
    // 合并写法
    [[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        // 发送信号
        [subscriber sendNext:@"发送的数据1"];
        [subscriber sendCompleted];
        return nil;
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"1%@", x);
    }];
    
    // 冷热信号
    // 创建热信号
    RACSubject *subject = [RACSubject subject];
    [subject sendNext:@1]; // 立即发送1
    
    [[RACScheduler mainThreadScheduler] afterDelay:0.5 schedule:^{
        [subject sendNext:@2]; // 0.5S后发送2
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        [subject sendNext:@3]; // 2S后发送3
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:0.1 schedule:^{
        [subject subscribeNext:^(id  _Nullable x) {
            NSLog(@"subject1接收到了%@", x); // 0.1S后subject1订阅了
        }];
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
        [subject subscribeNext:^(id  _Nullable x) {
            NSLog(@"subject2接收到了%@", x); // 1S后subject2订阅了
        }];
    }];
    
}

- (void)noMoreHard1
{
    // 创建冷信号
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@1];
        [[RACScheduler mainThreadScheduler] afterDelay:0.5 schedule:^{
            [subscriber sendNext:@2];
        }];
        [[RACScheduler mainThreadScheduler] afterDelay:2.0 schedule:^{
            [subscriber sendNext:@3];
        }];
        return nil;
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:0 schedule:^{
        [signal1 subscribeNext:^(id  _Nullable x) {
            NSLog(@"signal1接收到了%@", x);
        }];
    }];
    [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
        [signal1 subscribeNext:^(id  _Nullable x) {
            NSLog(@"signal2接收到了%@", x);
        }];
    }];
}

- (void)multiSubscribe
{
    RACModel *model = [RACModel new];
    // 冷信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        // 网络请求产生的model
        [subscriber sendNext:model];
        return nil;
    }];
    
    RACSignal *name = [signal flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return [RACSignal return:model.name];
    }];
    RACSignal *age = [signal flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return [RACSignal return:model.age];
    }];
    
    RAC(self.textfield, text) = [[name catchTo:[RACSignal return:@"error"]] startWith:@"name"];
    RAC(self.label, text) = [[age catchTo:[RACSignal return:@"error"]] startWith:@"age"];
}

- (void)multiSubscribe1
{
    RACModel *model = [RACModel new];
    // 热信号
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:model];
        return nil;
    }] replayLazily];
    
    RACSignal *name = [signal flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return [RACSignal return:model.name];
    }];
    RACSignal *age = [signal flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return [RACSignal return:model.age];
    }];
    
    RAC(self.textfield, text) = [[name catchTo:[RACSignal return:@"error"]] startWith:@"name"];
    RAC(self.label, text) = [[age catchTo:[RACSignal return:@"error"]] startWith:@"age"];
}

- (void)RACMemoryLeak
{
    RACModel *model = [RACModel new];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }];
    @weakify(self)
    // 这里需要weakself以避免内存泄漏
    self.flattenMapSignal = [signal flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        @strongify(self)
        // 因为RACObserve这个宏里面引用了self来observe model的name属性
        return RACObserve(model, name);
    }];
    [self.flattenMapSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"receive - %@", x);
    }];
}

@end

@implementation RACModel

@end
