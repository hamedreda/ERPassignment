import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBranches extends StatefulWidget {
  const AdminBranches({super.key});

  @override
  State<AdminBranches> createState() => _AdminBranchesState();
}

class _AdminBranchesState extends State<AdminBranches> {
  final _branchNameController = TextEditingController();
  final _branchAddressController = TextEditingController();
  final _branchContactController = TextEditingController();

  void addBranch() async{
    String name = _branchNameController.text.trim();
    String address = _branchAddressController.text.trim();
    String contact = _branchContactController.text.trim();

    if(name.isNotEmpty && address.isNotEmpty && contact.isNotEmpty){
      DocumentReference docRef = await FirebaseFirestore.instance.collection('branches').add(
          {'name':name,'address':address,'contact':contact,'timestamp':FieldValue.serverTimestamp()}
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("added branch: ${docRef.id}")));
      _branchNameController.clear();
      _branchAddressController.clear();
      _branchContactController.clear();
    }
    else
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed, Please fill all fields")));
  }

  void deleteBranch(String docId) async{
    await FirebaseFirestore.instance.collection('branches').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deleted Branch")));
  }

  void editBranchDialog(String docId, Map<String, dynamic> currentData) {
    final _editNameController = TextEditingController(text: currentData['name']);
    final _editAddressController = TextEditingController(text: currentData['address']);
    final _editContactController = TextEditingController(text: currentData['contact']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Branch"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _editNameController, decoration: InputDecoration(labelText: "Branch Name")),
                TextField(controller: _editAddressController, decoration: InputDecoration(labelText: "Branch Address")),
                TextField(controller: _editContactController, decoration: InputDecoration(labelText: "Branch Contact")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                String newName = _editNameController.text.trim();
                String newAddress = _editAddressController.text.trim();
                String newContact = _editContactController.text.trim();

                if (newName.isNotEmpty && newAddress.isNotEmpty && newContact.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('branches').doc(docId).update({
                    'name': newName,
                    'address': newAddress,
                    'contact': newContact,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Branch updated")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields")));
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
            TextField(decoration: InputDecoration(labelText: "branch name"),controller: _branchNameController,),
            TextField(decoration: InputDecoration(labelText: "branch address"),controller: _branchAddressController),
            TextField(decoration: InputDecoration(labelText: "branch contact"),controller: _branchContactController),
            SizedBox(height: 10,),
            ElevatedButton(onPressed: ()=>addBranch(), child: Text("Add New Branch")),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('branches').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final branches = snapshot.data!.docs;

                if (branches.isEmpty) return Text("No branches found.");

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: branches.length,
                  itemBuilder: (context, index) {
                    final branch = branches[index];
                    final data = branch.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['name'] ?? ''),
                      subtitle: Text("Address: ${data['address'] ?? ''}\nContact: ${data['contact'] ?? ''}\nID: ${branch.id}"),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            editBranchDialog(branch.id, data);
                          } else if (value == 'delete') {
                            deleteBranch(branch.id);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
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
