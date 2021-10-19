#ifndef NATIVE_EXTENSION_GRAB_H
#define NATIVE_EXTENSION_GRAB_H

#include <nan.h>

class WindowController : public Nan::ObjectWrap {
  public:
    static NAN_MODULE_INIT(Init);

  private:
    explicit WindowController(pid_t windowNumber = 0);
    ~WindowController();

    static NAN_METHOD(New);
    static NAN_METHOD(Show);
    static Nan::Persistent<v8::Function> constructor;
    pid_t windowNumber_;
    void *windowController_;
};

#endif
