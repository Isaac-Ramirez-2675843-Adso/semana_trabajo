import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  
  List<Item> _items = [];
  String _name = '';
  String _date = '';
  double _price = 0.0;

  double _calculateTotalPrice() {
    return _items.fold(0.0, (sum, item) => sum + item.price);
  }

  double _paraIsaac() {
    return _items.fold(0.0, (sum, item) => sum + item.price * 0.50);
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final items = await _dbHelper.getItems();
    setState(() {
      _items = items;
    });
  }

  void _showForm({Item? item}) {
    if (item != null) {
      _name = item.name;
      _date = item.date;
      _price = item.price;
    } else {
      _name = '';
      _date = '';
      _price = 0.0;
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(item == null ? 'Agregar Item' : 'Editar Item'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Campo para Nombre
                  TextFormField(
                    
                    initialValue: _name,
                    
                    decoration: InputDecoration(labelText: 'Nombre'),
                    textCapitalization: TextCapitalization.words,
                    onSaved: (value) => _name = value!,

                   

                  
                  ),
                  // Campo para Fecha con DatePicker
                  TextButton(
                    onPressed: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate:
                            item != null
                                ? DateTime.parse(item.date)
                                : DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _date =
                              selectedDate.toIso8601String().split('T').first;
                        });
                      }
                    },
                    child: Text(
                      _date.isEmpty ? 'Seleccionar fecha' : 'Fecha: $_date',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),

                  // Campo para Precio
                  TextFormField(
                    initialValue: _price.toString(),
                    decoration: InputDecoration(labelText: 'Precio'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _price = double.parse(value!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  _formKey.currentState?.save();
                  if (item == null) {
                    _dbHelper.insertItem(
                      Item(name: _name, date: _date, price: _price),
                    );
                  } else {
                    _dbHelper.updateItem(
                      Item(
                        id: item.id,
                        name: _name,
                        date: _date,
                        price: _price,
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                  _loadItems();
                },
                child: Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _deleteItem(int id) async {
    await _dbHelper.deleteItem(id);
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Semana de trabajo con Jack')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, index) {
                final item = _items[index];
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name),
                      Text('Fecha: ${item.date}'),
                      Text('Precio: \$${item.price.toStringAsFixed(2)}'),
                    ],
                  ),
                  // subtitle: Text(
                  //   'Fecha: ${item.date} - Precio: \$${item.price.toStringAsFixed(2)}'
                  //   ,
                  // ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showForm(item: item),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteItem(item.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${_calculateTotalPrice().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Para Isaac: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${_paraIsaac().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showForm(),
      ),
    );
  }
}


// String capitalizeEachWord(String text) {
//     if (text.isEmpty) return text;
//     return text
//         .split(' ')
//         .map((word) => word.isNotEmpty
//             ? word[0].toUpperCase() + word.substring(1).toLowerCase()
//             : '')
//         .join(' ');
//   }