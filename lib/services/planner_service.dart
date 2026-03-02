import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/models/planner_item/planner_item.dart';

class PlannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPlannerItem(PlannerItem item) async {
    await _firestore.collection('plannerItems').doc(item.id).set(item.toJson());
  }

  Future<void> updatePlannerItem(PlannerItem item) async {
    await _firestore.collection('plannerItems').doc(item.id).update(item.toJson());
  }

  Future<void> deletePlannerItem(String id) async {
    await _firestore.collection('plannerItems').doc(id).delete();
  }

  Stream<List<PlannerItem>> getPlannerItemStream(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('plannerItems')
        // Match the `ownerId` field from PlannerItem.
        .where('ownerId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PlannerItem.fromJson(doc.data())).toList(),
        );
  }

  Future<void> togglePlannerItemCompletion(String itemId, bool isCompleted) async {
    await _firestore
        .collection('plannerItems')
        .doc(itemId)
        .update({'isCompleted': isCompleted});
  }
}
