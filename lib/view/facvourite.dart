import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_dose/Utility/colors..dart';
import 'package:food_dose/view/address_list.dart';
import 'package:food_dose/view/home-screen.dart';
import 'package:food_dose/view/order-success.dart';
import 'package:food_dose/view/profile_screen.dart';
import 'package:food_dose/view/select_address.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'add_shipping_address.dart';

class favourites extends StatefulWidget {
  const favourites({Key? key}) : super(key: key);

  @override
  State<favourites> createState() => _favouritesState();
}

class _favouritesState extends State<favourites> {
  var email;
  get_user_data() async {
    SharedPreferences localStore = await SharedPreferences.getInstance();
    setState(() {
      email = localStore.getString('email');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_user_data();
    UserLocation();
  }

  var userLat;
  var userLng;
  var userFullAddress;
  void UserLocation() async {
    SharedPreferences localStore = await SharedPreferences.getInstance();
    var lat = localStore.getString("lat");
    var lng = localStore.getString("lat");
    var fulladdress = localStore.getString("full_address");
    print(lat);
    setState(() {
      userLat = lat;
      userLng = lng;
      userFullAddress = fulladdress;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: appColors.blactText,
          ),
        ),
        title: Text(
          "Your Favourites",
          style: TextStyle(color: appColors.blactText),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(email)
                    .collection('favourites')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    var ds = snapshot.data!.docs;
                    double sum = 0.0;
                    for (int i = 0; i < ds.length; i++)
                      sum += (ds[i]['price']).toDouble();
                    return Column(
                      children: [
                        ListView.builder(
                          itemBuilder: (_, index) {
                            return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    width: width,
                                    margin: EdgeInsets.only(bottom: 10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          width: 2,
                                          color: Colors.grey.shade200,
                                        )),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: Image.network(
                                            snapshot.data!.docs[index]['url'],
                                            height: 70,
                                            width: 70,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: width * .5,
                                                  child: Text(
                                                    snapshot.data!.docs[index]
                                                        ['product_name'],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12.sp,
                                                        color: appColors
                                                            .blactText),
                                                  ),
                                                ),
                                                InkWell(
                                                    onTap: () async {
                                                      try {
                                                        print('test');
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("users")
                                                            .doc(email)
                                                            .collection(
                                                                'favourites')
                                                            .doc(snapshot.data!
                                                                .docs[index].id)
                                                            .delete();
                                                      } catch (e) {
                                                        print(e.toString());
                                                      }
                                                    },
                                                    child: Icon(
                                                      Icons.delete_outline,
                                                      color:
                                                          Colors.grey.shade400,
                                                      size: 30,
                                                    ))
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: width / 2.8,
                                                  child: Text(
                                                    "\$" +
                                                        snapshot
                                                            .data!
                                                            .docs[index]
                                                                ['price']
                                                            .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12.sp,
                                                        color: appColors
                                                            .mainColor),
                                                  ),
                                                ),

                                                // Container(
                                                //   padding: EdgeInsets.all(5),
                                                //   child: Row(
                                                //     children: [
                                                //       Bounce(
                                                //         onPressed: (){
                                                //           // setState(() {
                                                //           // snapshot.data!.docs[index]['quantity']+1;
                                                //           // });
                                                //           FirebaseFirestore.instance.collection("users").doc(email).collection("cart").doc(snapshot.data!.docs[index].id).
                                                //           update({"quantity": snapshot.data!.docs[index]['quantity']+1,
                                                //             'price':(snapshot.data!.docs[index]['quantity']+1)*snapshot.data!.docs[index]['base_price']
                                                //
                                                //           })
                                                //               .whenComplete(() async {
                                                //             print("Completed");
                                                //           }).catchError((e) => print(e));
                                                //         },
                                                //         duration: Duration(milliseconds: 80),
                                                //         child: Container(
                                                //           color: Colors.grey.shade200,
                                                //           child: Icon(
                                                //             Icons.add,
                                                //           ),
                                                //         ),
                                                //       ),
                                                //       Container(
                                                //           padding: EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
                                                //           color: Colors.white,
                                                //           child: Text(snapshot.data!.docs[index]['quantity'].toString())
                                                //       ),
                                                //       Bounce(
                                                //         onPressed: (){
                                                //           // snapshot.data!.docs[index]['quantity']+1;
                                                //           FirebaseFirestore.instance.collection("users").doc(email).collection("cart").doc(snapshot.data!.docs[index].id).
                                                //           update({"quantity": snapshot.data!.docs[index]['quantity']>0?snapshot.data!.docs[index]['quantity']-1:1,
                                                //             'price':snapshot.data!.docs[index]['quantity']>0?
                                                //             (snapshot.data!.docs[index]['quantity']-1)*snapshot.data!.docs[index]['base_price']:snapshot.data!.docs[index]['base_price']
                                                //
                                                //           })
                                                //               .whenComplete(() async {
                                                //             print("Completed");
                                                //           }).catchError((e) => print(e));
                                                //
                                                //         },
                                                //         duration: Duration(milliseconds: 80),
                                                //         child: Container(
                                                //           color: Colors.grey.shade200,
                                                //           child: Icon(
                                                //             Icons.remove,
                                                //           ),
                                                //         ),
                                                //       )
                                                //
                                                //     ],
                                                //   ),
                                                // )
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ));
                          },
                          itemCount: snapshot.data!.docs.length,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                        ),
                      ],
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.none) {
                    return Center(child: Text('No Data'));
                  }
                  return CircularProgressIndicator();
                }),
          ],
        ),
      ),
    ));
  }
}
