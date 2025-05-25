import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminSKU extends StatefulWidget {
  const AdminSKU({super.key});

  @override
  State<AdminSKU> createState() => _AdminSKUState();
}

class _AdminSKUState extends State<AdminSKU> {
  String? selectedCategory;
  String? selectedSubCategory;
  int sku = 110;
  final _ItemNameController = TextEditingController();
  final _SKUController = TextEditingController();
  final _BrandController = TextEditingController();

  final List<String> categories = ['Fresh Food', 'Snacks', 'Beverages'];
  final Map<String, List<String>> subCategoryMap = {
    'Fresh Food': ['Dairy', 'Eggs', 'Seafood'],
    'Snacks': ['Ice Cream', 'Chocolate', 'Chips'],
    'Beverages': ['Water', 'Juices', 'Soft Drinks'],
  };
  List<String> get subCategories {
    return selectedCategory != null ? subCategoryMap[selectedCategory!] ?? [] : [];
  }

  // void GenerateSku(){
  //   sku++;
  //   setState(() {
  //     _SKUController.text = sku.toString();
  //   });
  // }
  void AddItem() async {
    String name = _ItemNameController.text.trim();
    String brand = _BrandController.text.trim();

    if (name.isEmpty || brand.isEmpty || selectedCategory == null || selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference counterRef = firestore.collection('counters').doc('sku_counter');

    await firestore.runTransaction((transaction) async {
      DocumentSnapshot counterSnapshot = await transaction.get(counterRef);

      int newSku;
      if (!counterSnapshot.exists) {
        // Initialize the counter if it doesn't exist
        transaction.set(counterRef, {'latest': 110});
        newSku = 110;
      } else {
        int latestSku = counterSnapshot.get('latest');
        newSku = latestSku + 1;
        transaction.update(counterRef, {'latest': newSku});
      }

      // Add the new product with the generated SKU
      transaction.set(firestore.collection('SKU').doc(), {
        'item': name,
        'SKU': newSku.toString(),
        'category': selectedCategory,
        'subcategory': selectedSubCategory,
        'brand': brand,
        'active': true,
        'stock': 0,
        'threshold': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the SKU controller text
      _SKUController.text = newSku.toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added item: ${_SKUController.text}")));

    // Clear input fields
    _ItemNameController.clear();
    _SKUController.clear();
    _BrandController.clear();
    setState(() {
      selectedCategory = null;
      selectedSubCategory = null;
    });
  }

  
  void Deactivate(String docId) async{
    final docRef = FirebaseFirestore.instance.collection('SKU').doc(docId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final currentData = docSnapshot.data() as Map<String, dynamic>;
      final currentActive = currentData['active'] as bool;

      await docRef.update({'active': !currentActive});

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Item has been ${!currentActive ? 'activated' : 'deactivated'}"))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Item not found"))
      );
    }
  }

  void editItem(String docId, Map<String, dynamic> currentData) {
    final _ItemNameController = TextEditingController(text: currentData['item']);
    final _BrandController = TextEditingController(text: currentData['brand']);
    String selectedEditCategory = currentData['category'];
    String selectedEditSubCategory = currentData['subcategory'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<String> editSubCategories = subCategoryMap[selectedEditCategory] ?? [];

            return AlertDialog(
              title: Text("Edit Item"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _ItemNameController,
                      decoration: InputDecoration(labelText: "Item Name"),
                    ),
                    TextField(
                      controller: _BrandController,
                      decoration: InputDecoration(labelText: "Brand"),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: "Category"),
                      value: selectedEditCategory,
                      items: categories
                          .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedEditCategory = val;
                          });
                        }
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: "Sub Category"),
                      value: selectedEditSubCategory,
                      items: (subCategoryMap[selectedEditCategory] ?? [])
                          .map((sub) => DropdownMenuItem(
                        value: sub,
                        child: Text(sub),
                      ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedEditSubCategory = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context), child: Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    String newName = _ItemNameController.text.trim();
                    String newBrand = _BrandController.text.trim();

                    if (newName.isNotEmpty &&
                        newBrand.isNotEmpty &&
                        selectedEditCategory.isNotEmpty &&
                        selectedEditSubCategory.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('SKU')
                          .doc(docId)
                          .update({
                        'item': newName,
                        'brand': newBrand,
                        'category': selectedEditCategory,
                        'subcategory': selectedEditSubCategory,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Successfully updated")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Failed, Please fill all fields")));
                    }
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
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
            TextField(decoration: InputDecoration(labelText: "item name"),controller: _ItemNameController,),
            Row(children: [
              Expanded(child: TextField(decoration: InputDecoration(labelText: "SKU Code"),controller: _SKUController,)),
              // Expanded(child: ElevatedButton(onPressed: ()=>GenerateSku(),child: Text("Generate"),))
            ],),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "category"),
              value: selectedCategory,
              items: categories.map((cat) => DropdownMenuItem(value: cat,child: Text(cat))).toList(),
              onChanged: (val){
                setState(() {
                  selectedCategory = val;
                  selectedSubCategory = null;
                });
              },
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Sub Category"),
              value: selectedSubCategory,
              items: subCategories.map((sub) => DropdownMenuItem(value: sub, child: Text(sub))).toList(),
              onChanged: (val) {
                setState(() {
                  selectedSubCategory = val;
                });
              },
            ),
            TextField(decoration: InputDecoration(labelText: "brand"),controller: _BrandController,),
            ElevatedButton(onPressed: ()=>AddItem(), child: Text("Add New Item")),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('SKU').orderBy('timestamp', descending: true).snapshots(),
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
                      subtitle: Text("${data['category']}, ${data['subcategory']}\nSKU: ${data['SKU']}\nBrand: ${data['brand']}\nActive: ${data['active']}"),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            editItem(item.id, data);
                          } else if (value == 'activity') {
                            Deactivate(item.id);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'activity', child: Text('De/Activate')),
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
