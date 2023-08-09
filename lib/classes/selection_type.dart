class SelectionType {
  static const int add = 1;
  static const int selected = 2;
  static const int editing = 4;
  static const int deleting = 8;
  static const int disabled = 16;
  static const int all = 1 + 2 + 4 + 8 + 16;
}
