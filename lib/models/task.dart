class Task {
  final String title;
  final String priority;
  final DateTime dateTime;
  final String? description; // Optional description field
  bool isDone;

  Task(
    this.title, 
    this.priority, 
    this.dateTime, {
    this.description,
    this.isDone = false,
  });

  // Helper method to get priority color
  String get priorityLevel => priority.toLowerCase();
  
  // Helper method to check if task is overdue
  bool get isOverdue => !isDone && DateTime.now().isAfter(dateTime);
  
  // Helper method to format date
  String get formattedDate {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
  
  // Helper method to format time
  String get formattedTime {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  // Helper method to get full formatted date and time
  String get formattedDateTime {
    return '$formattedDate at $formattedTime';
  }

  // Method to toggle task completion
  void toggleDone() {
    isDone = !isDone;
  }

  // Method to create a copy of the task with updated values
  Task copyWith({
    String? title,
    String? priority,
    DateTime? dateTime,
    String? description,
    bool? isDone,
  }) {
    return Task(
      title ?? this.title,
      priority ?? this.priority,
      dateTime ?? this.dateTime,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
    );
  }

  // Convert to Map for storage/serialization
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'priority': priority,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'description': description,
      'isDone': isDone,
    };
  }

  // Create Task from Map for loading/deserialization
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      map['title'] as String,
      map['priority'] as String,
      DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
      description: map['description'] as String?,
      isDone: map['isDone'] as bool? ?? false,
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'Task(title: $title, priority: $priority, dateTime: $dateTime, description: $description, isDone: $isDone)';
  }

  // Override equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.title == title &&
        other.priority == priority &&
        other.dateTime == dateTime &&
        other.description == description &&
        other.isDone == isDone;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        priority.hashCode ^
        dateTime.hashCode ^
        description.hashCode ^
        isDone.hashCode;
  }
}