//
//  ViewController.m
//  KBOpengl
//
//  Created by chengshenggen on 5/13/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "ViewController.h"
#import "KBOpenglView.h"
#import "Masonry.h"

@interface ViewController ()

@property(nonatomic,strong)KBOpenglView *openglView;

@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.openglView];
    
    [self layoutSubPages];
}

-(void)layoutSubPages{
    [_openglView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.bottom.equalTo(self.view).offset(-10);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);

    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [_openglView render];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - setters and getters
-(KBOpenglView *)openglView{
    if (_openglView == nil) {
        _openglView = [[KBOpenglView alloc] init];
    }
    return _openglView;
}

@end
