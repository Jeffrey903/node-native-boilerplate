#include "functions.h"
#import <Cocoa/Cocoa.h>

@interface BorderViewController : NSViewController

@end

@implementation BorderViewController

- (void)loadView
{
    self.view = [[NSView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSBox *box = [[NSBox alloc] init];
    box.boxType = NSBoxCustom;
    box.borderColor = [NSColor colorWithRed:190.0/255.0 green:250.0/255.0 blue:0.0 alpha:1.0];
    box.borderWidth = 4;
    box.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:box];

    [NSLayoutConstraint activateConstraints:@[
        [box.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [box.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [box.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [box.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

@end

@interface BorderWindowController : NSWindowController

@property (assign, nonatomic) NSInteger screenShareWindowNumber;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation BorderWindowController

+ (instancetype)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (instancetype)init
{
    BorderViewController *borderViewController = [[BorderViewController alloc] init];
    NSWindow *window = [NSWindow windowWithContentViewController:borderViewController];
    window.styleMask = NSWindowStyleMaskBorderless;
    window.opaque = NO;
    window.backgroundColor = [NSColor clearColor];
    window.collectionBehavior = NSWindowCollectionBehaviorTransient;

    self = [super initWithWindow:window];
    return self;
}

- (void)showWithScreenShareWindowNumber:(NSInteger)screenShareWindowNumber
{
    [self.timer invalidate];

    self.screenShareWindowNumber = screenShareWindowNumber;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(positionWindow) userInfo:nil repeats:YES];
}

- (void)hide
{
    [self.timer invalidate];
    self.timer = nil;
    [self close];
}

- (void)positionWindow
{
    NSArray<NSDictionary<NSString *, id> *> *windowList = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID));

    NSDictionary<NSString *, id> *window = nil;
    for (NSDictionary<NSString *, id> *w in windowList) {
        CFNumberRef windowNumber = (__bridge CFNumberRef)(w[(__bridge NSString *)kCGWindowNumber]);
        if (((__bridge NSNumber *)windowNumber).integerValue == self.screenShareWindowNumber) {
            window = w;
            break;
        }
    }

    if (!window) {
        // If the screen share window can't be found, then close the border window, but don't
        // invalidate the timer. The shared window may be minimized and may come back.
        [self close];
        return;
    }

    CFNumberRef windowNumber = (__bridge CFNumberRef)(window[(__bridge NSString *)kCGWindowNumber]);
    CFDictionaryRef bounds = (__bridge CFDictionaryRef)(window[(__bridge NSString *)kCGWindowBounds]);
    CGRect rect = CGRectZero;
    CGRectMakeWithDictionaryRepresentation(bounds, &rect);
    // TODO: consider multiple monitors of different sizes
    NSScreen *screen = [NSScreen screens].firstObject;

    CGRect frame = rect;
    // Adjust origin.y from CGRect to NSRect coordinate system
    frame.origin.y = screen.frame.size.height - frame.origin.y - frame.size.height;

    CGRect borderFrame = CGRectInset(frame, -5.0, -5.0);
    if (!CGRectEqualToRect(self.window.frame, borderFrame)) {
        [self.window setFrame:borderFrame display:YES];
    }
    [self showWindow:nil];
    [self.window orderWindow:NSWindowAbove relativeTo:((__bridge NSNumber *)windowNumber).integerValue];
}

@end

//

NAN_METHOD(show) {
    int windowNumber = Nan::To<int>(info[0]).FromJust();
    [[BorderWindowController sharedInstance] showWithScreenShareWindowNumber:windowNumber];
}

NAN_METHOD(hide) {
    [[BorderWindowController sharedInstance] hide];
}
