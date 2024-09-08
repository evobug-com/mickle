import 'package:flutter/material.dart';

class ChannelListRoomDialog extends StatefulWidget {
  final bool isEdit;
  final String inputName;
  final String inputDescription;
  final void Function(String title, String description, bool isPrivate) onSubmitted;

  const ChannelListRoomDialog({
    Key? key,
    required this.onSubmitted,
    this.inputName = '',
    this.inputDescription = '',
    required this.isEdit,
  }) : super(key: key);

  @override
  State<ChannelListRoomDialog> createState() => _ChannelListRoomDialogState();
}

class _ChannelListRoomDialogState extends State<ChannelListRoomDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isPrivateRoom = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.inputName);
    _descriptionController = TextEditingController(text: widget.inputDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String get dialogTitle => widget.isEdit ? 'Edit Room' : 'Create New Room';
  String get confirmButtonLabel => widget.isEdit ? 'Update' : 'Create';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dialogTitle,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildTextField(_nameController, 'Name', Icons.label),
            const SizedBox(height: 16),
            _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 3),
            if (!widget.isEdit) ...[
              const SizedBox(height: 16),
              _buildPrivateRoomSwitch(),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                  ),
                  child: Text(confirmButtonLabel),
                  onPressed: () {
                    widget.onSubmitted(
                      _nameController.text,
                      _descriptionController.text,
                      _isPrivateRoom,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    );
  }

  Widget _buildPrivateRoomSwitch() {
    return SwitchListTile(
      title: const Text('Private Room'),
      subtitle: const Text('Only visible to you. Invite others manually.'),
      value: _isPrivateRoom,
      onChanged: (value) => setState(() => _isPrivateRoom = value),
      secondary: const Icon(Icons.lock_outline),
    );
  }
}