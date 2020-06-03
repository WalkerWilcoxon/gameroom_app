//import 'package:gameroom_app/utils/imports.dart';
//
//class NotificationList extends ChangeNotifier {
//  List<Notification> _list = [];
//
//  int get length => _list.length;
//
//  Notification get last => _list.last;
//
//  void add(Notification notification) {
//    _list.add(notification);
//    notifyListeners();
//  }
//
//  void clear() {
//    _list.clear();
//    notifyListeners();
//  }
//
//  void removeLast() {
//    _list.removeLast();
//    notifyListeners();
//  }
//
//  void removeAt(int index) {
//    _list.removeAt(index);
//    notifyListeners();
//  }
//
//  operator[](int index) => _list[index];
//
//  operator[]=(int index, Notification notification) => _list[index] = notification;
//}