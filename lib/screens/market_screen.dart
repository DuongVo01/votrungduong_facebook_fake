import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:votrungduong_facebook_fake/models/Product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}
Future<String?> _getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}
class _MarketScreenState extends State<MarketScreen> {
  final String baseUrl = 'https://lastgoldbag44.conveyor.cloud/api/ProductApi';
  List<Product> products = [];
  List<Product> filteredProducts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final token = await _getToken();
      final response = await http.get(Uri.parse('$baseUrl/GetProducts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          products = data.map((item) => Product.fromJson(item)).toList();
          filteredProducts = products;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/AddProduct'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(product.toJson()),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
        await fetchProducts(); // Tải lại danh sách sản phẩm
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    }
  }

  Future<void> editProduct(Product product) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/UpdateProduct/${product.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(product.toJson()),
      );
      if (response.statusCode == 204) {
        setState(() {
          int index = products.indexWhere((p) => p.id == product.id);
          products[index] = product;
          filteredProducts = products;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error editing product: $e')),
      );
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final token = await _getToken();
      final response = await http.delete(Uri.parse('$baseUrl/DeleteProduct/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },);
      if (response.statusCode == 204) {
        setState(() {
          products.removeWhere((product) => product.id == id);
          filteredProducts = products;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  Future<void> searchProducts(String keyword) async {
    try {
      final token = await _getToken();
      final response = await http.get(Uri.parse('$baseUrl/SearchProducts/search?keyword=$keyword'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          filteredProducts = data.map((item) => Product.fromJson(item)).toList();
        });
      } else if (response.statusCode == 404) {
        setState(() {
          filteredProducts = [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching products: $e')),
      );
    }
  }

  void showAddEditDialog({Product? product}) {
    final TextEditingController nameController =
    TextEditingController(text: product?.name ?? '');
    final TextEditingController descriptionController =
    TextEditingController(text: product?.description ?? '');
    final TextEditingController priceController =
    TextEditingController(text: product?.price?.toString() ?? '');
    final TextEditingController imageController =
    TextEditingController(text: product?.image ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
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
                final Product newProduct = Product(
                  id: product == null ? 0 : product.id, // Gán id = 0 khi thêm mới
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text),
                  image: imageController.text,
                );
                if (product == null) {
                  addProduct(newProduct);
                } else {
                  editProduct(newProduct);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteProduct(id);
              },
              child: const Text('Delete'),
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
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.isEmpty) {
              setState(() {
                filteredProducts = products;
              });
            } else {
              searchProducts(value);
            }
          },
        ),
      ),
      body: filteredProducts.isEmpty
          ? const Center(
        child: Text('No products found.'),
      )
          : ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final Product product = filteredProducts[index];
          return Dismissible(
            key: Key(product.id.toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              confirmDelete(product.id!);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              leading: product.image != null && product.image!.isNotEmpty
                  ? Image.network(
                product.image!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 50),
              )
                  : const Icon(Icons.image_not_supported, size: 50),
              title: Text(product.name ?? 'No name'),
              subtitle: Text(product.description ?? 'No description'),
              trailing: Text('${product.price} VND'),
              onLongPress: () => showAddEditDialog(product: product),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(product.name ?? 'Product Details'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.image != null && product.image!.isNotEmpty)
                              Center(
                                child: Image.network(
                                  product.image!,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 100),
                                ),
                              ),
                            const SizedBox(height: 16),
                            const Text(
                              'Description:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(product.description ?? 'No description available'),
                            const SizedBox(height: 16),
                            Text(
                              'Price: ${product.price?.toStringAsFixed(2) ?? 'Unknown'} VND',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Đóng dialog
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}