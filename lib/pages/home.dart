// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          _searchBar(),
          SizedBox(height: 40,),
          _ServerList()
        ],
      ),
    );
  }

  Column _ServerList() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20,),
              child: Text(
                'Servers',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
            SizedBox(height: 40,),
            ListView.separated(
              itemCount: 3,
              shrinkWrap: true,
              separatorBuilder: (context, index) => SizedBox(height: 25,),
              padding: EdgeInsets.only(
                left: 10,
                right: 10
              ),
              itemBuilder: (context, index) {
                return Container(
                  height: 135,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xff1D1617).withOpacity(0.07),
                        offset: Offset(0, 10),
                        blurRadius: 40,
                        spreadRadius: 0,
                      )
                    ]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Server Name',
                            style: TextStyle(
                              fontWeight: FontWeight(500),
                              color: Colors.black,
                              fontSize: 18
                            ),
                          ),
                          Text(
                            'example.exaroton.me:25565',
                            style: TextStyle(
                              color: Color(0xff7B6F72),
                              fontSize: 14,
                              fontWeight: FontWeight(450)
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Start',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight(500),
                                  color: Colors.blueGrey
                                ),
                              )
                            ),
                          ),
                          SizedBox(width: 15,),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.yellowAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Restart',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight(500),
                                  color: Colors.blueGrey
                                ),
                              )
                            )
                          ),
                          SizedBox(width: 15,),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Stop',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight(500),
                                  color: Colors.blueGrey
                                ),
                              )
                            )
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            )
          ],
        );
  }

  Container _searchBar() {
    return Container(
          margin: EdgeInsets.only(top: 40, left: 20, right: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xff1D1617).withOpacity(0.11),
                blurRadius: 40,
                spreadRadius: 0.0,
              )
            ]
          ),
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(15),
              hintText: 'Servers',
              hintStyle: TextStyle(
                color: Color(0xffDDDADA),
                fontSize: 14,
              ),
              prefixIcon: Icon(Icons.search),
              suffixIcon: SizedBox(
                width: 100,
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      VerticalDivider(
                        color: Colors.black,
                        indent: 10,
                        endIndent: 10,
                        thickness: 0.1,
                      ),
                      Icon(Icons.filter),
                    ],
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none
              )
            ),
          ),
        );
  }
}