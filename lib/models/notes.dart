class NoteModel {
  String noteId;
  String userId;
  String title;
  String description;

  NoteModel({
    required this.noteId,
    required this.userId,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'noteId': noteId,
      'userId': userId,
      'title': title,
      'description': description,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NoteModel(
      noteId: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Note: $title - $description';
  }
}