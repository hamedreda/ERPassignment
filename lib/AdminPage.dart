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
        body: GridView.count(
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
            Container(),
            InkWell(
              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminSKU())),
              child: Card(
                elevation: 4,
                child: Container(
                  alignment: Alignment.center,
                  child: Text("manage\nitems"),
                ),
              ),
            ),
            InkWell(
              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminBranches())),
              child: Card(
                elevation: 4,
                child: Container(
                  alignment: Alignment.center,
                  child: Text("manage\nbranches",),
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
    );
  }
}
