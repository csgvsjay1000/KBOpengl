//
//  ViewController.m
//  KBOpengl
//
//  Created by chengshenggen on 5/13/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"

//#import "KBOpenglView.h"
//#import "KBOpenglView2_0.h"
#import "KBOpenglView3_0.h"

@interface ViewController ()

//@property(nonatomic,strong)KBOpenglView *openglView;
@property(nonatomic,strong)CADisplayLink *disLink;

@property(nonatomic,strong)KBOpenglView3_0 *openglView;



@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.openglView];
    
    [self layoutSubPages];
    
    _disLink = [CADisplayLink displayLinkWithTarget:self.openglView selector:@selector(render)];
    _disLink.paused = YES;
    _disLink.frameInterval = 8;
    [_disLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)layoutSubPages{
    [_openglView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
    }];
}

-(void)viewDidAppear:(BOOL)animated{
//    [_openglView render];
    _disLink.paused = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - setters and getters
-(KBOpenglView3_0 *)openglView{
    if (_openglView == nil) {
        _openglView = [[KBOpenglView3_0 alloc] init];
    }
    return _openglView;
}

@end
