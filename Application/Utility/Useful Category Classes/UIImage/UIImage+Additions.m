//
//  UIImage+Additions.m
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//
// Copyright (c) 2013 Joan Martin, vilanovi@gmail.com.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

#import "UIImage+Additions.h"

@interface NSString (MD5Hashing)

- (NSString *)md5;

@end

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5Hashing)

- (NSString *)md5 {
	const char *cStr = [self UTF8String];
	unsigned char result[16];
    
	CC_MD5(cStr, (u_int32_t)strlen(cStr), result);
    
	return [NSString stringWithFormat:
	        @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
	        result[0], result[1], result[2], result[3],
	        result[4], result[5], result[6], result[7],
	        result[8], result[9], result[10], result[11],
	        result[12], result[13], result[14], result[15]
            ];
}

@end

const UICornerInset UICornerInsetZero = { 0.0f, 0.0f, 0.0f, 0.0f };

NSString *NSStringFromUICornerInset(UICornerInset cornerInset) {
	return [NSString stringWithFormat:@"UICornerInset <topLeft:%f> <topRight:%f> <bottomLeft:%f> <bottomRight:%f>", cornerInset.topLeft, cornerInset.topRight, cornerInset.bottomLeft, cornerInset.bottomRight];
}

static NSCache *_imageCache = nil;

static NSString *kUIImageName = @"kUIImageName";
static NSString *kUIImageResizableImage = @"kUIImageResizableImage";
static NSString *kUIImageColors = @"kUIImageColors";
static NSString *kUIImageTintColor = @"kUIImageTintColor";
static NSString *kUIImageTintStyle = @"kUIImageTintStyle";
static NSString *kUIImageCornerInset = @"kUIImageCornerInset";
static NSString *kUIImageGradientDirection = @"kUIImageGradientDirection";
static NSString *kUIImageSize = @"kUIImageSize";

@implementation UIImage (Additions)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
	return [self imageWithColor:color size:size cornerInset:UICornerInsetZero];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius {
	return [self imageWithColor:color size:size cornerInset:UICornerInsetMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size cornerInset:(UICornerInset)cornerInset {
	return [self _imageWithColor:color size:size cornerInset:cornerInset saveInCache:YES];
}

+ (UIImage *)resizableImageWithColor:(UIColor *)color {
	return [self resizableImageWithColor:color cornerInset:UICornerInsetZero];
}

+ (UIImage *)resizableImageWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius {
	return [self resizableImageWithColor:color cornerInset:UICornerInsetMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)];
}

+ (UIImage *)resizableImageWithColor:(UIColor *)color cornerInset:(UICornerInset)cornerInset {
	if (!color)
		return nil;
    
	NSDictionary *descriptors =  @{ kUIImageColors : @[color],
		                            kUIImageResizableImage : @YES,
		                            kUIImageCornerInset : [NSValue valueWithUICornerInset:cornerInset] };
    
	UIImage *image = [self _cachedImageWithDescriptors:descriptors];
    
	if (image)
		return image;
    
	CGSize size = CGSizeMake(MAX(cornerInset.topLeft, cornerInset.bottomLeft) + MAX(cornerInset.topRight, cornerInset.bottomRight) + 1,
	                         MAX(cornerInset.topLeft, cornerInset.topRight) + MAX(cornerInset.bottomLeft, cornerInset.bottomRight) + 1);
    
	UIEdgeInsets capInsets = UIEdgeInsetsMake(MAX(cornerInset.topLeft, cornerInset.topRight),
	                                          MAX(cornerInset.topLeft, cornerInset.bottomLeft),
	                                          MAX(cornerInset.bottomLeft, cornerInset.bottomRight),
	                                          MAX(cornerInset.topRight, cornerInset.bottomRight));
    
	image = [[self imageWithColor:color size:size cornerInset:cornerInset] resizableImageWithCapInsets:capInsets];
    
	[self _cacheImage:image withDescriptors:descriptors];
    
	return image;
}

+ (UIImage *)blackColorImage {
	return [self resizableImageWithColor:[UIColor blackColor]];
}

+ (UIImage *)darkGrayColorImage {
	return [self resizableImageWithColor:[UIColor darkGrayColor]];
}

+ (UIImage *)lightGrayColorImage {
	return [self resizableImageWithColor:[UIColor lightGrayColor]];
}

+ (UIImage *)whiteColorImage {
	return [self resizableImageWithColor:[UIColor whiteColor]];
}

+ (UIImage *)grayColorImage {
	return [self resizableImageWithColor:[UIColor grayColor]];
}

+ (UIImage *)redColorImage {
	return [self resizableImageWithColor:[UIColor redColor]];
}

+ (UIImage *)greenColorImage {
	return [self resizableImageWithColor:[UIColor greenColor]];
}

+ (UIImage *)blueColorImage {
	return [self resizableImageWithColor:[UIColor blueColor]];
}

+ (UIImage *)cyanColorImage {
	return [self resizableImageWithColor:[UIColor cyanColor]];
}

+ (UIImage *)yellowColorImage {
	return [self resizableImageWithColor:[UIColor yellowColor]];
}

+ (UIImage *)magentaColorImage {
	return [self resizableImageWithColor:[UIColor magentaColor]];
}

+ (UIImage *)orangeColorImage {
	return [self resizableImageWithColor:[UIColor orangeColor]];
}

+ (UIImage *)purpleColorImage {
	return [self resizableImageWithColor:[UIColor purpleColor]];
}

+ (UIImage *)brownColorImage {
	return [self resizableImageWithColor:[UIColor brownColor]];
}

+ (UIImage *)clearColorImage {
	return [self resizableImageWithColor:[UIColor clearColor]];
}

+ (UIImage *)imageNamed:(NSString *)name tintColor:(UIColor *)color style:(UIImageTintedStyle)tintStyle {
	if (!name)
		return nil;
    
	UIImage *image = [UIImage imageNamed:name];
    
	if (!image)
		return nil;
    
	if (!color)
		return image;
    
	NSDictionary *descriptors =  @{ kUIImageName : name,
		                            kUIImageTintColor : color,
		                            kUIImageTintStyle : @(tintStyle) };
    
	UIImage *tintedImage = [self _cachedImageWithDescriptors:descriptors];
    
	if (!tintedImage) {
		tintedImage = [image tintedImageWithColor:color style:tintStyle];
		[self _cacheImage:tintedImage withDescriptors:descriptors];
	}
    
	return tintedImage;
}

- (UIImage *)tintedImageWithColor:(UIColor *)color style:(UIImageTintedStyle)tintStyle {
	if (!color)
		return self;
    
	CGFloat scale = self.scale;
	CGSize size = CGSizeMake(scale * self.size.width, scale * self.size.height);
    
	UIGraphicsBeginImageContext(size);
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGContextTranslateCTM(context, 0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    
	CGRect rect = CGRectMake(0, 0, size.width, size.height);
	// ---
    
	if (tintStyle == UIImageTintedStyleOverAlpha) {
		[color setFill];
		CGContextFillRect(context, rect);
	}
    
	// draw alpha-mask
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGContextDrawImage(context, rect, self.CGImage);
    
	if (tintStyle == UIImageTintedStyleKeepingAlpha) {
		CGContextSetBlendMode(context, kCGBlendModeSourceIn);
		[color setFill];
		CGContextFillRect(context, rect);
	}
    
	// ---
	CGImageRef bitmapContext = CGBitmapContextCreateImage(context);
    
	UIImage *coloredImage = [UIImage imageWithCGImage:bitmapContext scale:scale orientation:UIImageOrientationUp];
    
	CGImageRelease(bitmapContext);
    
	UIGraphicsEndImageContext();
    
	return coloredImage;
}

- (UIImage *)imageWithRoundedBounds {
	CGSize size = self.size;
	CGFloat radius = MIN(size.width, size.height) / 2.0;
	return [self imageWithCornerRadius:radius];
}

- (UIImage *)imageWithCornerRadius:(CGFloat)cornerRadius {
	return [self imageWithCornerInset:UICornerInsetMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)];
}

- (UIImage *)imageWithCornerInset:(UICornerInset)cornerInset {
	if (![self isValidCornerInset:cornerInset])
		return nil;
    
	CGFloat scale = self.scale;
    
	CGRect rect = CGRectMake(0.0f, 0.0f, scale * self.size.width, scale * self.size.height);
    
	cornerInset.topRight *= scale;
	cornerInset.topLeft *= scale;
	cornerInset.bottomLeft *= scale;
	cornerInset.bottomRight *= scale;
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease(colorSpace);
    
	if (context == NULL)
		return nil;
    
	CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, cornerInset.bottomLeft);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, cornerInset.bottomRight);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, cornerInset.topRight);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, cornerInset.topLeft);
	CGContextClosePath(context);
	CGContextClip(context);
    
	CGContextDrawImage(context, rect, self.CGImage);
    
	CGImageRef bitmapImageRef = CGBitmapContextCreateImage(context);
    
	CGContextRelease(context);
    
	UIImage *newImage = [UIImage imageWithCGImage:bitmapImageRef scale:scale orientation:UIImageOrientationUp];
    
	CGImageRelease(bitmapImageRef);
    
	return newImage;
}

- (BOOL)isValidCornerInset:(UICornerInset)cornerInset {
	CGSize size = self.size;
    
	BOOL isValid = YES;
    
	if (cornerInset.topLeft + cornerInset.topRight > size.width)
		isValid = NO;
    
	else if (cornerInset.topRight + cornerInset.bottomRight > size.height)
		isValid = NO;
    
	else if (cornerInset.bottomRight + cornerInset.bottomLeft > size.width)
		isValid = NO;
    
	else if (cornerInset.bottomLeft + cornerInset.topLeft > size.height)
		isValid = NO;
    
	return isValid;
}

- (UIImage *)imageAddingImage:(UIImage *)image offset:(CGPoint)offset {
	CGSize size = self.size;
	CGFloat scale = self.scale;
    
	size.width *= scale;
	size.height *= scale;
    
	UIGraphicsBeginImageContext(size);
    
	[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
	[image drawInRect:CGRectMake(scale * offset.x, scale * offset.y, image.size.width * scale, image.size.height * scale)];
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGImageRef bitmapContext = CGBitmapContextCreateImage(context);
	UIImage *destImage = [UIImage imageWithCGImage:bitmapContext scale:image.scale orientation:UIImageOrientationUp];
	CGContextRelease(context);
	CGImageRelease(bitmapContext);
    
	return destImage;
}

#pragma mark Private Methods

+ (NSCache *)_cache {
	if (!_imageCache)
		_imageCache = [[NSCache alloc] init];
    
	return _imageCache;
}

+ (UIImage *)_cachedImageWithDescriptors:(NSDictionary *)descriptors {
	return [[self _cache] objectForKey:[self _keyForImageWithDescriptors:descriptors]];
}

+ (void)_cacheImage:(UIImage *)image withDescriptors:(NSDictionary *)descriptors {
	NSString *key = [self _keyForImageWithDescriptors:descriptors];
	[[self _cache] setObject:image forKey:key];
}

+ (NSString *)_keyForImageWithDescriptors:(NSDictionary *)descriptors {
	NSMutableString *string = [NSMutableString string];
    
	NSString *imageName = [descriptors valueForKey:kUIImageName];
	[string appendFormat:@"<%@:%@>", kUIImageName, (imageName == nil) ? @"":imageName];
	[string appendFormat:@"<%@:%@>", kUIImageSize, NSStringFromCGSize([[descriptors valueForKey:kUIImageSize] CGSizeValue])];
	[string appendFormat:@"<%@:%d>", kUIImageResizableImage, [[descriptors valueForKey:kUIImageResizableImage] boolValue]];
    
	[string appendFormat:@"<%@:", kUIImageColors];
	NSArray *colors = [descriptors valueForKey:kUIImageColors];
	for (UIColor *color in colors)
		[string appendFormat:@"%d", (int)color.hash];
	[string appendFormat:@">"];
    
	[string appendFormat:@"<%@:%d>", kUIImageTintColor, (int)[[descriptors valueForKey:kUIImageTintColor] hash]];
	[string appendFormat:@"<%@:%d>", kUIImageTintStyle, [[descriptors valueForKey:kUIImageTintStyle] intValue]];
	[string appendFormat:@"<%@:%@>", kUIImageCornerInset, NSStringFromUICornerInset([[descriptors valueForKey:kUIImageCornerInset] UICornerInsetValue])];
	[string appendFormat:@"<%@:%d>", kUIImageGradientDirection, [[descriptors valueForKey:kUIImageGradientDirection] intValue]];
    
	return [string md5];
}

+ (UIImage *)_imageWithColor:(UIColor *)color size:(CGSize)size cornerInset:(UICornerInset)cornerInset saveInCache:(BOOL)save {
	NSDictionary *descriptors =  @{ kUIImageColors : @[color],
		                            kUIImageSize : [NSValue valueWithCGSize:size],
		                            kUIImageCornerInset : [NSValue valueWithUICornerInset:cornerInset] };
    
	UIImage *image = [self _cachedImageWithDescriptors:descriptors];
    
	if (image)
		return image;
    
	CGFloat scale = [[UIScreen mainScreen] scale];
	CGRect rect = CGRectMake(0.0f, 0.0f, scale * size.width, scale * size.height);
    
	cornerInset.topRight *= scale;
	cornerInset.topLeft *= scale;
	cornerInset.bottomLeft *= scale;
	cornerInset.bottomRight *= scale;
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
	CGColorSpaceRelease(colorSpace);
    
	if (context == NULL)
		return nil;
    
	CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    
	CGContextBeginPath(context);
	CGContextSetGrayFillColor(context, 1.0, 0.0); // <-- Alpha color in background
	CGContextAddRect(context, rect);
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathFill);
    
	CGContextSetFillColorWithColor(context, [color CGColor]); // <-- Color to fill
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, cornerInset.bottomLeft);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, cornerInset.bottomRight);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, cornerInset.topRight);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, cornerInset.topLeft);
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathFill);
    
	CGImageRef bitmapContext = CGBitmapContextCreateImage(context);
    
	CGContextRelease(context);
    
	UIImage *theImage = [UIImage imageWithCGImage:bitmapContext scale:scale orientation:UIImageOrientationUp];
    
	CGImageRelease(bitmapContext);
    
	if (save)
		[self _cacheImage:theImage withDescriptors:descriptors];
    
	return theImage;
}

+ (UIImage *)imageWithGradient:(NSArray *)colors size:(CGSize)size direction:(UIImageGradientDirection)direction {
	NSDictionary *descriptors = @{ kUIImageColors: colors,
		                           kUIImageSize: [NSValue valueWithCGSize:size],
		                           kUIImageGradientDirection: @(direction) };
    
	UIImage *image = [self _cachedImageWithDescriptors:descriptors];
	if (image)
		return image;
    
	CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	// Create Gradient
	NSMutableArray *cgColors = [NSMutableArray arrayWithCapacity:colors.count];
	for (UIColor *color in colors)
		[cgColors addObject:(id)color.CGColor];
    
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)cgColors, NULL);
    
	// Apply gradient
	CGPoint startPoint = CGPointZero;
	CGPoint endPoint = CGPointZero;
    
	if (direction == UIImageGradientDirectionVertical)
		endPoint = CGPointMake(0, rect.size.height);
    
	else if (direction == UIImageGradientDirectionHorizontal)
		endPoint = CGPointMake(rect.size.width, 0);
    
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	image = UIGraphicsGetImageFromCurrentImageContext();
    
	// Clean memory & End context
	UIGraphicsEndImageContext();
	CGGradientRelease(gradient);
	CGColorSpaceRelease(space);
    
	[self _cacheImage:image withDescriptors:descriptors];
    
	return image;
}

+ (UIImage *)resizableImageWithGradient:(NSArray *)colors size:(CGSize)size direction:(UIImageGradientDirection)direction {
	if ((size.width == 0.0f && direction == UIImageGradientDirectionHorizontal) ||
	    (size.height == 0.0f && direction == UIImageGradientDirectionVertical) ||
	    (size.height == 0.0f && size.width == 0.0f))
		return nil;
    
	NSDictionary *descriptors = @{ kUIImageColors: colors,
		                           kUIImageSize: [NSValue valueWithCGSize:size],
		                           kUIImageGradientDirection: @(direction),
		                           kUIImageResizableImage: @YES };
    
	UIImage *image = [self _cachedImageWithDescriptors:descriptors];
	if (image)
		return image;
    
	CGSize imageSize = CGSizeMake(1.0f, 1.0f);
    
	UIEdgeInsets insets = UIEdgeInsetsZero;
    
	if (direction == UIImageGradientDirectionVertical) {
		imageSize.height = size.height;
		insets = UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f);
	}
	else if (direction == UIImageGradientDirectionHorizontal) {
		imageSize.width = size.width;
		insets = UIEdgeInsetsMake(1.0f, 0.0f, 1.0f, 0.0f);
	}
    
	return [[self imageWithGradient:colors size:imageSize direction:direction] resizableImageWithCapInsets:insets];
}

- (UIImage *)horizontalFlip {
	UIGraphicsBeginImageContext(self.size);
	CGContextRef current_context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(current_context, self.size.width, 0);
	CGContextScaleCTM(current_context, -1.0, 1.0);
	[self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
	UIImage *flipped_img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return flipped_img;
}

- (UIImage *)fixrotation {
	UIImage *image = self;
	if (image.imageOrientation == UIImageOrientationUp) return image;
	CGAffineTransform transform = CGAffineTransformIdentity;
    
	switch (image.imageOrientation) {
		case UIImageOrientationDown:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
            
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
			transform = CGAffineTransformTranslate(transform, image.size.width, 0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
            
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, 0, image.size.height);
			transform = CGAffineTransformRotate(transform, -M_PI_2);
			break;
            
		case UIImageOrientationUp:
		case UIImageOrientationUpMirrored:
			break;
	}
    
	switch (image.imageOrientation) {
		case UIImageOrientationUpMirrored:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, image.size.width, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
            
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, image.size.height, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
            
		case UIImageOrientationUp:
		case UIImageOrientationDown:
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
			break;
	}
    
	// Now we draw the underlying CGImage into a new context, applying the transform
	// calculated above.
	CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
	                                         CGImageGetBitsPerComponent(image.CGImage), 0,
	                                         CGImageGetColorSpace(image.CGImage),
	                                         CGImageGetBitmapInfo(image.CGImage));
	CGContextConcatCTM(ctx, transform);
	switch (image.imageOrientation) {
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			// Grr...
			CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.height, image.size.width), image.CGImage);
			break;
            
		default:
			CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
			break;
	}
    
	// And now we just create a new UIImage from the drawing context
	CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
	UIImage *img = [UIImage imageWithCGImage:cgimg];
	CGContextRelease(ctx);
	CGImageRelease(cgimg);
	return img;
}

@end

#pragma mark - Categories

@implementation NSValue (UICornerInset)

+ (NSValue *)valueWithUICornerInset:(UICornerInset)cornerInset {
	CGRect rect = CGRectMake(cornerInset.topLeft, cornerInset.topRight, cornerInset.bottomLeft, cornerInset.bottomRight);
	return [NSValue valueWithCGRect:rect];
    
	//    UICornerInset inset = cornerInset;
	//    return [[NSValue alloc] initWithBytes:&inset objCType:@encode(struct __UICornerInset)];
}

- (UICornerInset)UICornerInsetValue {
	CGRect rect = [self CGRectValue];
	return UICornerInsetMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
	//    UICornerInset cornerInset;
	//    [self getValue:&cornerInset];
	//    return cornerInset;
}

@end
