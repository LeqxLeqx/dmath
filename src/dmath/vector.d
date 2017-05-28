module dmath.vector;


import std.format;
import std.math;
import std.algorithm.mutation;

import dmath.dmathexception;
import dmath.axis;
import dmath.matrix;


template Vector(T)
{

  class Vector
  {

    static Vector zero (uint dimensionality)
    {
      if (dimensionality == 0)
        throw new DMathException("Cannot create vector of zero dimensions");

      T[] values = new T[dimensionality];
      values.fill(0);

      return new Vector(values);
    }

    static Vector iHat (uint dimensionality)
    {
      if (dimensionality == 0)
        throw new DMathException("Cannot create vector of zero dimensions");

      T[] values = new T[dimensionality];
      values.fill(0);

      values[0] = 1;

      return new Vector(values);
    }
    static Vector jHat (uint dimensionality)
    {
      if (dimensionality == 0)
        throw new DMathException("Cannot create vector of zero dimensions");
      if (dimensionality < 2)
        throw new DMathException("Cannot create 'jhat' vector of less than two dimensions");

      T[] values = new T[dimensionality];
      values.fill(0);

      values[1] = 1;

      return new Vector(values);
    }
    static Vector kHat (uint dimensionality)
    {
      if (dimensionality == 0)
        throw new DMathException("Cannot create vector of zero dimensions");
      if (dimensionality < 3)
        throw new DMathException("Cannot create 'jhat' vector of less than two dimensions");

      T[] values = new T[dimensionality];
      values.fill(0);

      values[2] = 1;

      return new Vector(values);
    }




    /+ OPERATIONS +/

    static Vector vectorAdd(Vector v1, Vector v2)
    {
      if (v1 is null)
        throw new DMathException("Argument 'v1' cannot be null");
      if (v2 is null)
        throw new DMathException("Argument 'v2' cannot be null");
      if (v1.dimensionality != v2.dimensionality)
        throw new DMathException("Dimensionality mismatch");

      T[] ret = new T[v1.values.length];
      ret[] = v1.values[] + v2.values[];

      return new Vector(ret);
    }

    static Vector vectorSub(Vector v1, Vector v2)
    {
      if (v1 is null)
        throw new DMathException("Argument 'v1' cannot be null");
      if (v2 is null)
        throw new DMathException("Argument 'v2' cannot be null");
      if (v1.dimensionality != v2.dimensionality)
        throw new DMathException("Dimensionality mismatch");

      T[] ret = new T[v1.values.length];
      ret[] = v1.values[] - v2.values[];

      return new Vector(ret);
    }

    static T vectorDot(Vector v1, Vector v2)
    {
      if (v1 is null)
        throw new DMathException("Argument 'v1' cannot be null");
      if (v2 is null)
        throw new DMathException("Argument 'v2' cannot be null");
      if (v1.dimensionality != v2.dimensionality)
        throw new DMathException("Dimensionality mismatch");

      T ret = v1.values[0] * v2.values[0];
      for (uint k = 1; k < v1.values.length; k++)
      {
        ret += v1.values[k] * v2.values[k];
      }

      return ret;
    }

    static bool vectorsShareDimensionality(Vector[] vectors ...)
    {
      if (vectors is null)
        throw new DMathException("Vectors array cannot be null");
      if (vectors.length == 0)
        return true;

      Vector first = vectors[0];

      for (uint k = 1; k < vectors.length; k++)
      {
        if (first.dimensionality != vectors[k].dimensionality)
          return false;
      }

      return true;
    }




    /+ PROPERTIES +/

    private T[] values;


    /+ CONSTRUCTOR(S) +/

    this(T[] values ...)
    {
      if (values is null)
        throw new DMathException("Values array cannot be null");
      if (values.length == 0)
        throw new DMathException("Cannot create a vector of zero dimensions");

      this.values = values.dup;
    }


    /+ PROPERTY FUNCTIONS +/

    @property uint dimensionality()
    {
      return cast(uint) values.length;
    }

    @property T x()
    {
      return this[0];
    }
    @property T y()
    {
      return this[1];
    }
    @property T z()
    {
      return this[2];
    }


    /+ UNARY OPERATORS +/

    Vector clone()
    {
      return new Vector(this.values.dup);
    }

    Vector negative()
    {
      T[] ret = new T[this.values.length];
      ret[] = -this.values[];

      return new Vector(ret);
    }

    Vector scale(T factor)
    {
      T[] ret = new T[this.values.length];
      ret[] = this.values[] * factor;

      return new Vector(ret);
    }

    T magnitude()
    {
      T t = this.x * this.x;

      for (uint k = 1; k < this.values.length; k++)
      {
        t = t + this.values[k] * this.values[k];
      }

      return cast(T) sqrt(cast(real) t);
    }

    /+ ROTATION OPERATIONS +/

    Vector rotate3d(Axis axis)(real rot)
    {
      return Matrix!T.rotationMatrix3d!(axis)(rot).transform(this);
    }

    Vector rotate3d(real alpha, real beta, real gamma)
    {
      return Matrix!T.rotationMatrix3d(alpha, beta, gamma).transform(this);
    }



    /+ OPERATOR OVERLOADS +/

    Vector opUnary(string s)()
    {
      static if (s == "-")
      {
        return this.negative();
      }
      else static if (s == "+")
      {
        return this.clone();
      }
      else static assert(0, "The unary operator " ~ s ~ " has not been implemented for the Vector type");
    }

    T opBinary(string s)(Vector v) /+ Dot product +/
        if (s == "*")
    {
      return vectorDot(this, v);
    }

    Vector opBinary(string s)(Vector v)
        if (s != "*")
    {
      static if (s == "+")
      {
        return vectorAdd(this, v);
      }
      else static if (s == "-")
      {
        return vectorSub(this, v);
      }
      else static if (s == "&") /+ Cross product. Perhaps change +/
      {
        assert(0, "Cross product is not yet implemented");
      }
      else static assert(0, "The binary operator " ~ s ~ " has not been implemented for the Vector type");
    }



    Vector opBinary(string s)(T v)
    {
      static if (s == "*") /+ Scalar multiplication +/
      {
        return scale( v );
      }
      else static if (s == "/") /+ Scalar division +/
      {
        return scale( 1 / v );
      }
      else static assert(0, "The binary operator " ~ s ~ " has not been implemented for the Vector type");
    }

    bool opEquals(Object v)
    {
      /+
       + the cast will create a null value
       + if the object is not a vector, which
       + the 'equals' method with then return
       + false
       +/
      return equals(cast(Vector) v);
    }

    T opIndex(size_t index)
    {
      if (index >= this.dimensionality)
        throw new DMathException("Cannot access vector component beyond dimensionality");

      return this.values[index];
    }



    /+ COMMONS +/

    bool equals(Vector v)
    {

      if (v is null)
        return false;
      if (this.dimensionality != v.dimensionality)
        return false;

      for ( uint k = 0; k < this.values.length; k++ )
      {
        if (this.values[k] != v.values[k])
          return false;
      }

      return true;
    }

    override string toString()
    {
      string ret = format("%s", this.values[0]);

      for (uint k = 1; k < this.values.length; k++)
      {
        ret = format("%s,%s", ret, this.values[k]);
      }

      return format("[%s]", ret);
    }

  }



}
