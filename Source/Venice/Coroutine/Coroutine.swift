// Co.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import CLibvenice

/// Current time.
public var now: Int64 {
    return CLibvenice.now()
}

public let hour: Int64 = 3600000
public let hours = hour
public let minute: Int64 = 60000
public let minutes = minute
public let second: Int64 = 1000
public let seconds = second
public let millisecond: Int64 = 1
public let milliseconds = millisecond

public typealias Deadline = Int64
public let never: Deadline = -1
public let noDeadline = never

public typealias Duration = Int64
public typealias PID = pid_t

/// Runs the expression in a lightweight coroutine.
public func co(routine: Void -> Void) {
    var _routine = routine
    CLibvenice.co(&_routine, { routinePointer in
        UnsafeMutablePointer<(Void -> Void)>(routinePointer).pointee()
    }, "co")
}

/// Runs the expression in a lightweight coroutine.
public func co(@autoclosure(escaping) routine: Void -> Void) {
    var _routine: Void -> Void = routine
    CLibvenice.co(&_routine, { routinePointer in
        UnsafeMutablePointer<(Void -> Void)>(routinePointer).pointee()
    }, "co")
}

/// Runs the expression in a lightweight coroutine after the given duration.
public func after(napDuration: Duration, routine: Void -> Void) {
    co {
        nap(napDuration)
        routine()
    }
}

/// Runs the expression in a lightweight coroutine periodically. Call done() to leave the loop.
public func every(napDuration: Duration, routine: (done: Void -> Void) -> Void) {
    co {
        var done = false
        while !done {
            nap(napDuration)
            routine {
                done = true
            }
        }
    }
}

/// Preallocates coroutine stacks. Returns the number of stacks that it actually managed to allocate.
public func preallocateCoroutineStacks(stackCount stackCount: Int, stackSize: Int) {
    return goprepare(Int32(stackCount), stackSize)
}

/// Sleeps for duration.
public func nap(duration: Duration) {
    mill_msleep(now + duration, "nap")
}

/// Wakes up at deadline.
public func wakeUp(deadline: Deadline) {
    mill_msleep(deadline, "wakeUp")
}

/// Passes control to other coroutines.
public var yield: Void {
    mill_yield("yield")
}

/// Fork the current process.
public func fork() -> PID {
    return mfork()
}

/// Get the number of logical CPU cores available. This might return a bigger number than the physical CPU Core number if the CPU supports hyper-threading.
public var CPUCoreCount: Int {
    return Int(mill_number_of_cores())
}

public func dump() {
    goredump()
}

infix operator <- {}
prefix operator <- {}
prefix operator !<- {}
