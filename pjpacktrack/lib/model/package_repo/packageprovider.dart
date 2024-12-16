import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package.dart';

final packageProvider = StreamProvider.family<Package?, String>((ref, packageId) {
  return FirebaseFirestore.instance
      .collection('packages')
      .where('packageId', isEqualTo: packageId)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      return Package.fromDocument(snapshot.docs.first);
    } else {
      return null;
    }
  });
});