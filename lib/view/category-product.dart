import 'package:food_dose/Utility/AppUrl.dart';
import 'package:food_dose/Utility/colors..dart';
import 'package:food_dose/view/signle_foods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:get/route_manager.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  // We will fetch data from this Rest api
  final _baseUrl = 'https://api.fooddoose.com/food/all-food';

  // At the beginning, we fetch the first 20 posts
  int _page = 1;
  // you can change this value to fetch more or less posts per page (10, 15, 5, etc)
  final int _limit = 10;

  // There is next page or not
  bool _hasNextPage = true;

  // Used to display loading indicators when _firstLoad function is running
  bool _isFirstLoadRunning = false;

  // Used to display loading indicators when _loadMore function is running
  bool _isLoadMoreRunning = false;

  // This holds the posts fetched from the server
  List _posts = [];

  // This function will be called when the app launches (see the initState function)
  void _firstLoad() async {
    setState(() {
      _isFirstLoadRunning = true;
    });
    try {
      final res =
      await http.get(Uri.parse("$_baseUrl?page=$_page&limit=$_limit"));
      print('dekho+'+json.decode(res.body)['allFoods'].toString());
      setState(() {
        _posts = json.decode(res.body)['allFoods'];
      });
    } catch (err) {
      if (kDebugMode) {
        print('Something went wrong');
      }
      print(err);
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  // This function will be triggered whenver the user scroll
  // to near the bottom of the list view
  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      _page += 1; // Increase _page by 1
      try {
        final res =
        await http.get(Uri.parse("$_baseUrl?page=$_page&limit=$_limit"));

        final List fetchedPosts = json.decode(res.body)['allFoods'];
        if (fetchedPosts.isNotEmpty) {
          setState(() {
            _posts.addAll(fetchedPosts);
          });
        } else {
          // This means there is no more data
          // and therefore, we will not send another GET request
          setState(() {
            _hasNextPage = false;
          });
        }
      } catch (err) {
        if (kDebugMode) {
          print('Something went wrong!');
        }
      }

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  // The controller for the ListView
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _firstLoad();
    _controller = ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }
  late List Fav = [];

  @override
  Widget build(BuildContext context) {  var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: ()=>Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.black,),
        ),
        title: Text("Popular Foods", style: TextStyle(color: Colors.black),),
      ),
      body: _isFirstLoadRunning
          ? const Center(
        child: const CircularProgressIndicator(),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _controller,
              itemCount: _posts.length,
              shrinkWrap: true,
              itemBuilder: (_, index) {
                return Bounce(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleFoods(id: _posts[index]['_id'].toString())));

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
                      width: width,
                      height: 75,

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(AppUrl.picurl+_posts[index]['image'],
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
                                        child: Text(_posts[index]['itemName'],
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.sp,
                                              color: appColors.blactText
                                          ),
                                        ),
                                      ),


                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_posts[index]['categoryName'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 10.sp,
                                            color: appColors.blactText
                                        ),
                                      ),
                                      SizedBox(height: 5,),
                                      Row(
                                        children: [
                                          int.parse(_posts[index]['discountPrice'].toString())>0? Text("\$"+_posts[index]['withOutDiscountPrice'].toString(),
                                            style: TextStyle(
                                                decoration: TextDecoration.lineThrough,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.sp,
                                                color: appColors.mainColor
                                            ),
                                          ):Container(),
                                          int.parse(_posts[index]['discountPrice'].toString())>0?   SizedBox(width: 10,):Container(),
                                          Text("\$"+_posts[index]['price'].toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10.sp,
                                                color: appColors.mainColor
                                            ),)
                                        ],
                                      ),

                                      // SizedBox(
                                      //   width: width/2.8,
                                      //   child: Text("\$230.90",
                                      //     style: TextStyle(
                                      //         fontWeight: FontWeight.w600,
                                      //         fontSize: 12.sp,
                                      //         color: appColors.mainColor
                                      //     ),
                                      //   ),
                                      // ),



                                    ],
                                  ),
                                ],
                              )

                            ],
                          ),
                          InkWell(
                              onTap: (){
                                setState(() {
                                  Fav.add(index);
                                  print(Fav);
                                });
                              },
                              child: Icon(
                                Fav.isNotEmpty && Fav[0]==index ? Icons.favorite:Icons.favorite_border_outlined,
                                color:  Fav.isNotEmpty && Fav[0]==index ?Colors.red: Colors.grey.shade400,
                                size: 30,
                              )
                          )
                        ],
                      ),
                    ),
                  ),
                );

              }
            ),
          ),

          // when the _loadMore function is running
          if (_isLoadMoreRunning == true)
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 40),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // When nothing else to load
          if (_hasNextPage == false)
            Container(
              padding: const EdgeInsets.only(top: 30, bottom: 40),
              color: Colors.amber,
              child: const Center(
                child: Text('You have discovered all the foods'),
              ),
            ),
        ],
      ),
    );
  }
}
// class ProductList extends StatefulWidget {
//   const ProductList({Key? key}) : super(key: key);
//
//   @override
//   State<ProductList> createState() => _ProductListState();
// }
//
// class _ProductListState extends State<ProductList> {
//
//   //add fev
//   late List Fav = [];
//   @override
//   Widget build(BuildContext context) {
//     var width = MediaQuery.of(context).size.width;
//     var height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: ()=>Navigator.pop(context),
//           icon: Icon(Icons.arrow_back, color: Colors.black,),
//         ),
//         title: Text("Popular Foods", style: TextStyle(color: Colors.black),),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: ListView.builder(
//           itemCount: 10,
//             itemBuilder: (_, index){
//             return Bounce(
//               onPressed: (){
//                 Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleFoods(id: '1',)));
//
//               },
//               duration: Duration(milliseconds: 80),
//                 child: Container(
//                   padding: EdgeInsets.all(20),
//                   margin: EdgeInsets.only(bottom: 20),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                           blurRadius: 10,
//                           spreadRadius: 2,
//                           color: Colors.grey.shade200,
//                           offset: Offset(0,2)
//                       ),
//                     ],
//                   ),
//                   child: Container(
//                     width: width,
//                     height: 75,
//
//                     child: Row(
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(5),
//                           child: Image.asset("assets/images/f1.jpeg",
//                             height: 70,
//                             width: 70,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         SizedBox(width: 20,),
//
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 SizedBox(
//                                   width: width*.5,
//                                   child: Text("Chicken Berger",
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 14.sp,
//                                         color: appColors.blactText
//                                     ),
//                                   ),
//                                 ),
//
//                                 InkWell(
//                                     onTap: (){
//                                       setState(() {
//                                         Fav.add(index);
//                                         print(Fav);
//                                       });
//                                     },
//                                     child: Icon(
//                                       Fav.isNotEmpty && Fav[0]==index ? Icons.favorite:Icons.favorite_border_outlined,
//                                       color:  Fav.isNotEmpty && Fav[0]==index ?Colors.red: Colors.grey.shade400,
//                                       size: 30,
//                                     )
//                                 )
//                               ],
//                             ),
//                             SizedBox(height: 5,),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               //mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text("Thy Burger",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.w400,
//                                       fontSize: 10.sp,
//                                       color: appColors.blactText
//                                   ),
//                                 ),
//                                 SizedBox(height: 5,),
//                                 SizedBox(
//                                   width: width/2.8,
//                                   child: Text("\$230.90",
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 12.sp,
//                                         color: appColors.mainColor
//                                     ),
//                                   ),
//                                 ),
//
//
//
//                               ],
//                             ),
//                           ],
//                         )
//
//                       ],
//                     ),
//                   ),
//                 ),
//             );
//             }
//         )
//       ),
//     );
//   }
//
// }

