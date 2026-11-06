
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conociendo tu IMC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
        useMaterial3: true,
      ),
      home: const PantallaImc(),
    );
  }
}

class PantallaImc extends StatefulWidget {
  const PantallaImc({super.key});

  @override
  State<PantallaImc> createState() => _PantallaImcState();
}

class _PantallaImcState extends State<PantallaImc> {
  // Controladores: uno por cada TextField
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _pesoCtrl = TextEditingController();
  final TextEditingController _estaturaCtrl = TextEditingController();

  // Variable de estado con el texto que se muestra en la etiqueta
  String _resultado = '';

  // Color del borde de la etiqueta según la categoría (reto opcional)
  Color _colorBorde = Colors.indigo;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _pesoCtrl.dispose();
    _estaturaCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Lógica de negocio
  // ---------------------------------------------------------------------------

  /// Aplica la fórmula IMC = peso / (estatura en metros)^2.
  /// Convierte cm a m y redondea el resultado a un decimal.
  double calcularImc(double pesoKg, double estaturaCm) {
    final double estaturaM = estaturaCm / 100; // cm -> m
    final double imc = pesoKg / (estaturaM * estaturaM);
    // Redondeo a 1 decimal y se regresa a double
    return double.parse(imc.toStringAsFixed(1));
  }

  /// Clasifica el IMC (ya redondeado) con los límites 18.5, 25 y 30.
  String obtenerCategoria(double imc) {
    if (imc < 18.5) {
      return 'Bajo peso';
    } else if (imc < 25.0) {
      return 'Peso normal';
    } else if (imc < 30.0) {
      return 'Sobrepeso';
    } else {
      return 'Obesidad';
    }
  }

  /// Mensaje de recomendación según la categoría.
  String _obtenerMensaje(String categoria) {
    switch (categoria) {
      case 'Bajo peso':
        return 'Te recomendamos mejorar tu alimentación.';
      case 'Peso normal':
        return '¡Sigue así, vas muy bien!';
      case 'Sobrepeso':
        return 'Te conviene cuidar tu alimentación y actividad física.';
      default:
        return 'Es importante buscar orientación profesional.';
    }
  }

  /// Color del borde según la categoría.
  Color _obtenerColor(String categoria) {
    switch (categoria) {
      case 'Bajo peso':
        return Colors.blue;
      case 'Peso normal':
        return Colors.green;
      case 'Sobrepeso':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  // ---------------------------------------------------------------------------
  // Acciones
  // ---------------------------------------------------------------------------

  /// Método reutilizable que abre un AlertDialog con un título y un mensaje.
  void _mostrarDialogo(String titulo, String mensaje) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  /// Lee los datos, valida, calcula el IMC, clasifica y arma el mensaje.
  void _calcular() {
    final String nombre = _nombreCtrl.text.trim();
    final String pesoTxt = _pesoCtrl.text.trim();
    final String estaturaTxt = _estaturaCtrl.text.trim();

    // R9: validar campos vacíos
    if (nombre.isEmpty || pesoTxt.isEmpty || estaturaTxt.isEmpty) {
      _mostrarDialogo(
        'Datos incompletos',
        'Por favor captura tu nombre, peso y estatura.',
      );
      return;
    }

    // R9: validar que sean números válidos
    final double? peso = double.tryParse(pesoTxt);
    final double? estatura = double.tryParse(estaturaTxt);

    if (peso == null || estatura == null || peso <= 0 || estatura <= 0) {
      _mostrarDialogo(
        'Datos no válidos',
        'El peso y la estatura deben ser números mayores que cero.',
      );
      return;
    }

    // Cálculo y clasificación
    final double imc = calcularImc(peso, estatura);
    final String categoria = obtenerCategoria(imc);
    final String recomendacion = _obtenerMensaje(categoria);

    // Mensaje con interpolación de cadenas
    final String mensaje = 'Hola, $nombre.\n'
        'Tu IMC es $imc ($categoria).\n'
        '$recomendacion';

    // Mostrar en la etiqueta (setState) y en el diálogo
    setState(() {
      _resultado = mensaje;
      _colorBorde = _obtenerColor(categoria);
    });
    _mostrarDialogo('Resultado', mensaje);
  }

  /// Vacía los controladores y la etiqueta.
  void _limpiar() {
    _nombreCtrl.clear();
    _pesoCtrl.clear();
    _estaturaCtrl.clear();
    setState(() {
      _resultado = '';
      _colorBorde = Colors.indigo;
    });
  }

  /// Cierra la aplicación (Android).
  void _salir() {
    SystemNavigator.pop();
  }

  // ---------------------------------------------------------------------------
  // Interfaz
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    const Color azul = Color(0xFF3F51B5);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azul,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Conociendo tu IMC'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Captura tus datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: azul,
              ),
            ),
            const SizedBox(height: 16),

            // Nombre completo: cada palabra inicia con mayúscula
            TextField(
              controller: _nombreCtrl,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Peso: teclado decimal, un punto y hasta dos decimales
            TextField(
              controller: _pesoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Estatura: teclado numérico, solo dígitos enteros
            TextField(
              controller: _estaturaCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Estatura (cm)',
                prefixIcon: Icon(Icons.height),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Botón Calcular IMC
            ElevatedButton.icon(
              onPressed: _calcular,
              icon: const Icon(Icons.calculate),
              label: const Text('Calcular IMC'),
              style: ElevatedButton.styleFrom(
                backgroundColor: azul,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Botón Limpiar datos
            OutlinedButton.icon(
              onPressed: _limpiar,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Limpiar datos'),
              style: OutlinedButton.styleFrom(
                foregroundColor: azul,
                side: const BorderSide(color: azul),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Botón Salir
            TextButton.icon(
              onPressed: _salir,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Salir',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            // Etiqueta de resultado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _resultado.isEmpty
                    ? const Color(0xFFE8EAF6)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: _resultado.isEmpty ? Colors.indigo.shade100 : _colorBorde,
                    width: 4,
                  ),
                  top: BorderSide(
                    color: _resultado.isEmpty ? Colors.indigo.shade100 : _colorBorde,
                  ),
                  right: BorderSide(
                    color: _resultado.isEmpty ? Colors.indigo.shade100 : _colorBorde,
                  ),
                  bottom: BorderSide(
                    color: _resultado.isEmpty ? Colors.indigo.shade100 : _colorBorde,
                  ),
                ),
              ),
              child: Text(
                _resultado.isEmpty ? 'Aquí aparecerá tu resultado' : _resultado,
                style: TextStyle(
                  fontSize: 14,
                  color: _resultado.isEmpty ? Colors.grey : Colors.black87,
                ),
              ),
            ),

            // Aclaración (opcional)
            if (_resultado.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'El IMC es una referencia general para personas adultas; '
                  'no es un diagnóstico médico.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}