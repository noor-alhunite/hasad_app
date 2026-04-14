/// يربط الشاشات الفرعية بشريط التنقل السفلي في [FarmerMainScreen] / التاجر / المصنع.
class ShellTabBridge {
  void Function(int index)? _handler;

  void bind(void Function(int index) handler) {
    _handler = handler;
  }

  void unbind() {
    _handler = null;
  }

  void goToTab(int index) {
    _handler?.call(index);
  }
}
