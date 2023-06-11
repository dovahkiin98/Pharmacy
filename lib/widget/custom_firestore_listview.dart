import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

import 'error_view.dart';

class CustomFirestoreListView<Document> extends StatelessWidget {
  final Query<Document> query;
  final FirestoreItemBuilder<Document> itemBuilder;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const CustomFirestoreListView({
    required this.query,
    required this.itemBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FirestoreListView(
      query: query,
      itemBuilder: itemBuilder,
      errorBuilder: (context, e, stacktrace) {
        return ErrorView(error: e);
      },
      loadingBuilder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
    );
  }
}
