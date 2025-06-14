import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketplace_app_v0/models/animal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddAnimalForm extends StatefulWidget {
  const AddAnimalForm({super.key});

  @override
  State<AddAnimalForm> createState() => _AddAnimalFormState();
}

class _AddAnimalFormState extends State<AddAnimalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _status = 'alive';
  final _supabase = Supabase.instance.client;
  bool _isSubmitting = false;

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<String?> _uploadImage(XFile file) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final bytes = await file.readAsBytes();
      final fileName =
          'animals/${user.id}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      // Upload the file bytes to Supabase Storage
      await _supabase.storage.from('animal-images').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get the public URL of the uploaded image
      final publicUrl =
          _supabase.storage.from('animal-images').getPublicUrl(fileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')),
        );
      }
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // Dismiss keyboard
    setState(() => _isSubmitting = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      String? imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _uploadImage(_pickedImage!);
        if (imageUrl == null) throw Exception('Image upload failed');
      }

      final animal = Animal(
        id: '',
        ownerId: user.id,
        name: _nameController.text.trim(),
        status: _status,
        imageUrl: imageUrl,
        createdAt: null,
      );

      await _supabase.from('animals').insert({
        'owner_id': animal.ownerId,
        'name': animal.name,
        'status': animal.status,
        'image_url': animal.imageUrl,
      });

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding animal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add New Animal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Animal Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 12),

              // Image picker button + preview
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: _pickedImage == null
                      ? const Center(child: Text('Tap to select image'))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_pickedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ['alive', 'sick', 'dead']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add Animal'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
