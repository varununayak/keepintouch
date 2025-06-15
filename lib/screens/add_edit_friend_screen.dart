import 'package:flutter/material.dart';
import '../models/friend.dart';

class AddEditFriendScreen extends StatefulWidget {
  final Friend? friend;
  const AddEditFriendScreen({super.key, this.friend});

  @override
  State<AddEditFriendScreen> createState() => _AddEditFriendScreenState();
}

class _AddEditFriendScreenState extends State<AddEditFriendScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  ClosenessTier _closenessTier = ClosenessTier.medium;
  String? _notes;
  DateTime? _lastContacted;

  @override
  void initState() {
    super.initState();
    if (widget.friend != null) {
      _name = widget.friend!.name;
      _closenessTier = widget.friend!.closenessTier;
      _notes = widget.friend!.notes;
      _lastContacted = widget.friend!.lastContacted;
    } else {
      _name = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friend == null ? 'Add Friend' : 'Edit Friend'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ClosenessTier>(
                value: _closenessTier,
                decoration: const InputDecoration(labelText: 'Closeness Tier'),
                items: ClosenessTier.values.map((tier) {
                  return DropdownMenuItem(
                    value: tier,
                    child: Text(_getTierLabel(tier)),
                  );
                }).toList(),
                onChanged: (tier) {
                  if (tier != null) setState(() => _closenessTier = tier);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(labelText: 'Notes'),
                onSaved: (value) => _notes = value,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_lastContacted == null
                    ? 'Last Contacted: Never'
                    : 'Last Contacted: ${_lastContacted!.toLocal().toString().split(' ')[0]}'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _lastContacted ?? now,
                      firstDate: DateTime(now.year - 10),
                      lastDate: now,
                    );
                    if (picked != null) {
                      setState(() => _lastContacted = picked);
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final newFriend = Friend(
                      id: widget.friend?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _name,
                      closenessTier: _closenessTier,
                      notes: _notes,
                      lastContacted: _lastContacted,
                    );
                    Navigator.of(context).pop(newFriend);
                  }
                },
                child: Text(widget.friend == null ? 'Add Friend' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTierLabel(ClosenessTier tier) {
    switch (tier) {
      case ClosenessTier.close:
        return 'Close - Weekly check-ins';
      case ClosenessTier.medium:
        return 'Medium - Monthly check-ins';
      case ClosenessTier.distant:
        return 'Distant - Every 2-3 months';
    }
  }
} 