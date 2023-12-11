import 'package:flutter/material.dart';
import 'package:kasir_makanan/models/cart_model.dart';

class CartProvider with ChangeNotifier {
  List<CartModel> _cart = [];
  // List<CartModel> get cart => _cart;
  int _total = 0;
  int get total => total;

  void addRemove(String nama, int harga, int menuId, bool isAdd) {
    if (_cart.where((element) => menuId == element.menuId).isNotEmpty) {
      var index = _cart.indexWhere((element) => element.menuId == menuId);
      _cart[index].quantity = (isAdd)
          ? _cart[index].quantity + 1
          : (_cart[index].quantity > 0)
              ? _cart[index].quantity - 1
              : 0;
      _total = (isAdd)
          ? _total + 1
          : (_total > 0)
              ? _total - 1
              : 0;
    } else {
      _cart.add(
          CartModel(nama: nama, harga: harga, menuId: menuId, quantity: 1));
    }
    print('JUMLAH: ' + _cart.length.toString());
    notifyListeners();
  }

  get cart {
    return _cart;
  }

  void getCart() {
    print("hhh");
  }
}
