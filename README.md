# Tink UV

Incorporate the mighty libuv in your Haxe program!

## Supported platform

C++ only (maybe HL in the future)

## What it does

`tink_uv` does basically two things:

1. Inject the libuv runloop to the end of your `main` function
2. Patch haxe.Timer so that haxe's `MainLoop` is not generated

## What you do

Use API from the `linc_uv` library (`uv.Uv.*`) to write your scalable software.
Note that you have to manage libuv-related memory manually.