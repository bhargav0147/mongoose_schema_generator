import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData, FontWeight, TextAlign;
import 'package:schema_creator/Components/CustomButton.dart';

class SchemaForm extends StatefulWidget {
  @override
  _SchemaFormState createState() => _SchemaFormState();
}

class _SchemaFormState extends State<SchemaForm> {
  final List<FieldSchema> _fieldSchemas = [];
  final _formKey = GlobalKey<FormState>();
  final _fieldNameController = TextEditingController();
  final _schemaNameController = TextEditingController(); // Controller for the schema name
  String _selectedType = 'String';
  bool _isRequired = false;

  void _addField() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _fieldSchemas.add(FieldSchema(
          name: _fieldNameController.text,
          type: _selectedType,
          isRequired: _isRequired,
        ));
        _fieldNameController.clear();
        _isRequired = false;
      });
    }
  }

  String _generateSchemaCode(String schemaName) {
    StringBuffer schemaCode = StringBuffer();
    schemaCode.writeln("const { model, Schema } = require('mongoose');\n");
    schemaCode.writeln("const ${schemaName}Schema = new Schema({\n");

    for (var field in _fieldSchemas) {
      schemaCode.writeln('  ${field.name}: {');
      schemaCode.writeln('    type: ${field.type},');
      schemaCode.writeln('    required: ${field.isRequired.toString()},');
      schemaCode.writeln('  },');
    }

    schemaCode.writeln('}, { timestamps: true });\n');
    schemaCode.writeln("const ${schemaName} = model('${schemaName}', ${schemaName}Schema);\n");
    schemaCode.writeln("module.exports = ${schemaName};");

    return schemaCode.toString();
  }

  void _copyToClipboard(String schemaCode) {
    Clipboard.setData(ClipboardData(text: schemaCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schema code copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Mongoose Schema Generator',style: TextStyle(
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,fontSize: 20
        ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left Side: Form
            Expanded(
              flex: 1,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _schemaNameController, 
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        labelText: "Schema Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey),

                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.red),
                      
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.red),
                      
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue),
                  
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter A Schema Name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _fieldNameController,
                      decoration: const InputDecoration(labelText: 'Field Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a field name';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(labelText: 'Field Type'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedType = newValue!;
                        });
                      },
                      items: <String>['String', 'Number', 'Boolean']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _isRequired,
                          onChanged: (bool? value) {
                            setState(() {
                              _isRequired = value!;
                            });
                          },
                        ),
                        const Text('Required'),
                      ],
                    ),
                    CustomButton(name: 'Add Field', onPressed: _addField)
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20), // Space between form and preview
            // Right Side: Preview
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Generated Schema Code:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _generateSchemaCode(_schemaNameController.text.isEmpty ? 'User' : _schemaNameController.text), // Use schema name from the form
                    style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  CustomButton(name: "Copy Code to Clipboard", onPressed: () {
                      String schemaCode = _generateSchemaCode(_schemaNameController.text.isEmpty ? 'User' : _schemaNameController.text); // Change schema name if needed
                      _copyToClipboard(schemaCode);
                    })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FieldSchema {
  final String name;
  final String type;
  final bool isRequired;

  FieldSchema({required this.name, required this.type, required this.isRequired});
}
