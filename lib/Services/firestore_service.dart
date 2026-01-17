import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notes.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<NoteModel?> createNote(NoteModel note) async {
    try {
      DocumentReference docRef = await _firestore.collection('notes').add({
        'userId': note.userId,
        'title': note.title,
        'description': note.description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      note.noteId = docRef.id;
      return note;
    } catch (e) {
      print('Error creating note: $e');
      return null;
    }
  }

  Stream<List<NoteModel>> getUserNotes(String userId) {
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return NoteModel(
          noteId: doc.id,
          userId: data['userId'] ?? '',
          title: data['title'] ?? '',
          description: data['description'] ?? '',
        );
      }).toList();
    });
  }

  Future<List<NoteModel>> getUserNotesFuture(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NoteModel(
          noteId: doc.id,
          userId: data['userId'] ?? '',
          title: data['title'] ?? '',
          description: data['description'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error getting notes: $e');
      return [];
    }
  }

  Future<NoteModel?> getNoteById(String noteId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('notes')
          .doc(noteId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return NoteModel(
          noteId: doc.id,
          userId: data['userId'] ?? '',
          title: data['title'] ?? '',
          description: data['description'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Error getting note: $e');
      return null;
    }
  }

  Future<bool> updateNote(NoteModel note) async {
    try {
      await _firestore.collection('notes').doc(note.noteId).update({
        'title': note.title,
        'description': note.description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating note: $e');
      return false;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();
      return true;
    } catch (e) {
      print('Error deleting note: $e');
      return false;
    }
  }

  Future<bool> deleteAllUserNotes(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (e) {
      print('Error deleting all notes: $e');
      return false;
    }
  }

  Future<List<NoteModel>> searchNotes(String userId, String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return NoteModel(
              noteId: doc.id,
              userId: data['userId'] ?? '',
              title: data['title'] ?? '',
              description: data['description'] ?? '',
            );
          })
          .where((note) =>
              note.title.toLowerCase().contains(query.toLowerCase()) ||
              note.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Error searching notes: $e');
      return [];
    }
  }

  Future<int> getNotesCount(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.size;
    } catch (e) {
      print('Error getting notes count: $e');
      return 0;
    }
  }
}