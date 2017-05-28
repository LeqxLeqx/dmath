
module dmath.dmathexception;

import std.format;

class DMathException : Exception
{

  this(string message)
  {
    super(message);
  }

  this(Args...)(string message, Args args)
  {
    super(format(message, args));
  }

}
