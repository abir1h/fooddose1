import 'dart:convert';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:food_dose/Utility/AppUrl.dart';
import 'package:food_dose/Utility/colors..dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../widget/buttom-navigation.dart';
import '../signle_foods.dart';
class resturent_foods extends StatefulWidget {
  final String name,location,id,image,logo,phone,open_hour,close_hour;

  const resturent_foods({Key? key,required this.phone,required this.open_hour,required this.close_hour,required this.logo, required this.name,required this.id,required this.location,required this.image}) : super(key: key);

  @override
  State<resturent_foods> createState() => _resturent_foodsState();
}

class _resturent_foodsState extends State<resturent_foods> {
  Future get_food() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'authorization': "Bearer $token"
    };

    var response = await http.get(Uri.parse(AppUrl.resturent_foods+widget.id),
        headers: requestHeaders);
    if (response.statusCode == 200) {
      print('Get post collected' + response.body);
      var userData1 = jsonDecode(response.body)['allFoods'];

      return userData1;
    } else {
      print("post have no Data${response.body}");
      var userData1 = jsonDecode(response.body)['allFoods'];
      return userData1;
    }
  } Future get_catagory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'authorization': "Bearer $token"
    };

    var response = await http.get(Uri.parse(AppUrl.catagorries+widget.id),
        headers: requestHeaders);
    if (response.statusCode == 200) {
      print('Get post collected' + response.body);
      var userData1 = jsonDecode(response.body)['categories'];

      return userData1;
    } else {
      print("post have no Data${response.body}");
      var userData1 = jsonDecode(response.body)['categories'];
      return userData1;
    }
  }
  Future? banner,foods,get_catqagories;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    foods=get_food();
    print(widget.id);
    get_catqagories=get_catagory();
  }
  @override
  Widget build(BuildContext context) {
    var size=MediaQuery.of(context).size;
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: (){Get.to(()=>AppBottomNavigation());},
          icon: Icon(Icons.arrow_back,color: Colors.black,),
        ),
        title: Text(widget.name,style: TextStyle(
          color: Colors.black,fontSize: 16,fontWeight: FontWeight.w600
        ),),
      ),
      body: ListView(
       children: [
         Container(
             child: FutureBuilder(
                 future: get_catqagories,
                 builder: (_, AsyncSnapshot snapshot) {
                   print(snapshot.data);
                   switch (snapshot.connectionState) {
                     case ConnectionState.waiting:
                       return SizedBox(
                         width: MediaQuery.of(context).size.width,
                         height: MediaQuery.of(context).size.height/15,
                         child: Shimmer.fromColors(
                           baseColor: Colors.grey.withOpacity(.3),
                           highlightColor: Colors.grey.withOpacity(.1),
                           child: ListView.builder(
                             physics: AlwaysScrollableScrollPhysics(),
                             itemBuilder: (_, __) => Padding(
                               padding: const EdgeInsets.only(bottom: 8.0),
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
                                       CrossAxisAlignment.start,
                                       children: <Widget>[
                                         Container(
                                           width: double.infinity,
                                           height: 8.0,
                                           color: Colors.white,
                                         ),
                                         const Padding(
                                           padding: EdgeInsets.symmetric(
                                               vertical: 2.0),
                                         ),
                                         Container(
                                           width: double.infinity,
                                           height: 8.0,
                                           color: Colors.white,
                                         ),
                                         const Padding(
                                           padding: EdgeInsets.symmetric(
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
                             ?  Container(
                           height: size.height/8,
                               width: size.width,
                               child: ListView.builder(itemBuilder: (_,index){
                           return Bounce(
                               onPressed: (){
                                 // Get.to(()=>SingleFoods(id: snapshot.data[index]['_id'].toString(),));

                               },
                               duration: Duration(milliseconds: 80),
                               child: Padding(
                                 padding: const EdgeInsets.all(8.0),
                                 child: Container(
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(10),
                                     border: Border.all(color: appColors.mainColor)
                                   ),
                                   child: Center(child: Text(
                                     snapshot.data[index]['categoryName']
                                   ),),
                                 ),
                               ),
                           );

                         },itemCount: snapshot.data.length,
                           padding: EdgeInsets.zero,
                           shrinkWrap: true,
                                 scrollDirection: Axis.horizontal,

                         ),
                             ):Center(
                             child: Column(
                               children: [
                                 SizedBox(
                                   height: size.height / 10,
                                 ),
                                 Text('No Post Yet!!')
                               ],
                             ))
                             : Text('No data');
                       }
                   }
                   return CircularProgressIndicator();
                 })),
         Container(
             child: FutureBuilder(
                 future: foods,
                 builder: (_, AsyncSnapshot snapshot) {
                   print(snapshot.data);
                   switch (snapshot.connectionState) {
                     case ConnectionState.waiting:
                       return SizedBox(
                         width: MediaQuery.of(context).size.width,
                         height: MediaQuery.of(context).size.height/15,
                         child: Shimmer.fromColors(
                           baseColor: Colors.grey.withOpacity(.3),
                           highlightColor: Colors.grey.withOpacity(.1),
                           child: ListView.builder(
                             physics: AlwaysScrollableScrollPhysics(),
                             itemBuilder: (_, __) => Padding(
                               padding: const EdgeInsets.only(bottom: 8.0),
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
                                       CrossAxisAlignment.start,
                                       children: <Widget>[
                                         Container(
                                           width: double.infinity,
                                           height: 8.0,
                                           color: Colors.white,
                                         ),
                                         const Padding(
                                           padding: EdgeInsets.symmetric(
                                               vertical: 2.0),
                                         ),
                                         Container(
                                           width: double.infinity,
                                           height: 8.0,
                                           color: Colors.white,
                                         ),
                                         const Padding(
                                           padding: EdgeInsets.symmetric(
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
                             ?  ListView.builder(itemBuilder: (_,index){
                           return Bounce(
                             onPressed: (){
                               Get.to(()=>SingleFoods(id: snapshot.data[index]['_id'].toString(),));

                             },
                             duration: Duration(milliseconds: 80),
                             child: Container(
                               padding: EdgeInsets.all(20),
                               margin: EdgeInsets.only(bottom: 20),
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(10),
                                 color: Colors.white,
                                 boxShadow: [
                                   BoxShadow(
                                       blurRadius: 10,
                                       spreadRadius: 2,
                                       color: Colors.grey.shade200,
                                       offset: Offset(0,2)
                                   ),
                                 ],
                               ),
                               child: Container(
                                 width: size.width,
                                 height: 75,

                                 child: Row(
                                   children: [
                                     ClipRRect(
                                       borderRadius: BorderRadius.circular(5),
                                       child: Image.network(AppUrl.picurl+snapshot.data[index]['image'],
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
                                               width: size.width*.5,
                                               child: Text(snapshot.data[index]['itemName'],
                                                 overflow: TextOverflow.ellipsis,
                                                 style: TextStyle(
                                                     fontWeight: FontWeight.w600,
                                                     fontSize: 14.sp,
                                                     color: appColors.blactText
                                                 ),
                                               ),
                                             ),

                                             // InkWell(
                                             //     onTap: (){
                                             //       setState(() {
                                             //         Fav.add(index);
                                             //         print(Fav);
                                             //       });
                                             //     },
                                             //     child: Icon(
                                             //       Fav.isNotEmpty && Fav[0]==index ? Icons.favorite:Icons.favorite_border_outlined,
                                             //       color:  Fav.isNotEmpty && Fav[0]==index ?Colors.red: Colors.grey.shade400,
                                             //       size: 30,
                                             //     )
                                             // )
                                           ],
                                         ),
                                         SizedBox(height: 5,),
                                         Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children: [
                                             Text(snapshot.data[index]['categoryName'],
                                               style: TextStyle(
                                                   fontWeight: FontWeight.w400,
                                                   fontSize: 10.sp,
                                                   color: appColors.blactText
                                               ),
                                             ),
                                             SizedBox(height: 5,),
                                             Row(
                                               children: [
                                                 int.parse(snapshot.data[index]['discountPrice'].toString())>0? Text("\$"+snapshot.data[index]['withOutDiscountPrice'].toString(),
                                                   style: TextStyle(
                                                       decoration: TextDecoration.lineThrough,
                                                       fontWeight: FontWeight.bold,
                                                       fontSize: 12.sp,
                                                       color: appColors.mainColor
                                                   ),
                                                 ):Container(),
                                                 int.parse(snapshot.data[index]['discountPrice'].toString())>0?   SizedBox(width: 10,):Container(),
                                                 Text("\$"+snapshot.data[index]['price'].toString(),
                                                   style: TextStyle(
                                                       fontWeight: FontWeight.bold,
                                                       fontSize: 10.sp,
                                                       color: appColors.mainColor
                                                   ),)
                                               ],
                                             )


                                           ],
                                         ),
                                       ],
                                     )

                                   ],
                                 ),
                               ),
                             ),
                           );

                         },itemCount: snapshot.data.length,
                               padding: EdgeInsets.zero,
                               shrinkWrap: true,
                               physics:NeverScrollableScrollPhysics(),
                         ):Center(
                             child: Column(
                               children: [
                                 SizedBox(
                                   height: size.height / 10,
                                 ),
                                 Text('No Post Yet!!')
                               ],
                             ))
                             : Text('No data');
                       }
                   }
                   return CircularProgressIndicator();
                 })),
       ],
        ),

    ));
  }
}
