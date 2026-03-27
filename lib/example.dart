// Correct way to extend a class
class ParentClass {
  void doSomething() {
    // Parent class implementation
  }
}

class ChildClass extends ParentClass {
  @override
  void doSomething() {
    // Child class implementation
    super.doSomething();
  }
}

// Examples of what NOT to do:
// class WrongClass extends String {} // Error: Can't extend String
// class AnotherWrongClass extends int {} // Error: Can't extend int
// class YetAnotherWrongClass extends List {} // Error: Can't extend List directly

// Instead, if you need String-like functionality, use composition:
class StringWrapper {
  final String value;

  StringWrapper(this.value);

  @override
  String toString() => value;
}
