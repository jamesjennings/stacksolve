stacksolve
==========

Is there anything that can't be solved with StackOverflow?

This code takes in an arbitrary input and a description of the desired transformation or calculation, then searches StackOverflow for posts with code attached matching your criteria, and finally runs the found code until an "answer" is found.

Inspired by (and started as a direct port of) [http://gkoberger.github.com/stacksort/](http://gkoberger.github.com/stacksort/) (and [http://xkcd.com/1185/](http://xkcd.com/1185/) by extension).

Usage:
----------
./stacksolve "inputData" "desired transform/calculation" "[optional Stack Apps key](http://stackapps.com/)"

Some fun examples:
----------
`./stacksolve.rb "'Computers are hard'" "reverse"`

`./stacksort.rb "10" "factorial"`

`./stacksort.rb "[3,5,6,2]" "multiply"`

Commentary:
----------
So, generally speaking, this is probably a really bad idea. The code searches StackOverflow for arbitrary code, which is then run on your machine. Use at your own risk.

I made this mostly to improve my Ruby skills; obviously that implies nothing in here should be assumed to be best practice. I'd *love* feedback on better/safer ways to do this (honestly).

Things I'd like to add:

* Stripping of potentially unsafe code
* Figure out a way around the inevitable namespace poisoning
* Pretty up the UI, add links to answers, more responsiveness, etc.
