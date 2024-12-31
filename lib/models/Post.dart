class Post {
  Post({
    required this.id,
    required this.authorName,
    required this.content,
    required this.imageUrl,
    required this.likes,
  });

  final int? id;
  final String? authorName;
  final String? content;
  final String? imageUrl;
  late final int? likes;

  factory Post.fromJson(Map<String, dynamic> json){
    return Post(
      id: json["id"],
      authorName: json["authorName"],
      content: json["content"],
      imageUrl: json["imageUrl"],
      likes: json["likes"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "authorName": authorName,
    "content": content,
    "imageUrl": imageUrl,
    "likes": likes,
  };

}
