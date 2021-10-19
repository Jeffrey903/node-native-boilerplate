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

- (instancetype)initWithScreenShareWindowNumber:(NSInteger)screenShareWindowNumber
{
    BorderViewController *borderViewController = [[BorderViewController alloc] init];
    NSWindow *window = [NSWindow windowWithContentViewController:borderViewController];
    window.styleMask = NSWindowStyleMaskBorderless;
    window.opaque = NO;
    window.backgroundColor = [NSColor clearColor];
    window.collectionBehavior = NSWindowCollectionBehaviorTransient;

    self = [super initWithWindow:window];
    if (self) {
        self.screenShareWindowNumber = screenShareWindowNumber;
    }
    return self;
}

- (void)show
{
    [self.timer invalidate];
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

Nan::Persistent<v8::Function> WindowController::constructor;

NAN_MODULE_INIT(WindowController::Init) {
  v8::Local<v8::FunctionTemplate> tpl = Nan::New<v8::FunctionTemplate>(New);
  tpl->SetClassName(Nan::New("WindowController").ToLocalChecked());
  tpl->InstanceTemplate()->SetInternalFieldCount(1);

  Nan::SetPrototypeMethod(tpl, "show", Show);
  Nan::SetPrototypeMethod(tpl, "hide", Hide);

  constructor.Reset(Nan::GetFunction(tpl).ToLocalChecked());
  Nan::Set(target, Nan::New("WindowController").ToLocalChecked(), Nan::GetFunction(tpl).ToLocalChecked());
}

WindowController::WindowController(pid_t windowNumber) : windowNumber_(windowNumber) {
}

WindowController::~WindowController() {
}

NAN_METHOD(WindowController::New) {
  if (info.IsConstructCall()) {
    pid_t windowNumber = info[0]->IsUndefined() ? 0 : Nan::To<double>(info[0]).FromJust();
    WindowController *obj = new WindowController(windowNumber);
    obj->windowController_ = [[BorderWindowController alloc] initWithScreenShareWindowNumber:windowNumber];
    obj->Wrap(info.This());
    info.GetReturnValue().Set(info.This());
  } else {
    const int argc = 1;
    v8::Local<v8::Value> argv[argc] = {info[0]};
    v8::Local<v8::Function> cons = Nan::New(constructor);
    info.GetReturnValue().Set(Nan::NewInstance(cons, argc, argv).ToLocalChecked());
  }
}

NAN_METHOD(WindowController::Show) {
  WindowController* obj = Nan::ObjectWrap::Unwrap<WindowController>(info.This());

  BorderWindowController *bwc = (BorderWindowController *)obj->windowController_;
  [bwc show];
}

NAN_METHOD(WindowController::Hide) {
  WindowController* obj = Nan::ObjectWrap::Unwrap<WindowController>(info.This());

  BorderWindowController *bwc = (BorderWindowController *)obj->windowController_;
  [bwc hide];
}
