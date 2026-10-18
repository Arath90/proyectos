# Instalar una version nueva en la tablet sin perder datos

La base de la propietaria vive en la tablet y no hay servidor. Actualizar la
aplicacion **no** borra nada por si mismo: el archivo
`punto_venta_madre.sqlite` esta en el almacenamiento privado de la aplicacion y
un APK nuevo instalado encima del viejo no lo toca.

Lo que si lo borra son cuatro cosas, y las cuatro se evitan con reglas fijas.

| Lo que borra los datos | Como se evita |
|---|---|
| Desinstalar, o "Borrar datos" en Ajustes | No hacerlo. Si Android pide desinstalar para poder instalar, **parar**: significa que algo de abajo esta mal. |
| Cambiar el `applicationId` | Esta clavado en `android/app/build.gradle.kts` con un comentario. Para Android, otro id es otra aplicacion. |
| Firmar el APK con otra llave | La llave de release es una sola y se guarda. Es el resto de este documento. |
| Cambiar el esquema sin migracion | Cada version sube `schemaVersion` y agrega su paso en `onUpgrade`, con prueba. Ver `MODELO_DE_DATOS.md`. |

## La llave de firma

Android identifica una aplicacion por su `applicationId` **y su firma**. Si un
dia se instala un APK firmado con una llave distinta, el sistema se niega a
actualizar: el unico camino queda ser desinstalar, y ahi se va la base.

El peligro no es teorico. Sin configurar nada, Flutter firma el APK de release
con la **llave de debug**, que se genera sola en cada computadora y se puede
borrar sin darse cuenta. Compilar desde otra maquina, o reinstalar el sistema,
bastaria para no poder volver a actualizar la tablet.

### La llave de este proyecto ya esta decidida: NO crees una nueva

La tablet de la propietaria tiene instalada una version firmada con el
`debug.keystore` de la computadora donde se compilo. Eso no fue una decision,
fue el valor por omision de Flutter; pero una vez instalado, **es irreversible
sin desinstalar**. Generar hoy una llave nueva -por mas correcta que sea- haria
que la siguiente actualizacion se rechace.

Asi que la llave del proyecto es una copia de aquel `debug.keystore`, guardada
aparte para que Android Studio no la regenere:

```
C:/Users/ar90w/llave-punto-venta.jks     alias androiddebugkey
SHA-1  c2:dc:1e:5c:a6:4a:52:a8:29:98:d5:f8:b7:0f:38:94:7e:2b:2c:b2
```

Sus contrasenas son las fijas de un keystore de depuracion (`android` las dos).
No protegen nada: lo que hay que cuidar es **el archivo**, que es irremplazable
igual que cualquier otra llave de firma. Guardalo en dos lugares que no sean
esta computadora -Drive y una USB-. Si se pierde, la unica forma de instalar
una version nueva sera desinstalar, y eso borra las ventas y las deudas.

Cambiar a una llave de release "de verdad" es posible, pero cuesta un
desinstalar con restauracion desde respaldo, y no compra nada mientras la
aplicacion no se publique en una tienda. Si algun dia se hace, se hace a
proposito y con el respaldo en la mano, no de pasada.

### Apuntar el proyecto a la llave

Crear `android/key.properties` (no se sube al repositorio, ya esta en
`.gitignore`):

```properties
storePassword=android
keyPassword=android
keyAlias=androiddebugkey
storeFile=C:/Users/ar90w/llave-punto-venta.jks
```

`storeFile` tiene que ser ruta absoluta y con `/`, incluso en Windows.

### Comprobar la firma ANTES de instalar

Esto convierte la parte peligrosa en una verificacion de treinta segundos. Se
saca el APK que la tablet ya tiene y se comparan las dos huellas: si son
iguales, la actualizacion esta garantizada.

```sh
adb shell pm path com.example.punto_venta_madre        # imprime la ruta
adb pull <la-ruta-que-imprimio> instalado.apk
apksigner verify --print-certs instalado.apk           # huella de la tablet
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

`apksigner` esta en `<SDK>/build-tools/<version>/`. Las dos huellas SHA-1 deben
ser la misma que aparece arriba. Si no coinciden, **no instales**: avisa antes
de tocar nada.

### Compilar e instalar

```sh
flutter build apk --release
```

El APK sale en `build/app/outputs/flutter-apk/app-release.apk`.

Si falta `key.properties`, la compilacion **falla** con el motivo escrito. Es a
proposito: un aviso no serviria, porque Flutter se traga la salida de Gradle y
nadie lo veria, y un APK de release firmado con la llave de debug se instala
bien la primera vez -es la *siguiente* actualizacion la que se rechaza, cuando
ya hay meses capturados-.

Para sacar un APK de release de prueba, que no va a instalarse en la tablet de
la propietaria:

```sh
flutter build apk --release -Pfirma_de_prueba=si
```

Para instalarlo:

```sh
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

`-r` es "reinstalar conservando los datos".

**Nunca con `flutter install`.** Ese comando corre por dentro el mismo
`adb install -r`, pero si falla **desinstala la version vieja y reinstala** por
su cuenta (`android_device.dart:414-421` del SDK de Flutter). Es decir, toma el
unico caso en que Android te esta protegiendo -un rechazo que deja los datos
intactos- y lo convierte en el borrado que el rechazo venia a evitar, sin
preguntar. Con `adb` directo, un fallo es solo un fallo.

Si `adb` contesta
`INSTALL_FAILED_UPDATE_INCOMPATIBLE` o
`INSTALL_FAILED_VERSION_DOWNGRADE`, **no desinstales para salir del paso**:

- `UPDATE_INCOMPATIBLE` significa que la firma no coincide. Estas compilando
  con otra llave, o con la de debug. Arregla `key.properties`.
- `VERSION_DOWNGRADE` significa que el `versionCode` del APK es menor o igual
  al instalado. Sube el numero despues del `+` en `version:` de `pubspec.yaml`.

### Antes de cada instalacion

1. En la tablet, pestana **Respaldo** → **Respaldar y enviar**, y mandar el
   archivo a WhatsApp o Drive. Treinta segundos.
2. Instalar el APK.
3. Abrir la aplicacion. Si la version nueva migra la base, la aplicacion hace
   sola una copia de como estaba antes de tocar nada; queda en la pestana
   Respaldo como *Antes de actualizar*.

El paso 1 no es redundante con el 3. La copia automatica se queda en la misma
tablet, asi que salva de una migracion que salga mal; no salva de que la tablet
se caiga al agua, que es la forma mas probable de perderlo todo.

## Cambiar de tablet, o recuperar despues de un desastre

1. En la tablet vieja (si todavia enciende): **Respaldar y enviar**, y guardar
   el archivo en WhatsApp o Drive. Si ya no enciende, sirve el ultimo respaldo
   que se haya mandado.
2. Instalar el APK en la tablet nueva -firmado con la misma llave- y abrirla
   una vez.
3. Descargar el archivo de respaldo a la tablet nueva desde WhatsApp o Drive.
4. En la aplicacion: pestana **Respaldo** -> **Traer un respaldo de afuera**,
   elegir el archivo, y en el renglon que aparece, los tres puntos -> **Volver
   a este respaldo**.

El paso 4 solo copia el archivo a la lista; reemplazar la base es la accion
aparte del paso siguiente, con su confirmacion. Si el respaldo viene de una
version anterior de la aplicacion, se migra solo al abrirlo.

## Apendice: sacar la base por USB

Sirve cuando la version instalada en la tablet es **anterior** a la pestana
Respaldo, que es el caso en que el paso 1 de "Antes de cada instalacion" no se
puede hacer: la aplicacion que esta corriendo todavia no sabe respaldarse.

El truco es que un APK *debug* lleva la misma firma y el mismo `applicationId`,
asi que entra encima sin tocar los datos, y al ser debuggable habilita `run-as`,
que deja leer el archivo sin abrir la aplicacion:

```sh
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
# NO abrir la aplicacion: se busca la base como estaba, sin migrar
adb exec-out run-as com.example.punto_venta_madre     cat app_flutter/punto_venta_madre.sqlite > respaldo.sqlite
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Dos detalles que arruinan el archivo si se pasan por alto:

- **`exec-out`, no `shell`.** `adb shell` traduce saltos de linea y corrompe
  cualquier binario que pase por el.
- **No lo redirijas desde PowerShell.** El `>` de PowerShell 5.1 reescribe la
  salida como texto. Usa Git Bash o `cmd`.

Comprobar que salio bien antes de seguir:

```sh
python -c "import sqlite3;c=sqlite3.connect('respaldo.sqlite');print(c.execute('PRAGMA integrity_check').fetchone(),      c.execute('PRAGMA user_version').fetchone())"
```

Tiene que decir `ok` y la version de esquema **anterior** a la que trae el
codigo. Si dice la misma, la aplicacion ya migro y esta copia es de despues.
