# punto_venta_madre

Sistema de punto de venta para un negocio de venta por catalogo. Funciona sin
internet: todo vive en una base SQLite local.

## Los tres flujos

El negocio tiene tres momentos, y el sistema tiene un feature para cada uno.
El inventario esta en medio porque es lo que los otros dos mueven:

```
  PEDIDO a la distribuidora          INVENTARIO                VENTA al cliente
  (features/pedidos)              (features/inventario)      (features/ventas)

  Se captura la hoja impresa   ->  Producto                ->  Se apartan piezas
  con todas sus columnas           marca, codigo,              (aun no salen)
  (puntos, precio de compra,       descripcion,
   precio revista, descuento       cantidad actual,        ->  Se entregan
   CN, regalos)                    cantidad original           (salen del
  Al RECIBIRLO, la                                              inventario)
  cantEnviada entra  ------------>  sube actual
  al inventario                     y original           ->  Se cobra a plazos
                                                             con Abonos hasta
                                    baja actual <----------   liquidar el saldo
```

- **Pedido**: la propietaria le compra a la distribuidora. Se captura la hoja
  tal como viene impresa, con sus **dos precios**: el unitario, que es lo que
  le cuesta la pieza, y el de revista, que es lo que el catalogo le pide al
  cliente. Cuando llega la caja se *recibe*: la `cantEnviada` de cada linea
  entra al inventario, dando de alta el producto si no existia. La diferencia
  contra la `cantPedida` queda como faltante.
- **Inventario**: el catalogo de lo que hay en casa. Es un CRUD de cinco
  campos, y el unico lugar del sistema autorizado para mover existencias.
- **Venta**: la propietaria le vende a un cliente. La venta nace *apartada*
  (compromete piezas sin sacarlas), luego se *entrega* (ahi si bajan las
  existencias) y se cobra con abonos, porque el pago casi nunca es de contado.
  Es la tabla final donde aparecen juntos el cliente, el producto, el importe y
  el saldo.

## Lo que queda cuando el tercer flujo no se cierra

Vender a plazos deja dos problemas que no caben dentro de una venta, y cada uno
tiene su respuesta:

```
   CARPETAS                                  ADEUDOS
   (features/ventas)                         (features/adeudos)

   La propietaria vende en varios            Tony se llevo mercancia hace
   lugares. Una lista corrida no             meses, cuando esto no existia.
   contesta "cuanto me deben en              Capturarlo como venta obligaria a
   Xalisco", que es lo que se                dar de alta hoy productos que
   pregunta antes de subirse al              salieron el ano pasado: el
   camion.                                   inventario quedaria mintiendo.

   Las ventas se guardan en                  Un adeudo es solo dinero. Se anota
   carpetas -un nivel, por lugar-            cuanto debe y ya, sin tocar
   y cada carpeta trae su propio             existencias.
   resumen y su propio Excel.
                                             Al cobrarle, lo que deje tapa
                                             primero lo viejo y solo lo que
                                             sobra baja la venta del dia.
```

Las dos deudas de una persona -lo de antes y el saldo de sus ventas abiertas-
se muestran por separado y sumadas, porque se cobran en lugares distintos pero
lo que ella dice en voz alta es el total.

Para que eso sea posible hay un **padron de clientes**: el cliente se elige de
una lista en vez de teclearse. Mientras cada venta se cobraba sola, un nombre
libre alcanzaba; con adeudos, un dedazo partiria la cuenta de alguien en dos y
ningun abono cuadraria.

## Arquitectura (MVVM)

```
lib/
  core/            escala_decimal.dart   dinero y puntos como enteros escalados
                   formato.dart          fechas en espanol
  infrastructure/  database/             Drift: tablas y base generada
  app/             providers.dart        el cableado: quien construye a quien
                   app.dart              MaterialApp, idioma y las cinco pestanas
                   tema.dart             crema y naranja, letra negra
                   widgets_comunes.dart  campos y piezas compartidas
  features/<feature>/
    domain/        modelos y reglas puras, sin Flutter ni SQL
    data/          repositorios: el unico lugar que conoce Drift
    presentation/  ViewModel (estado + comandos) y paginas
```

Los features son siete: `pedidos`, `inventario`, `ventas`, `clientes`,
`adeudos`, `reportes` y `respaldos`.

- `clientes` es el mas chico: una lista de nombres a la que ventas y adeudos
  apuntan, mas el selector que se abre encima de las dos.
- `adeudos` no recibe el inventario, y esa ausencia es su definicion: existe
  justamente para registrar dinero sin fingir movimientos de mercancia.
- `reportes` no tiene tablas propias -lee de los otros y produce archivos-,
  pero respeta la misma division: el contenido del reporte y su conversion a
  `.xlsx` son Dart puro, y solo el paso de escribir el archivo y abrir el menu
  de compartir toca el sistema.
- `respaldos` es el unico que trata la base como archivo en vez de como base.
  Copia el `.sqlite` antes de cada migracion -en `main()`, antes de que nadie
  la abra- y deja mandar una copia fuera de la tablet, que es lo unico que
  protege de perderla. Ver [docs/PUBLICAR.md](docs/PUBLICAR.md).

Las capas van en un solo sentido: **View -> ViewModel -> Repository -> Drift**.

- El **dominio** no importa Flutter ni Drift. Se puede probar sin levantar la
  aplicacion, y ahi viven las reglas: `CalculoLinea` (IVA y "tu pagas"),
  `VentaDetallada` (totales y saldo), `Existencia` (disponible = actual menos
  apartado).
- Los **repositorios** traducen filas a modelos y coordinan las operaciones que
  tocan dos tablas dentro de una transaccion. `InventarioRepository` es
  dependencia de los otros dos: es quien sabe que una entrada sube existencia
  actual y original, y que una salida solo baja la actual.
- Los **ViewModel** (Riverpod `Notifier`) cruzan lecturas de features distintos
  para que ninguno tenga que importar al otro, guardan el estado de la pantalla
  (busqueda, filtros) y exponen comandos. Devuelven el mensaje de error en vez
  de lanzarlo, para que la vista solo tenga que mostrarlo.
- Las **vistas** son tontas: pintan el estado que reciben y llaman metodos del
  ViewModel. No conocen repositorios ni Drift.

## Decisiones que conviene conocer antes de tocar el codigo

- **El dinero nunca es `double`.** Se guarda en centavos y los puntos en
  centesimas de punto, siempre enteros. Ver `core/escala_decimal.dart`.
- **Nada se borra fisicamente.** Todo lleva `eliminadoEn`: un registro que
  desaparece no se podria propagar cuando exista sincronizacion.
- **Los ids son UUID generados en el dispositivo**, no autoincrementos, por la
  misma razon.
- **Ningun total se guarda.** Se recalculan siempre, porque un total almacenado
  se desincroniza en cuanto se edita un renglon.
- **Las lineas copian marca, codigo y descripcion** del producto en vez de solo
  apuntarlo: una venta o un pedido son documentos historicos y deben seguir
  diciendo lo que decian el dia que se hicieron.
- **El nombre del cliente es la excepcion a esa regla.** Tambien se copia en la
  venta -para que las ventas viejas y las que no se enlazaron sigan diciendo a
  quien se le vendio-, pero ahi si se mantiene al dia: un nombre se corrige
  porque estaba mal escrito, y dejar el error congelado en veinte ventas no le
  sirve a nadie.
- **Un pago es una sola fila aunque tape dos cosas.** El cliente entrego un
  billete, no dos pagos: `abonos` guarda el total y cuanto de el se aplico al
  adeudo. Partirlo en dos registros obligaria a borrar los dos para corregir un
  dedazo y dejaria la puerta abierta a que uno sobreviva sin el otro.
- **Un adeudo no toca el inventario, nunca.** Es la razon de que el feature
  exista; si alguna vez lo tocara, dejaria de tener sentido frente a una venta.
- **Los reportes salen de lo que se esta viendo.** El boton de exportar corona
  una lista ya filtrada y saca esa lista a Excel; los filtros de pantalla son
  el generador de reportes.

## Documentacion

| Documento | Para que |
|---|---|
| [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) | Que hace cada clase y con quien habla. Empieza aqui antes de tocar codigo. |
| [docs/MODELO_DE_DATOS.md](docs/MODELO_DE_DATOS.md) | Las seis tablas, sus invariantes y las migraciones. |
| [docs/MANUAL.md](docs/MANUAL.md) | Como se usa, escrito para la propietaria. |
| [docs/PUBLICAR.md](docs/PUBLICAR.md) | Como se instala una version nueva en la tablet sin perder los datos. La llave de firma, el `versionCode` y el respaldo previo. Leerlo **antes** de compilar el primer APK de release. |

## Comandos

```sh
flutter pub get
dart run build_runner build --force-jit   # regenerar app_database.g.dart
flutter analyze
flutter test
flutter run
```

`--force-jit` es necesario: la compilacion AOT del script de build choca con
los build hooks de `sqlite3`.

### Instalar en la tablet

Con la tablet conectada por USB, en modo desarrollador, depuracion USB activada
y transferencia de datos (MTP):

```sh
adb devices                # confirma que aparezca
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

**No uses `flutter install`.** Si el `adb install` de adentro falla, flutter
desinstala la version vieja y reinstala por su cuenta
(`android_device.dart:414-421` del SDK): convierte un rechazo inofensivo en el
borrado de la base. Con `adb install -r`, un fallo es solo un fallo y la tablet
se queda como estaba -Android valida firma y `versionCode` **antes** de escribir
nada-.

El APK de release se firma con la llave declarada en `android/key.properties`,
que no va al repositorio. Sin ese archivo la compilacion **falla a proposito**:
un release firmado con la llave de debug se instala bien la primera vez y hace
que la *siguiente* actualizacion se rechace. Ver
[docs/PUBLICAR.md](docs/PUBLICAR.md), que es de lectura obligada antes de
instalar en la tablet de la propietaria.

## Estado

- 262 pruebas en verde y `flutter analyze` sin observaciones.
- **En uso en una tablet Qtab LTE** (Android 15, 800x1280) con captura real. La
  version instalada es la `0.2.0+3`, esquema v5, y se actualizo encima de la
  anterior sin desinstalar: se comprobo que la firma del APK ya instalado
  coincidiera con la de `key.properties` antes de instalar, y se saco una copia
  de la base fuera de la tablet antes de migrar. El procedimiento esta en
  [docs/PUBLICAR.md](docs/PUBLICAR.md).
- Pedidos y ventas se exportan a `.xlsx` y se mandan por WhatsApp desde el menu
  de compartir de Android.
- El esquema va en la v5. La v4 agrego el padron de clientes, las carpetas del
  listado de ventas y los adeudos; la v5 le da al cliente telefono y direccion.
  Las migraciones desde una base con datos capturados estan probadas en
  `test/infrastructure/migracion_v4_test.dart` y `migracion_v5_test.dart`, y
  ademas la aplicacion copia el `.sqlite` en `main()` antes de que Drift lo
  abra, asi que una migracion que salga mal deja de donde volver.
- Falta: imprimir una venta suelta como nota para el cliente, y sincronizacion
  entre dispositivos (el esquema ya esta preparado con UUID y borrado logico,
  pero no hay backend).
- El respaldo protege de una migracion que salga mal y de perder la tablet,
  **pero solo hasta donde llegue el ultimo archivo que se haya mandado
  fuera**. La copia automatica se queda en la misma tablet; sacarla es un acto
  manual desde la pestana Respaldo.
- Las ventas capturadas antes de la v4 quedan sin cliente del padron: siguen
  mostrando el nombre que se les tecleo, y es la propietaria quien decide
  cuales enlazar. Adivinar por parecido de texto es justo lo que el padron
  viene a evitar.
