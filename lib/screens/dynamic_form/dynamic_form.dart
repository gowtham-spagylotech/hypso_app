import 'package:flutter/material.dart';

class DynamicForm extends StatefulWidget {
  final List<Map<String, dynamic>> formFields;

  DynamicForm({required this.formFields});

  @override
  _DynamicFormState createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> formData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: _buildFormFields(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            // Form is valid, handle form submission
            _formKey.currentState?.save();
            // Do something with the form data
            print(formData);
          }
        },
        child: Icon(Icons.save),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    List<Widget> fields = [];

    for (var field in widget.formFields) {
      String type = field['type'];
      String label = field['label'];
      String key = field['key'];

      switch (type) {
        case 'text':
          fields.add(
            TextFormField(
              decoration: InputDecoration(labelText: label),
              onSaved: (value) => formData[key] = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '$label is required';
                }
                return null;
              },
            ),
          );
          break;
        case 'number':
          fields.add(
            TextFormField(
              decoration: InputDecoration(labelText: label),
              keyboardType: TextInputType.number,
              onSaved: (value) => formData[key] = int.parse(value ?? '0'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '$label is required';
                }
                return null;
              },
            ),
          );
          break;
        case 'dropdown':
          fields.add(
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: label),
              items: (field['options'] as List<String>).map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                formData[key] = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '$label is required';
                }
                return null;
              },
            ),
          );
          break;
        case 'checkbox':
          fields.add(
            CheckboxListTile(
              title: Text(label),
              value: formData[key] ?? false,
              onChanged: (value) {
                setState(() {
                  formData[key] = value;
                });
              },
            ),
          );
          break;
        case 'radio':
          fields.addAll(
            (field['options'] as List<String>).map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: formData[key],
                onChanged: (value) {
                  setState(() {
                    formData[key] = value;
                  });
                },
              );
            }).toList(),
          );
          break;
        case 'date':
          fields.add(
            TextFormField(
              decoration: InputDecoration(labelText: label),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  formData[key] = pickedDate.toLocal().toString();
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '$label is required';
                }
                return null;
              },
            ),
          );
          break;
        case 'file':
          fields.add(
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement file picker logic here
                  },
                  child: Text('Choose File'),
                ),
                SizedBox(width: 8),
                Text(formData[key] ?? 'No file chosen'),
              ],
            ),
          );
          break;
        case 'email':
          fields.add(
            TextFormField(
              decoration: InputDecoration(labelText: label),
              keyboardType: TextInputType.emailAddress,
              onSaved: (value) => formData[key] = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '$label is required';
                }
                if (!RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
          );
          break;
        case 'password':
          fields.add(
            TextFormField(
              decoration: InputDecoration(labelText: label),
              obscureText: true,
              onSaved: (value) => formData[key] = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '$label is required';
                }
                // You can add more password validation logic if needed
                return null;
              },
            ),
          );
          break;
      }
    }

    return fields;
  }
}


