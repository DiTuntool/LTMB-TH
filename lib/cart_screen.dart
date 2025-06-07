import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _cartItems = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  // Load cart items from SharedPreferences
  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartData = prefs.getString('cartItems');
    if (cartData != null) {
      final List<dynamic> decodedData = jsonDecode(cartData);
      setState(() {
        _cartItems.clear();
        _cartItems.addAll(
          decodedData.map((item) => CartItem.fromJson(item)).toList(),
        );
      });
    }
  }

  // Save cart items to SharedPreferences
  Future<void> _saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      _cartItems.map((item) => item.toJson()).toList(),
    );
    await prefs.setString('cartItems', encodedData);
  }

  // Add new item to cart
  void _addItem() {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();

    if (name.isNotEmpty && priceText.isNotEmpty) {
      final price = double.tryParse(priceText);
      if (price != null) {
        setState(() {
          _cartItems.add(CartItem(name: name, price: price));
          _nameController.clear();
          _priceController.clear();
        });
        _saveCartItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập giá hợp lệ')),
        );
      }
    }
  }

  // Remove item from cart
  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
    _saveCartItems();
  }

  // Calculate total price
  double _calculateTotalPrice() {
    return _cartItems.fold(0, (sum, item) => sum + item.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input fields for adding new item
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên mặt hàng'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Giá (VND)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addItem,
              child: const Text('Thêm mặt hàng'),
            ),
            const SizedBox(height: 20),
            // Cart items list
            Expanded(
              child: ListView.builder(
                itemCount: _cartItems.length + 1, // +1 for total price
                itemBuilder: (context, index) {
                  if (index == _cartItems.length) {
                    // Display total price at the end
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Tổng giá: ${_calculateTotalPrice().toStringAsFixed(0)} VND',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  final item = _cartItems[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.price.toStringAsFixed(0)} VND'),
                    trailing: ElevatedButton(
                      onPressed: () => _removeItem(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, // Màu đỏ cho nút xóa
                        foregroundColor: Colors.white, // Màu chữ trắng
                        minimumSize: const Size(80, 36), // Kích thước nhỏ gọn
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Góc bo tròn
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('Xóa'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

// Model for cart item
class CartItem {
  final String name;
  final double price;

  CartItem({required this.name, required this.price});

  Map<String, dynamic> toJson() {
    return {'name': name, 'price': price};
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(name: json['name'], price: json['price']);
  }
}
