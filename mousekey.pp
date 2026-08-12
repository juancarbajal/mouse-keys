program mousekey;

{$mode objfpc}{$H+}

uses
  Classes,
  xlib, x, ctypes, unix;

var
  DisplayPtr: PDisplay;
  RootWin: TWindow;
  Event: TXEvent;
  GrabResult: cint;
begin
  // Open connection to X server
  DisplayPtr := XOpenDisplay(nil);
  if DisplayPtr = nil then
  begin
    WriteLn('Cannot open X display');
    Halt(1);
  end;

  RootWin := DefaultRootWindow(DisplayPtr);

  // Grab the pointer (mouse capture)
  GrabResult := XGrabPointer(
    DisplayPtr,
    RootWin,          // Grab relative to root window
    True,             // Owner events
    ButtonPressMask or ButtonReleaseMask or PointerMotionMask,
    GrabModeAsync,    // Pointer mode
    GrabModeAsync,    // Keyboard mode
    None,             // Confine to window
    None,             // No custom cursor
    CurrentTime
  );

  if GrabResult <> GrabSuccess then
  begin
    WriteLn('Failed to grab pointer');
    XCloseDisplay(DisplayPtr);
    Halt(1);
  end;

  WriteLn('Pointer captured. Move mouse or click to see events.');
  repeat
    XNextEvent(DisplayPtr, @Event);
    Writeln('Button: ', Event.xbutton.button);
    case Event._type of
      MotionNotify:
        WriteLn('Mouse moved to: ', Event.xmotion.x, ',', Event.xmotion.y);
      ButtonPress:
        WriteLn('Button pressed: ', Event.xbutton.button);
      ButtonRelease:
        WriteLn('Button released: ', Event.xbutton.button);
    end;
  until False;

  // Release pointer (never reached in this example)
  XUngrabPointer(DisplayPtr, CurrentTime);
  XCloseDisplay(DisplayPtr);
end.

