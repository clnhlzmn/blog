---
layout: post
title:  "Unit Testing Embedded C"
date:  2020-08-22
categories: programming
tags: [programming, C, coding, software, engineering]
---

I have been trying to be more thorough in my testing efforts lately. What has always seemed like a big challenge is how to automate testing for source code that is targeting a microcontroller like AVR? I will talk about two sides of this challenge: decoupling and running unit tests.

## Decoupling
 
I write a lot of code for AVR microcontrollers so the code here will be in that context, but these ideas work equally well for any target. Decoupling means to separate your software into small pieces that are coupled only with a small number of dependencies. A dependency could be a target header file like `avr/io.h` or it could be another software module that you have written. In either case, keeping the number of dependencies small will improve your chances of successful unit testing.

Assume you have a module called `relay_control` which is intended to turn a relay on if an input value exceeds a threshold and off otherwise. Your `relay_control.c` file might look like this:

```
#include <avr/io.h>

#define THRESHOLD (100)

void relay_control(int value) {
    if (value > THRESHOLD) {
        PORTA |= 1;
    } else {
        PORTA &= ~1;
    }
}
```

The `relay_control` function takes `value`, compares it to `THRESHOLD`, and sets bit zero of `PORTA` high or low accordingly (assuming `PA0` is somehow controlling the relay). Of course this is a trivially simple function but imagine some other complicated logic in it's place. One way to test this function is to compile this using GCC on your development machine while somehow including a mock `avr/io.h` that defines `PORTA` in such a way that the test code can determine if the relay is on or off for a range of the `value` argument passed to `relay_control`. That requires you to mock the header file which is not always possible. A better way is to use features of the C language to decouple the direct io port access from `relay_control` so that the `relay_control` module doesn't depend on `avr/io.h`. That way you can test it on your development machine or wherever you want. The new `relay_control.c` could look something like this:

```
#define THRESHOLD (100)

void (*relay_writer)(char relay_on);

void relay_control(int value) {
    if (relay_writer) 
        relay_writer(value > THRESHOLD);
}
```

The new `relay_control.c` doesn't depend on `avr/io.h`. Instead it depends on a function pointer, `relay_writer`, that acts as an interface to the hardware. Now the application can implement `relay_writer` to access the hardware, and your test code can implement it to set a bit in memory to allow you to check the output of the `relay_control` module. Your application could implement `relay_writer` like this (perhaps in `relay_control_hal.c` [relay control hardware abstraction layer]):

```
#include <avr/io.h>

extern void (*relay_writer)(char relay_on);

void relay_writer_impl(char relay_on) {
    if (relay_on) {
        PORTA |= 1;
    } else {
        PORTA &= ~1;
    }
}

void relay_control_init(void) {
    relay_writer = relay_writer_impl;
}
```

The hardware abstraction layer code is purposfully kept as trivial as possible, it's only accessing the io port, because the only way to test it is to run it on the target platform (because it depends on `avr/io.h`). Since it's so simple you're not as concerned with testing `relay_control_hal.c` (trivial hardware access only) as you are with `relay_control.c` (non-trivial application logic).

Now you can write a test, `test_relay_control.c`, that might look like this:

```
#include <assert.h>
#include "relay_control.h"

char relay_state = 0;

void relay_writer_test_impl(char relay_on) {
    relay_state = relay_on;
}

extern void (*relay_writer)(char relay_on);

int main(void) {
    relay_writer = relay_writer_test_impl;
    relay_control(0);
    assert(relay_state == 0);
    relay_control(1000);
    assert(relay_state == 1);
    return 0;
}
```

Decoupling `relay_control.c` from the hardware (`avr/io.h`) has the added benefit that your tests are not constrained by the target environment's memory or processor limitations. The tests can use the full power of the C language.

Now whenever you make a change to `relay_control.c` you can quickly run the test to make sure that the functionality remains. But how do you run the test?

## Running unit tests

One way is to use a simple makefile that compiles `test_relay_control.c` and `relay_control.c` and then runs the resulting executable. Or you could use a more advanced build system generator like CMake. I recommend using CMake because it gets very tricky very quickly to link up a bunch of `.c` and `.h` files in different directories to create an executable with only a makefile. I have only recently learned how to use CMake so please bear with me on this. The solution that I have come up with for running unit tests on windows goes like this:

1. create a directory somewhere in your project called `test`

2. in the `test` directory create a file called `cmakelists.txt`

    `cmakelists.txt`:

    ````
    cmake_minimum_required (VERSION 3.18)
    project(Test)
    enable_testing()
    add_executable(Test 
        test_relay_control.c 
        <path to relay_control.c>
    )
    include_directories(<path to relay_control.h>)
    add_test(NAME Test COMMAND Test)
    ````

    In this case there is only one test called `Test` which is generated by the `add_executable` and `add_test` commands.

    To add another test you would first create your test file `another_test.c` and add the following lines to `cmakelists.txt`
    
    ````
    add_executable(AnotherTest 
        another_test.c 
        <path to another_file_under_test.c>
    )
    include_directories(<path to headers needed by another_test.c>)
    add_test(NAME AnotherTest COMMAND AnotherTest)
    ````

3. in the `test` directory create a file called `test.sh`

    `test.sh`:
    ````
    if ! [[ -d "build" ]]; then
        mkdir build
    fi
    cd build
    cmake .. -G"MinGW Makefiles"
    cmake --build . && ctest -C Debug
    ````

    In this case I am using the `MinGW Makefiles` generator for CMake because I run my tests on Windows but I would like to use GCC rather than the default MSVC.

With those steps having been done you can now run `test.sh` and whatever tests you have defined will be run and the output will show you clearly which have passed and which have failed.

Happy testing!