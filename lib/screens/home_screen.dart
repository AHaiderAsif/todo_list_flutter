import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _todoController = TextEditingController();
  String _selectedCategory = 'Code';

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  void _handleSaveTask(BuildContext context) async {
    if (_todoController.text.trim().isEmpty) return;

    final todoProv = context.read<TodoProvider>();
    String title = _todoController.text.trim();
    String category = _selectedCategory;

    Navigator.pop(context);
    await todoProv.createNewTask(title, category);
    _todoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final todoProvider = context.watch<TodoProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Stack(
        children: [
          Container(
            height: size.height * 0.31,
            width: size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assalam-o-Alaikum,',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                          ),
                          const Text(
                            'My Workspace',
                            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                          icon: const Icon(Iconsax.logout, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // 🔥 STABLE STREAM CONNECTOR VIA PROVIDER STREAM
                  StreamBuilder<QuerySnapshot>(
                    stream: todoProvider.tasksStream, // Isko provider ke getter se hi chalne dein
                    builder: (context, snapshot) {
                      // Agar snapshot abhi tak connect nahi hua ya active nahi hai
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 80),
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      int total = docs.length;
                      int completed = docs.where((doc) => doc['isDone'] == true).length;
                      int pending = total - completed;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(10),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem('Total Tasks', total.toString(), Colors.blue),
                                Container(width: 1, height: 40, color: Colors.grey.shade200),
                                _buildStatItem('Completed', completed.toString(), Colors.green),
                                Container(width: 1, height: 40, color: Colors.grey.shade200),
                                _buildStatItem('Pending', pending.toString(), Colors.orange),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),
                          const Text(
                            "Today's Tasks",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                          ),
                          const SizedBox(height: 15),

                          SizedBox(
                            height: size.height * 0.45,
                            child: docs.isEmpty
                                ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Iconsax.document_text5, size: 60, color: Colors.grey.shade300),
                                  const SizedBox(height: 10),
                                  Text('All caught up! No pending tasks.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                                ],
                              ),
                            )
                                : ListView.builder(
                              itemCount: docs.length,
                              padding: const EdgeInsets.only(bottom: 20),
                              itemBuilder: (context, index) {
                                final todo = docs[index];
                                String docId = todo.id;
                                String title = todo['title'] ?? '';
                                bool isDone = todo['isDone'] ?? false;
                                String category = todo['category'] ?? 'Code';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDone ? Colors.green.shade100 : Colors.transparent,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    leading: GestureDetector(
                                      onTap: () => todoProvider.toggleTask(docId, isDone),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        decoration: BoxDecoration(
                                          color: isDone ? Colors.green : Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isDone ? Colors.green : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3),
                                          child: isDone
                                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                                              : const SizedBox(width: 16, height: 16),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: isDone ? Colors.grey.shade400 : const Color(0xFF2C3E50),
                                        decoration: isDone ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getCategoryColor(category).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            category,
                                            style: TextStyle(
                                              color: _getCategoryColor(category),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        IconButton(
                                          onPressed: () => todoProvider.removeTask(docId),
                                          icon: const Icon(Iconsax.trash, color: Colors.redAccent, size: 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskBottomSheet(context),
        backgroundColor: const Color(0xFF11998e),
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Code': return Colors.deepPurple;
      case 'Uni': return Colors.blue;
      case 'Bug': return Colors.red;
      case 'Gaming': return Colors.orange;
      default: return Colors.blueGrey;
    }
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    top: 20, left: 20, right: 20
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Create New Task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _todoController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'What needs to be done?',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Select Category:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ['Code', 'Uni', 'Bug', 'Gaming'].map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: _getCategoryColor(cat).withOpacity(0.2),
                          labelStyle: TextStyle(
                              color: isSelected ? _getCategoryColor(cat) : Colors.black87,
                              fontWeight: FontWeight.bold
                          ),
                          onSelected: (bool selected) {
                            setModalState(() {
                              _selectedCategory = cat;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () => _handleSaveTask(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF11998e),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Task', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }
        );
      },
    );
  }
}