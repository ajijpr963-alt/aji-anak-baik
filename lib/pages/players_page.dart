
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final Color peach = const Color(0xFFB88C83);
  final Color cream = const Color(0xFFFFF8F5);
  final Color brown = const Color(0xFF57443F);

  final ImagePicker picker = ImagePicker();
  final TextEditingController searchController =
      TextEditingController();

  List<Map<String, dynamic>> items = [];

  List<String> categories = [
    'Books',
    'Movies',
    'Places',
    'Favorites',
  ];

  String selectedCategory = 'All';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =========================
  // LOAD DAN SIMPAN DATA
  // =========================

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedItems = prefs.getString('collections');
    final savedCategories = prefs.getStringList('categories');

    if (savedItems != null) {
      final decoded = jsonDecode(savedItems) as List;

      items = decoded.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();
    }

    if (savedCategories != null) {
      categories = savedCategories;
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'collections',
      jsonEncode(items),
    );

    await prefs.setStringList(
      'categories',
      categories,
    );
  }

  // =========================
  // PILIH DAN SIMPAN FOTO
  // =========================

  Future<String?> pickImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image == null) return null;

      final directory = await getApplicationDocumentsDirectory();

      final fileName =
          'collection_${DateTime.now().microsecondsSinceEpoch}'
          '${image.path.substring(image.path.lastIndexOf('.'))}';

      final savedImage = await File(image.path).copy(
        '${directory.path}/$fileName',
      );

      return savedImage.path;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih foto: $e')),
        );
      }
      return null;
    }
  }

  // =========================
  // TAMBAH KATEGORI
  // =========================

  Future<void> addCategory() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          title: Text(
            'New Category',
            style: TextStyle(color: brown),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Category name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: peach,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (name == null || name.isEmpty) return;

    final exists = categories.any(
      (category) => category.toLowerCase() == name.toLowerCase(),
    );

    if (exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kategori sudah tersedia!'),
          ),
        );
      }
      return;
    }

    setState(() {
      categories.add(name);
      selectedCategory = name;
    });

    await saveData();
  }

  // =========================
  // FORM TAMBAH / EDIT ITEM
  // =========================

  Future<void> showItemForm({
    Map<String, dynamic>? existingItem,
  }) async {
    final nameController = TextEditingController(
      text: existingItem?['name'] ?? '',
    );

    final descriptionController = TextEditingController(
      text: existingItem?['description'] ?? '',
    );

    String category = existingItem?['category'] ?? categories.first;
    String? imagePath = existingItem?['image'];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, updateDialog) {
            return AlertDialog(
              backgroundColor: cream,
              title: Text(
                existingItem == null
                    ? 'Add New Item'
                    : 'Edit Collection',
                style: TextStyle(
                  color: brown,
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FOTO
                    GestureDetector(
                      onTap: () async {
                        final image = await pickImage();

                        if (image != null) {
                          updateDialog(() {
                            imagePath = image;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 155,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5DF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: imagePath != null &&
                                File(imagePath!).existsSync()
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  File(imagePath!),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    color: peach,
                                    size: 35,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add Photo',
                                    style: TextStyle(color: brown),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // NAMA
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        hintText: 'Enter name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // KATEGORI
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: categories.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          updateDialog(() {
                            category = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    // DESKRIPSI
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Write something about this item...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      return;
                    }

                    Navigator.pop(dialogContext, {
                      'name': nameController.text.trim(),
                      'category': category,
                      'description':
                          descriptionController.text.trim(),
                      'image': imagePath,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: peach,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();

    if (result == null) return;

    setState(() {
      if (existingItem == null) {
        items.add(result);
      } else {
        existingItem.addAll(result);
      }

      selectedCategory = 'All';
    });

    await saveData();
  }

  // =========================
  // HAPUS ITEM
  // =========================

  Future<void> deleteItem(Map<String, dynamic> item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          title: Text(
            'Delete Item?',
            style: TextStyle(color: brown),
          ),
          content: const Text(
            'Apakah kamu yakin ingin menghapus koleksi ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      items.remove(item);
    });

    await saveData();
  }

  // =========================
  // PENCARIAN DAN FILTER
  // =========================

  List<Map<String, dynamic>> get filteredItems {
    final query = searchController.text.toLowerCase();

    return items.where((item) {
      final matchesCategory =
          selectedCategory == 'All' ||
          item['category'] == selectedCategory;

      final matchesSearch =
          (item['name'] ?? '').toString().toLowerCase().contains(query) ||
          (item['description'] ?? '')
              .toString()
              .toLowerCase()
              .contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // =========================
  // KARTU ITEM
  // =========================

  Widget collectionCard(Map<String, dynamic> item) {
    final imagePath = item['image'] as String?;

    return GestureDetector(
      onTap: () => showItemForm(existingItem: item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: peach.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.15,
              child: imagePath != null &&
                      File(imagePath).existsSync()
                  ? Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: const Color(0xFFF3E5DF),
                      child: Icon(
                        Icons.photo_outlined,
                        size: 45,
                        color: peach,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(11, 11, 7, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: brown,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    item['category'] ?? '',
                    style: TextStyle(
                      color: peach,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    (item['description'] ?? '').isEmpty
                        ? 'No description'
                        : item['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: brown.withOpacity(0.65),
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => deleteItem(item),
                      icon: Icon(
                        Icons.delete_outline,
                        color: peach,
                        size: 20,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // TAMPILAN UTAMA
  // =========================

  @override
  Widget build(BuildContext context) {
    final visibleItems = filteredItems;

    return Scaffold(
      backgroundColor: cream,

      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: brown,
        elevation: 0,
        title: const Text(
          'My Collections',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: addCategory,
            icon: Icon(Icons.create_new_folder_outlined, color: peach),
            tooltip: 'Add Category',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showItemForm();
        },
        backgroundColor: peach,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),

      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: peach),
            )
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your little library ♡',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: brown,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Keep everything you love in one place.',
                          style: TextStyle(
                            color: brown.withOpacity(0.65),
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // TOTAL COLLECTION
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E5DF),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.collections_bookmark_outlined,
                                color: peach,
                                size: 32,
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${items.length} Items',
                                    style: TextStyle(
                                      color: brown,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${categories.length} Categories',
                                    style: TextStyle(
                                      color: brown.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // SEARCH
                        TextField(
                          controller: searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search your collections...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: peach,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // CATEGORY FILTER
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              'All',
                              ...categories,
                            ].map((category) {
                              final selected =
                                  selectedCategory == category;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(category),
                                  selected: selected,
                                  onSelected: (_) {
                                    setState(() {
                                      selectedCategory = category;
                                    });
                                  },
                                  selectedColor: peach,
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : brown,
                                  ),
                                  side: BorderSide.none,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // GALLERY GRID
                  Expanded(
                    child: visibleItems.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(25),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.collections_outlined,
                                    color: peach,
                                    size: 60,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    items.isEmpty
                                        ? 'Your collection is empty.'
                                        : 'No items found.',
                                    style: TextStyle(
                                      color: brown,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Start adding something you love ♡',
                                    style: TextStyle(
                                      color: brown.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              18, 5, 18, 90,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 13,
                              mainAxisSpacing: 13,
                              childAspectRatio: 0.68,
                            ),
                            itemCount: visibleItems.length,
                            itemBuilder: (context, index) {
                              return collectionCard(
                                visibleItems[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
