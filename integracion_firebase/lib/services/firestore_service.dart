import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/universidad.dart';

class FirestoreService {
  final CollectionReference _universidadesCollection =
      FirebaseFirestore.instance.collection('universidades');

  // Create
  Future<void> addUniversidad(Universidad universidad) {
    return _universidadesCollection.add(universidad.toMap());
  }

  // Read (Stream)
  Stream<List<Universidad>> getUniversidades() {
    return _universidadesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Universidad.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Update
  Future<void> updateUniversidad(Universidad universidad) {
    return _universidadesCollection
        .doc(universidad.id)
        .update(universidad.toMap());
  }

  // Delete
  Future<void> deleteUniversidad(String id) {
    return _universidadesCollection.doc(id).delete();
  }
}
