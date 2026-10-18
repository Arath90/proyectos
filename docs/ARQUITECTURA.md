# Arquitectura

Este documento explica que hace cada clase y, sobre todo, con quien habla.
Para el panorama del negocio ver el [README](../README.md); para el esquema de
la base, [MODELO_DE_DATOS.md](MODELO_DE_DATOS.md).

## MVVM, y por que en ese orden

```
                 lee                        llama                    consulta
   Vista  ───────────────►  ViewModel  ───────────────►  Repositorio  ─────────►  Drift
 (Widget)  ◄───────────────            ◄───────────────               ◄─────────
             estado inmutable            modelos de dominio             filas
```

La dependencia va en un solo sentido y ninguna capa salta a la siguiente:

| Capa | Sabe de | No sabe de |
|---|---|---|
| `domain/` | nada mas que Dart | Flutter, Drift, Riverpod |
| `data/` | dominio + Drift | Flutter, Riverpod, widgets |
| `presentation/` (ViewModel) | dominio + repositorios + Riverpod | widgets, `BuildContext` |
| `presentation/` (paginas) | ViewModel + widgets | repositorios, Drift, SQL |

Lo que compra esa disciplina:

- Las reglas del negocio se prueban sin levantar la aplicacion. Las 151 pruebas
  corren en segundos porque casi ninguna necesita pintar un pixel.
- Cambiar SQLite por un backend deberia tocar `data/` y `app/providers.dart`,
  nada mas.
- Una pantalla que no calcula nada no puede calcular algo distinto a otra.

## El mapa de clases

### `core/` — lo que usan todos los features

| Clase | Que hace | Quien la usa |
|---|---|---|
| `EscalaDecimal` | Convierte texto capturado a enteros escalados y de vuelta. Las constantes `dinero` (centavos) y `puntos` (centesimas) son las dos escalas del sistema. | Todos los formularios y todos los importes |
| `redondearDivision` | Division entera redondeada sin pasar por `double`. | `CalculoLinea.promSinIva` |
| `Formato` | Fechas en espanol, iguales en toda la aplicacion. | Las tres pantallas |

### `features/inventario/` — el centro

| Clase | Que hace | Con quien se relaciona |
|---|---|---|
| `Producto` | Un articulo: marca, codigo, descripcion, cantidad actual y original. No sabe de precios ni de clientes; solo cuenta piezas. | Lo apuntan `LineaVenta.productoId` y `LineaPedido.productoId` |
| `ProductoBorrador` | Lo que produce el formulario antes de que exista el id. | `ProductoForm` lo arma, `InventarioRepository.crearProducto` lo consume |
| `Existencia` | Un `Producto` junto con lo que las ventas apartaron. Contesta "cuantas puedo prometer". | Lo arma `InventarioViewModel` cruzando dos fuentes |
| `InventarioRepository` | CRUD del catalogo y **el unico lugar que mueve existencias**. | Es dependencia de `PedidosRepository` y `VentasRepository` |
| `InventarioViewModel` | Cruza catalogo + apartados, guarda busqueda y filtros, expone los comandos. | Lee `productosProvider` y `apartadoPorProductoProvider` |
| `InventarioPage`, `ProductoForm` | Pintan y capturan. | Solo hablan con el ViewModel |

La regla que concentra `InventarioRepository`, y que ningun otro codigo puede
escribir por su cuenta:

```
registrarEntrada(p, n)  ->  actual += n   y   original += n     (llego mercancia nueva)
registrarSalida(p, n)   ->  actual -= n                          (se entrego a un cliente)
revertirSalida(p, n)    ->  actual += n                          (regreso lo entregado)
```

Los tres son `UPDATE` relativos (`actual = actual + ?`), no leer-modificar-
escribir, para que dos movimientos sobre el mismo producto no se pisen.

### `features/pedidos/` — por donde entra

| Clase | Que hace | Con quien se relaciona |
|---|---|---|
| `Pedido` | Encabezado de la hoja a la distribuidora. `recibidoEn` marca si sus piezas ya entraron al inventario. | Agrupa `LineaPedido` |
| `LineaPedido` | Un renglon con todas las columnas del papel. Lleva los dos precios: `precioUnitario` es lo que se le paga a la distribuidora y `precioRevista` lo que el catalogo le pide al cliente. `precioTotal`, `valorPromSinIva` y `tuPagas` se calculan pero admiten un valor manual. | Usa `CalculoLinea`; apunta a `Producto` |
| `LineaBorrador` | Lo que produce el formulario. `LineaBorrador.deProducto` arranca desde el catalogo para resurtir. | `LineaPedidoForm` |
| `CalculoLinea` | IVA incluido, valor sin IVA, precio total de compra y "tu pagas". Enteros dentro, enteros fuera. | `LineaPedido` y el formulario |
| `TotalesPedido` | Suma la hoja columna por columna. Nunca se guarda. | Encabezado y listado |
| `PedidosRepository` | CRUD de la hoja **y `recibirPedido`**, la operacion que surte el inventario. | Recibe `InventarioRepository` |
| `PedidoDetallado` | Pedido + lineas + totales, listo para pintar. | Lo arma `PedidosViewModel` |

`recibirPedido` es la bisagra del sistema. Para cada linea con piezas enviadas
busca a que producto sumarselas, en este orden:

1. el `productoId` que la linea ya traiga;
2. un producto vivo con la misma marca y codigo;
3. si no existe, **lo da de alta en cero** y le suma lo recibido.

El paso 3 es deliberado: obligar a capturar el catalogo antes de poder surtir
la primera caja convertiria el inventario en un tramite. Todo ocurre en una
transaccion y `recibidoEn` impide surtir dos veces.

### `features/ventas/` — por donde sale

| Clase | Que hace | Con quien se relaciona |
|---|---|---|
| `Venta` | Encabezado: cliente, fecha, estado del apartado, carpeta. | Agrupa `LineaVenta` y `Abono`; apunta a `Cliente` y a `CarpetaVenta` |
| `EstadoVenta` | `apartada`, `entregada`, `cancelada`. Decide si las piezas ya salieron. | Lo lee `VentasRepository` para mover inventario |
| `LineaVenta` | Un renglon: producto, cantidad, precio, descuento. Copia marca/codigo/descripcion. | Apunta a `Producto` solo para mover existencias |
| `LineaVentaBorrador` | Lo que produce el formulario; `deProducto` copia del catalogo. | `LineaVentaForm` |
| `Abono` | Un pago. Guarda el total entregado y cuanto de el tapo adeudo (`montoAdeudo`); `montoVenta` es el resto. | Puede pertenecer a una `Venta`, a un `Cliente`, o a los dos |
| `CarpetaVenta` | Un separador del listado. Un solo nivel. | La apunta `Venta.carpetaId` |
| `ResumenCarpeta` | Una carpeta con lo que guarda, para pintar la estanteria. | Lo arma `VentasEstado` |
| `VentaDetallada` | **La tabla final**: venta + renglones + abonos + lo traspasado, con totales, saldo y avance de cobro. | La consumen listado y detalle |
| `ResumenVentas` | Suma de un conjunto de ventas para el encabezado del listado. | `VentasViewModel` |
| `VentasRepository` | CRUD, **la coordinacion con el inventario**, las carpetas y los abonos. | Recibe `InventarioRepository` |

El ciclo de vida de una venta y su efecto en las existencias:

```
   crearVenta            entregarVenta                cancelarVenta / reabrirVenta
       │                       │                                │
       ▼                       ▼                                ▼
   apartada  ──────────►  entregada  ─────────────►  cancelada / apartada
       │                       │                                │
  no toca actual;        actual -= piezas                 actual += piezas
  aparece en el          entregadaEn = ahora              (solo si habian salido)
  apartado calculado     y deja de apartar                entregadaEn = null
```

Editar una venta ya entregada tambien mueve inventario, por la diferencia:
agregar un renglon descuenta enseguida, cambiar la cantidad aplica solo el
delta, y quitarlo devuelve las piezas. Sin eso, una venta entregada y su
inventario quedarian desalineados en cuanto se corrigiera un dedazo.

Las **carpetas** no tocan nada de eso: son una etiqueta sobre la venta.
Borrarlas suelta sus ventas (`carpetaId = null`) y nunca se las lleva.
`VentasEstado` es quien decide como se ven -lista corrida mientras no haya
carpetas, estanteria en cuanto exista la primera, y lista otra vez en cuanto se
busca a alguien-, porque la pantalla no calcula nada.

### `features/clientes/` — quien es quien

| Clase | Que hace | Con quien se relaciona |
|---|---|---|
| `Cliente` | Nombre, telefono, direccion y una nota. No es un CRM: es la lista con la que la propietaria ya trabaja, escrita una vez para que dos pantallas hablen de la misma persona. El telefono y la direccion viven aqui y no en la venta, porque son de la persona: teclearlos en cada hoja es lo que acaba produciendo dos direcciones del mismo cliente. | Lo apuntan `Venta`, `Abono` y `Adeudo` |
| `claveDeNombre` | Reduce un nombre a como se compara: sin mayusculas, sin acentos, sin espacios de mas. | La usan el alta y el buscador del selector |
| `ClientesRepository` | CRUD del padron **y la propagacion del nombre a las ventas de esa persona**. | Escribe `clientes` y `ventas` en una transaccion |
| `ClientesViewModel` | Alta sin duplicar, correccion del nombre y la negativa a dar de baja a alguien con deuda. | Lee `ventasProvider` y `adeudosPorClienteProvider` |
| `SelectorCliente` | La hoja donde se elige a la persona, o se da de alta tecleando un nombre nuevo. | La abren ventas y adeudos |

El padron nace con los adeudos y no antes. Mientras cada venta se cobraba sola,
un nombre libre alcanzaba; en cuanto hay que sumar la deuda vieja de alguien con
su venta de hoy, un dedazo parte esa cuenta en dos y ningun abono cuadra. Por
eso el cliente se elige y no se teclea, igual que un producto del inventario.

### `features/adeudos/` — lo que se debe sin mercancia detras

| Clase | Que hace | Con quien se relaciona |
|---|---|---|
| `Adeudo` | Un cargo: cuanto debe, de que y desde cuando. `ventaOrigenId` distingue el capturado a mano del traspasado desde una venta. | Pertenece a un `Cliente` |
| `CuentaCliente` | **La cuenta completa de una persona**: sus cargos, los pagos que taparon deuda y el saldo de sus ventas abiertas, por separado y sumados. | La arma `AdeudosViewModel` |
| `repartoPropuesto` | La regla que la propietaria pidio: un pago tapa primero lo viejo, y solo lo que sobra baja la venta del dia. | La usan el formulario de cobro y `VentaDetalleEstado` |
| `ResumenAdeudos` | Cuanto se debe en total y cuantos deben. | Encabezado de la pantalla |
| `AdeudosRepository` | CRUD de los cargos. **No recibe el inventario**, y esa ausencia es la definicion del feature. | Escribe solo `adeudos` |
| `AdeudosViewModel` | Cruza padron + cargos + pagos + saldo de ventas en una lista de `CuentaCliente`. | Lee `ventasViewModelProvider` |

Los abonos **no** viven aqui: siguen en `VentasRepository`, porque son una sola
tabla y un pago es un pago venga de donde venga. Lo que cambia es a que le pega,
no quien lo guarda.

El traspaso de un saldo a la cuenta del cliente tampoco escribe en `ventas`:

```
   venta entregada con saldo          adeudos                      la venta
   ─────────────────────────          ───────                      ────────
   saldo = 800  ──── pasarSaldoAAdeudo ────►  cargo de 800    ──►  traspasado = 800
                                              ventaOrigenId         saldo = 0
                                                                    pero NO liquidada
   deshacerTraspaso ◄──── borrar el cargo ────┘
```

`VentaDetallada.traspasado` no es una columna: llega desde afuera, sumado por
`VentasViewModel` a partir de los cargos que apuntan a esa venta, igual que
llegan los renglones y los abonos. Es lo que permite que ventas y adeudos no se
importen entre si.

### `features/reportes/` — por donde sale la informacion

| Clase | Que hace | Con quien se relaciona |
|---|---|---|
| `Celda`, `Columna`, `Hoja`, `LibroReporte` | Describen un reporte -columnas, filas, totales- sin saber nada de Excel. Las celdas van tipadas (`dinero`, `entero`, `fecha`) y no como texto ya formateado. | Las arman los dos `armarReporte*` |
| `armarReportePedidos` | Dos pestanas: una fila por hoja de pedido, y todos los renglones aplanados. | Lee `Pedido`, `LineaPedido` y `TotalesPedido` |
| `armarReporteVentas` | Tres pestanas: ventas (con su carpeta y lo pasado a adeudos), renglones y abonos (con el reparto de cada pago). | Lee `VentaDetallada` |
| `armarReporteAdeudos` | Tres pestanas: la cuenta de cada persona, los cargos y los pagos a la deuda. | Lee `CuentaCliente` |
| `convertirAExcel` | Traduce un `LibroReporte` a los bytes de un `.xlsx`. Dart puro: ni disco ni Flutter. | Lo usa `CompartidorReportes` |
| `CompartidorReportes` | Escribe el archivo en la carpeta temporal y abre el menu de compartir de Android. | Es el unico punto que toca el sistema de archivos |
| `ExportacionViewModel` | Toma lo que la pantalla esta mostrando y lo manda a exportar. | Lee `PedidosViewModel`, `VentasViewModel` y `AdeudosViewModel` |
| `BotonExportar` | El mismo boton en las dos barras de titulo. | Solo habla con el ViewModel |

Dos decisiones que explican el resto del feature:

- **Se exporta lo visible, no todo.** El boton corona una lista filtrada y saca
  esa lista. Es lo que convierte los filtros que ya existian -"me deben", "con
  faltantes"- en un generador de reportes sin escribir ninguna pantalla nueva.
- **Los numeros van como numeros.** Un importe escrito como `"$1,234.56"` llega
  a Excel como cadena y no se puede sumar ni ordenar. Por eso `Celda` es una
  clase sellada por tipo y el exportador le pone a cada una su formato de
  Excel. Es tambien el unico punto del sistema donde un importe se convierte a
  `double`, porque un `.xlsx` guarda asi sus numeros; la division es una sola,
  al final, sobre un total ya sumado en enteros.

La cadena completa, y por que esta partida en tres:

```
   ViewModel          domain/reporte_*        data/libro_a_excel     data/compartidor
  lo visible  ──────►  LibroReporte  ──────►      bytes xlsx    ──────►  archivo + menu
                       (Dart puro)              (Dart puro)            (disco y Android)
```

Las dos primeras etapas se prueban sin dispositivo; solo la ultima necesita
una tablet. Por eso el error clasico del paquete `excel` -una celda numerica
sin formato numerico revienta al guardar- lo atrapan las pruebas y no la
propietaria.

### `features/respaldos/` — que los datos sobrevivan a la aplicacion

| Pieza | Que es | Con quien habla |
|---|---|---|
| `Respaldo` | Una copia de la base: su archivo, cuando se hizo, por que y de que version del esquema venia. Todo eso vive en el **nombre del archivo**, no en un indice: un indice se desincroniza del disco y la lista acabaria ofreciendo copias que ya no existen. | Nadie |
| `RespaldosRepository` | El unico lugar que trata la base como archivo y no como base. Copia, lista, rota, importa y restaura. | Lee el `.sqlite` directo; para respaldar en caliente le pide a Drift un `VACUUM INTO` |
| `CompartidorRespaldo` | Entrega la copia al menu de compartir de Android. | `share_plus` |
| `SelectorDeArchivo` | Abre el explorador para traer una copia de vuelta. | `file_picker` |
| `RespaldosViewModel` | Las cuatro acciones y el estado de "trabajando". | Invalida `baseDeDatosProvider` al restaurar |

Hay dos formas de copiar y las dos hacen falta:

- **Copiar el archivo** con sus `-wal`/`-shm`. Es lo que se hace en `main()`,
  antes de construir `AppDatabase`, y solo entonces: en cuanto Drift abre la
  base, la migracion ya corrio y la copia seria de la base migrada. Ese es el
  motivo de que `AppDatabase.versionDeEsquema` sea `static` y de que la version
  del archivo se lea de los bytes 60-63 de su cabecera sin abrirlo.
- **`VACUUM INTO`** con la base abierta, que es lo que hace el boton de
  respaldar. SQLite escribe una copia consistente desde su propia vista de los
  datos; copiar bytes con la aplicacion escribiendo encima daria un archivo
  roto que solo se descubre el dia que hace falta.

Restaurar borra los `-wal`/`-shm` vivos antes de poner los del respaldo. Un
`-wal` viejo junto a un `.sqlite` restaurado hace que SQLite le aplique encima
transacciones de otra base: el resultado no seria ni la copia ni lo que habia.

### `app/` — el cableado

| Archivo | Que hace |
|---|---|
| `providers.dart` | Construye base de datos y repositorios, y publica una lectura reactiva por consulta. Es el unico lugar donde se decide quien depende de quien. `baseDeDatosProvider` es el unico que se invalida en caliente: restaurar un respaldo reemplaza el archivo y hay que reabrirlo. |
| `main.dart` | Formatos en espanol, **respaldo de la base si esta version la va a migrar** -antes de que nada la abra- y el `ProviderScope`. |
| `app.dart` | `MaterialApp`, idioma (`es_MX` fijo, con los delegados de Material para que el calendario hable espanol) y las cinco pestanas en un `IndexedStack` (para no perder la busqueda -ni la carpeta abierta- al cambiar de pestana). |
| `tema.dart` | El unico tema: crema y naranja con letra negra. Las decisiones -por que el fondo no es blanco, por que el naranja es senal y no relleno, por que los campos si son blancos- estan documentadas ahi, y todas salen de que la tablet se mira durante horas seguidas. |
| `widgets_comunes.dart` | `CampoTexto`, `CampoSelector`, `CampoEntero`, `CampoDecimal`, `BarraResumen`, `EstadoVacio`, `Insignia`, `avisar`, `confirmar`, `pedirTexto`, `menuDeAcciones`. |

## Como se cruzan los features sin conocerse

Inventario y ventas se necesitan pero no se importan. El cruce ocurre en dos
puntos, y en los dos es alguien mas quien los junta:

1. **Lo apartado.** `VentasRepository.observarApartadoPorProducto()` publica un
   `Map<productoId, piezas>`. `InventarioViewModel` lo une al catalogo y produce
   `Existencia`. El cruce vive en la capa de presentacion, no en los datos.
2. **El movimiento de piezas.** `VentasRepository` y `PedidosRepository` reciben
   `InventarioRepository` por constructor y le piden los movimientos dentro de
   su propia transaccion. La regla de que sube y que baja existe una sola vez.
3. **Lo traspasado a adeudos.** `traspasadoPorVentaProvider` publica un
   `Map<ventaId, centavos>` derivado de los cargos. `VentasViewModel` lo entrega
   ya sumado dentro de cada `VentaDetallada`; ventas nunca importa a adeudos.
4. **La deuda completa de una persona.** `AdeudosViewModel` toma el saldo de las
   ventas de `VentasViewModel` -ya calculado por `VentaDetallada`- y lo suma con
   los cargos. No vuelve a decidir que cuenta como saldo: esa regla ya existe.

Los cuatro siguen el mismo patron: **quien cruza dos features es el ViewModel,
nunca el repositorio**, y el dato que viaja entre ellos es lo mas tonto posible
-un mapa de enteros- para que ninguna regla se escriba dos veces.

El unico caso donde el pago mismo cruza los dos mundos es `abonos`, y ahi la
solucion es que no cruza: es una sola tabla con dos lecturas.
`observarAbonosPorVenta` y `observarAbonosPorCliente` devuelven el mismo pago
visto por sus dos mitades, y quien suma es el dominio -`VentaDetallada` se queda
con `montoVenta` y `CuentaCliente` con `montoAdeudo`-.

## Convenciones que se repiten a proposito

- **Borrador antes de entidad.** `ProductoBorrador`, `LineaBorrador`,
  `LineaVentaBorrador`: lo que el formulario produce no tiene id ni posicion;
  el repositorio los asigna. Ninguna pantalla inventa identificadores.
- **`copyWith` con campos envueltos.** Cuando `null` significa algo (`vuelve al
  calculo`, `todavia no entregada`, `sin producto`), el parametro se envuelve en
  un registro `({T? valor})` para distinguir "no lo menciones" de "ponlo en
  null".
- **Los comandos devuelven el error, no lo lanzan.** Un ViewModel regresa
  `String?`: `null` si todo salio bien, el mensaje si no. La vista solo lo
  muestra; no tiene que conocer `ProductoDuplicadoException`.
- **Los filtros viven en campos del Notifier.** `build()` se re-ejecuta cada vez
  que la base emite; sin guardar la busqueda aparte, teclear mientras entra una
  venta borraria lo escrito.
