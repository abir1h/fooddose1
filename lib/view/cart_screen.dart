import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_dose/Utility/AppUrl.dart';
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
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'add_shipping_address.dart';
import 'package:http/http.dart'as http;

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List restu=[];
  List items=[];
  double calculateDistance(lat1, lon1, lat2, lon2){
    print(lat1);
    print(lon1);
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    setState(() {
      distance=12742 * asin(sqrt(a));
    });

    return 12742 * asin(sqrt(a));
  }
  var distance=0.0;

  var email;
  final _formKey = GlobalKey<FormState>();
  TextEditingController phone=TextEditingController();
  TextEditingController message=TextEditingController();
  get_user_data()async{
    SharedPreferences localStore = await SharedPreferences.getInstance();
    setState(() {
      email=localStore.getString('email');
    });

  }
  Future get_food3() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('ref_token');


    final queryParameters = {
      'token': token,
    };
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    final url = Uri.https(
        'fooddoose.payrapay.com', 'simple-user/refreshToken', queryParameters);
    final response = await http
        .get(
      url,
      headers: headers,
    );
    print(jsonDecode(response.body));
    if(response.statusCode==200){
      print(response.body.toString());
    }
  }

  List lats=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_user_data();
    UserLocation();
    get_food("90.3523847", "23.659140");
  }
  getref()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('ref_token');
    print(token);
    final queryParameters = {
      'token': token,
    };
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    final url = Uri.https(
        'fooddoose.payrapay.com', 'simple-user/refreshToken', queryParameters);
    final response = await http
        .get(
      url,
      headers: headers,
    );
    print(jsonDecode(response.body));
    if(response.statusCode==200){
      print(response.body.toString());
    }

  }
  bool add=false;
  Future<void> checkout(Map<String, dynamic> info) async {
    print('test');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      // Get image URL from firebase

      Map<String, dynamic> thirdMap = {}
        ..addAll(info);
   //
   //    FirebaseFirestore.instance
   //        .collection('users')
   //        .doc(email)
   //        .collection('cart')
   //        .add(thirdMap)
   //        .whenComplete(() {
   //      setState(() {
   //        add = false;
   //      });
   // Get.to(()=>Success(title: '',));
   //      // Dialogs.bottomMaterialDialog(
   //      //   msg: 'Your product has been added to your carts',
   //      //   title: 'Congratulations',
   //      //   color: Colors.white,
   //      //   lottieBuilder: Lottie.asset(
   //      //     'assets/images/congrats.json',
   //      //     fit: BoxFit.contain,
   //      //   ),
   //      //   context: context,
   //      //   actions: [
   //      //     IconsButton(
   //      //       onPressed: () {
   //      //         Get.to(() => AppBottomNavigation(
   //      //           index: 1,
   //      //         ));
   //      //       },
   //      //       text: 'View Cart',
   //      //       iconData: Icons.add_shopping_cart,
   //      //       color: appColors.rating_back,
   //      //       textStyle: TextStyle(color: Colors.white),
   //      //       iconColor: Colors.white,
   //      //     ),
   //      //   ],
   //      // );
   //    });

      // Add location and url to database
      // await FirebaseFirestore.instance.collection('Prescriptions').doc().set({
      //   'url': imageString,
      //   'location': text,
      //   'Patient_phone': phone,
      //   'created_at': FieldValue.serverTimestamp(),
      // });
      var response=await http.post(
          Uri.parse(AppUrl.order_food),

          headers: <String, String>{
            'Content-Type': 'application/json',
            'authorization': "Bearer $token"

          },
          body: jsonEncode(thirdMap)
      );
      if(response.statusCode==200){
        print('loginsuccefull');
        print(response.body);
        var data = jsonDecode(response.body);
        // if(data['success']==true){
        //   // saveprefs(data['accessToken'],data['userData']['name'],data['userData']['email'],data['userData']['uid'],data['refreshtoken']);
        //   Get.to(()=>Success(title: 'title'));
        // }else{
        //   print(response.body);
        // }
        Get.to(()=>Success(title: 'title'));

      }else{
        print(response.body);
        print(response.statusCode);

      }
    } catch (e) {
      print(e);
    }
  }
  bool enter_msg=false;
  var userLat;
  var userLng;
  var userFullAddress;
  void UserLocation()async{
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
    calculateDistance(
        double.parse(userLat), double.parse(userLng),90.3523847, 23.659140
    );

  }
  var cost;
  var initialcost;
  var costperlm;
  var distancekm;

  Future get_food(String m_lat,String m_long) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    SharedPreferences localStore = await SharedPreferences.getInstance();
    var lat = localStore.getString("lat");
    var lng = localStore.getString("lat");
    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
    };

    var response = await http.get(Uri.parse(AppUrl.distance+'lat1=$m_lat&lon1=$m_long&lat2=$lat&lon2=$lng'),
        headers: requestHeaders);
    if (response.statusCode == 200) {
      print('Get post collected' + response.body);
      var userData1 = jsonDecode(response.body);
      setState(() {
        cost=userData1['cost'];
        initialcost=userData1['initialCost'];
        costperlm=userData1['costPerKm'];
        distancekm=userData1['distance'];
      });

      return userData1;
    } else {
      print("post have no Data${response.body}");
      var userData1 = jsonDecode(response.body)['cost'];
      return userData1;
    }
  }

  @override
  Widget build(BuildContext context) {
    var width =MediaQuery.of(context).size.width;
    var height =MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: ()=> Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: appColors.blactText,),
        ),
        title: Text("Your Cart", style: TextStyle(color: appColors.blactText),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: ListView(
          children: [
            distancekm!=null?Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users").doc(email).collection('cart')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        var ds=snapshot.data!.docs;
                        double sum = 0.0;
                        for(int i=0; i<ds.length;i++)
                          sum+=(ds[i]['price']).toDouble();
                        return ds.length>0?Column(
                          children: [
                            ListView.builder(itemBuilder: (_,index){

                              return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {

                                    },
                                    child:  Container(
                                      width: width,
                                      margin: EdgeInsets.only(bottom: 10),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(width: 2, color: Colors.grey.shade200, )
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(5),
                                            child: Image.network(snapshot.data!.docs[index]['url'],
                                              height: 70,
                                              width: 70,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(width: 20,),

                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: width*.5,
                                                    child: Text(snapshot.data!.docs[index]['product_name'],
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 12.sp,
                                                          color: appColors.blactText
                                                      ),
                                                    ),
                                                  ),

                                                  InkWell(
                                                      onTap: ()async{

                                                        try{
                                                          print('test');
                                                          FirebaseFirestore.instance.collection("users").doc(email).collection('cart').doc(snapshot.data!.docs[index].id).delete();


                                                        }catch(e){
                                                          print(e.toString());
                                                        }

                                                        },
                                                      child: Icon(
                                                        Icons.delete_outline,
                                                        color: Colors.grey.shade400,
                                                        size: 30,
                                                      )
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width: width/2.8,
                                                    child: Text("\$"+snapshot.data!.docs[index]['price'].toString(),
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 12.sp,
                                                          color: appColors.mainColor
                                                      ),
                                                    ),
                                                  ),

                                                  Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Row(
                                                      children: [
                                                        Bounce(
                                                          onPressed: (){
                                                            // setState(() {
                                                            // snapshot.data!.docs[index]['quantity']+1;
                                                            // });
                                                            FirebaseFirestore.instance.collection("users").doc(email).collection("cart").doc(snapshot.data!.docs[index].id).
                                                                update({"quantity": snapshot.data!.docs[index]['quantity']+1,
                                                                'price':(snapshot.data!.docs[index]['quantity']+1)*snapshot.data!.docs[index]['base_price']

                                                            })
                                                                .whenComplete(() async {
                                                              print("Completed");
                                                            }).catchError((e) => print(e));
                                                          },
                                                          duration: Duration(milliseconds: 80),
                                                          child: Container(
                                                            color: Colors.grey.shade200,
                                                            child: Icon(
                                                              Icons.add,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                            padding: EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
                                                            color: Colors.white,
                                                            child: Text(snapshot.data!.docs[index]['quantity'].toString())
                                                        ),
                                                        Bounce(
                                                          onPressed: (){
                                                          // snapshot.data!.docs[index]['quantity']+1;
                                                            FirebaseFirestore.instance.collection("users").doc(email).collection("cart").doc(snapshot.data!.docs[index].id).
                                                            update({"quantity": snapshot.data!.docs[index]['quantity']>0?snapshot.data!.docs[index]['quantity']-1:1,
                                                              'price':snapshot.data!.docs[index]['quantity']>0?
                                                              (snapshot.data!.docs[index]['quantity']-1)*snapshot.data!.docs[index]['base_price']:snapshot.data!.docs[index]['base_price']

                                                            })
                                                                .whenComplete(() async {
                                                              print("Completed");
                                                            }).catchError((e) => print(e));

                                                          },
                                                          duration: Duration(milliseconds: 80),
                                                          child: Container(
                                                            color: Colors.grey.shade200,
                                                            child: Icon(
                                                              Icons.remove,
                                                            ),
                                                          ),
                                                        )

                                                      ],
                                                    ),
                                                  )

                                                ],
                                              ),
                                            ],
                                          )

                                        ],
                                      ),
                                    ),
                                  )
                              );
                            },
                            itemCount: snapshot.data!.docs.length,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                            ),
                            SizedBox(height: 50,),

                            DottedBorder(
                              color: Colors.grey,
                              strokeWidth: 1,
                              child: Container(
                                padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Shipping Address:",
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w300,
                                              color: Color(0xFF9B9B9B)
                                          ),
                                        ),
                                        // Text(distance.toString()),

                                        SizedBox(height: 20,),
                                        Container(
                                          width: 200,
                                          child: Text(userFullAddress.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Bounce(
                                      onPressed: ()=>Get.to(()=>add_shipping()),
                                      duration: Duration(milliseconds: 80),
                                      child: Container(
                                        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                        decoration: BoxDecoration(
                                            color: appColors.mainColor,
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: Colors.white,
                                            ),
                                            Text("Change",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 15,),
                            Form(
                              key:_formKey,
                              child: Container(

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(

                                      child: TextFormField(
                                        controller:phone,
                                        validator:(v)=>v!.isEmpty?"Please enter phone":null,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.phone),
                                          border: OutlineInputBorder()
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 15,),
                            enter_msg==false?InkWell(
                              onTap:(){
                        setState(() {
                          enter_msg=true;
                        });
                      },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent.withOpacity(.2),
                                  borderRadius: BorderRadius.circular(10)
                                ),child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(child: Text("Give more information",style: TextStyle(
                                  color: Colors.orangeAccent,fontWeight: FontWeight.w600,
                              ),),),
                                ),
                              ),
                            ):Container(),
                            enter_msg==true?Container(
                              child:
                              TextFormField(
                                controller:message,
                                maxLines:2,

                                validator:(v)=>v!.isEmpty?"Please enter phone":null,
                                decoration: InputDecoration(


                                    border: OutlineInputBorder(),
                                  labelText: "Description"
                                ),
                              ),
                            ):Container(),


                            SizedBox(height: 40,),

                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Items ( "+snapshot.data!.docs.length.toString()+" )",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10.sp,
                                        color: appColors.blactText,
                                      ),
                                    ),

                                    Text("\$"+sum.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                        color: appColors.blactText,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Shipping Fee",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10.sp,
                                        color: appColors.blactText,
                                      ),
                                    ),

                                    Text("\$ "+cost.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                        color: appColors.blactText,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10,),
                                Divider(height: 1,color: Colors.grey.shade400,),
                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Total Price",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11.sp,
                                        color: Colors.black,
                                      ),
                                    ),

                                    Text("\$"+(sum+cost).toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                        color: appColors.mainColor,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),

                          // Text(items.toString()),
                            SizedBox(height: 40,),
                            add==false?Bounce(
                              duration: Duration(milliseconds: 80),
                              onPressed: (){
                                if(int.parse(distancekm.toString())<10){
                                  if(_formKey.currentState!.validate()){
                                    print("Total Items= "+snapshot.data!.docs.length.toString());
                                    print("address = "+userFullAddress);
                                    print("email = "+email);
                                    print("cart Total = "+sum.toString());
                                    FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(email)
                                        .collection('cart')
                                        .get()
                                        .then((value) {
                                      print(value);

                                      for (int i = 0; i < value.docs.length; i++) {
                                        setState(() {
                                          restu.add(value.docs[i]['product_category']);
                                        });
                                        print(restu.toString());
                                      }
                                      print("testtttt" + value.docs.length.toString());
                                    });
                                    FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(email)
                                        .collection('cart')
                                        .get()
                                        .then((value) {
                                      print(value);

                                      for (int i = 0; i < value.docs.length; i++) {
                                        setState(() {
                                          items.clear();
                                          items.add(value.docs[i]['items']);
                                        });
                                        print(items.toString());
                                      }
                                      print("testtttt" + value.docs.length.toString());
                                    });

                                    Map<String, dynamic> data={
                                      "phone":phone.text,
                                      'address':userFullAddress,
                                      'totalItems':snapshot.data!.docs.length.toString(),
                                      'totalUniqueItems':restu.length.toString(),
                                      'deliveryCost':cost,
                                      'cartTotal':sum+cost,
                                      'items':items.toString(),


                                    };
                                    setState(() {
                                      add=true;
                                    });
                                    checkout(data);


                                  }
                                }else{

                                  Dialogs.bottomMaterialDialog(
                                    msg: 'Distance should be in between 10 km',
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

                              },
                              child: Container(
                                height: 50,
                                margin: EdgeInsets.only(left: width*.10, bottom: 50, right: width*.10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: appColors.mainColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text("CHECKOUT",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ):SpinKitCircle(color: Colors.orangeAccent,size: 20,)
                          ],
                        ): Lottie.asset(
                          'assets/images/empty.json',
                          fit: BoxFit.contain,
                        );
                      }if(snapshot.connectionState==ConnectionState.none){
                        return Center(child: Text('No Data'));
                      }
                      return Center(child: CircularProgressIndicator());
                    }),


                // Container(
                //   width: width,
                //   margin: EdgeInsets.only(bottom: 20),
                //   padding: EdgeInsets.all(10),
                //   decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(5),
                //       border: Border.all(width: 2, color: Colors.grey.shade200, )
                //   ),
                //   child: Row(
                //     children: [
                //       ClipRRect(
                //         borderRadius: BorderRadius.circular(5),
                //         child: Image.asset("assets/images/f1.jpeg",
                //           height: 70,
                //           width: 70,
                //           fit: BoxFit.cover,
                //         ),
                //       ),
                //       SizedBox(width: 20,),
                //
                //       Column(
                //         mainAxisAlignment: MainAxisAlignment.start,
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               SizedBox(
                //                 width: width*.5,
                //                 child: Text("Chicken Berger",
                //                   style: TextStyle(
                //                       fontWeight: FontWeight.w600,
                //                       fontSize: 14.sp,
                //                       color: appColors.blactText
                //                   ),
                //                 ),
                //               ),
                //
                //               InkWell(
                //                   onTap: (){},
                //                   child: Icon(
                //                     Icons.delete_outline,
                //                     color: Colors.grey.shade400,
                //                     size: 30,
                //                   )
                //               )
                //             ],
                //           ),
                //           SizedBox(height: 10,),
                //           Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               SizedBox(
                //                 width: width/2.8,
                //                 child: Text("\$230.90",
                //                   style: TextStyle(
                //                       fontWeight: FontWeight.w600,
                //                       fontSize: 12.sp,
                //                       color: appColors.mainColor
                //                   ),
                //                 ),
                //               ),
                //
                //               Container(
                //                 padding: EdgeInsets.all(5),
                //                 child: Row(
                //                   children: [
                //                     Bounce(
                //                       onPressed: (){},
                //                       duration: Duration(milliseconds: 80),
                //                       child: Container(
                //                         color: Colors.grey.shade200,
                //                         child: Icon(
                //                           Icons.add,
                //                         ),
                //                       ),
                //                     ),
                //                     Container(
                //                         padding: EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
                //                         color: Colors.white,
                //                         child: Text("1")
                //                     ),
                //                     Bounce(
                //                       onPressed: (){},
                //                       duration: Duration(milliseconds: 80),
                //                       child: Container(
                //                         color: Colors.grey.shade200,
                //                         child: Icon(
                //                           Icons.remove,
                //                         ),
                //                       ),
                //                     )
                //
                //                   ],
                //                 ),
                //               )
                //
                //             ],
                //           ),
                //         ],
                //       )
                //
                //     ],
                //   ),
                // ),
              ],
            ):Column(
              children: [
                SizedBox(height: height/2.5,),
                Center(
                  child: SpinKitCircle(
                    color: appColors.mainColor,
                    size: 25,
                  ),
                ),
                Center(
                  child: Text("Please wait..."),
                )
              ],
            ),





          ],

        ),
      ),


    );
  }
}
