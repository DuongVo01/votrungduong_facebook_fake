import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:votrungduong_facebook_fake/models/Post.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String baseUrl = 'https://lastgoldbag44.conveyor.cloud/api/PostApi';
  List<Post> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
  Future<void> fetchPosts() async {
    try {
      final token = await _getToken();
      final response = await http.get(Uri.parse('$baseUrl/GetPosts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },);
      if (response.statusCode == 200) {

        List<dynamic> data = json.decode(response.body);
        setState(() {
          posts = data.map((item) => Post.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching posts: $e')),
      );
    }
  }

  Future<void> addPost(String content, String imageUrl) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/AddPost'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "authorName": "Anonymous",
          "content": content,
          "imageUrl": imageUrl,
          "likes": 0,
        }),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post added successfully')),
        );
        fetchPosts(); // Cập nhật danh sách bài viết
      } else {
        throw Exception('Failed to add post');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding post: $e')),
      );
    }
  }

  Future<void> editPost(Post updatedPost) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/UpdatePost/${updatedPost.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updatedPost.toJson()),
      );

      if (response.statusCode == 204) {
        setState(() {
          // Tìm và cập nhật bài viết đã chỉnh sửa trong danh sách `posts`
          int index = posts.indexWhere((post) => post.id == updatedPost.id);
          if (index != -1) {
            posts[index] = updatedPost;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully')),
        );
      } else {
        throw Exception('Failed to update post');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating post: $e')),
      );
    }
  }


  Future<void> deletePost(int id) async {
    try {
      final token = await _getToken();
      final response = await http.delete(Uri.parse('$baseUrl/DeletePost/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },);
      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
        fetchPosts(); // Cập nhật danh sách bài viết
      } else {
        throw Exception('Failed to delete post');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }

  void showAddPostDialog() {
    final TextEditingController contentController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Enter your post content...',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    hintText: 'Enter image URL (optional)...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (contentController.text.isNotEmpty) {
                  addPost(contentController.text, imageUrlController.text);
                }
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  void showEditDialog(Post post) {
    final TextEditingController contentController =
    TextEditingController(text: post.content);
    final TextEditingController imageUrlController =
    TextEditingController(text: post.imageUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trường nhập nội dung bài viết
                TextField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Enter post content...',
                  ),
                ),
                const SizedBox(height: 10),

                // Trường nhập URL hình ảnh
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    hintText: 'Enter image URL (optional)...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Nút Cancel
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),

            // Nút Save
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Tạo một bài viết mới với dữ liệu đã chỉnh sửa
                final updatedPost = Post(
                  id: post.id, // Giữ nguyên ID của bài viết
                  authorName: 'Duy Khoa 03', // Giữ nguyên tên tác giả
                  content: contentController.text, // Nội dung đã chỉnh sửa
                  imageUrl: imageUrlController.text, // URL hình ảnh đã chỉnh sửa
                  likes: post.likes, // Giữ nguyên số lượt thích
                );

                // Gửi bài viết đã chỉnh sửa đến API và cập nhật danh sách
                editPost(updatedPost);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'facebook',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Post Composer
            Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/n.png'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: showAddPostDialog,
                        child: const Text(
                          "What's on your mind?",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Post Feed
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post Header
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage('assets/n.png'),
                        ),
                        title: Text(
                          post.authorName ?? 'Anonymous',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${post.likes ?? 0} Likes',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'edit') {
                              showEditDialog(post);
                            } else if (value == 'delete') {
                              deletePost(post.id!);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),

                      // Post Content
                      if (post.content != null &&
                          post.content!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            post.content!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),

                      // Post Image
                      if (post.imageUrl != null &&
                          post.imageUrl!.isNotEmpty)
                        Image.network(
                          post.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                        ),

                      // Post Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                post.likes = (post.likes ?? 0) + 1;
                              });
                            },
                            icon: const Icon(Icons.thumb_up_alt_outlined,
                                color: Colors.grey),
                            label: const Text(
                              'Like',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.comment_outlined,
                                color: Colors.grey),
                            label: const Text(
                              'Comment',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.share_outlined,
                                color: Colors.grey),
                            label: const Text(
                              'Share',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}