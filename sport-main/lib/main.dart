import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

// Función principal que inicia la aplicación
void main() {
  runApp(MaterialApp(
    title: 'Sports Streaming', // Título de la aplicación
    // Define el tema oscuro
    theme: ThemeData.dark().copyWith(
      // Personaliza la paleta de colores para el tema oscuro
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4CAF50), // Color principal (usado en AppBar, botón seleccionado)
        secondary: Color(0xFF8BC34A), // Color secundario (usado en botones no seleccionados)
        onSecondary: Colors.black87, // Color del texto sobre el color secundario
        surface: Color(0xFF424242), // Color de fondo de superficies
        background: Color(0xFF303030), // Color de fondo general de la pantalla
      ),
      cardColor: const Color(0xFF424242), // Color de fondo de Cards
      // Configura el color de fondo del Scaffold
      scaffoldBackgroundColor: const Color(0xFF303030),
      // Configura el tema de la AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF4CAF50), // Usa el color primario para la AppBar
        foregroundColor: Colors.white, // Color del texto y iconos en la AppBar
      ),
      // Configura el tema por defecto para los ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(), // Forma de pastilla
          padding: EdgeInsets.symmetric(vertical: 24), // Espaciado interno
          elevation: 8.0, // Elevación de la sombra
          textStyle: TextStyle( // Estilo del texto
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    home: StreamMenuPage(), // Página principal de la aplicación
  ));
}

// Widget principal con estado para la página del menú de transmisiones
class StreamMenuPage extends StatefulWidget {
  @override
  _StreamMenuPageState createState() => _StreamMenuPageState();
}

// Estado asociado a StreamMenuPage
class _StreamMenuPageState extends State<StreamMenuPage> {
  // Lista de transmisiones disponibles con su título y URL
  // Nota: Las URLs con parámetros md5 y expires suelen ser temporales.
  // Estas URLs pueden dejar de funcionar.
  final List<Map<String, String>> streams = [
    {
      'title': 'Apple Sample Stream',
      'url': 'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8',
    },
    {
      'title': 'Historic Planet Content',
      'url': 'https://devstreaming-cdn.apple.com/videos/streaming/examples/historic_planet_content_2023-10-26-3d-video/main.m3u8',
    },
    {
      'title': 'Adv DV Atmos',
      'url': 'https://devstreaming-cdn.apple.com/videos/streaming/examples/adv_dv_atmos/main.m3u8',
    },
    {
      'title': 'THE BEST IPTV',
      'url': 'https://www.the-best-iptv.com/438-free-and-active-iptv-m3u-playlist-urls/',
    },
  ];

  // Estado para rastrear la transmisión actualmente seleccionada
  Map<String, String>? _selectedStream;
  // Controlador para la instancia de WebViewX
  WebViewXController? _inlineWebViewController;
  // Estado para rastrear si la WebViewX está cargando
  bool _isLoading = false;

  // Encabezados personalizados (custom headers) para la solicitud web
  // Nota: Estos encabezados pueden no ser aplicados directamente por WebViewX
  // al cargar URLs .m3u8, ya que WebViewX carga contenido web (HTML) por defecto.
  // Si la URL es un .m3u8, el reproductor HLS subyacente (dentro de la webview)
  // podría necesitar sus propios encabezados.
  final Map<String, String> customHeaders = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:138.0) Gecko/20100101 Firefox/138.0',
    'Accept': '*/*',
    'Accept-Language': 'en-US,en;q=0.5',
    'Accept-Encoding': 'gzip, deflate, br, zstd',
    'Referer': 'https://capo5play.com/',
    'Origin': 'https://capo5play.com',
    'Connection': 'keep-alive',
  };

  @override
  void dispose() {
    // Libera el controlador de WebViewX cuando el widget se destruye
    _inlineWebViewController?.dispose();
    super.dispose();
  }

  // Función para manejar la selección de una transmisión
  void _selectStream(Map<String, String> stream) {
    // Si se hace clic en la transmisión que ya está seleccionada, la cierra
    if (_selectedStream != null && _selectedStream!['title'] == stream['title']) {
      _closeStream();
      return;
    }

    // Libera el controlador anterior antes de crear uno nuevo (importante!)
    _inlineWebViewController?.dispose();
    _inlineWebViewController = null;

    // Actualiza el estado para mostrar la transmisión seleccionada y empezar a cargar
    setState(() {
      _selectedStream = stream;
      _isLoading = true;
    });
  }

  // Función para cerrar la transmisión actualmente reproduciéndose
  void _closeStream() {
    // Libera el controlador y reinicia el estado
    _inlineWebViewController?.dispose();
    _inlineWebViewController = null;
    setState(() {
      _selectedStream = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene el esquema de color del tema actual
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sports Streaming'), // Título en la AppBar
        // El color de fondo de la AppBar se define en el tema
      ),
      // El cuerpo es una lista que construye sus elementos
      body: ListView.builder(
        padding: EdgeInsets.all(16), // Espaciado alrededor de la lista
        itemCount: streams.length, // Número de elementos en la lista
        itemBuilder: (context, index) {
          // Obtiene los datos de la transmisión para este elemento
          final stream = streams[index];
          // Verifica si este elemento es la transmisión actualmente seleccionada
          final isSelected = _selectedStream != null && _selectedStream!['title'] == stream['title'];

          // Cada elemento de la lista es una columna
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Estira los hijos al ancho máximo
            children: [
              // El botón para seleccionar la transmisión
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8), // Espaciado vertical alrededor del botón
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // Cambia el color de fondo según si está seleccionado o no
                    backgroundColor: isSelected
                        ? colorScheme.primary // Usa color primario si está seleccionado
                        : colorScheme.secondary, // Usa color secundario si no
                    // Cambia el color del texto según si está seleccionado o no
                    foregroundColor: isSelected
                        ? colorScheme.onPrimary // Color del texto sobre primario
                        : colorScheme.onSecondary, // Color del texto sobre secundario
                    // Otros estilos de botón se heredan del tema
                  ),
                  child: Text(stream['title']!), // Texto del botón (título de la transmisión)
                  onPressed: () => _selectStream(stream), // Acción al presionar el botón
                ),
              ),
              // Muestra condicionalmente el contenedor de WebViewX si esta transmisión está seleccionada
              // Usa AnimatedSwitcher para una transición suave al aparecer/desaparecer
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300), // Duración de la animación
                transitionBuilder: (Widget child, Animation<double> animation) {
                   // Define el tipo de transición: desvanecimiento
                   return FadeTransition(opacity: animation, child: child);
                   // O puedes usar una transición de escala:
                  // return ScaleTransition(scale: animation, child: child);
                },
                // El hijo de AnimatedSwitcher cambia entre el reproductor y un espacio vacío
                child: isSelected
                    ?
                    // Si está seleccionado, muestra el reproductor envuelto en ClipRRect
                    // La Key es importante para que AnimatedSwitcher sepa qué widget animar
                    ClipRRect(
                      key: ValueKey(stream['title']), // Clave única para el reproductor
                      borderRadius: BorderRadius.circular(12.0), // Aplica esquinas redondeadas
                      child: Container(
                        // Define la altura del contenedor del reproductor dentro del elemento de la lista
                        height: 350.0, // Ajusta la altura según sea necesario
                        color: Colors.black, // Color de fondo del contenedor
                        child: Column( // Columna para la barra de título y la WebViewX
                          children: [
                            // Fila para el título de la transmisión y el botón de cerrar
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinea elementos al principio y al final
                                children: [
                                  Expanded( // Permite que el texto del título se expanda pero no exceda
                                    child: Text(
                                      _selectedStream!['title']!, // Título de la transmisión seleccionada
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70), // Estilo del texto
                                      overflow: TextOverflow.ellipsis, // Agrega puntos suspensivos si el texto es muy largo
                                    ),
                                  ),
                                  // Botón para cerrar el reproductor
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.white70), // Icono de cerrar
                                    onPressed: _closeStream, // Acción al presionar: cierra la transmisión
                                  ),
                                ],
                              ),
                            ),
                            // La propia WebViewX que cargará la transmisión
                            Expanded( // Ocupa el espacio restante
                              child: _isLoading
                                  ? Center(child: CircularProgressIndicator(color: Colors.white70)) // Muestra indicador de carga si está cargando
                                  : WebViewX(
                                      // Carga la URL de la transmisión seleccionada
                                      initialContent: _selectedStream!['url']!,
                                      initialSourceType: SourceType.url, // Indica que el contenido es una URL

                                      width: MediaQuery.of(context).size.width, // Ancho total del contenedor
                                      height: double.infinity, // Altura total disponible en el Expanded
                                      onWebViewCreated: (controller) {
                                        // Se llama cuando la WebView se ha creado
                                        _inlineWebViewController = controller;
                                        // Opcionalmente, puedes ejecutar JavaScript aquí
                                      },
                                      onPageStarted: (src) {
                                        // Se llama cuando la carga de la página comienza
                                        print("Carga iniciada: $src");
                                        if(mounted) { // Verifica si el widget todavía está montado
                                           setState(() { _isLoading = true; }); // Muestra el indicador de carga
                                        }
                                      },
                                      onPageFinished: (src) {
                                        // Se llama cuando la carga de la página termina
                                        print("Carga finalizada: $src");
                                        if(mounted) { // Verifica si el widget todavía está montado
                                           setState(() { _isLoading = false; }); // Oculta el indicador de carga
                                        }
                                        // Para transmisiones HLS en WebViewX, a veces necesitas JavaScript
                                        // para iniciar la reproducción usando una librería como hls.js
                                      },
                                      onWebResourceError: (error) {
                                        // Se llama si ocurre un error al cargar un recurso
                                        print("Error cargando WebView: ${error.description}");
                                        if(mounted) { // Verifica si el widget todavía está montado
                                           setState(() { _isLoading = false; }); // Oculta el indicador de carga
                                           // Muestra un mensaje de error al usuario
                                           ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error al cargar transmisión: ${error.description}')),
                                           );
                                        }
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    )
                    :
                    // Si no está seleccionado, muestra una caja vacía que no ocupa espacio
                    // La Key es importante para AnimatedSwitcher
                    SizedBox.shrink(key: ValueKey('empty')), // Clave para el estado vacío
              ),
            ],
          );
        },
      ),
    );
  }
}