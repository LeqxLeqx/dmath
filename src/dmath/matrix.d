
module dmath.matrix;


import std.math;
import std.format;
import std.algorithm.mutation;

import dmath.dmathexception;
import dmath.vector;
import dmath.axis;

template Matrix(T)
{

  class Matrix
  {

    static Matrix identity(uint width, uint height)
    {
      if (width == 0 || height == 0)
        throw new DMathException("Neither width nor height of an identity matrix may be non-positive");

      T[] values = new T[width * height];
      values.fill(0);

      for (uint k = 0; k < width && k < height; k++)
      {
        values[k + k * width] = 1;
      }

      return new Matrix(width, height, values);
    }
    static Matrix identity(uint dimensions)
    {
      return identity(dimensions, dimensions);
    }

    static Matrix zero(uint width, uint height)
    {
      if (width == 0 || height == 0)
        throw new DMathException("Neither width nor height of a zero matrix may be non-positive");

      T[] values = new T[width * height];
      values.fill(0);

      return new Matrix(width, height, values);
    }
    static Matrix zero(uint dimensions)
    {
      return zero(dimensions, dimensions);
    }

    static Matrix fromRowVectors(Vector!T[] vectors ...)
    {
      if (vectors is null)
        throw new DMathException("Row vector array cannot be null");
      if (vectors.length == 0)
        throw new DMathException("Row vector array cannot be of zero length");
      if (!Vector!T.vectorsShareDimensionality(vectors))
        throw new DMathException("Vectors must share a common dimensionality");

      uint
        width = vectors[0].dimensionality,
        height = cast(uint) vectors.length,
        top
        ;
      T[]
        values = new T[width * height]
        ;

      for (uint y = 0; y < height; y++)
      {
        for (uint x = 0; x < width; x++)
        {
          values[top++] = (vectors[y])[x];
        }
      }


      return new Matrix(width, height, values);
    }

    static Matrix fromColumnVectors(Vector!T[] vectors ...)
    {
      if (vectors is null)
        throw new DMathException("Column vector array cannot be null");
      if (vectors.length == 0)
        throw new DMathException("Column vector array cannot be of zero length");
      if (!Vector!T.vectorsShareDimensionality(vectors))
        throw new DMathException("Vectors must share a common dimensionality");

      uint
        height = vectors[0].dimensionality,
        width = cast(uint) vectors.length,
        top
        ;
      T[]
        values = new T[width * height]
        ;

      for (uint x = 0; x < width; x++)
      {
        for (uint y = 0; y < height; y++)
        {
          values[top++] = (vectors[x])[y];
        }
      }

      return new Matrix(width, height, values);
    }

    static Matrix rotationMatrix3d(Axis axis)(real rot)
    {
      static if (axis == Axis.X)
      {
        return new Matrix(3, 3,
          1, 0, 0,
          0, cast(T) cos(rot), cast(T) -sin(rot),
          0, cast(T) sin(rot), cast(T) cos(rot)
          );
      }
      else static if (axis == Axis.Y)
      {
        return new Matrix(3, 3,
          cast(T) cos(rot), 0, cast(T) sin(rot),
          0, 1, 0,
          cast(T) -sin(rot), 0, cast(T) cos(rot)
          );
      }
      else static if (axis == Axis.Z)
      {
        return new Matrix(3, 3,
          cast(T) cos(rot), cast(T) -sin(rot), 0,
          cast(T) sin(rot), cast(T) cos(rot), 0,
          0, 0, 1
          );
      }
      else static assert(0, format("No implementation exists for given axis type: %s", axis));
    }

    static Matrix rotationMatrix3d(real alpha, real beta, real gamma)
    {
      return
        rotationMatrix3d!(Axis.Z)(alpha) *
        rotationMatrix3d!(Axis.Y)(beta)  *
        rotationMatrix3d!(Axis.X)(gamma)
        ;
    }

    static Matrix rotationMatrix2d(real rot)
    {
      return new Matrix(2, 2,
        cast(T) cos(rot), cast(T) -sin(rot),
        cast(T) sin(rot), cast(T) cos(rot)
        );
    }



    static Matrix matrixAdd(Matrix m1, Matrix m2)
    {
      if (m1 is null)
        throw new DMathException("Argument 'm1' cannot be null");
      if (m2 is null)
        throw new DMathException("Argument 'm2' cannot be null");
      if (
        m1.width != m2.width ||
        m1.height != m2.height
        )
        throw new DMathException("Dimensionality mismatch");

      T[] ret = new T[m1.width * m2.height];
      ret[] = m1.values[] + m2.values[];

      return new Matrix(
        m1.width,
        m1.height,
        ret
        );
    }

    static Matrix matrixSub(Matrix m1, Matrix m2)
    {
      if (m1 is null)
        throw new DMathException("Argument 'm1' cannot be null");
      if (m2 is null)
        throw new DMathException("Argument 'm2' cannot be null");
      if (
        m1.width != m2.width ||
        m1.height != m2.height
        )
        throw new DMathException("Dimensionality mismatch");

      T[] ret = new T[m1.width * m2.height];
      ret[] = m1.values[] - m2.values[];

      return new Matrix(
        m1.width,
        m1.height,
        ret
        );
    }

    static Matrix matrixMul(Matrix m1, Matrix m2)
    {
      if (m1 is null)
        throw new DMathException("Argument 'm1' cannot be null");
      if (m2 is null)
        throw new DMathException("Argument 'm2' cannot be null");
      if (m1.width != m2.height)
        throw new DMathException("Dimensionality mismatch");

      T[] ret = new T[m1.height * m2.width];

      for (uint x = 0; x < m2.width; x++)
      {
        for (uint y = 0; y < m1.height; y++)
        {
          T val = m1.get(0, y) * m2.get(x, 0);

          for (uint k = 1; k < m1.width; k++)
          {
            val = val + m1.get(k, y) * m2.get(x, k);
          }

          ret[x + y * m2.width] = val;
        }
      }

      return new Matrix(m2.width, m1.height, ret);
    }



    /+ PROPERTIES +/

    private uint w, h;
    private T[] values;


    /+ CONSTRUCTOR(S) +/

    this(
      uint width,
      uint height,
      T[] values...
      )
    {
      if (width == 0 || height == 0)
        throw new DMathException("Neither width nor height may be non-positive");
      if (values == null)
        throw new DMathException("Values array cannot be null");
      if (width * height != values.length)
        throw new DMathException("The length of the provided value array must be equal to the product of the width and height");

      this.w = width;
      this.h = height;
      this.values = values.dup;
    }


    /+ HELPER FUNCTIONS +/

    private uint index(uint n, uint m)
    {
      return n + m * width;
    }


    /+ PROPERTY FUNCTIONS +/

    @property uint width()
    {
      return this.w;
    }
    @property uint height()
    {
      return this.h;
    }

    T get(uint n, uint m)
    {
      if ( n >= this.width || m >= this.height)
        throw new DMathException("Out of bounds (%d, %d)", n, m);

      return this.values[index(n, m)];
    }


    /+ UNARY OPERATORS +/

    Matrix clone()
    {
      return new Matrix(width, height, this.values.dup);
    }

    Matrix negative()
    {
      T[] ret = new T[this.values.length];
      ret[] = -this.values[];

      return new Matrix(width, height, ret);
    }

    Matrix scale(T factor)
    {
      T[] ret = new T[this.values.length];
      ret[] = this.values[] * factor;

      return new Matrix(width, height, ret);
    }

    Matrix transpose()
    {
      T[] ret = new T[this.values.length];
      for (uint x = 0; x < width; x++)
      {
        for (uint y = 0; y < height; y++)
        {
          ret[index(y, x)] = this.values[index(x, y)];
        }
      }

      return new Matrix(height, width, ret);
    }


    @property T determinant()
    {
      if (this.width != this.height)
        throw new DMathException("Matrix must be a square to take a determinant");

      if (this.width == 1) /+ and thus, height == 1+/
        return get(0, 0);
      if (this.width == 2) /+ and thus, height == 2 +/
      {
        return get(0, 0) * get(1, 1) - get(1, 0) * get(0, 1);
      }
      else
      {
        T ret = get(0, 0) * getSubMatrix(0, 0).determinant;

        for (uint k = 1; k < this.width; k++)
        {
          T aug = get(k, 0) * getSubMatrix(k, 0).determinant;
          if (k % 2 == 0)
            ret = ret + aug;
          else
            ret = ret - aug;
        }

        return ret;
      }

    }

    /+ COMPLEX OPERATIONS +/


    Matrix getSubMatrix(uint x, uint y)
    {
      if (this.width == 1 || this.height == 1)
        throw new DMathException("Matrix is too small to get sub matrix");

      uint
        xtop = 0,
        ytop = 0,
        newWidth = this.width - 1,
        newHeight = this.height - 1
        ;
      T[]
        values = new T[newWidth * newHeight]
        ;

      for (uint dx = 0; dx < this.width; dx++)
      {

        if (dx == x)
          continue;

        ytop = 0;
        for (uint dy = 0; dy < this.height; dy++)
        {
          if (dy == y)
            continue;

          values[xtop + ytop * newWidth] = this.get(dx, dy);

          ytop++;
        }

        xtop++;
      }

      return new Matrix(newWidth, newHeight, values);
    }


    Vector!U transform(U)(Vector!U vector)
    {
      if (this.width != vector.dimensionality)
        throw new DMathException("Dimensional mismatch");

      U[] ret = new U[this.height];
      ret.fill(0);

      for (uint y = 0; y < this.height; y++)
      {
        for (uint x = 0; x < this.width; x++)
        {
          ret[y] += cast(U) (vector[x] * this.get(x, y));
        }
      }

      return new Vector!T(ret);
    }





    /+ OPERATOR OVERLOADS +/

    Matrix opUnary(string s)()
    {
      static if (s == "-")
      {
        return this.negative();
      }
      else static if (s == "+")
      {
        return this.clone();
      }
      else static if (s == "~")
      {
        return this.transpose();
      }
      else static assert(0, "The unary operator " ~ s ~ " has not been implemented for the Matrix type");
    }

    Matrix opBinary(string s)(Matrix m)
    {
      static if (s == "+")
      {
        return matrixAdd(this, m);
      }
      else static if (s == "-")
      {
        return matrixSub(this, m);
      }
      else static if (s == "*")
      {
        return matrixMul(this, m);
      }
      else static assert(0, "The binary operator " ~ s ~ " has not been implemented for the Matrix type");
    }
    Vector!U opBinary(string s, U)(Vector!U m) if (s == "*")
    {
      return transform(m);
    }

    T opIndex(uint x, uint y)
    {
      return this.get(x, y);
    }


    override string toString()
    {

      string ret;
      for (uint x = 0; x < width; x++)
      {

        string subRet = format("%s", get(x, 0));
        for (uint y = 1; y < height; y++)
        {
          subRet = format("%s,%s", subRet, get(x, y));
        }

        if (x == 0)
        {
          ret = format("[%s]", subRet);
        }
        else
        {
          ret = format("%s,[%s]", ret, subRet);
        }

      }

      return format("[%s]", ret);
    }


  }

}
