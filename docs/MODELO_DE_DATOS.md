# Modelo de datos

Una sola base SQLite local (`punto_venta_madre.sqlite`), definida en
`lib/infrastructure/database/tables.dart` y abierta por `AppDatabase`. Las
nueve tablas viven juntas para que las operaciones que cruzan features sean
atomicas: recibir un pedido escribe en `pedidos` y `productos` a la vez;
entregar una venta escribe en `ventas` y `productos` a la vez; renombrar a un
cliente escribe en `clientes` y `ventas` a la vez.

## Diagrama

```
   pedidos                          productos                        ventas
   ───────                          ─────────                        ──────
   id (uuid) PK                     id (uuid) PK                     id (uuid) PK
   fecha                            marca                            fecha
   campana                          codigo                           cliente
   marca_predeterminada             descripcion                      notas
   notas                            cantidad_actual                  estado
   cerrado                          cantidad_original                entregada_en
   recibido_en  ────────┐           creado/actualizado/eliminado     creado/actualizado/eliminado
   creado/actualizado/  │              ▲              ▲                   │ 1
   eliminado            │              │              │                   │
        │ 1             │              │              │                   │ N
        │               └── entrada ───┘              └─── salida ───┐    ▼
        │ N                  (cant_enviada)                          │  lineas_venta
        ▼                                                            │  ────────────
   lineas_pedido                                                     │  id PK
   ─────────────                                                     └─ venta_id  FK
   id PK                                                                producto_id FK (nullable)
   pedido_id      FK                                                    marca / codigo / descripcion
   producto_id    FK (nullable) ─────────────────────────────────────►  cantidad
   marca / codigo / descripcion                                         precio_unitario
   cant_pedida / cant_enviada                                           descuento
   valor_total_puntos                                                   orden
   precio_unitario                                                      creado/actualizado/eliminado
   precio_revista
   valor_total_promocionado                                          ventas 1 ── N abonos
   total_descuento_cn                                                ──────────────────
   valor_regalos                                                     id PK
   valor_prom_sin_iva_manual (nullable)                              venta_id FK (nullable)
   tu_pagas_manual (nullable)                                        cliente_id FK (nullable)
   precio_total_manual (nullable)                                    fecha / nota
   orden                                                             monto / monto_adeudo
   creado/actualizado/eliminado                                      creado/actualizado/eliminado
```

La cobranza agrega tres tablas mas, que no mueven mercancia:

```
   carpetas_venta                  clientes                    adeudos
   ──────────────                  ────────                    ───────
   id (uuid) PK                    id (uuid) PK                id (uuid) PK
   nombre                          nombre                      cliente_id       FK
   notas                           telefono                    fecha
   creado/actualizado/eliminado    direccion                   concepto
                                   notas                       monto
                                   creado/actualizado/
                                   eliminado
        ▲                            ▲   ▲   ▲                 venta_origen_id  FK
        │                            │   │   │                   (nullable)
        │ ventas.carpeta_id          │   │   └── adeudos.cliente_id
        └──────── ventas ────────────┘   │
                  ventas.cliente_id      └────── abonos.cliente_id

   ventas ◄──────── adeudos.venta_origen_id ──── el saldo que se traspaso
```

- **`carpetas_venta`** es donde la propietaria guarda cada venta. Un solo nivel:
  no hay carpetas dentro de carpetas, porque el criterio real es el lugar.
  `ventas.carpeta_id` en `null` significa "sin carpeta", que no es una fila de
  la tabla sino el resto.
- **`clientes`** es el padron. `ventas.cliente_id` y `abonos.cliente_id` lo
  apuntan, y eso es lo que permite que la deuda vieja de alguien y su venta de
  hoy sean la misma cuenta.
- **`adeudos`** es dinero que se debe sin mercancia detras. `venta_origen_id`
  distingue los dos origenes: capturado a mano (deuda anterior) o traspasado
  desde una venta entregada que quedo con saldo.

## Reglas que valen para todo el esquema

**Llaves primarias UUID, generadas en el dispositivo.** No autoincrementos:
cuando exista sincronizacion, dos tablets que capturaron sin conexion deben
poder subir lo suyo sin colisionar. Cambiarlo despues obligaria a migrar datos
reales.

**Borrado logico en todas las tablas.** Ninguna fila se borra fisicamente; se
marca `eliminado_en`. Un registro que desaparece no se puede propagar a las
demas tablets. Toda consulta de lectura filtra por `eliminado_en IS NULL`.

**Marcas de tiempo en todas las tablas.** `creado_en` y `actualizado_en`. Al
cambiar una linea o un abono tambien se refresca el `actualizado_en` de su
encabezado, para que la sincronizacion futura sepa que el conjunto cambio.

**El dinero es entero, siempre.** Importes en centavos, puntos en centesimas de
punto. Nunca `double`: `0.1 + 0.2` no es `0.3` en punto flotante, y en una hoja
de pedido eso termina en un total que no cuadra con el papel. La conversion
vive en `EscalaDecimal`.

**Los codigos son texto.** Hay codigos de catalogo con ceros a la izquierda;
guardarlos como numero los perderia.

**Ningun total se guarda.** `TotalesPedido`, `VentaDetallada` y `ResumenVentas`
se recalculan siempre. Un total almacenado se desincroniza en cuanto se edita
un renglon o se corrige un abono.

**Las lineas copian los datos del producto.** `marca`, `codigo` y `descripcion`
se duplican en `lineas_pedido` y `lineas_venta`. Es deliberado: si manana se
corrige la descripcion en el catalogo, el documento de hace tres meses debe
seguir diciendo lo que decia. `producto_id` conserva el vinculo solo para mover
existencias.

**`ventas.cliente` es la unica copia que si se mantiene al dia.** Convive con
`cliente_id` porque tiene que seguir diciendo algo cuando la venta no esta
enlazada -las de antes de la v4, o las que se abrieron sin elegir a nadie-,
pero al renombrar en el padron `ClientesRepository` la reescribe en las ventas
de esa persona. La diferencia con la regla anterior es el motivo del cambio:
una descripcion cambia porque el articulo cambio, y un nombre cambia porque
estaba mal escrito.

**`PRAGMA foreign_keys = ON` en cada apertura.** Sin eso SQLite ignora las
llaves foraneas.

## Invariantes por tabla

### `productos`

- `cantidad_original` es el historico de entradas: sube al recibir un pedido y
  nunca baja por una venta. `cantidad_original - cantidad_actual` es lo que ha
  salido.
- `cantidad_actual` puede quedar por debajo de lo apartado (sobreventa). Se
  muestra en negativo en vez de recortarse: es justo el problema que hay que
  notar.
- La unicidad de marca + codigo **no** esta en el esquema. Con borrado logico un
  `UNIQUE` tambien chocaria contra productos dados de baja, y la propietaria si
  tiene derecho a volver a dar de alta algo que borro. La vigila
  `InventarioRepository`, que lanza `ProductoDuplicadoException`.

### `pedidos` / `lineas_pedido`

- `cerrado` y `recibido_en` son distintos: cerrado significa "ya no lo edites";
  recibido significa "sus piezas ya sumaron existencias". Recibir tambien
  cierra.
- Se guarda la **fecha** de recepcion y no un booleano: es lo que impide surtir
  el mismo pedido dos veces y deja constancia de cuando llego la caja.
- `precio_total_manual`, `valor_prom_sin_iva_manual` y `tu_pagas_manual` son
  nullable con significado: `null` = sigue la formula de `CalculoLinea`; con
  valor = gana el papel.
- `precio_unitario` y `precio_revista` son los dos precios del mismo articulo y
  no hay que confundirlos: el unitario es el de **compra** -lo que la
  propietaria le paga a la distribuidora por una pieza- y el de revista el de
  **venta** al publico que trae el catalogo. La diferencia entre los dos es el
  margen del negocio, y por eso los dos viven en la misma hoja.
- `precio_total` se calcula sobre la cantidad **pedida**, no la enviada: la
  hoja se captura al hacer el pedido, cuando todavia no se sabe que va a
  llegar. Si la distribuidora manda de menos, la cifra corregida del papel
  entra por `precio_total_manual`.
- Que `cant_enviada` supere a `cant_pedida` no es un error: la distribuidora a
  veces manda de mas y eso tambien hay que poder capturarlo.

### `ventas` / `lineas_venta` / `abonos`

- `estado` se guarda como texto (`apartada`, `entregada`, `cancelada`) para que
  la base siga siendo legible si hay que revisarla a mano. Un valor desconocido
  se lee como `apartada` en vez de reventar.
- `entregada_en` es el seguro contra descontar dos veces: la entrega solo se
  aplica si esta vacio.
- `producto_id` es nullable en `lineas_venta`: se permite vender algo que no
  esta dado de alta (una muestra, un regalo). Esa linea cobra pero no mueve
  existencias.
- Una venta cancelada conserva sus renglones como constancia, pero su total
  vale cero.
- Lo apartado no se guarda: se calcula sumando las lineas de las ventas
  `apartada` sin entregar. Es la unica suma que se hace en SQL, porque no hay
  ninguna regla de negocio que duplicar y traerse a memoria todos los renglones
  vendidos en la historia del negocio seria pagar el catalogo completo cada vez
  que se abre el inventario.
- `abonos.venta_id` es nullable desde la v4: un pago puede ser de pura deuda
  vieja, sin ninguna venta abierta contra la cual aplicarlo.
- `abonos.monto_adeudo` es la parte del pago que bajo el adeudo del cliente; el
  resto (`monto - monto_adeudo`) baja el saldo de la venta. Se guarda el reparto
  y no solo el total porque la propietaria lo puede mover: la propuesta es tapar
  primero lo viejo, pero a veces prefiere abonar todo a la venta del dia.
- Cuando `monto_adeudo` es mayor que cero, `cliente_id` nunca es nulo: sin
  cliente no habria de que adeudo descontarlo. Lo garantiza
  `VentaDetalleViewModel`, que rechaza el pago antes de escribirlo.
- Borrar una venta se lleva sus abonos, **salvo los que taparon adeudo**: esos
  se sueltan (`venta_id = NULL`) y su `monto` se recorta a `monto_adeudo`. Ese
  dinero si se cobro y bajo una deuda que nada tiene que ver con la venta que se
  borra; hacerlo desaparecer resucitaria un adeudo ya pagado.

### `carpetas_venta`

- Borrar una carpeta **no** borra sus ventas: se les pone `carpeta_id = NULL` y
  quedan sueltas. La carpeta es una etiqueta; la venta es el documento.
- No hay `UNIQUE` sobre el nombre, por la misma razon que en `productos`: con
  borrado logico chocaria contra carpetas dadas de baja.

### `clientes` / `adeudos`

- La unicidad del nombre tampoco esta en el esquema. La vigila
  `ClientesRepository.asegurarCliente`, que compara con `claveDeNombre` -sin
  mayusculas, sin acentos, sin espacios de mas- y devuelve al que ya existia en
  vez de crear un duplicado. Un cliente duplicado es el peor error posible aqui:
  parte su deuda en dos cuentas y ninguna cuadra.
- `adeudos.cliente_id` **no** es nullable: una deuda sin duenio no se le cobra a
  nadie.
- Los pagos no se restan de `adeudos.monto`. El saldo se calcula en
  `CuentaCliente` restando la suma de `abonos.monto_adeudo`, por la misma razon
  que no se guarda el saldo de una venta.
- Lo traspasado de una venta tampoco es una columna de `ventas`: es la suma de
  los `adeudos` cuyo `venta_origen_id` la apunta. Deshacer un traspaso es borrar
  ese cargo, y el saldo vuelve a aparecer solo en su venta.
- Dar de baja a un cliente suelta sus ventas (`cliente_id = NULL`) pero les deja
  el nombre copiado. `ClientesViewModel` ademas se niega a darlo de baja si
  tiene ventas o adeudos: borrar a un deudor no borraria su deuda, solo la
  volveria invisible.

## Migraciones

`schemaVersion` esta en `AppDatabase`.

| Version | Cambio |
|---|---|
| 1 | Solo `pedidos` y `lineas_pedido`: el pedido a la distribuidora. |
| 2 | Agrega `productos`, `ventas`, `lineas_venta` y `abonos`; agrega `pedidos.recibido_en` y `lineas_pedido.producto_id`, las dos columnas que enlazan lo viejo con el inventario. |
| 3 | Agrega `lineas_pedido.precio_unitario` y `lineas_pedido.precio_total_manual`: el precio de compra a la distribuidora, que hasta aqui solo se conocia por hoja completa. Las hojas ya capturadas quedan en cero, porque no hay de donde deducirlo. |
| 4 | Agrega `clientes`, `carpetas_venta` y `adeudos`; agrega `ventas.cliente_id` y `ventas.carpeta_id`; y **recrea `abonos`** para que `venta_id` deje de ser obligatorio y para agregarle `cliente_id` y `monto_adeudo`. Las ventas y los abonos ya capturados se quedan como estaban: sin cliente del padron, sin carpeta y con `monto_adeudo` en cero, que es la verdad -se cobraron cuando los adeudos no existian, asi que ninguno tapo deuda-. |
| 5 | Agrega `clientes.telefono` y `clientes.direccion`. Los clientes que ya existian quedan con las dos vacias: no se intentan deducir de `notas`, donde hay telefonos, apodos y direcciones mezclados, porque una direccion mal extraida es peor que una vacia -la vacia se ve y se llena, la equivocada se lee como buena-. |

La v4 es la primera que **recrea** una tabla en vez de agregarle columnas, y
eso tiene dos consecuencias que conviene no olvidar:

- `onUpgrade` empieza con `PRAGMA foreign_keys = OFF`. Recrear `abonos` es
  copiar a una tabla nueva, tirar la vieja y renombrar; con las llaves
  encendidas ese baile falla o reescribe referencias a medio camino.
  `beforeOpen` las vuelve a encender antes de que la aplicacion escriba nada.
- La migracion esta probada de verdad, sobre una base v3 levantada a mano con
  ventas, lineas y abonos dentro:
  `test/infrastructure/migracion_v4_test.dart`. Es la prueba mas cara del
  proyecto y la que mas importa, porque la tablet de la propietaria no tiene
  respaldo. La v5 tiene la suya sobre una base v4 poblada:
  `test/infrastructure/migracion_v5_test.dart`.

Y hay una trampa que la v5 destapo y que va a estar ahi en cada version nueva:
**`createTable` crea la tabla como es hoy, no como era en su version.** Una
tablet que viene de la v3 crea `clientes` en el escalon de la v4 y esa tabla ya
nace con `telefono` y `direccion`; si el escalon de la v5 se las agregara sin
mas, la migracion se caeria con `duplicate column name` justo a la mitad. Por
eso cada `addColumn` lleva ademas el `desde >=` de la version en que su tabla
nacio:

```dart
if (desde >= 4 && desde < 5) {
  await m.addColumn(clientes, clientes.telefono);
}
```

Al tocar `tables.dart` hay que subir `schemaVersion`, agregar el paso en
`onUpgrade` y regenerar:

```sh
dart run build_runner build --force-jit
```

`--force-jit` es necesario porque la compilacion AOT del script de build choca
con los build hooks de `sqlite3`.
