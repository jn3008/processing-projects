import java.util.Arrays;
final public static class Matrix {
  private final int M;             // number of rows
  private final int N;             // number of columns
  private final double[][] data;   // M-by-N array

  public static Matrix Rx(float th) {
    return new Matrix(new double[][]{
      {1, 0, 0, 0},
      {0, cos(th), sin(th), 0},
      {0, -sin(th), cos(th), 0},
      {0, 0, 0, 1}
      });
  }

  public static Matrix Ry(float th) {
    return new Matrix(new double[][]{
      {cos(th), 0, -sin(th), 0},
      {0, 1, 0, 0},
      {sin(th), 0, cos(th), 0},
      {0, 0, 0, 1}
      });
  }

  public static Matrix Rz(float th) {
    return new Matrix(new double[][]{
      {cos(th), -sin(th), 0, 0},
      {sin(th), cos(th), 0, 0},
      {0, 0, 1, 0},
      {0, 0, 0, 1}
      });
  }

  public static Matrix T(float x, float y) {
    return new Matrix(new double[][]{
      {1, 0, 0, x},
      {0, 1, 0, y},
      {0, 0, 1, 0},
      {0, 0, 0, 1}
      });
  }

  public static Matrix T(float x, float y, float z) {
    return new Matrix(new double[][]{
      {1, 0, 0, x},
      {0, 1, 0, y},
      {0, 0, 1, z},
      {0, 0, 0, 1}
      });
  }

  public static Matrix T(Vec v) {
    return new Matrix(new double[][]{
      {1, 0, 0, v.x},
      {0, 1, 0, v.y},
      {0, 0, 1, v.z},
      {0, 0, 0, 1}
      });
  }

  public static Matrix S(float s) {
    return new Matrix(new double[][]{
      {s, 0, 0, 0},
      {0, s, 0, 0},
      {0, 0, s, 0},
      {0, 0, 0, 1}
      });
  }

  public static Matrix S(float sx, float sy, float sz) {
    return new Matrix(new double[][]{
      {sx, 0, 0, 0},
      {0, sy, 0, 0},
      {0, 0, sz, 0},
      {0, 0, 0, 1}
      });
  }

  public static Matrix S(Vec v) {
    return new Matrix(new double[][]{
      {v.x, 0, 0, 0},
      {0, v.y, 0, 0},
      {0, 0, v.z, 0},
      {0, 0, 0, 1}
      });
  }

  public static Matrix Sxy(float s) {
    return new Matrix(new double[][]{
      {s, 0, 0, 0},
      {0, s, 0, 0},
      {0, 0, 1, 0},
      {0, 0, 0, 1}
      });
  }

  Vec apply(Vec v) {
    float[] v_ = new float[]{v.x, v.y, v.z, 1};
    float[] ret = new float[3];
    for (int i = 0; i < 3; i++)
      for (int k = 0; k < 4; k++)
        ret[i] += this.data[i][k] * v_[k];
    return new Vec(ret[0], ret[1], ret[2]);
  }

  void apply(Vec[] arr) {
    for (int i = 0; i < arr.length; i++)
      arr[i] = this.apply(arr[i]);
  }

  // create M-by-N matrix of 0's
  public Matrix(int M, int N) {
    this.M = M;
    this.N = N;
    data = new double[M][N];
  }

  // create matrix based on 2d array
  public Matrix(double[][] data) {
    M = data.length;
    N = data[0].length;
    this.data = new double[M][N];
    for (int i = 0; i < M; i++)
      for (int j = 0; j < N; j++)
        this.data[i][j] = data[i][j];
  }

  // copy constructor
  private Matrix(Matrix A) {
    this(A.data);
  }

  // create and return a random M-by-N matrix with values between 0 and 1
  public Matrix random(int M, int N) {
    Matrix A = new Matrix(M, N);
    for (int i = 0; i < M; i++)
      for (int j = 0; j < N; j++)
        A.data[i][j] = Math.random();
    return A;
  }

  // create and return the N-by-N identity matrix
  public static Matrix identity(int N) {
    Matrix I = new Matrix(N, N);
    for (int i = 0; i < N; i++)
      I.data[i][i] = 1;
    return I;
  }

  // create and return the N-by-N identity matrix
  public static Matrix zero(int N) {
    Matrix I = new Matrix(N, N);
    return I;
  }

  public static Matrix matrixlerp(Matrix A, Matrix B, float amt) {
    Matrix ret = new Matrix(4, 4);
    for (int i = 0; i < ret.data.length; i++)
      for (int j = 0; j < ret.data[i].length; j++)
        ret.data[i][j] = lerp((float)A.data[i][j], (float)B.data[i][j], amt);
    return ret;
  }

  public Matrix matrixlerp(Matrix B, float amt) {
    Matrix A = this;
    Matrix ret = new Matrix(4, 4);
    for (int i = 0; i < ret.data.length; i++)
      for (int j = 0; j < ret.data[i].length; j++)
        ret.data[i][j] = lerp((float)A.data[i][j], (float)B.data[i][j], amt);
    return ret;
  }

  Matrix copy() {
    return new Matrix(this.data);
  }

  // swap rows i and j
  private void swap(int i, int j) {
    double[] temp = data[i];
    data[i] = data[j];
    data[j] = temp;
  }

  // create and return the transpose of the invoking matrix
  public Matrix transpose() {
    Matrix A = new Matrix(N, M);
    for (int i = 0; i < M; i++)
      for (int j = 0; j < N; j++)
        A.data[j][i] = this.data[i][j];
    return A;
  }

  // return C = A + B
  public Matrix plus(Matrix B) {
    Matrix A = this;
    if (B.M != A.M || B.N != A.N) throw new RuntimeException("Illegal matrix dimensions.");
    Matrix C = new Matrix(M, N);
    for (int i = 0; i < M; i++)
      for (int j = 0; j < N; j++)
        C.data[i][j] = A.data[i][j] + B.data[i][j];
    return C;
  }

  // return C = A - B
  public Matrix minus(Matrix B) {
    Matrix A = this;
    if (B.M != A.M || B.N != A.N) throw new RuntimeException("Illegal matrix dimensions.");
    Matrix C = new Matrix(M, N);
    for (int i = 0; i < M; i++)
      for (int j = 0; j < N; j++)
        C.data[i][j] = A.data[i][j] - B.data[i][j];
    return C;
  }

  // does A = B exactly?
  public boolean eq(Matrix B) {
    Matrix A = this;
    if (B.M != A.M || B.N != A.N) throw new RuntimeException("Illegal matrix dimensions.");
    for (int i = 0; i < M; i++)
      for (int j = 0; j < N; j++)
        if (A.data[i][j] != B.data[i][j]) return false;
    return true;
  }

  // return C = A * B
  public Matrix times(Matrix B) {
    Matrix A = this;
    if (A.N != B.M) throw new RuntimeException("Illegal matrix dimensions.");
    Matrix C = new Matrix(A.M, B.N);
    for (int i = 0; i < C.M; i++)
      for (int j = 0; j < C.N; j++)
        for (int k = 0; k < A.N; k++)
          C.data[i][j] += (A.data[i][k] * B.data[k][j]);
    return C;
  }

  public Matrix scale(float m) {
    for (int i = 0; i < this.data.length; i++)
      for (int j = 0; j < this.data[i].length; j++)
        this.data[i][j] *= m;
    return this;
  }

  public static void multiply(Matrix A, Matrix B) {
    A.set(A.times(B));
  }

  public static void multiply_(Matrix A, Matrix B) {
    B.set(A.times(B));
  }


  public void set(Matrix A) {
    if (A.N != this.N || A.M != this.M) throw new RuntimeException("Illegal matrix dimensions.");
    for (int i = 0; i < this.data.length; i++)
      for (int j = 0; j < this.data[i].length; j++)
        this.data[i][j] = A.data[i][j];
  }

  public static Matrix mult(Matrix A, Matrix B) {
    return A.times(B);
  }

  public static Matrix mult(Matrix A, Matrix B, Matrix C) {
    return mult(A, B).times(C);
  }

  public static Matrix mult(Matrix A, Matrix B, Matrix C, Matrix D) {
    return mult(A, B, C).times(D);
  }

  public static Matrix mult(Matrix A, Matrix B, Matrix C, Matrix D, Matrix E) {
    return mult(A, B, C, D).times(E);
  }

  public static Matrix mult(Matrix A, Matrix B, Matrix C, Matrix D, Matrix E, Matrix F) {
    return mult(A, B, C, D, E).times(F);
  }

  public static Matrix mult(Matrix A, Matrix B, Matrix C, Matrix D, Matrix E, Matrix F, Matrix G) {
    return mult(A, B, C, D, E, F).times(G);
  }

  // return x = A^-1 b, assuming A is square and has full rank
  public Matrix solve(Matrix rhs) {
    if (M != N || rhs.M != N || rhs.N != 1)
      throw new RuntimeException("Illegal matrix dimensions.");

    // create copies of the data
    Matrix A = new Matrix(this);
    Matrix b = new Matrix(rhs);

    // Gaussian elimination with partial pivoting
    for (int i = 0; i < N; i++) {

      // find pivot row and swap
      int max = i;
      for (int j = i + 1; j < N; j++)
        if (Math.abs(A.data[j][i]) > Math.abs(A.data[max][i]))
          max = j;
      A.swap(i, max);
      b.swap(i, max);

      // singular
      if (A.data[i][i] == 0.0) throw new RuntimeException("Matrix is singular.");

      // pivot within b
      for (int j = i + 1; j < N; j++)
        b.data[j][0] -= b.data[i][0] * A.data[j][i] / A.data[i][i];

      // pivot within A
      for (int j = i + 1; j < N; j++) {
        double m = A.data[j][i] / A.data[i][i];
        for (int k = i+1; k < N; k++) {
          A.data[j][k] -= A.data[i][k] * m;
        }
        A.data[j][i] = 0.0;
      }
    }

    // back substitution
    Matrix x = new Matrix(N, 1);
    for (int j = N - 1; j >= 0; j--) {
      double t = 0.0;
      for (int k = j + 1; k < N; k++)
        t += A.data[j][k] * x.data[k][0];
      x.data[j][0] = (b.data[j][0] - t) / A.data[j][j];
    }
    return x;
  }

  // print matrix to standard output
  public void print() {
    for (int i = 0; i < M; i++) {
      for (int j = 0; j < N; j++)
        System.out.printf("%9.4f ", data[i][j]);
      println();
    }
  }

  private static double determinant(double[][] matrix) {
    if (matrix.length != matrix[0].length)
      throw new IllegalStateException("invalid dimensions");

    if (matrix.length == 2)
      return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0];

    double det = 0;
    for (int i = 0; i < matrix[0].length; i++)
      det += Math.pow(-1, i) * matrix[0][i]
        * determinant(submatrix(matrix, 0, i));
    return det;
  }

  private static Matrix inverse(Matrix in) {
    Matrix ret = new Matrix(inverse(in.data));
    return ret;
  }

  private static double[][] inverse(double[][] matrix) {
    double[][] inverse = new double[matrix.length][matrix.length];

    // minors and cofactors
    for (int i = 0; i < matrix.length; i++)
      for (int j = 0; j < matrix[i].length; j++)
        inverse[i][j] = Math.pow(-1, i + j)
          * determinant(submatrix(matrix, i, j));

    // adjugate and determinant
    double det = 1.0 / determinant(matrix);
    for (int i = 0; i < inverse.length; i++) {
      for (int j = 0; j <= i; j++) {
        double temp = inverse[i][j];
        inverse[i][j] = inverse[j][i] * det;
        inverse[j][i] = temp * det;
      }
    }

    return inverse;
  }

  private static double[][] submatrix(double[][] matrix, int row, int column) {
    double[][] submatrix = new double[matrix.length - 1][matrix.length - 1];

    for (int i = 0; i < matrix.length; i++)
      for (int j = 0; i != row && j < matrix[i].length; j++)
        if (j != column)
          submatrix[i < row ? i : i - 1][j < column ? j : j - 1] = matrix[i][j];
    return submatrix;
  }

  private static double[][] multiply(double[][] a, double[][] b) {
    if (a[0].length != b.length)
      throw new IllegalStateException("invalid dimensions");

    double[][] matrix = new double[a.length][b[0].length];
    for (int i = 0; i < a.length; i++) {
      for (int j = 0; j < b[0].length; j++) {
        double sum = 0;
        for (int k = 0; k < a[i].length; k++)
          sum += a[i][k] * b[k][j];
        matrix[i][j] = sum;
      }
    }

    return matrix;
  }

  private static double[][] rref(double[][] matrix) {
    double[][] rref = new double[matrix.length][];
    for (int i = 0; i < matrix.length; i++)
      rref[i] = Arrays.copyOf(matrix[i], matrix[i].length);

    int r = 0;
    for (int c = 0; c < rref[0].length && r < rref.length; c++) {
      int j = r;
      for (int i = r + 1; i < rref.length; i++)
        if (Math.abs(rref[i][c]) > Math.abs(rref[j][c]))
          j = i;
      if (Math.abs(rref[j][c]) < 0.00001)
        continue;

      double[] temp = rref[j];
      rref[j] = rref[r];
      rref[r] = temp;

      double s = 1.0 / rref[r][c];
      for (j = 0; j < rref[0].length; j++)
        rref[r][j] *= s;
      for (int i = 0; i < rref.length; i++) {
        if (i != r) {
          double t = rref[i][c];
          for (j = 0; j < rref[0].length; j++)
            rref[i][j] -= t * rref[r][j];
        }
      }
      r++;
    }

    return rref;
  }

  private static double[][] transpose(double[][] matrix) {
    double[][] transpose = new double[matrix[0].length][matrix.length];

    for (int i = 0; i < matrix.length; i++)
      for (int j = 0; j < matrix[i].length; j++)
        transpose[j][i] = matrix[i][j];
    return transpose;
  }
}
