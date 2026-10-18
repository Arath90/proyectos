import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Base de datos local de la tablet.
///
/// Es la unica fuente de verdad mientras no exista backend. Todo lo que se
/// captura vive aqui aunque no haya internet.
///
/// Reune los tres flujos del negocio en un solo archivo SQLite para que las
/// operaciones que los cruzan sean atomicas: recibir un pedido escribe en
/// `Pedidos` y en `Productos` a la vez, y entregar una venta escribe en
/// `Ventas` y en `Productos` a la vez. Si el inventario viviera en otra base
/// no habria forma de garantizar que ambas mitades ocurran o ninguna.
@DriftDatabase(
  tables: [
    Pedidos,
    LineasPedido,
    Productos,
    Clientes,
    CarpetasVenta,
    Ventas,
    LineasVenta,
    Abonos,
    Adeudos,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_abrirConexion());

  /// Constructor para pruebas: recibe una base en memoria.
  AppDatabase.paraPruebas(super.e);

  /// La version del esquema que conoce este codigo.
  ///
  /// Es `static` ademas de `schemaVersion` porque hay que consultarla **antes**
  /// de abrir la base: al arrancar, el respaldo automatico compara esta cifra
  /// con la que trae el archivo en disco para saber si la proxima apertura va
  /// a migrar. Si hubiera que instanciar `AppDatabase` para preguntarlo, la
  /// migracion ya habria ocurrido y el respaldo llegaria tarde.
  static const versionDeEsquema = 5;

  @override
  int get schemaVersion => versionDeEsquema;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),

        /// v1 solo conocia el pedido a la distribuidora. La v2 agrega el
        /// inventario y la venta al cliente, y le cuelga a las tablas viejas
        /// las dos columnas que las enlazan con el inventario. La v3 agrega a
        /// la linea de pedido el precio de compra. La v4 agrega el padron de
        /// clientes, las carpetas del listado de ventas y los adeudos. La v5
        /// le da al cliente telefono y direccion propios.
        ///
        /// Los pasos son `if` sueltos y no `else if` a proposito: una tablet
        /// que venia en la v1 tiene que recorrer los cuatro escalones.
        ///
        /// Con una regla que hay que tener presente al agregar el siguiente:
        /// `createTable` no crea la tabla como era en su version, sino como
        /// es **hoy**, con todas las columnas que se le han colgado desde
        /// entonces. Por eso cada `addColumn` lleva ademas el `desde >=` de la
        /// version en que su tabla nacio: sin el, una tablet vieja crea la
        /// tabla ya completa en un escalon y en el siguiente intenta agregarle
        /// una columna que acaba de crear, y la migracion se cae a la mitad
        /// con "duplicate column name". El caso no es teorico: es exactamente
        /// lo que le pasaria a la base que trae la propietaria.
        onUpgrade: (m, desde, hasta) async {
          // Las llaves foraneas se apagan mientras dura la migracion. La v4
          // reconstruye `abonos` -copiar a una tabla nueva, tirar la vieja,
          // renombrar- y con las llaves encendidas ese baile falla o, peor,
          // reescribe referencias a medio camino. `beforeOpen` las vuelve a
          // encender antes de que la aplicacion escriba nada.
          await customStatement('PRAGMA foreign_keys = OFF');

          if (desde < 2) {
            await m.createTable(productos);
            await m.createTable(ventas);
            await m.createTable(lineasVenta);
            await m.createTable(abonos);
            await m.addColumn(pedidos, pedidos.recibidoEn);
            await m.addColumn(lineasPedido, lineasPedido.productoId);
          }
          if (desde < 3) {
            // Las hojas ya capturadas quedan con precio de compra en cero: no
            // hay de donde deducirlo, y cero es visiblemente "falta capturar".
            await m.addColumn(lineasPedido, lineasPedido.precioUnitario);
            await m.addColumn(lineasPedido, lineasPedido.precioTotalManual);
          }
          if (desde < 4) {
            await m.createTable(clientes);
            await m.createTable(carpetasVenta);
            await m.createTable(adeudos);

            // Las ventas ya capturadas quedan sueltas y sin cliente del
            // padron: siguen mostrando el nombre que se les tecleo, y es la
            // propietaria quien decide cuales enlazar. Adivinar por parecido
            // de texto es justo lo que este padron viene a evitar.
            //
            // Solo para las bases que ya tenian la tabla: la que viene de la
            // v1 acaba de crearla arriba, y ya nacio con estas dos columnas.
            if (desde >= 2) {
              await m.addColumn(ventas, ventas.clienteId);
              await m.addColumn(ventas, ventas.carpetaId);
            }

            // `abonos` cambia de forma, no solo de columnas: `venta_id` deja
            // de ser obligatorio para que un pago pueda ser de pura deuda
            // vieja. Eso obliga a recrear la tabla, que es lo que hace
            // `alterTable`. Los abonos que ya existen conservan su venta y
            // quedan con `monto_adeudo` en cero: todos ellos se cobraron
            // cuando los adeudos no existian, asi que ninguno tapo deuda.
            await m.alterTable(
              TableMigration(
                abonos,
                newColumns: [abonos.clienteId, abonos.montoAdeudo],
              ),
            );
          }
          // `desde >= 4` porque `clientes` nacio en la v4: una base anterior
          // ya la creo completa en el escalon de arriba.
          if (desde >= 4 && desde < 5) {
            // Dos columnas nuevas con default vacio: los clientes que ya
            // existen quedan sin telefono ni direccion hasta que ella los
            // capture. No se intenta adivinarlos leyendo `notas` -ahi hay
            // telefonos, apodos y direcciones mezclados en texto libre- porque
            // una direccion mal extraida es peor que una vacia: la vacia se ve
            // y se llena, la equivocada se lee como buena.
            await m.addColumn(clientes, clientes.telefono);
            await m.addColumn(clientes, clientes.direccion);
          }
        },
        beforeOpen: (details) async {
          // Sin esto SQLite ignora las llaves foraneas y borrar un pedido
          // dejaria sus lineas huerfanas.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

/// Nombre del archivo, sin extension. `drift_flutter` le pega `.sqlite` y lo
/// deja en la carpeta de documentos de la aplicacion.
///
/// Es constante y publico porque el respaldo tiene que dar con el mismo
/// archivo sin abrir la base: dos lugares escribiendo el nombre a mano es como
/// se acaba respaldando un archivo que no es.
const nombreDeLaBase = 'punto_venta_madre';

QueryExecutor _abrirConexion() => driftDatabase(name: nombreDeLaBase);
