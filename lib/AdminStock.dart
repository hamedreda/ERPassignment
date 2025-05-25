import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminStock extends StatefulWidget {
  const AdminStock({super.key});

  @override
  State<AdminStock> createState() => _AdminStockState();
}

class _AdminStockState extends State<AdminStock> {

  void editTreshold(String docId, Map<String, dynamic> currentData) {
    final _TresholdController = TextEditingController(
      text: currentData['treshold'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Treshold"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _TresholdController, decoration: InputDecoration(labelText: "New Treshold")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                int newTreshold = int.parse(_TresholdController.text.trim());

                if (newTreshold >=0 ) {
                  await FirebaseFirestore.instance.collection('SKU').doc(docId).update({
                    'treshold': newTreshold,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Treshold updated")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed")));
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void ReOrder(String docId, Map<String, dynamic> currentData){
    final _StockController = TextEditingController(
      text: currentData['stock'].toString(),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("ReOrder Item"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _StockController, decoration: InputDecoration(labelText: "Order Quantity")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                int newStock = int.parse(_StockController.text.trim());

                if (newStock >=0 ) {
                  await FirebaseFirestore.instance.collection('SKU').doc(docId).update({
                    'stock': newStock,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order Done")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed")));
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('SKU').where('active', isEqualTo: true).orderBy('stock').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final items = snapshot.data!.docs;

                if (items.isEmpty) return Text("No items found.");

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final data = item.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['item'] ?? ''),
                      subtitle: Text("${data['category']}, ${data['subcategory']}\nSKU: ${data['SKU']}\nBrand: ${data['brand']}\nStock: ${data['stock']}\nTreshold: ${data['treshold']}"),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            editTreshold(item.id, data);
                          } else if (value == 'order') {
                            ReOrder(item.id,data);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'edit', child: Text('Edit treshold')),
                          PopupMenuItem(value: 'order', child: Text('reorder')),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
