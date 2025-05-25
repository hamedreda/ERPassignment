import 'package:flutter/material.dart';
import 'AdminBranches.dart';
import 'AdminSKU.dart';
import 'AdminStock.dart';
import 'AdminDamage.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: [
            // Padding(padding: EdgeInsets.all(0),child: Image.asset('assets/flower-8625039.png',),),
            GridView.count(
              crossAxisCount: 2,
              children: [
                InkWell(
                  onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminStock())),
                  child: Card(
                    elevation: 4,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text("Stock"),
                    ),
                  ),
                ),
                InkWell(
                  onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminSKU())),
                  child: Card(
                    elevation: 4,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text("manage items"),
                    ),
                  ),
                ),
                InkWell(
                  onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminBranches())),
                  child: Card(
                    elevation: 4,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text("manage branches",),
                    ),
                  ),
                ),
                InkWell(
                  onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminDamage())),
                  child: Card(
                    elevation: 4,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text("Damages/Returns"),
                    ),
                  ),
                ),


              ],
            )
          ],
        )
    );
  }
}
