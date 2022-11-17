import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_dose/Utility/colors..dart';
import 'package:food_dose/view/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:food_dose/view/login_page.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

import '../Utility/AppUrl.dart';
import '../widget/buttom-navigation.dart';
import 'facvourite.dart';

class SingleFoods extends StatefulWidget {
  final String id;
  const SingleFoods({Key? key, required this.id}) : super(key: key);

  @override
  State<SingleFoods> createState() => _SingleFoodsState();
}

class _SingleFoodsState extends State<SingleFoods> {
  var count = 1;
  Future get_food() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'authorization': "Bearer $token"
    };

    var response = await http.get(Uri.parse(AppUrl.single_foods + widget.id),
        headers: requestHeaders);
    if (response.statusCode == 200) {
      print('Get post collected' + response.body);
      var userData1 = jsonDecode(response.body)['food'];

      return userData1;
    } else {
      print("post have no Data${response.body}");
      var userData1 = jsonDecode(response.body)['food'];
      return userData1;
    }
  }

  late DocumentSnapshot get_information;
  Future? banner, foods;
  var email;
  var base_price = 0;
  get_user_data() async {
    SharedPreferences localStore = await SharedPreferences.getInstance();
    setState(() {
      email = localStore.getString('email');
    });
  }

  Future urlToFile(String imageUrl, Map<String, dynamic> user_data,
      String shope_name) async {
    _addPathToDatabase(imageUrl, user_data, shope_name);
  }

  // Future<void> _uploadImageToFirebase(String image, Map<String,dynamic> info) async {
  //   try {
  //     // Make random image name.
  //
  //     String imageLocation =
  //         'images/image${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
  //
  //     // Upload image to firebase.
  //     FirebaseStorage storage = FirebaseStorage.instance;
  //     final Reference ref = storage.ref().child(imageLocation);
  //     final UploadTask uploadTask = ref.putFile(image);
  //     await uploadTask
  //         .whenComplete(() => _addPathToDatabase(imageLocation, info));
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  bool add = false;
  bool add_favourites = false;
  Future<void> _addPathToDatabase(
      String text, Map<String, dynamic> info, String shope_name) async {
    try {
      // Get image URL from firebase
      FirebaseStorage storage = FirebaseStorage.instance;

      Map<String, dynamic> iamge = {'url': text};
      Map<String, dynamic> thirdMap = {}
        ..addAll(info)
        ..addAll(iamge);

      FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('cart')
          .add(thirdMap)
          .whenComplete(() {
        setState(() {
          add = false;
        });

        Dialogs.bottomMaterialDialog(
          msg: 'Your product has been added to your carts',
          title: 'Congratulations',
          color: Colors.white,
          lottieBuilder: Lottie.asset(
            'assets/images/congrats.json',
            fit: BoxFit.contain,
          ),
          context: context,
          actions: [
            IconsButton(
              onPressed: () {
                Get.to(() => AppBottomNavigation(
                      index: 1,
                    ));
              },
              text: 'View Cart',
              iconData: Icons.add_shopping_cart,
              color: appColors.rating_back,
              textStyle: TextStyle(color: Colors.white),
              iconColor: Colors.white,
            ),
          ],
        );
      });

      // Add location and url to database
      // await FirebaseFirestore.instance.collection('Prescriptions').doc().set({
      //   'url': imageString,
      //   'location': text,
      //   'Patient_phone': phone,
      //   'created_at': FieldValue.serverTimestamp(),
      // });
    } catch (e) {
      print(e);
    }
  }

  Future add_favourite(
    String text,
    Map<String, dynamic> info,
  ) async {
    try {
      // Get image URL from firebase
      FirebaseStorage storage = FirebaseStorage.instance;

      Map<String, dynamic> iamge = {'url': text};
      Map<String, dynamic> thirdMap = {}
        ..addAll(info)
        ..addAll(iamge);

      FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('favourites')
          .add(thirdMap)
          .whenComplete(() {
        setState(() {
          add_favourites = false;
        });
        Dialogs.bottomMaterialDialog(
          msg: 'Your product has been added to favourites',
          title: 'Congratulations',
          color: Colors.white,
          lottieBuilder: Lottie.asset(
            'assets/images/heart.json',
            fit: BoxFit.contain,
          ),
          context: context,
          actions: [
            IconsButton(
              onPressed: () {
                Get.to(() => favourites());
              },
              text: 'View Favourites',
              iconData: Icons.add_shopping_cart,
              color: appColors.rating_back,
              textStyle: TextStyle(color: Colors.white),
              iconColor: Colors.white,
            ),
          ],
        );
      });

      // Add location and url to database
      // await FirebaseFirestore.instance.collection('Prescriptions').doc().set({
      //   'url': imageString,
      //   'location': text,
      //   'Patient_phone': phone,
      //   'created_at': FieldValue.serverTimestamp(),
      // });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    foods = get_food();
    print(widget.id);
    get();
    get_user_data();
  }

  List restu = [];
  get() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(email)
        .collection('cart')
        .get()
        .then((value) {
      print(value);

      for (int i = 0; i < value.docs.length; i++) {
        // restu.add(value.docs[i]['shop_name']);
        print(value.docs[i]['shop_name']);
      }
      print("testtttt" + value.docs.length.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
          backgroundColor: Color(0xFF363707),
          body: ListView(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(email)
                      .collection('cart')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      var data = snapshot.data;

                      return Container(
                          child: FutureBuilder(
                              future: foods,
                              builder: (_, AsyncSnapshot snapshot) {
                                print(snapshot.data);
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              15,
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey.withOpacity(.3),
                                        highlightColor:
                                            Colors.grey.withOpacity(.1),
                                        child: ListView.builder(
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                          itemBuilder: (_, __) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  width: 48.0,
                                                  height: 48.0,
                                                  color: Colors.white,
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Container(
                                                        width: double.infinity,
                                                        height: 8.0,
                                                        color: Colors.white,
                                                      ),
                                                      const Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 2.0),
                                                      ),
                                                      Container(
                                                        width: double.infinity,
                                                        height: 8.0,
                                                        color: Colors.white,
                                                      ),
                                                      const Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 2.0),
                                                      ),
                                                      Container(
                                                        width: 40.0,
                                                        height: 8.0,
                                                        color: Colors.white,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          itemCount: 6,
                                        ),
                                      ),
                                    );
                                  default:
                                    if (snapshot.hasError) {
                                      Text('Error: ${snapshot.error}');
                                    } else {
                                      return snapshot.hasData
                                          ? snapshot.data.length > 0
                                              ? Column(
                                                  children: [
                                                    Container(
                                                      height: height / 2,
                                                      child: Stack(
                                                        children: [
                                                          Positioned(
                                                            top: 0,
                                                            left: 0,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(20),
                                                              child: Container(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    InkWell(
                                                                      onTap: () =>
                                                                          Get.back(),
                                                                      child: Container(
                                                                          width: 30,
                                                                          height: 30,
                                                                          padding: EdgeInsets.only(left: 7),
                                                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                                                                          child: Center(
                                                                            child:
                                                                                Icon(
                                                                              Icons.arrow_back_ios,
                                                                              color: Colors.black,
                                                                              size: 20,
                                                                            ),
                                                                          )),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            right: 0,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(20),
                                                              child: Container(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    StreamBuilder<
                                                                            QuerySnapshot>(
                                                                        stream: FirebaseFirestore
                                                                            .instance
                                                                            .collection(
                                                                                "users")
                                                                            .doc(
                                                                                email)
                                                                            .collection(
                                                                                'cart')
                                                                            .snapshots(),
                                                                        builder:
                                                                            (context,
                                                                                snapshot) {
                                                                          if (snapshot.data !=
                                                                              null) {
                                                                            return Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: InkWell(
                                                                                  onTap: () {
                                                                                    Get.to(() => Cart());
                                                                                  },
                                                                                  child: Badge(
                                                                                    badgeContent: Text(snapshot.data!.docs.length.toString()),
                                                                                    child: Container(
                                                                                        width: 30,
                                                                                        height: 30,
                                                                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                                                                                        child: Center(
                                                                                          child: Icon(
                                                                                            Icons.shopping_cart,
                                                                                            color: appColors.blactText,
                                                                                            size: 20,
                                                                                          ),
                                                                                        )),
                                                                                  ),
                                                                                ));
                                                                          }
                                                                          if (snapshot.connectionState ==
                                                                              ConnectionState.none) {
                                                                            return Center(child: Text('No Data'));
                                                                          }
                                                                          return CircularProgressIndicator();
                                                                        })
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: width,
                                                            height:
                                                                height / 2.6,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 50),
                                                            decoration:
                                                                BoxDecoration(),
                                                            child:
                                                                Image.network(
                                                              AppUrl.picurl +
                                                                  snapshot.data[
                                                                      'image'],
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                          Positioned(
                                                            bottom: 10,
                                                            right: 20,
                                                            child: Row(
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    count > 1
                                                                        ? setState(
                                                                            () {
                                                                            count =
                                                                                count - 1;
                                                                          })
                                                                        : null;
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 30,
                                                                    height: 30,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              100),
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .remove,
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  count
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        15.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      count =
                                                                          count +
                                                                              1;
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 30,
                                                                    height: 30,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              100),
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    child: Icon(
                                                                      Icons.add,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      height: height / 2,
                                                      width: width,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    20),
                                                            topLeft:
                                                                Radius.circular(
                                                                    20),
                                                          )),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        snapshot
                                                                            .data['itemName'],
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .w600,
                                                                            fontSize: 12
                                                                                .sp,
                                                                            fontFamily:
                                                                                "ThemeFonts",
                                                                            color:
                                                                                appColors.blactText),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        snapshot
                                                                            .data['categoryName'],
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .w300,
                                                                            fontSize: 10
                                                                                .sp,
                                                                            fontFamily:
                                                                                "ThemeFonts",
                                                                            color:
                                                                                appColors.blactText),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    width: 50,
                                                                    height: 50,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                5),
                                                                        border: Border.all(
                                                                            width:
                                                                                3,
                                                                            color:
                                                                                Colors.grey.shade200)),
                                                                    child: Icon(
                                                                      Icons
                                                                          .star,
                                                                      color: Colors
                                                                          .amber,
                                                                      size: 30,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 20,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  int.parse(snapshot
                                                                              .data['discountPrice']
                                                                              .toString()) >
                                                                          0
                                                                      ? Text(
                                                                          "\$" +
                                                                              snapshot.data['withOutDiscountPrice'].toString(),
                                                                          style: TextStyle(
                                                                              decoration: TextDecoration.lineThrough,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 15.sp,
                                                                              fontFamily: "ThemeFonts",
                                                                              color: appColors.blactText),
                                                                        )
                                                                      : Container(),
                                                                  int.parse(snapshot
                                                                              .data['discountPrice']
                                                                              .toString()) >
                                                                          0
                                                                      ? SizedBox(
                                                                          width:
                                                                              10,
                                                                        )
                                                                      : Container(),
                                                                  Text(
                                                                    "\$" +
                                                                        snapshot
                                                                            .data['price']
                                                                            .toString(),
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize: 15
                                                                            .sp,
                                                                        fontFamily:
                                                                            "ThemeFonts",
                                                                        color: appColors
                                                                            .blactText),
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Text(
                                                                "Details",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        10.sp,
                                                                    fontFamily:
                                                                        "ThemeFonts",
                                                                    color: appColors
                                                                        .blactText),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              SizedBox(
                                                                width: width,
                                                                child: Text(
                                                                  snapshot.data[
                                                                      'longDescription'],
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                      fontSize:
                                                                          10.sp,
                                                                      fontFamily:
                                                                          "ThemeFonts",
                                                                      color: appColors
                                                                          .blactText),
                                                                ),
                                                              ),
                                                              add == false
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                              .all(
                                                                          20.0),
                                                                      child:
                                                                          Bounce(
                                                                        duration:
                                                                            Duration(milliseconds: 80),
                                                                        onPressed:
                                                                            () async {
                                                                          print(snapshot.data);

                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection("users")
                                                                              .doc(email)
                                                                              .collection('in_queue')
                                                                              .get()
                                                                              .then((value) {
                                                                            print(value.docs.length);
                                                                            if (value.docs.length >
                                                                                0) {
                                                                              if (value.docs[0]['shope_name'] == snapshot.data['shopName']) {
                                                                                Map<String, dynamic> user_data = {
                                                                                  'quantity': count,
                                                                                  'product_name': snapshot.data['itemName'],
                                                                                  'product_category': snapshot.data['categoryName'],
                                                                                  'price': snapshot.data['price'] * count,
                                                                                  'status': 0,
                                                                                  'base_price': snapshot.data['price'],
                                                                                  'shope_name': snapshot.data['shopName'],
                                                                                  'lat':snapshot.data['user']['location']['coordinates'][0],
                                                                                  'lon':snapshot.data['user']['location']['coordinates'][1]
                                                                                };
                                                                                FirebaseFirestore.instance.collection("users").doc(email).collection('in_queue').get().then((value) {
                                                                                  if (value.docs.isEmpty) {
                                                                                    FirebaseFirestore.instance.collection("users").doc(email).collection('in_queue').add({
                                                                                      'shope_name': snapshot.data['shopName']
                                                                                    });
                                                                                  } else {
                                                                                    FirebaseFirestore.instance.collection("users").doc(email).collection('in_queue').where("shope_name", isEqualTo: snapshot.data['shopName']).get().then((value) {
                                                                                      value.docs.forEach((element) {
                                                                                        FirebaseFirestore.instance.collection("users").doc(email).collection('in_queue').doc(element.id).update({
                                                                                          'shope_name': snapshot.data['shopName']
                                                                                        });
                                                                                      });
                                                                                    });
                                                                                  }
                                                                                });
                                                                                FirebaseFirestore.instance.collection("users").doc(email).collection('cart').where("product_category", isEqualTo: snapshot.data['categoryName']).get().then((value) async {
                                                                                  if (value.docs.isEmpty) {
                                                                                    setState(() {
                                                                                      add = true;
                                                                                    });
                                                                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                                                                    var token = pref.getString('token');
                                                                                    token != null ? urlToFile(AppUrl.picurl + snapshot.data['image'], user_data, snapshot.data['shopName']) : Get.to(() => LoginPages());
                                                                                  } else {
                                                                                    print('esxits');
                                                                                    Map<String, dynamic> user_data = {
                                                                                      'quantity': count,
                                                                                      'product_name': snapshot.data['itemName'],
                                                                                      'product_category': snapshot.data['categoryName'],
                                                                                      'price': snapshot.data['price'] * count,
                                                                                      'status': 0,
                                                                                      'base_price': snapshot.data['price'],
                                                                                      'shope_name': snapshot.data['shopName'],
                                                                                      'lat':snapshot.data['user']['location']['coordinates'][0],
                                                                                      'lon':snapshot.data['user']['location']['coordinates'][1]
                                                                                    };

                                                                                    try {
                                                                                      // Get image URL from firebase
                                                                                      FirebaseStorage storage = FirebaseStorage.instance;

                                                                                      Map<String, dynamic> iamge = {
                                                                                        'url': AppUrl.picurl + snapshot.data['image']
                                                                                      };
                                                                                      Map<String, dynamic> thirdMap = {}
                                                                                        ..addAll(user_data)
                                                                                        ..addAll(iamge);
                                                                                      var ref = FirebaseFirestore.instance.collection('users').doc(email).collection('cart').where('product_category', isEqualTo: snapshot.data['categoryName']).get().then((value) {
                                                                                        value.docs.forEach((element) {
                                                                                          print(element.id);
                                                                                          FirebaseFirestore.instance.collection('users').doc(email).collection('cart').doc(element.id).update(thirdMap).whenComplete(() {
                                                                                            setState(() {
                                                                                              add = false;
                                                                                            });
                                                                                            Dialogs.bottomMaterialDialog(
                                                                                              msg: 'Your product has been added to your carts',
                                                                                              title: 'Congratulations',
                                                                                              color: Colors.white,
                                                                                              lottieBuilder: Lottie.asset(
                                                                                                'assets/images/congrats.json',
                                                                                                fit: BoxFit.contain,
                                                                                              ),
                                                                                              context: context,
                                                                                              actions: [
                                                                                                IconsButton(
                                                                                                  onPressed: () {
                                                                                                    Get.to(() => AppBottomNavigation(
                                                                                                          index: 1,
                                                                                                        ));
                                                                                                  },
                                                                                                  text: 'View Cart',
                                                                                                  iconData: Icons.add_shopping_cart,
                                                                                                  color: appColors.rating_back,
                                                                                                  textStyle: TextStyle(color: Colors.white),
                                                                                                  iconColor: Colors.white,
                                                                                                ),
                                                                                              ],
                                                                                            );
                                                                                          });
                                                                                        });
                                                                                      });
                                                                                      print(ref.toString());

                                                                                      // Add location and url to database
                                                                                      // await FirebaseFirestore.instance.collection('Prescriptions').doc().set({
                                                                                      //   'url': imageString,
                                                                                      //   'location': text,
                                                                                      //   'Patient_phone': phone,
                                                                                      //   'created_at': FieldValue.serverTimestamp(),
                                                                                      // });
                                                                                    } catch (e) {
                                                                                      print(e);
                                                                                    }
                                                                                  }
                                                                                });
                                                                              } else {
                                                                                Dialogs.bottomMaterialDialog(
                                                                                  msg: 'Please empty cart before ordering from different resturent',
                                                                                  title: 'Oops',
                                                                                  color: Colors.white,
                                                                                  lottieBuilder: Lottie.asset(
                                                                                    'assets/images/remove_cart.json',
                                                                                    fit: BoxFit.contain,
                                                                                  ),
                                                                                  context: context,
                                                                                  actions: [
                                                                                    IconsButton(
                                                                                      onPressed: () {
                                                                                        FirebaseFirestore.instance.collection('users').doc(email).collection('cart').get().then((value) {
                                                                                          for (DocumentSnapshot ds in value.docs) {
                                                                                            ds.reference.delete();
                                                                                          }
                                                                                        });
                                                                                        FirebaseFirestore.instance.collection('users').doc(email).collection('in_queue').get().then((value) {
                                                                                          for (DocumentSnapshot ds in value.docs) {
                                                                                            ds.reference.delete();
                                                                                          }
                                                                                        });
                                                                                        Get.back();
                                                                                      },
                                                                                      text: 'Empty Cart Now',
                                                                                      iconData: Icons.add_shopping_cart,
                                                                                      color: appColors.rating_back,
                                                                                      textStyle: TextStyle(color: Colors.white),
                                                                                      iconColor: Colors.white,
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              }
                                                                            } else {
                                                                              Map<String, dynamic> user_data = {
                                                                                'quantity': count,
                                                                                'product_name': snapshot.data['itemName'],
                                                                                'product_category': snapshot.data['categoryName'],
                                                                                'price': snapshot.data['price'] * count,
                                                                                'status': 0,
                                                                                'base_price': snapshot.data['price'],
                                                                                'shope_name': snapshot.data['shopName'],
                                                                                'items':snapshot.data
                                                                              };
                                                                              FirebaseFirestore.instance.collection("users").doc(email).collection('cart').where("product_category", isEqualTo: snapshot.data['categoryName']).get().then((value) async {
                                                                                if (value.docs.isEmpty) {
                                                                                  setState(() {
                                                                                    add = true;
                                                                                  });
                                                                                  SharedPreferences pref = await SharedPreferences.getInstance();
                                                                                  var token = pref.getString('token');
                                                                                  FirebaseFirestore.instance.collection("users").doc(email).collection('in_queue').get().then((value) {
                                                                                    if (value.docs.isEmpty) {
                                                                                      FirebaseFirestore.instance.collection("users").doc(email).collection('in_queue').add({
                                                                                        'shope_name': snapshot.data['shopName']
                                                                                      });
                                                                                    } else {
                                                                                      FirebaseFirestore.instance.collection("users").doc(email).collection('in_queue').where("shope_name", isEqualTo: snapshot.data['shopName']).get().then((value) {
                                                                                        value.docs.forEach((element) {
                                                                                          FirebaseFirestore.instance.collection("users").doc(email).collection('in_queue').doc(element.id).update({
                                                                                            'shope_name': snapshot.data['shopName']
                                                                                          });
                                                                                        });
                                                                                      });
                                                                                    }
                                                                                  });
                                                                                  token != null ? urlToFile(AppUrl.picurl + snapshot.data['image'], user_data, snapshot.data['shopName']) : Get.to(() => LoginPages());
                                                                                } else {
                                                                                  print('esxits');
                                                                                  Map<String, dynamic> user_data = {
                                                                                    'quantity': count,
                                                                                    'product_name': snapshot.data['itemName'],
                                                                                    'product_category': snapshot.data['categoryName'],
                                                                                    'price': snapshot.data['price'] * count,
                                                                                    'status': 0,
                                                                                    'base_price': snapshot.data['price'],
                                                                                    'shope_name': snapshot.data['shopName'],
                                                                                    'items':snapshot.data

                                                                                  };

                                                                                  try {
                                                                                    // Get image URL from firebase
                                                                                    FirebaseStorage storage = FirebaseStorage.instance;

                                                                                    Map<String, dynamic> iamge = {
                                                                                      'url': AppUrl.picurl + snapshot.data['image']
                                                                                    };
                                                                                    Map<String, dynamic> thirdMap = {}
                                                                                      ..addAll(user_data)
                                                                                      ..addAll(iamge);
                                                                                    FirebaseFirestore.instance.collection("users").doc(email).collection('in_queue').get().then((value) {
                                                                                      if (value.docs.isEmpty) {
                                                                                        FirebaseFirestore.instance.collection("users").doc(email).collection('in_queue').add({
                                                                                          'shope_name': snapshot.data['shopName']
                                                                                        });
                                                                                      } else {
                                                                                        FirebaseFirestore.instance.collection("users").doc(email).collection('in_queue').where("shope_name", isEqualTo: snapshot.data['shopName']).get().then((value) {
                                                                                          value.docs.forEach((element) {
                                                                                            FirebaseFirestore.instance.collection("users").doc(email).collection('in_queue').doc(element.id).update({
                                                                                              'shope_name': snapshot.data['shopName']
                                                                                            });
                                                                                          });
                                                                                        });
                                                                                      }
                                                                                    });
                                                                                    var ref = FirebaseFirestore.instance.collection('users').doc(email).collection('cart').where('product_category', isEqualTo: snapshot.data['categoryName']).get().then((value) {
                                                                                      value.docs.forEach((element) {
                                                                                        print(element.id);
                                                                                        FirebaseFirestore.instance.collection('users').doc(email).collection('cart').doc(element.id).update(thirdMap).whenComplete(() {
                                                                                          setState(() {
                                                                                            add = false;
                                                                                          });
                                                                                          Dialogs.bottomMaterialDialog(
                                                                                            msg: 'Your product has been added to your carts',
                                                                                            title: 'Congratulations',
                                                                                            color: Colors.white,
                                                                                            lottieBuilder: Lottie.asset(
                                                                                              'assets/images/congrats.json',
                                                                                              fit: BoxFit.contain,
                                                                                            ),
                                                                                            context: context,
                                                                                            actions: [
                                                                                              IconsButton(
                                                                                                onPressed: () {
                                                                                                  Get.to(() => AppBottomNavigation(
                                                                                                        index: 1,
                                                                                                      ));
                                                                                                },
                                                                                                text: 'View Cart',
                                                                                                iconData: Icons.add_shopping_cart,
                                                                                                color: appColors.rating_back,
                                                                                                textStyle: TextStyle(color: Colors.white),
                                                                                                iconColor: Colors.white,
                                                                                              ),
                                                                                            ],
                                                                                          );
                                                                                        });
                                                                                      });
                                                                                    });
                                                                                    print(ref.toString());

                                                                                    // Add location and url to database
                                                                                    // await FirebaseFirestore.instance.collection('Prescriptions').doc().set({
                                                                                    //   'url': imageString,
                                                                                    //   'location': text,
                                                                                    //   'Patient_phone': phone,
                                                                                    //   'created_at': FieldValue.serverTimestamp(),
                                                                                    // });
                                                                                  } catch (e) {
                                                                                    print(e);
                                                                                  }
                                                                                }
                                                                              });
                                                                            }
                                                                          });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          padding: EdgeInsets.only(
                                                                              top: 15,
                                                                              bottom: 15),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                            color:
                                                                                appColors.mainColor,
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              "Add To Cart",
                                                                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          SpinKitThreeBounce(
                                                                        color: appColors
                                                                            .mainColor,
                                                                        size:
                                                                            25,
                                                                      ),
                                                                    ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        20.0),
                                                                child: Bounce(
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          80),
                                                                  onPressed:
                                                                      () async {
                                                                    Map<String,
                                                                            dynamic>
                                                                        user_data =
                                                                        {
                                                                      'quantity':
                                                                          count,
                                                                      'product_name':
                                                                          snapshot
                                                                              .data['itemName'],
                                                                      'product_category':
                                                                          snapshot
                                                                              .data['categoryName'],
                                                                      'price': snapshot
                                                                              .data['price'] *
                                                                          count,
                                                                      'status':
                                                                          0,
                                                                      'base_price':
                                                                          snapshot
                                                                              .data['price']
                                                                    };
                                                                    // SharedPreferences localStore = await SharedPreferences.getInstance();
                                                                    // var email=localStore.getString('email');

                                                                    // FirebaseFirestore.instance.collection('users').doc(email).collection('cart').add(
                                                                    //     {
                                                                    //       'quantity':count,
                                                                    //       'product_name':snapshot.data['itemName'],
                                                                    //       'product_category':snapshot.data['categoryName'],
                                                                    //       'price':snapshot.data['price']*count,
                                                                    //       'status':0
                                                                    //     });

                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "users")
                                                                        .doc(
                                                                            email)
                                                                        .collection(
                                                                            'favourites')
                                                                        .where(
                                                                            "product_category",
                                                                            isEqualTo: snapshot.data[
                                                                                'categoryName'])
                                                                        .get()
                                                                        .then(
                                                                            (value) async {
                                                                      if (value
                                                                          .docs
                                                                          .isEmpty) {
                                                                        setState(
                                                                            () {
                                                                          add_favourites =
                                                                              true;
                                                                        });
                                                                        SharedPreferences
                                                                            pref =
                                                                            await SharedPreferences.getInstance();
                                                                        var token =
                                                                            pref.getString('token');
                                                                        token !=
                                                                                null
                                                                            ? add_favourite(AppUrl.picurl + snapshot.data['image'],
                                                                                user_data)
                                                                            : Get.to(() => LoginPages());
                                                                      } else {
                                                                        print(
                                                                            'esxits');
                                                                        Fluttertoast.showToast(
                                                                            msg:
                                                                                "Already in your favourites",
                                                                            toastLength: Toast
                                                                                .LENGTH_SHORT,
                                                                            gravity: ToastGravity
                                                                                .CENTER,
                                                                            timeInSecForIosWeb:
                                                                                1,
                                                                            backgroundColor:
                                                                                Colors.black,
                                                                            textColor: Colors.white,
                                                                            fontSize: 16.0);
                                                                      }
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding: EdgeInsets.only(
                                                                        top: 15,
                                                                        bottom:
                                                                            15),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                10),
                                                                        color: Colors
                                                                            .white,
                                                                        border: Border.all(
                                                                            color:
                                                                                appColors.mainColor)),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        "Add To Favourite",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12.sp,
                                                                            fontWeight: FontWeight.bold,
                                                                            color: appColors.mainColor),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Center(
                                                  child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height: height / 10,
                                                    ),
                                                    Text('No Post Yet!!')
                                                  ],
                                                ))
                                          : Text('No data');
                                    }
                                }
                                return CircularProgressIndicator();
                              }));
                    }
                    if (snapshot.connectionState == ConnectionState.none) {
                      return Center(child: Text('No Data'));
                    }
                    return Center(child: CircularProgressIndicator());
                  })
            ],
          )),
    );
  }
}
