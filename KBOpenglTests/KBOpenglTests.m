//
//  KBOpenglTests.m
//  KBOpenglTests
//
//  Created by chengshenggen on 5/13/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface KBOpenglTests : XCTestCase

@end

@implementation KBOpenglTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"wall" ofType:@"jpg"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    
    CGImageRef cgimg = image.CGImage;
    
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    size_t pixelsWide = CGImageGetWidth(cgimg);
    size_t pixelsHigh = CGImageGetHeight(cgimg);
    
    bitmapBytesPerRow = pixelsWide*4;
    bitmapByteCount = bitmapBytesPerRow*pixelsHigh;
    
    size_t bitmapBytesPerRow_t =  CGImageGetBytesPerRow(cgimg);
    
    size_t bitsPerPixel_t = CGImageGetBitsPerPixel(cgimg);
    size_t bitsPerComponent_t = CGImageGetBitsPerComponent(cgimg);
    
    NSLog(@"\n\n==================================\n\n");
    
    NSLog(@"bitsPerPixel_t %ld",bitsPerPixel_t);
    NSLog(@"bitsPerComponent_t %ld",bitsPerComponent_t);
    
    NSLog(@"pixelsWide %ld",pixelsWide);
    NSLog(@"pixelsHigh %ld",pixelsHigh);

    NSLog(@"bitmapByteCount %d",bitmapByteCount);

    
    NSLog(@"bitmapBytesPerRow %d",bitmapBytesPerRow);

    NSLog(@"bitmapBytesPerRow_t %ld",bitmapBytesPerRow_t);
    
    NSLog(@"\n\n==================================\n\n");

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
