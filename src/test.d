

import dmath;


import std.stdio;
import std.random;
import std.math;

void runTests()
{

  uint
    successes = 0,
    failures = 0,
    tests = 1000000;
  real
    threshold = .01;

  write("\033[?25l");
  write("Working... (00%)");

  for (uint k = 0; k < tests; k++)
  {
    Vector!real v1 = new Vector!real(
        uniform(0.0, 10.0),
        uniform(0.0, 10.0),
        uniform(0.0, 10.0)
        )
        ;

    Vector!real v2 = v1.rotate3d( uniform(0.0, PI * 2), uniform(0.0, PI * 2), uniform(0.0, PI * 2) );

    if ( abs(v1.magnitude() - v2.magnitude()) > threshold )
      failures++;
    else
      successes++;

    write("\033[4D"); /+ cursor back 4 +/
    writef("%02d", 100 * k / tests);
    writef("\033[2C"); /+ cursor forward 2 +/

  }

  write("\033[5D"); /+ cursor back 4 +/
  writefln("Done!");
  write("\033[?25h");

  writefln("\nSuccesses:  %d", successes);
  if (failures > 0)
    write("\033[31m\033[1m");
  writefln("Failures:    %d", failures);
  write("\033[39m\033[0m");
  writefln("Total Tests: %d", successes + failures);

}

void main()
{

  runTests();

}
