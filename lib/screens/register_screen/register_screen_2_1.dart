import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "package:tuberculos/services/api.dart";
import "package:tuberculos/utils.dart";

class ChooseApotekerDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ChooseApotekerDialogState();
}

class _ChooseApotekerDialogState extends State<ChooseApotekerDialog> {
  String query = "";
  bool isLoading = false;
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      query = controller.text;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Widget _getCircleAvatarChild(document) {
    if (document["photoUrl"] == null) {
      if (document["displayName"] != null) {
        return new Text(document["displayName"]);
      } else {
        return new Text("...");
      }
    }
    return null;
  }

  Widget _buildStreams() {
    return new StreamBuilder<QuerySnapshot>(
        stream: apotekerReference.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          Widget child;
          if (!snapshot.hasData) {
            child = const Text('Loading...');
          }
          final data = snapshot.data.documents.where((documentSnapshot) {
            if (query.isEmpty)
              return true;
            else if (documentSnapshot.documentID.contains(query))
              return true;
            else if (documentSnapshot.data["displayName"].contains(query))
              return true;
            else
              return false;
          }).toList();
          final int dataCount = data.length;
          if (dataCount > 0) {
            child = new ListView.builder(
              itemCount: dataCount,
              itemBuilder: (_, int index) {
                final DocumentSnapshot document = data[index];
                return new ListTile(
                    leading: new CircleAvatar(
                      backgroundImage: document['photoUrl'] != null
                          ? new NetworkImage(document['photoUrl'])
                          : null,
                      child: _getCircleAvatarChild(document),
                    ),
                    subtitle:
                        new Text(document['email'] ?? '<No message retrieved>'),
                    title: new Text('${document["displayName"]}'),
                    onTap: () {
                      Navigator.pop(context, document["email"]);
                    });
              },
            );
          } else {
            child = new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(
                      "Maaf, belum ada Apoteker yang terdaftar dalam sistem."),
                ],
              ),
            );
          }
          return child;
        });
  }

  @override
  Widget build(BuildContext context) {
    return new Dialog(
      child: _buildStreams(),
    );
  }
}