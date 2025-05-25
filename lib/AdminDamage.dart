import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDamage extends StatefulWidget {
  const AdminDamage({super.key});

  @override
  State<AdminDamage> createState() => _AdminDamageState();
}

class _AdminDamageState extends State<AdminDamage> {
  String actionType = 'damage';
  final skuController = TextEditingController();
  final quantityController = TextEditingController();


  void _Submit() async {
    String action = actionType.trim();
    String sku = skuController.text.trim();
    String qt = quantityController.text.trim();

    if (action.isNotEmpty && sku.isNotEmpty && qt.isNotEmpty) {
      int quantity = int.tryParse(qt) ?? 0;
      if (quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Quantity must be a positive number")),
        );
        return;
      }

      // Add to history
      await FirebaseFirestore.instance.collection('history').add({
        'sku': sku,
        'quantity': qt,
        'reason': action,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update stock
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('SKU')
          .where('SKU', isEqualTo: sku)
          .get();

      if (query.docs.isNotEmpty) {
        DocumentSnapshot doc = query.docs.first;
        DocumentReference skuRef = doc.reference;

        int currentStock = doc.get('stock') ?? 0;
        int updatedStock =
        action == 'damage' ? currentStock - quantity : currentStock + quantity;

        if (updatedStock < 0) updatedStock = 0;

        await skuRef.update({'stock': updatedStock});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Record added and stock updated")),
        );

        setState(() {
          actionType = 'damage';
          skuController.clear();
          quantityController.clear();
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("SKU not found in stock")),
        );
      }


      // Show success and clear
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Record added and stock updated")));
      setState(() {
        actionType = 'damage';
        skuController.clear();
        quantityController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed, Please fill all fields")));
    }
  }


  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return "${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} "
          "${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}";
    }
    return "Unknown time";
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(decoration: InputDecoration(labelText: "SKU"),controller: skuController,),
              SizedBox(height: 10,),
              Container(child: Text("Reason:",style: TextStyle(fontSize: 20),),alignment: Alignment.topLeft,),
              RadioListTile<String>(title: Text("Damage"),value: 'damage', groupValue: actionType,
                  onChanged: (value){
                    setState(() {
                      actionType = value!;
                    });
                  }
              ),
              RadioListTile<String>(title: Text("Return"),value: 'return', groupValue: actionType,
                  onChanged: (value){
                    setState(() {
                      actionType = value!;
                    });
                  }
              ),
              TextField(decoration: InputDecoration(labelText: "Quantity"),controller: quantityController,),
              ElevatedButton(onPressed: ()=>_Submit(), child: Text("Submit")),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('history').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final items = snapshot.data!.docs;//is it ok?

                  if (items.isEmpty) return Text("No items found.");

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final data = item.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['reason'] ?? ''),
                        subtitle: Text("SKU:${data['sku']}, quantity: ${data['quantity']}\nTime: ${_formatTimestamp(data['timestamp'])}"),
                        isThreeLine: true,
                      );
                    },
                  );
                },
              ),
            ],
          )
      ),
    );
  }
}

