# Manual de uso

La aplicacion tiene cinco pestanas. Las tres primeras son los tres momentos
del negocio en el orden en que ocurren, con el inventario al centro porque es el
que se consulta a media conversacion con un cliente. La cuarta, **Adeudos**, es
lo que queda cuando la venta no se termina de pagar. La quinta, **Respaldo**, no
es del negocio sino de tus datos: es la que hace que nada de lo anterior se
pierda si le pasa algo a la tablet.

## 1. Pedidos — cuando le compras a la distribuidora

1. **Nuevo pedido** (boton de abajo a la derecha). Se pide el nombre del
   catalogo (`Catalogo 9`, `C-14`, `Navidad`) y una marca, que se propone luego
   en cada linea para no teclearla otra vez.
2. **Agrega las lineas** tal como vienen en la hoja impresa: marca, codigo,
   descripcion, cantidad pedida y enviada, puntos, los dos precios, valor
   promocionado, descuento CN y regalos.
   - Los dos precios se parecen y no son lo mismo: el **precio unitario** es lo
     que *tu* le pagas a la distribuidora por una pieza, y el **precio de
     revista** es lo que le cobras al cliente. La diferencia entre los dos es
     tu ganancia.
   - Si el articulo ya esta en tu inventario, usa **Resurtir algo del
     inventario** y se llenan solos marca, codigo y descripcion. La lista pone
     primero lo agotado, que es justo lo que hay que volver a pedir.
   - **Precio total**, **Valor prom. sin IVA** y **Tu pagas** se calculan
     solos: el precio total es el unitario por la cantidad pedida. Si la hoja
     impresa trae otra cifra, toca el candado y captura la del papel.
3. **Cuando llegue la caja, toca "Recibir".** Ahi es donde la cantidad
   *enviada* de cada linea entra a tu inventario. Lo que no exista se da de alta
   solo, con la marca, codigo y descripcion de la hoja.
   - La diferencia entre lo pedido y lo enviado queda marcada como **faltante**.
   - Un pedido recibido ya no se edita: cambiar una cantidad despues dejaria tu
     existencia mintiendo. Esto no se puede deshacer desde la aplicacion.

El encabezado del pedido te dice cuanto te costo la caja (**Costo de
compra**), cuanto llevas pagado a la distribuidora, cuantos puntos juntaste y
cuantas piezas te faltan.

## 2. Inventario — lo que tienes

Es un catalogo simple: marca, codigo, descripcion, cantidad actual y original.

- **Cantidad actual**: lo que hay fisicamente hoy.
- **Cantidad original**: todo lo que ha entrado desde que lo diste de alta. No
  baja cuando vendes; sirve para saber cuanto se ha movido.
- **Apartadas**: piezas que ya prometiste en una venta abierta. Siguen en casa,
  pero no se las puedes prometer a nadie mas.

Cada renglon muestra `actual / de original` y, con los botones `−` y `+`,
puedes corregir el conteo cuando cuentes cajas. Si el conteo sube por encima de
lo que habia entrado, la original sube tambien.

Los avisos que veras:

| Etiqueta | Significa |
|---|---|
| **N apartadas** | Hay ventas abiertas que ya comprometieron esas piezas |
| **Agotado** | No queda ninguna. Toca pedirla |
| **Faltan N** | Apartaste mas de lo que tienes. Vas a quedar mal con alguien |

Arriba a la derecha puedes filtrar solo lo que tiene apartado, o esconder lo
agotado.

## 3. Ventas — cuando le vendes a un cliente

1. **Nueva venta**: se pide el cliente. Se pide de entrada porque casi nadie
   paga completo el mismo dia y sin nombre no hay a quien cobrarle.
   - **Se elige de tu lista, no se teclea.** Escribe las primeras letras y toca
     el nombre. Si es alguien nuevo, la primera opcion es *Dar de alta a
     "..."*: queda en la lista y elegido, sin ir a otra pantalla.
   - Elegirlo de la lista es lo que hace que su deuda vieja y esta venta sean la
     misma cuenta. Si en vez de eso se teclea dos veces distinto -"Tony" y
     "toni"-, para la aplicacion son dos personas y ningun abono cuadra.
2. **Apunta su telefono y su direccion** desde el menu de los tres puntos,
   **Editar datos de la venta y del cliente**. Se guardan en la ficha de la
   persona, no en esta hoja: en su proxima venta ya aparecen solos, y si
   corriges un numero mal apuntado se corrige en todas sus ventas a la vez.
   Se ven arriba, en el encabezado de la venta, y el telefono se copia con
   tocarlo.
   - Los mismos datos se capturan desde Adeudos, en la cuenta de la persona,
     con **Telefono, direccion y nota**. Es la misma ficha vista desde el otro
     lado.
   - Si la venta trae el nombre escrito a mano -las viejas- no hay donde
     guardarlos: primero eligela de tu lista.
3. **Agrega productos**. Nada de teclear lo que ya esta dado de alta: toca
   **Marca** y elige de la rejilla, toca **Producto** y elige de la rejilla del
   inventario -que puedes buscar y que ya viene filtrada por la marca-. Marca,
   codigo y descripcion se copian solos al renglon, y debajo se ve cuantas
   piezas te quedan *disponibles* (existencia menos apartado). Solo capturas
   cantidad, precio unitario y, si aplica, el descuento del renglon.
   - Puedes vender algo que no tengas en el catalogo: toca **A mano** y teclea
     marca, codigo y descripcion. Esa linea cobra pero no mueve inventario.
   - Si vendes mas de lo disponible la aplicacion te avisa, pero no te lo
     impide: a veces vendes algo que sabes que llega en el proximo pedido.
4. **La venta nace apartada.** Las piezas quedan comprometidas pero siguen en
   casa. Cuando el cliente se lleve la mercancia, toca **Entregar y descontar
   del inventario**: ahi si bajan las existencias.
5. **Registra los abonos** conforme te vayan pagando. La aplicacion propone el
   saldo completo, y tu lo bajas a lo que traiga. Cada pago puede llevar fecha y
   una nota (`efectivo`, `transferencia`).

Entregar y cobrar son cosas distintas: una venta entregada puede seguir
debiendo dinero durante meses, y eso es lo normal.

**Cancelar** libera el apartado y, si ya la habias entregado, regresa las
piezas al inventario. **Regresar a apartada** deshace una entrega o una
cancelacion.

### El filtro que mas vas a usar

En la lista de ventas, **Me deben** te muestra solo las que tienen saldo. El
encabezado suma lo vendido, lo cobrado y lo que te deben de lo que estas
viendo: si filtras, el resumen contesta sobre lo filtrado.

Cada renglon trae una barra de avance del cobro y la etiqueta **Liquidada**
cuando ya no falta nada.

### Carpetas — separar por lugar

Si vendes en varios lugares, la lista corrida deja de servirte: lo que quieres
saber antes de salir no es "cuanto me deben" sino "cuanto me deben en Xalisco".

- **Crear una carpeta**: el menu de los tres puntos, arriba a la derecha,
  **Nueva carpeta**. Ponle el nombre del lugar. Al crearla entras a ella.
- **Entrar y salir**: la pantalla de Ventas te muestra primero tus carpetas, con
  cuantas ventas guarda cada una y cuanto te deben ahi. Tocas una y ves sus
  ventas; la flecha de arriba a la izquierda (o el boton de atras de la tablet)
  te regresa.
- **Meter una venta a una carpeta**: manten el dedo sobre ella en la lista y
  elige **Mover a otra carpeta**. Tambien puedes hacerlo desde la venta abierta,
  en su menu.
- Una venta que abras **estando dentro de una carpeta nace ahi**. Las que no
  esten en ninguna caen en **Sin carpeta**, que se ve como una carpeta mas.
- **Buscar salta por encima de las carpetas.** Si escribes un nombre en el
  buscador, te muestra las ventas de todas: estas buscando a una persona, no un
  lugar.
- **Borrar una carpeta no borra sus ventas.** Quedan sueltas, en Sin carpeta.
- El resumen de arriba y el boton de compartir hablan de la carpeta en la que
  estas: dentro de Tepic, el Excel sale con las ventas de Tepic.

Mientras no crees ninguna carpeta, la pantalla se ve y funciona exactamente
igual que antes.

## 4. Adeudos — lo que te deben de antes

Esta pestana existe por un caso concreto: alguien se llevo mercancia hace
meses, cuando todavia no usabas la aplicacion, y no ha terminado de pagarla.

Eso **no se puede capturar como venta**. Una venta descuenta del inventario, y
dar de alta hoy productos que salieron el ano pasado dejaria tus existencias
mintiendo justo en el numero que usas para prometerle piezas a alguien mas. Un
adeudo, en cambio, es solo dinero: anotas cuanto debe y ya.

1. **Anotar un adeudo**: boton **Adeudo**, abajo a la derecha. Eliges de quien
   es, cuanto debe, de que (`productos de la campana 9`, `lo de diciembre`) y
   desde cuando. No toca tu inventario.
2. **La lista** muestra a cada persona con lo que debe en total, y debajo de
   donde viene: **De antes** es el adeudo, **En ventas** es el saldo de sus
   ventas abiertas. Arranca mostrando solo a quien te debe.
3. **Tocando a alguien** ves su cuenta completa: sus cargos, los pagos que ha
   dejado contra la deuda y sus ventas, cada una con su saldo. Desde ahi puedes
   corregirle el nombre o abonarle.

### Como se cobra cuando alguien debe de antes y ademas acaba de comprar

Es el caso de Tony: te debe 2000 de antes y hoy se llevo 1000 en producto.

Cuando **registras el abono dentro de la venta**, la aplicacion te propone el
reparto: **primero tapa lo viejo** y lo que sobre baja la venta del dia. Ves las
dos cifras y puedes moverlas -si prefieres abonar todo a la venta, cambias *A su
adeudo* a cero-. **Repartir solo** vuelve a la propuesta.

Es un solo pago aunque tape dos cosas, porque Tony te entrego un billete, no
dos. Por eso aparece una sola vez, y para corregirlo se toca ahi mismo.

Si Tony viene a dejar algo **sin llevarse nada**, se lo abonas desde su cuenta,
en Adeudos: ahi todo el pago va contra la deuda vieja.

### Pasar el saldo de una venta a la cuenta

Cuando una venta ya se entrego y llevas meses persiguiendola hoja por hoja,
puedes mandar lo que falta a la cuenta del cliente: en la venta, el menu de los
tres puntos, **Pasar el saldo a adeudos**.

- No entra ni sale dinero: la deuda cambia de lugar. Deja de contarse en Ventas
  y empieza a contarse en Adeudos, para que se cobre junto con lo demas que esa
  persona arrastra.
- La venta queda con saldo cero pero **no** dice Liquidada, porque nadie pago.
  Dice **En adeudos**.
- Se puede deshacer: en la misma venta, **Regresar el saldo a esta venta**.
- Solo se puede con ventas ya entregadas y con un cliente elegido de la lista.
  Mientras la mercancia no salga, lo que tienes es un apartado, y un apartado se
  cancela, no se cobra aparte.

## 5. Mandar tus numeros por WhatsApp

Arriba a la derecha, en **Pedidos**, **Ventas** y **Adeudos**, esta el boton de
compartir. Al tocarlo la aplicacion arma una hoja de Excel y abre el menu de
Android para que elijas WhatsApp -o correo, o Drive- y a quien se la mandas.

**Manda lo que estas viendo.** Si filtraste **Me deben** y buscaste a una
clienta, el archivo trae eso y nada mas. Si estas dentro de una carpeta, trae
esa carpeta. Si quieres todo, sal de la carpeta, quita el filtro y borra la
busqueda antes de tocar el boton.

El archivo de ventas trae tres pestanas: **Ventas** (una fila por clienta, con
su carpeta, su total y su saldo), **Renglones** (que articulo se vendio) y
**Abonos** (cada pago que entro, ordenado por fecha, y a que le pego). El de
pedidos trae dos: **Pedidos** y **Renglones**. El de adeudos trae tres:
**Adeudos** (una fila por persona), **Cargos** y **Pagos**.

Los importes van como numeros de verdad, no como texto: en Excel los puedes
sumar, ordenar de mayor a menor y filtrar. Al pie de cada pestana hay una fila
de **TOTAL**.

## 6. Respaldo — para no perder nada

Todo lo que capturas vive **solo en esta tablet**. No hay internet de por medio
ni nadie guardando una copia en otro lado, asi que si la tablet se rompe, se
pierde o alguien la resetea, se va con ella un ano de ventas y de deudas.

**Respaldar y enviar** hace una copia de todo -ventas, clientes, deudas e
inventario- y abre el menu de compartir. Mandatela a tu propio WhatsApp o a tu
Drive. Toma medio minuto y es lo unico que te devuelve los datos.

Hazlo:

- Antes de instalar una version nueva de la aplicacion.
- Al terminar una ronda de cobranza, cuando acabas de capturar mucho.
- De vez en cuando aunque no pase nada. Cada semana esta bien.

La aplicacion tambien guarda una copia sola cada vez que se actualiza, antes de
tocar nada: son las que dicen *Antes de actualizar*. Esas te salvan de una
actualizacion que salga mal, pero se quedan en la misma tablet, asi que no te
salvan de perderla.

### Volver a un respaldo

En el renglon de la copia, los tres puntos → **Volver a este respaldo**. Todo
lo que capturaste despues de esa fecha desaparece, asi que la aplicacion te lo
pregunta dos veces. Antes de cambiar nada guarda una copia de como estaba, por
si te arrepientes.

### Cambiar de tablet

1. En la vieja: **Respaldar y enviar**, y guarda el archivo.
2. Instala la aplicacion en la nueva y abrela una vez.
3. Baja el archivo a la tablet nueva desde WhatsApp o Drive.
4. **Traer un respaldo de afuera**, elige el archivo, y luego **Volver a este
   respaldo**.

## Preguntas rapidas

**Vendi algo que no tengo dado de alta.** En el renglon toca **A mano** y
teclea la descripcion. Cobra igual; simplemente no descuenta de ningun
producto.

**Mis ventas viejas no tienen cliente de la lista.** Las que capturaste antes de
que existiera la lista siguen mostrando el nombre que tecleaste, y te lo avisan
al abrirlas. Para poder llevarle adeudos a esa persona, abre la venta, toca
**Editar datos de la venta y del cliente** y eligela de la lista. No se enlazan
solas a proposito: adivinar por parecido de texto es justo lo que la lista viene a
evitar.

**El telefono lo apunte en la venta y no aparece en las demas.** Si aparece: el
telefono y la direccion se guardan en la ficha de la persona, no en la hoja, y
salen en todas sus ventas. Lo que si es distinto son las **notas**, que son de
esa venta nada mas.

**Escribi mal el nombre de un cliente.** Abre su cuenta en Adeudos y toca
**Corregir el nombre**. Se corrige tambien en todas sus ventas.

**Se me perdio la tablet.** Si mandaste un respaldo por WhatsApp, se recupera
todo hasta ese dia: instala la aplicacion en la tablet nueva, pestana
**Respaldo** → **Traer un respaldo de afuera** y luego **Volver a este
respaldo**. Si nunca mandaste ninguno, no hay de donde sacarlo.

**Quiero borrar un cliente.** Solo se puede si no tiene ventas ni adeudos.
Borrar a alguien que te debe no borraria la deuda, solo la esconderia; si el
problema es el nombre, corrigelo.

**Le anote un adeudo a quien no era.** Borra el cargo desde su cuenta y anotalo
en la correcta. Se hace en dos pasos a proposito, para que quede claro que se le
bajo a uno y se le cargo al otro.

**Me equivoque en una venta que ya entregue.** Editala normal: la aplicacion
ajusta el inventario por la diferencia. Si le subes la cantidad descuenta mas;
si se la bajas o quitas el renglon, las piezas regresan.

**Di de baja un producto que aparece en ventas viejas.** Las ventas siguen
guardadas y siguen diciendo lo mismo: cada renglon conserva su propia copia de
marca, codigo y descripcion.

**Recibi un pedido dos veces por error.** No pasa nada: la aplicacion solo lo
surte una vez, y guarda la fecha en que lo hizo.

**No tengo internet.** No hace falta para capturar: todo se guarda en la
tablet. Solo para mandar el reporte por WhatsApp.

**Toque compartir y no aparece WhatsApp.** Aparece el menu de Android con todas
las aplicaciones que aceptan archivos. Si WhatsApp no sale, desliza el menu
hacia arriba para ver la lista completa.

**Se me perdio el archivo que mande.** No importa: se vuelve a sacar en un
segundo. La tablet no lo guarda a proposito, para no llenarse de copias
viejas.
