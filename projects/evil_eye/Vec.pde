public static class Vec extends PVector {
  Vec(float x, float y, float z) {
    super(x, y, z);
  }

  Vec(int x, int y, float z) {
    super(x, y, z);
  }

  Vec(int x, int y, int z) {
    super(x, y, z);
  }

  Vec(int x, int y) {
    super(x, y);
  }

  Vec(float x, int y) {
    super(x, y);
  }

  Vec(int x, float y) {
    super(x, y);
  }

  Vec(float x, float y) {
    super(x, y);
  }

  Vec() {
    super();
  }

  Vec(PVector v) {
    super(v.x, v.y, v.z);
  }

  @Override
    public Vec rotate(float angle) {
    super.rotate(angle);
    return this;
  }

  @Override
    public Vec mult(float scale) {
    super.mult(scale);
    return this;
  }

  @Override
    public Vec copy() {
    return new Vec(this.x, this.y, this.z);
  }

  @Override
    public Vec normalize() {
    super.normalize();
    return this;
  }

  public static Vec lerp(Vec from, Vec to, float q) {
    return (Vec) PVector.lerp(from, to, q);
  }

  public static float dist(Vec from, Vec to) {
    return PVector.dist(from, to);
  }

  public Vec add(Vec other) {
    super.add(other);
    return this;
  }

  public Vec sub(Vec other) {
    super.sub(other);
    return this;
  }

  public Vec cross(Vec other) {
    PVector ret = super.cross(other);
    return new Vec(ret);
  }

  public float dot(Vec other) {
    return this.x*other.x+this.y*other.y+this.z*other.z;
  }

  void multiply(Matrix mat) {
    Vec vec = mat.apply(this);
    this.x = vec.x;
    this.y = vec.y;
    this.z = vec.z;
  }

  Vec multiply_ret(Matrix mat) {
    this.multiply(mat);
    return this;
  }

  public void set(Vec other) {
    this.x = other.x;
    this.y = other.y;
    this.z = other.z;
  }
}

void println(Vec v) {
  println(v.x, v.y, v.z);
}
