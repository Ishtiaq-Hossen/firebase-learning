class Book{
  final String id,title,author,publisher,language;
  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.language
});
  
  factory Book.fromJson(String id, Map<String, dynamic> json){
    return Book(
        id: id, title: json['title'],
        author: json['author'],
        publisher: json['publisher'],
        language: json['language']
    );
  }
}