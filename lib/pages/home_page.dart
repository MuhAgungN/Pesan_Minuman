import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as myHttp;
import 'package:open_whatsapp/open_whatsapp.dart';
import '/models/menu_model.dart';
import '/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:open_whatsapp/open_whatsapp.dart';
import '/auth.dart';

class HomePage extends StatelessWidget {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final String urlMenu =
      "https://script.google.com/macros/s/AKfycbxhBtCfuMGjriZSjtVUQZ8Z9wrUHKMjQFpvZwE4_q5Jrkr7BkizXUvxMkgd7P1WEyiR5Q/exec";

  late List carts;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => CartProvider())],
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.green),
        home: Scaffold(
          appBar: AppBar(
            title: _title(),
            actions: [
              _signOutButton(), // Menempatkan tombol sign out di sebelah kanan AppBar
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              openDialog(context);
            },
            child: Icon(Icons.shopping_bag),
          ),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FutureBuilder<List<MenuModel>>(
                    future: getAllData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              MenuModel menu = snapshot.data![index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(menu.gambar),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            menu.nama,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            menu.deskripsi,
                                            textAlign: TextAlign.left,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 13),
                                          ),
                                          SizedBox(height: 30),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Rp " + menu.harga.toString(),
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      Provider.of<CartProvider>(
                                                        context,
                                                        listen: false,
                                                      ).addRemove(
                                                          menu.nama,
                                                          menu.harga,
                                                          menu.id,
                                                          false);

                                                      carts = Provider.of<
                                                          CartProvider>(
                                                        context,
                                                        listen: false,
                                                      ).cart;
                                                    },
                                                    icon: Icon(
                                                      Icons.remove_circle,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Consumer<CartProvider>(
                                                    builder:
                                                        (context, value, _) {
                                                      var id =
                                                          value.cart.indexWhere(
                                                        (element) =>
                                                            element.menuId ==
                                                            snapshot
                                                                .data![index]
                                                                .id,
                                                      );
                                                      return Text(
                                                        (id == -1)
                                                            ? "0"
                                                            : value.cart[id]
                                                                .quantity
                                                                .toString(),
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                fontSize: 15),
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(width: 10),
                                                  IconButton(
                                                    onPressed: () {
                                                      Provider.of<CartProvider>(
                                                        context,
                                                        listen: false,
                                                      ).addRemove(
                                                          menu.nama,
                                                          menu.harga,
                                                          menu.id,
                                                          true);

                                                      carts = Provider.of<
                                                          CartProvider>(
                                                        context,
                                                        listen: false,
                                                      ).cart;
                                                    },
                                                    icon: Icon(
                                                      Icons.add_circle,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(
                            child: Text("Tidak ada data"),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _title() {
    String? email = _userUid1();
    return Text('Hallo ${email ?? "User email"}');
  }

  String? _userUid1() {
    final User? user = Auth().currentUser;
    String? userEmail = user?.email;
    if (userEmail != null && userEmail.contains('@')) {
      return userEmail.split('@').first;
    }
    return userEmail;
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text("Sign Out"),
    );
  }

  Future<List<MenuModel>> getAllData() async {
    List<MenuModel> listMenu = [];
    var response = await myHttp.get(Uri.parse(urlMenu));
    List data = json.decode(response.body);

    data.forEach((element) {
      listMenu.add(MenuModel.fromJson(element));
    });

    return listMenu;
  }

  openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text(
                    "Nama",
                    style: GoogleFonts.montserrat(),
                  ),
                  TextFormField(
                    controller: namaController,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Alamat",
                    style: GoogleFonts.montserrat(),
                  ),
                  TextFormField(
                    controller: alamatController,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: ElevatedButton(
                      onPressed: () {
                        String strPesanan = "";
                        carts.forEach((element) {
                          strPesanan = strPesanan +
                              "\n" +
                              element.nama +
                              " (" +
                              element.harga.toString() +
                              ")" +
                              " x " +
                              element.quantity.toString();
                        });

                        String pesanan = "Nama: " +
                            namaController.text +
                            "\n" +
                            "Alamat: " +
                            alamatController.text +
                            "\n" +
                            "Pesanan: " +
                            strPesanan;
                        FlutterOpenWhatsapp.sendSingleMessage(
                            "6282242277559", pesanan);
                        print(pesanan);
                      },
                      child: Text("Submit Pesanan"),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }
}
