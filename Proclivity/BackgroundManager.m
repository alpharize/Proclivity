//
//  NavigationViewController.m
//  BetterRIP
//
//  Created by Terence Tan on 21/12/14.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "BackgroundManager.h"
#import "GPUImage.h"

@interface BackgroundManager ()

@end

@implementation BackgroundManager {
    UIView *preRenderedBackgroundView;
}

@synthesize backgroundIsLightStyle;

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(UIView *)getBackgroundView {
    if (preRenderedBackgroundView) {
        return preRenderedBackgroundView;
    }
    
    // Background image
    UIImageView *backgroundImageView=[[UIImageView alloc]initWithFrame:CGRectMake(-60, -60, [UIScreen mainScreen].bounds.size.width+120, [UIScreen mainScreen].bounds.size.height+120)];
    backgroundImageView.image=[self setUpBackground];
    //backgroundImageView.image=nil;
    [self.view insertSubview:backgroundImageView atIndex:0];
    
    // Parallax effect
    
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-60);
    verticalMotionEffect.maximumRelativeValue = @(60);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-60);
    horizontalMotionEffect.maximumRelativeValue = @(60);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [backgroundImageView addMotionEffect:group];
    
    // Blur the background
    /*UIBlurEffect *blurEffect = backgroundIsLightStyle ? [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight] : [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
     UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
     [blurEffectView setFrame:self.view.bounds];
     [self.view addSubview:blurEffectView];*/
    
    // Blur the background
    UIBlurEffect *blurEffect = backgroundIsLightStyle ? [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight] : [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.bounds];
    //blurEffectView.alpha=backgroundIsLightStyle ? 0.8 : 1.0;
    [self.view addSubview:blurEffectView];
    [self.view sendSubviewToBack:blurEffectView];
    [self.view sendSubviewToBack:backgroundImageView];
    preRenderedBackgroundView=self.view;
    return self.view;
}

-(UIImage *)setUpBackground {
    // testing
    
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Library/Caches/com.apple.springboard.sharedimagecache/Wallpaper/" error:nil];
    NSString *treatedImageName;
    NSLog(@"contents %@", directoryContents);
    for (int i=0; i<[directoryContents count]; i++) {
        NSLog(@"the file there %@", directoryContents[i]);
        if ([directoryContents[i]rangeOfString:@"-treated-image"].location!=NSNotFound) {
            treatedImageName=[NSString stringWithFormat:@"%@/%@", @"/var/mobile/Library/Caches/com.apple.springboard.sharedimagecache/Wallpaper/", directoryContents[i]];
            break;
        }
    }
    UIImage *croppedBackgroundImage;
    
    if (treatedImageName) {
        croppedBackgroundImage=[self decodeCPBitmapAtPath:treatedImageName];
        treatedImageName=nil;
    }
    
    NSLog(@"Our image size: %@",NSStringFromCGSize(croppedBackgroundImage.size));
    NSLog(@"Our display size: %@",NSStringFromCGRect([UIScreen mainScreen].bounds));
    if(croppedBackgroundImage.size.width ==croppedBackgroundImage.size.height){
        NSLog(@"Wallpaper is squaure.");
        
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1602, 2568), YES, 0.0);
        [croppedBackgroundImage drawAtPoint:CGPointMake(-552,-69)]; // Make an offset to draw part of the image
        UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        croppedBackgroundImage=croppedImage;
        croppedImage=nil;

    }
    
    // New code to determine style
    NSLog(@"Begin new code to determine style which seems crazy CPU taxing");
    long useLightStyle=0;
    long useDarkStyle=0;
    
    // Load image
    CGImageRef inImage = croppedBackgroundImage.CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) { return nil; /* error */ }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {

        NSInteger row=1;
        float imageWidth=croppedBackgroundImage.size.width;
        NSInteger xPosition=1;
        NSLog(@"Image frame: x %f y %f",croppedBackgroundImage.size.width,croppedBackgroundImage.size.height);
        for (long i=0; i<croppedBackgroundImage.size.width*croppedBackgroundImage.size.height; i++) {
            if (row==croppedBackgroundImage.size.height) {
                break;
            }
            //offset locates the pixel in the data from x,y.
            //4 for 4 bytes of data per pixel, w is width of one row of data.
            int offset = 4*((w*round(row))+round(xPosition));
            int red = data[offset+1];
            int green = data[offset+2];
            int blue = data[offset+3];
            // calculate brightness using formula brightness  =  sqrt( .241 R2 + .691 G2 + .068 B2 )
            
            float brightness=sqrtf((.241*(red/255.0f)) + (.691*(green/255.0f)) + (.068*(blue/255.0f)) );
            
            if (brightness>.55) {
                useLightStyle++;
            } else {
                useDarkStyle++;
            }
            
            if (xPosition==imageWidth) {
                xPosition=1;
                row++;
            } else {
                xPosition++;
            }
        }
        
        
    }
    
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    
    inImage=nil;
 
    NSLog(@"Dark to light ratio: %f",(float)useDarkStyle/(float)useLightStyle);
    
    if (useDarkStyle>useLightStyle)
    {
        NSLog(@"my color is dark");
        
        backgroundIsLightStyle=NO;
        return croppedBackgroundImage;
        
    }
    else
    {
        NSLog(@"my color is light");
       
        backgroundIsLightStyle=YES;
        return croppedBackgroundImage;
        
    }
    return croppedBackgroundImage;
    
}

- (UIColor*) getPixelColorAtLocation:(CGPoint)point image:(UIImage *)image {
    // Credit to http://www.markj.net/iphone-uiimage-pixel-color/
    
    UIColor* color = nil;
    CGImageRef inImage = image.CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) { return nil; /* error */ }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    
    return color;
}

-(UIImage *)applyGPUImageFilterBlur:(float)blurRadiusInPixels brightness:(float)brightness saturation:(float)saturation contrast:(float)contrast image:(UIImage *)image {
    
    GPUImageBrightnessFilter *brightnessFilter=[[GPUImageBrightnessFilter alloc]init];
    brightnessFilter.brightness=brightness;
    UIImage *imageWithFilters=[brightnessFilter imageByFilteringImage:image];
    
    GPUImageSaturationFilter *saturationFilter=[[GPUImageSaturationFilter alloc]init];
    saturationFilter.saturation=saturation;
    imageWithFilters=[saturationFilter imageByFilteringImage:imageWithFilters];
    
    GPUImageContrastFilter *contrastFilter=[[GPUImageContrastFilter alloc]init];
    contrastFilter.contrast=contrast;
    imageWithFilters=[contrastFilter imageByFilteringImage:imageWithFilters];
    
    GPUImageiOSBlurFilter *blurFilter=[[GPUImageiOSBlurFilter alloc]init];
    blurFilter.blurRadiusInPixels=blurRadiusInPixels;
    imageWithFilters=[blurFilter imageByFilteringImage:imageWithFilters];
    
    return imageWithFilters;
}

-(UIImage *)decodeCPBitmapAtPath:(NSString *)path {
    // Decode cpbitmap file
    CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);
    CFArrayRef cpBitmapImages=CPBitmapCreateImagesFromData((__bridge CFDataRef)([NSData dataWithContentsOfFile:path]), NULL, 1, NULL);
    
    // Convert CPArrayRef to NSArray
    NSArray *convertedArray = (__bridge NSArray*)cpBitmapImages;
    
    // Create an UIImage object
    UIImage *convertedImage=[UIImage imageWithCGImage:(__bridge CGImageRef)((convertedArray[0]))];
    
    convertedArray=nil;
    cpBitmapImages=nil;
    // Return the converted image
    return convertedImage;
}


- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect {
    CGImageRef cropped = CGImageCreateWithImageInRect(imageToCrop.CGImage, rect);
    UIImage *retImage = [UIImage imageWithCGImage: cropped];
    CGImageRelease(cropped);
    return retImage;
}

- (UIColor *)averageColor :(UIImage *)image {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

- (UIColor *)averageColorNew :(UIImage *)image {
    CGSize size = {1, 1};
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(ctx, kCGInterpolationMedium);
    [image drawInRect:(CGRect){.size = size} blendMode:kCGBlendModeCopy alpha:1];
    uint8_t *data = CGBitmapContextGetData(ctx);
    UIColor *color = [UIColor colorWithRed:data[0] / 255.f green:data[1] / 255.f blue:data[2] / 255.f alpha:1];
    UIGraphicsEndImageContext();
    return color;
}


- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
        
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}



@end
