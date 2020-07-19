---
layout: post
title:  "Unit Testing Embedded C"
date:  2020-07-19
categories: programming
tags: [programming, C, coding, software, engineering]
---

Testing my code hasn't always been a priority for me. When I first started programming I wasn't even aware of the concept of software testing software. At that time, to me, testing meant running the program and making sure it does what I want, manually. It's unfortunate that a lot of beginner tools like Arduino don't provide any facility to do anything other than that.

Nowadays when I'm programming in C I'm usually doing so using an IDE like Atmel Studio. AS doesn't provide any real support for testing either, but it's not as hopeless as Arduino IDE is.

First let me talk about my motivation for writing this post. I have been trying to find a convenient way to automate testing of code that is targeting a microcontroller. In these cases running test code on the target platform is not a convenient way to automate testing. It is possible, and necessary to do some testing on the target platform, but the majority of testing should be run and verified automatically and I haven't come across an easy way to do that on the target platform (such as AVR).

I beleive writing tests is equally as important as writing the application and an application that doens't have any tests is only halfway done. I have written plenty of applications that don't have tests and I always regret that decision when I am asked to make a change to those apps.

I have been trying to be more thorough in my testing efforts lately and what I have perceived as a big challenge is how to automate testing for source code that is targeting a microcontroller like AVR? For starters, if the code `#include`s headers like `avr/io.h` then that pretty much precludes them from being tested on my development machine.

The first step is to write as much code as possible in a platform independent way. For example, assume we have a module called `relay_control` which is intended to turn a relay on if an input value exceeds a threshold and off otherwise. Our `relay_control.c` function might look like this (assuming 8 bit AVR):

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

Our `relay_control` function takes `int value`, compares it to `THRESHOLD`, and sets bit zero of `PORTA` high or low accordingly (assuming `PA0` is somehow controlling the relay). Of course this is a trivially simple function but imagine some other complicated logic in it's place. Now one way to test this function is to compile this using gcc on our windows development machine and somehow include a mock `avr/io.h` that defines `PORTA` in such a way that our test code can determine if the relay is on or off according to the `value` passed to `relay_control`. A simpler way (in my opinion) and the way that I have been writing code lately is to abstract away the direct io port access to another place so that our `relay_control` module doesn't depend on `avr/io.h`. That way we can test it on our development machine or wherever we want. Our new `relay_control.c` could look something like this:

```
#define THRESHOLD (100)

void (*relay_writer)(char relay_on);

void relay_control(int value) {
    relay_writer(value > THRESHOLD);
}
```

Again imagine that `relay_control` is doing something non-trivial. Now `relay_control.c` doesn't depend on `avr/io.h` and we can write our tests. Somewhere else in our application we would have some code that looks like this (perhaps in `relay_control_hal.c` [relay control hardware abstraction layer]):

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

Our hardware abstraction layer code is purposfully kept as trivial as possible, it's only accessing the io port, because the only way to test it is to run it on the target platform (because it depends on `avr/io.h`). Since it's so simple though we're not as concerned with testing `relay_control_hal.c` (trivial hardware access only) as we are with `relay_control.c` (non-trivial application logic).

We could write a test, `test_relay_control.c`, that might look like:

```
#include <assert.h>
#include "relay_control.h"

char relay_state = 0;

void relay_writer_test_impl(char relay_on) {
    relay_state = relay_on;
}

int main(void) {
    relay_writer = relay_writer_test_impl;
    relay_control(0);
    assert(relay_state == 0);
    relay_control(1000);
    assert(relay_state == 1);
    return 0;
}
```

Decoupling `relay_control.c` from the hardware (`avr/io.h`) has the added benefit that our tests are not constrained by the target environment's memory or processor limitations. The tests can use the full power of the C language.

Now whenever we make a change to `relay_control.c` we can quicly run our test to make sure that the functionality remains. But how do we run this test?

One way is to use a simple makefile that compiles `test_relay_control.c` and `relay_control.c` and then runs the resulting executable. Or you could use a more advanced build system generator like CMake. Either way you will want an easy way to run your projects tests so that they're not forgotten. Using either a makefile or CMake it is possible to then create a single script `test.sh` or `test.bat` that runs all your tests and reports pass or fail with the click of a button.