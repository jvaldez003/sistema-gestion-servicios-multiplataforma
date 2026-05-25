# FlowServ — Contexto del Proyecto para el Agente

## ¿Qué es FlowServ?

Plataforma SaaS móvil multitenant para gestión de citas, servicios y empleados en negocios del sector servicios (barberías, estéticas, lavaderos, consultorios, spas). Opera inicialmente en Colombia (Cali, Valle del Cauca).

---

## Stack Tecnológico

| Capa | Tecnología |
|---|---|
| Frontend | Flutter (Dart) — Android, iOS |
| Estado | Riverpod / BLoC |
| Navegación | GoRouter |
| Backend | Firebase Cloud Functions (Node.js / TypeScript) |
| Base de datos | Cloud Firestore (NoSQL) |
| Autenticación | Firebase Auth + Custom Claims |
| Archivos | Firebase Storage |
| Notificaciones | Firebase Cloud Messaging (FCM) |
| Pagos | MercadoPago (principal) / PayU Latam (alternativa) |
| Correos | SendGrid |
| Mapas | Mapbox / Google Maps |
| CI/CD | GitHub Actions |

---

## Arquitectura

**Clean Architecture + Feature-First**

```
lib/
├── features/
│   ├── auth/
│   │   ├── domain/        ← Entities, Repository interfaces, Use Cases (solo Dart puro)
│   │   ├── data/          ← Implementaciones Firebase, modelos Firestore
│   │   └── presentation/  ← Screens, Providers Riverpod, Widgets
│   ├── booking/
│   ├── social/
│   ├── payments/
│   ├── employees/
│   ├── dashboard/
│   ├── catalog/
│   └── loyalty/
└── core/
    ├── theme/             ← Design tokens: AppColors, AppTypography, AppSpacing
    ├── widgets/           ← Componentes reutilizables
    ├── utils/
    └── router/            ← GoRouter con guards de rol
```

**Regla fundamental:** Domain no importa Flutter ni Firebase. Presentation nunca llama a Firebase directamente.

---

## Sistema de Roles — MUY IMPORTANTE

### Un solo login para todos

No hay selector de rol en el registro ni en el login. El usuario se registra con correo/contraseña o Google. El sistema detecta automáticamente el contexto disponible leyendo los **Custom Claims del token JWT** de Firebase Auth.

### Custom Claims del token

```json
{
  "rol": "usuario",
  "negociosAdmin": ["negocioId1", "negocioId2"],
  "empleadoEn": "negocioId3",
  "activo": true
}
```

### Lógica de detección de contexto (GoRouter)

```dart
// Al hacer login, el router lee el token y decide:
if (token.negociosAdmin.isNotEmpty)  → muestra opción "Mi Negocio" en el perfil
if (token.empleadoEn != null)        → muestra opción "Modo Empleado" en el perfil
// Siempre puede usar la app como cliente
```

### Un usuario puede tener TODOS los roles al mismo tiempo

- **Cliente:** reserva citas en cualquier negocio de la plataforma
- **Empleado:** trabaja en UN negocio (el que tiene en `empleadoEn`)
- **Admin:** gestiona uno o más negocios propios (`negociosAdmin[]`)

El usuario cambia de contexto desde el menú de perfil sin cerrar sesión. El contexto activo se guarda en `SharedPreferences`.

### Cómo se adquiere cada rol

| Rol | Cómo se adquiere |
|---|---|
| Cliente | Automático al registrarse |
| Admin | El usuario crea un negocio desde su perfil → Cloud Function actualiza `negociosAdmin[]` |
| Empleado | Se postula a un negocio con CV, el admin acepta → Cloud Function asigna `empleadoEn` |
| Empleado | El admin lo invita directamente por correo → el usuario acepta la invitación |

### Cómo se pierde el rol de Empleado

El admin desvincula al empleado → Cloud Function ejecuta:
```javascript
admin.auth().setCustomUserClaims(uid, { empleadoEn: null, activo: false })
admin.auth().revokeRefreshTokens(uid)  // Invalida todos los tokens activos
```
El usuario pierde acceso al panel de empleado inmediatamente pero conserva su cuenta como cliente.

---

## Flujo de Postulación de Empleado

```
Usuario ve negocio en el explorador
    ↓
Pulsa "Postularme como empleado" (visible solo si no es ya empleado/admin ahí)
    ↓
Llena formulario: especialidad, comisión esperada, descripción, sube CV (PDF → Firebase Storage)
    ↓
Cloud Function applyToJob() → crea postulación en Firestore → notifica al admin (FCM + correo)
    ↓
Admin ve la postulación en SA-APPLICATIONS → revisa CV → Acepta o Rechaza
    ↓
Si acepta → Cloud Function respondToApplication():
  - Crea documento en negocios/{negocioId}/empleados/{uid}
  - setCustomUserClaims(uid, { empleadoEn: negocioId })
  - Envía FCM + correo de bienvenida al nuevo empleado
    ↓
El empleado recibe notificación → acepta cambiar al contexto de empleado
    ↓
GoRouter navega a SE-HOME (agenda del día)
```

El admin también puede invitar directamente a cualquier usuario por correo (`inviteEmployee()`). El usuario recibe la invitación en su bandeja y decide aceptar o rechazar.

---

## Publicaciones Sociales (Feed)

Las fotos de trabajos son **publicaciones** con comportamiento social:

- El admin o empleado crea una publicación con: fotos (hasta 5), descripción de texto libre, servicio relacionado, empleado etiquetado
- Las publicaciones aparecen en **dos lugares:**
  1. **Feed general** (`SC-FEED`): todas las publicaciones de todos los negocios, scroll infinito, ordenadas por fecha o relevancia
  2. **Perfil del negocio** (`SC-BIZ-DETAIL`): sección "Trabajos recientes" en mosaico

- **Reacciones:** ❤️ Me gusta y ⭐ Guardado. Toggle (se puede quitar). Un usuario, una reacción de cada tipo por publicación.
- **Comentarios:** cualquier usuario puede comentar. El negocio puede responder. El admin puede eliminar comentarios inapropiados.

```
Colección Firestore:
publicaciones/{postId}
  negocioId, autorId, fotos:[], descripcion, servicioId,
  etiquetados:[], likes:0, likesUids:[], guardados:0,
  guardadosUids:[], comentarios:0, fechaCreacion, activa:bool

Subcollección:
publicaciones/{postId}/comentarios/{comentarioId}
  autorId, texto, fechaCreacion, respuestaDe
```

---

## Estructura de Datos Firestore

```
usuarios/{uid}
  nombre, correo, rol, negociosAdmin:[], empleadoEn,
  fcmTokens:[], puntos:0, publicacionesGuardadas:[]

negocios/{negocioId}
  duenoId, nombre, tipo, direccion, horario, descripcion,
  estado, geohash, depositoPorcentaje, programaFidelizacion
  
  ├── servicios/{servicioId}
  │     nombre, icono, descripcion, precio, duracion, buffer, activo
  │
  ├── empleados/{uid}
  │     nombre, rol, comisionPorcentaje, activo, visibleParaClientes,
  │     diasLaborales:[], especialidad
  │     └── bloqueos/{bloqueoId}  fechaInicio, fechaFin, motivo
  │
  ├── recursos/{recursoId}
  │     nombre, tipo, activo
  │
  ├── productos/{productoId}
  │     nombre, precio, stock, activo
  │
  └── galeria/{fotoId}
        url, servicioTipo, empleadoId, fecha, destacada

citas/{citaId}
  negocioId, clienteId, empleadoId, recursoId,
  servicios:[], productos:[], fecha, hora, duracionTotal,
  estado, pagoId, total, retrasoMinutos

transacciones/{pagoId}
  negocioId, citaId, clienteId, monto, metodoPago,
  estado, pasarela, referencia, reembolsado

publicaciones/{postId}
  (ver estructura arriba)

postulaciones/{postulacionId}
  applicantId, negocioId, estado, especialidad,
  comisionEsperada, cvUrl, fechaPostulacion

invitaciones/{invitacionId}
  targetUid, negocioId, estado, datosOferta

ganancias/{empleadoId}_{fecha}
  gananciaTotal, comisionPlataforma, totalNeto

fidelizacion/{clienteId}_{negocioId}
  puntos, sellosActuales, cupones:[], historialCanjes:[]

cierresCaja/{negocioId}_{fecha}
  efectivoContado, totalDigital, diferencia, timestamp
```

---

## Módulos — Resumen rápido

| Módulo | Descripción |
|---|---|
| `auth/` | Registro único, login, detección de rol, cambio de contexto |
| `business/` | Crear negocio, onboarding 4 pasos, configuración, multisede |
| `employees/` | Postulación con CV, invitación directa, gestión del equipo |
| `social/` | Feed de publicaciones, reacciones, comentarios |
| `booking/` | Explorador de negocios, reservas, motor de conflictos |
| `payments/` | MercadoPago/PayU, webhooks, reembolsos, historial |
| `notifications/` | FCM push, correos SendGrid |
| `employee_panel/` | Agenda diaria, completar servicio, ganancias, horario |
| `dashboard/` | KPIs admin, gestión de citas, equipo, postulaciones |
| `reports/` | Reportes financieros, horas pico, cierre de caja, PDF |
| `loyalty/` | Puntos, sellos, canjes, cupones de retención |

---

## Convenciones de Código

```
Commits:    feat(booking): agregar selección múltiple de servicios
            fix(payments): corregir webhook duplicado
            
Ramas:      main → develop → feature/{modulo}-{descripcion}
                           → fix/{descripcion}
                           → hotfix/{descripcion}

Capas:      Domain  → solo Dart puro, sin imports de Flutter o Firebase
            Data    → implementa interfaces de Domain, usa Firebase SDK
            Presentation → usa Use Cases, nunca Firebase directamente

Tokens:     AppColors.primary  (nunca Color(0xFF6F4FF2) directo)
            AppSpacing.lg      (nunca 16.0 directo)
```

---

## Security Rules — Principios

```javascript
// Toda colección de negocio verifica negocioId
allow read, write: if request.auth != null
  && (
    resource.data.negocioId == request.auth.token.empleadoEn
    || request.auth.token.negociosAdmin.hasAny([resource.data.negocioId])
  );

// Servicios inactivos: clientes no los ven
allow read: if resource.data.activo == true
  || request.auth.token.negociosAdmin.hasAny([resource.data.negocioId]);
```

---

## Requerimientos Funcionales (RF)

Ordenados por flujo de la aplicación.

### Bloque 1 · Registro y detección de rol

| ID | Nombre | Descripción | FE | BE / DB / CF |
|---|---|---|---|---|
| RF-01 | Registro único de usuario | Un solo formulario para todos. El usuario ingresa nombre, correo, contraseña o Google OAuth. No se elige rol. El sistema lo crea como usuario base. | Pantalla única sin selector de rol. | CF onUserCreate → setCustomUserClaims(uid, { rol:"usuario", negociosAdmin:[], empleadoEn:null }) → crea usuarios/{uid} en Firestore. |
| RF-02 | Login único con detección automática | Una sola pantalla de login. Tras autenticarse, el sistema lee el Custom Claim y redirige al contexto correspondiente (Cliente → SC-HOME, Empleado → SE-HOME, Admin → SA-HOME). | Tras login, lee token.negociosAdmin y token.empleadoEn para decidir la ruta con GoRouter. | Firebase Auth signInWithEmailAndPassword() o Google. El token JWT contiene todos los roles. No requiere consulta a Firestore. |
| RF-03 | Cambio de contexto de rol | Un usuario con varios roles cambia entre "Modo Cliente", "Modo Empleado" y "Mi Negocio" desde el menú de perfil sin cerrar sesión. | Menú de perfil con selector de contexto. Contexto activo guardado en SharedPreferences. GoRouter navega al home del contexto elegido. | No requiere llamada al servidor. Lógica completamente en Flutter leyendo el token en caché. |
| RF-04 | Recuperación de contraseña | El sistema envía un correo de recuperación a cualquier usuario. Aplica para todos los roles. | Link "¿Olvidaste tu contraseña?" en el login. | Firebase Auth sendPasswordResetEmail(). Firebase maneja el envío. |

### Bloque 2 · Creación de negocio — usuario se vuelve admin

| ID | Nombre | Descripción | FE | BE / DB / CF |
|---|---|---|---|---|
| RF-05 | Crear negocio desde cuenta existente | Cualquier usuario puede crear un negocio desde su perfil. Al hacerlo se le asigna el rol de admin de ese negocio sin perder el rol de cliente. | Botón "Crear mi negocio" en la pantalla de perfil. Inicia el onboarding de 4 pasos. | CF createBusiness(uid, datos) → crea negocios/{negocioId} con duenoId=uid → setCustomUserClaims actualizando negociosAdmin:[negocioId]. |
| RF-06 | Onboarding del negocio (4 pasos) | El nuevo admin configura su negocio: tipo → datos (nombre, dirección, horario, descripción) → servicios iniciales → confirmación y publicación. | Flujo de 4 pantallas con step dots. Estado con Riverpod StateNotifier. | CF publishBusiness(negocioId) valida campos → activa estado → crea subcollección servicios/ → notificación de bienvenida. |
| RF-07 | Configuración general del negocio | El admin edita nombre, dirección, horario, descripción y toggles (notificaciones, pago anticipado, recordatorios, multisede) en cualquier momento. | Pantalla SA-SETTINGS. Botón "Guardar" activo solo con cambios pendientes (dirty state). | Escritura directa a Firestore con permisos de admin. Los cambios de horario se reflejan en tiempo real en el explorador. |
| RF-08 | Registro multisede | El admin agrega múltiples sucursales bajo la misma cuenta. Cada sucursal tiene configuración, servicios y empleados independientes. | Opción "Agregar sucursal" en SA-SETTINGS con toggle multisede activo. Selector de sucursal en el topbar. | Cada sucursal es un documento en negocios/ con el mismo duenoId. Todos los negocioId en el Custom Claim negociosAdmin[]. |

### Bloque 3 · Postulación e incorporación de empleados

| ID | Nombre | Descripción | FE | BE / DB / CF |
|---|---|---|---|---|
| RF-09 | Postulación de usuario a negocio | Un usuario puede postularse como empleado a cualquier negocio enviando su perfil y CV. La postulación queda en estado "Pendiente". Puede postularse a varios negocios al mismo tiempo. | Botón "Postularme como empleado" en SC-BIZ-DETAIL (visible solo si no es ya empleado/admin ahí). Pantalla con especialidad, comisión esperada, descripción y adjunto de CV en PDF. | CF applyToJob(uid, negocioId, datos) → crea postulaciones/{postulacionId} → FCM push + SendGrid correo al admin. DB: postulaciones/{postulacionId} con applicantId, negocioId, estado:"pendiente", cvUrl. |
| RF-10 | Gestión de postulaciones por el admin | El admin ve la bandeja de postulaciones recibidas con el perfil de cada candidato y puede aceptar o rechazar. Al aceptar, el usuario se convierte en empleado automáticamente. | Pantalla SA-APPLICATIONS con lista filtrable por estado. Card con nombre, especialidad, comisión esperada y botón de descarga del CV. | CF respondToApplication(postulacionId, decision) → si acepta: crea empleados/{uid}, setCustomUserClaims(uid, { empleadoEn: negocioId }), FCM + correo al nuevo empleado. |
| RF-11 | Notificación de resultado al candidato | El candidato recibe notificación push y correo con el resultado. Si es aceptado, la app le pregunta si desea cambiar al contexto de empleado. | Diálogo "¡Fuiste aceptado en [Negocio]! ¿Cambiar a modo Empleado ahora?". El selector de contexto incluye el nuevo rol. | CF respondToApplication() dispara FCM al candidato. DB actualiza usuarios/{uid}.empleadoEn. |
| RF-12 | Invitación directa del admin a un usuario | El admin puede invitar directamente a cualquier usuario existente buscándolo por correo. El usuario decide aceptar o rechazar. | Botón "Invitar empleado por correo" en SA-TEAM. Campo de búsqueda por correo con vista previa del usuario. | CF inviteEmployee(adminUid, targetEmail, negocioId, datosOferta) → admin.auth().getUserByEmail() → crea invitaciones/{invitacionId} → FCM + correo al usuario. |
| RF-13 | Respuesta del usuario a la invitación | El usuario invitado acepta o rechaza la invitación desde su bandeja de notificaciones. Si acepta, pasa a ser empleado automáticamente. | Card especial en la pantalla de notificaciones con el nombre del negocio y condiciones. Botones "Aceptar" y "Rechazar". | CF respondToInvitation(uid, invitacionId, decision) → si acepta: mismo flujo que RF-10. |
| RF-14 | Desactivación de empleado | El admin desvincula a un empleado. El empleado pierde el acceso al panel de empleado inmediatamente pero conserva su cuenta como cliente. | Botón "Desvincular empleado" en SA-EMP-DETAIL con diálogo de confirmación. | CF deactivateEmployee(uid, negocioId) → setCustomUserClaims(uid, { empleadoEn:null, activo:false }) → revokeRefreshTokens(uid) → DB actualiza empleados/{uid}.activo=false. |

### Bloque 4 · Catálogo y publicaciones con feed social

| ID | Nombre | Descripción | FE | BE / DB / CF |
|---|---|---|---|---|
| RF-15 | Gestión del catálogo de servicios | El admin crea, edita y activa/desactiva servicios. Cada servicio tiene nombre, ícono, descripción, precio (COP), duración y buffer de limpieza. Los inactivos no son visibles para clientes. | SA-CATALOG con toggle activo/inactivo por servicio (optimistic UI). SA-NEW-SERVICE con formulario completo. | CRUD directo a Firestore. Security Rules: lectura de clientes solo si activo==true. |
| RF-16 | Crear publicación de trabajo | El admin o empleado publica fotos de trabajos realizados con descripción de texto. Las publicaciones aparecen en el feed general y en el perfil del negocio. | Pantalla de creación con selector de fotos (máx 5), campo de descripción, selector de servicio relacionado y etiquetado del empleado. Vista previa antes de publicar. | CF createPost(uid, negocioId, datos) → sube imágenes a Storage → genera thumbnails → crea publicaciones/{postId}. DB: negocioId, autorId, fotos:[], descripcion, servicioId, etiquetados:[], likes:0, comentarios:0. |
| RF-17 | Feed general de publicaciones | Todos los usuarios ven un feed con publicaciones de todos los negocios, ordenadas por fecha o relevancia. Funciona como explorador visual. | SC-FEED con scroll vertical infinito (lazy loading). Cada card con foto, nombre del negocio, descripción, contadores de likes/comentarios, botones de reacción y botón "Agendar este servicio". | Consulta Firestore: publicaciones/ donde activa==true, ordenado por fechaCreacion DESC, paginación startAfterDocument de 10 en 10. Índice [activa, fechaCreacion DESC]. |
| RF-18 | Reacciones a publicaciones | Los usuarios reaccionan con ❤️ Me gusta o ⭐ Guardado. Toggle (se quita tocando de nuevo). Un usuario, una reacción de cada tipo por publicación. | Botones ❤️ y ⭐ en cada card y en la vista de detalle. Cambio visual con toggle. Contador con optimistic UI. | CF toggleReaction(uid, postId, tipo) → transacción Firestore: si uid en array → arrayRemove + decrement; si no → arrayUnion + increment. DB: likes, likesUids:[], guardados, guardadosUids:[]. |
| RF-19 | Comentarios en publicaciones | Los usuarios comentan en cualquier publicación. El negocio puede responder. El admin puede eliminar comentarios inapropiados. | SC-POST-DETAIL con lista de comentarios paginada y campo de texto al fondo. Comentarios del negocio con badge especial. Swipe para eliminar (solo autor o admin del negocio). | Escritura directa a Firestore para crear comentario. CF onCommentCreated → increment en publicaciones/{postId}.comentarios → FCM notificación al autor. DB: publicaciones/{postId}/comentarios/{comentarioId}. |
| RF-20 | Publicaciones en el perfil del negocio | El perfil del negocio incluye una sección "Trabajos recientes" en mosaico con las publicaciones del negocio. | Sección en SC-BIZ-DETAIL con mosaico de 3 columnas. Tap en foto → SC-POST-DETAIL. | Consulta: publicaciones/ donde negocioId==X y activa==true, limitado a 9 para la vista previa. |

### Bloque 5 · Exploración y reservas

| ID | Nombre | Descripción | FE | BE / DB / CF |
|---|---|---|---|---|
| RF-21 | Explorador de negocios | El cliente busca y filtra negocios por categoría y ubicación. Cada tarjeta muestra nombre, tipo, rating, distancia, precio desde y estado (Abierto/Ocupado/Cerrado). | SC-HOME con barra de búsqueda, chips de categoría y lista de negocios. Geolocator para la ubicación. | Consulta con GeoFlutterFire (geohash) filtrada por tipo. Solo negocios activo==true. Índice [activo, tipo, geohash]. |
| RF-22 | Detalle del negocio | El cliente ve información completa: descripción, ubicación, horario, publicaciones recientes, catálogo de servicios, lista de profesionales con disponibilidad y botón de postulación. | SC-BIZ-DETAIL con scroll. Future.wait() para cargar servicios, empleados y publicaciones en paralelo. | Tres consultas paralelas: servicios (activo==true), empleados (activo==true, visibleParaClientes==true), publicaciones (últimas 6). |
| RF-23 | Selección de servicios múltiples | El cliente selecciona uno o varios servicios. El sistema calcula duración total (incluyendo buffers de limpieza) y muestra el costo acumulado. | Toggle de selección por servicio. Widget sticky en el fondo con totales actualizados reactivamente con Riverpod. | Cálculo de totales en Flutter. Validación final en CF al crear la cita. La cita almacena servicios:[] con IDs y total precalculado. |
| RF-24 | Selección de profesional y horario | El cliente elige un profesional o "Sin preferencia" y un slot de horario disponible. La disponibilidad se calcula en tiempo real. | Scroll horizontal de pills de profesionales. Al seleccionar fecha, los slots se recargan para el profesional elegido. | CF getAvailableSlots(negocioId, empleadoId, fecha, duracionTotal) calcula slots libres descontando citas existentes y buffers. Índice [negocioId, empleadoId, fecha]. |
| RF-25 | Motor de conflictos (anti-solapamiento) | Transacciones Firestore previenen reservas duplicadas aunque dos usuarios confirmen simultáneamente el mismo slot. | Loading indicator mientras CF valida. Si hay conflicto, recarga slots y muestra mensaje de error. | CF createBooking() → runTransaction(): lee slot → verifica ocupado==false → marca ocupado + crea cita en batch. Rollback automático si falla. Máximo 3 reintentos → retorna SLOT_NOT_AVAILABLE. |
| RF-26 | Cancelación y reprogramación | El cliente puede cancelar o reprogramar con al menos 2 horas de anticipación. El admin puede cancelar en cualquier momento. | Botón "Cancelar" habilitado solo si quedan más de 2 horas. Para reprogramar, reutiliza el flujo de fecha/hora. | CF cancelBooking(citaId) → actualiza estado → libera slot → dispara notificaciones → si había pago, inicia reembolso (RF-34). |

### Bloque 6 · Pagos en línea

| ID | Nombre | Descripción | FE | BE / DB / CF |
|---|---|---|---|---|
| RF-27 | Pago de servicio al reservar | Al confirmar la cita el cliente paga con tarjeta, PSE, Nequi o Daviplata vía MercadoPago o PayU. La cita se confirma solo tras la aprobación del pago. | SDK de MercadoPago Flutter tokeniza la tarjeta en el dispositivo. Los datos de tarjeta nunca pasan por el código propio. | CF createPaymentIntent(citaId, monto) genera la preference en MercadoPago usando la API Key del servidor (Secret Manager). DB: crea transacciones/{pagoId} con estado:"pendiente". |
| RF-28 | Pago anticipado parcial (depósito) | El admin puede habilitar el cobro de un depósito configurable (10-30%) para confirmar la reserva y reducir el no-show. | Slider de configuración en SA-SETTINGS. En el checkout, el depósito se muestra diferenciado del total. | createPaymentIntent() lee depositoPorcentaje del negocio y calcula el monto parcial. DB: transacciones con montoTotal, montoDepositado, saldoPendiente. |
| RF-29 | Webhook de confirmación de pago | Cloud Functions procesa los webhooks de MercadoPago/PayU al aprobar un pago. Actualiza la cita a "Pagada" de forma atómica. | Polling cada 2 segundos al documento de la transacción (30 segundos máximo). Cuando estado cambia a "completada", navega a SC-SUCCESS. | CF paymentWebhook() → valida firma HMAC-SHA256 → batch write: transacciones/{pagoId}.estado="completada" + citas/{citaId}.estado="pagada" → FCM push → SendGrid comprobante → acumula puntos. |
| RF-30 | Venta de productos adicionales | El cliente agrega productos del negocio al carrito durante la reserva y los paga junto al servicio en un solo checkout. | Sección de productos en SC-BIZ-DETAIL con botón "+ agregar". El total incluye servicios + productos. | DB: negocios/{negocioId}/productos/{productoId}. La cita almacena productos:[] con productoId y cantidad. |
| RF-31 | Pago en local (registro manual) | El admin o empleado registra un pago en efectivo o datáfono para citas no prepagadas. | Modal "Registrar pago" en el detalle de cita con selector de método y campo de monto. | Escritura directa a Firestore. DB: transacciones/{pagoId} con metodoPago:"efectivo" o "tarjeta_fisica". |
| RF-32 | Comprobante digital | El sistema genera y envía automáticamente comprobante de pago por correo y push con detalle de servicios, productos, total y método. | SC-RECEIPT con botón "Descargar PDF" usando la librería pdf de Flutter y share_plus. | CF sendReceipt(pagoId) genera HTML y envía via SendGrid. Se dispara automáticamente desde paymentWebhook(). |
| RF-33 | Historial de transacciones | El admin ve el historial completo de pagos con estado, método, monto y fecha. | SA-TRANSACTIONS con lista paginada y chips de filtro por estado y método. | Consulta: transacciones/ donde negocioId==X, ordenado por fecha DESC. Paginación startAfterDocument de 20 en 20. Índice [negocioId, fecha DESC]. |
| RF-34 | Reembolso por cancelación | Si el cliente cancela dentro del tiempo permitido y había pagado en línea, el sistema inicia el reembolso automático. | El botón de cancelación muestra el monto a reembolsar. Tras confirmar, muestra estado "Reembolso en proceso". | CF refundPayment(pagoId) → MercadoPago API POST /v1/payments/{id}/refunds. DB: transacciones/{pagoId}.estado="reembolsado". |

### Bloque 7 · Notificaciones

| ID | Nombre | Descripción | FE | BE / DB / CF |
|---|---|---|---|---|
| RF-35 | Notificaciones push (FCM) | El sistema envía notificaciones automáticas: confirmación de reserva, recordatorio 1 hora antes, cancelación, nueva postulación recibida, invitación laboral, nuevo comentario en publicación. | Permiso de notificaciones al iniciar sesión. Token FCM en usuarios/{uid}.fcmTokens[]. flutter_local_notifications para primer plano. | CF: onBookingCreated, scheduledReminders (cron cada 15min), onBookingCancelled, onNewApplication, onNewInvitation, onNewComment. Admin SDK: admin.messaging().send(). |
| RF-36 | Correos transaccionales | El sistema envía correos via SendGrid: bienvenida, comprobante de pago, resultado de postulación, invitación a negocio, recordatorio de cita. | No interviene directamente. El usuario ve confirmaciones en la UI. | Helper sendEmail(to, templateId, data) llamado desde cada CF relevante. Templates configurados en el dashboard de SendGrid. |

### Bloque 8 · Operación del empleado

| ID | Nombre | Descripción | FE | BE / DB / CF |
|---|---|---|---|---|
| RF-37 | Acceso y vista de empleado | El empleado accede con su cuenta normal. La app detecta el Custom Claim empleadoEn y le muestra el contexto de empleado en el selector de perfil. | Al hacer login, si empleadoEn != null, el selector de contexto incluye "Empleado en [Negocio]". GoRouter navega a SE-HOME al elegirlo. | Custom Claim empleadoEn contiene el negocioId. Si activo:false, Security Rules bloquean todo acceso al panel de empleado. |
| RF-38 | Hoja de ruta diaria | El empleado ve su agenda cronológica del día con estados: Completada, En Curso y Pendiente. Ve nombre del cliente, servicio, duración y productos solicitados. | SE-HOME con StreamBuilder sobre citas del día. Timeline vertical con cita en curso destacada y botones de acción. | Consulta: citas/ donde empleadoId==uid y fecha==hoy y estado!="cancelada", ordenado por hora ASC. Índice [empleadoId, fecha, estado]. |
| RF-39 | Completar servicio | El empleado marca una cita como "Completada". Dispara el cálculo de su comisión y actualiza el dashboard del admin en tiempo real. | Botón "Marcar completado" en la cita en curso con diálogo de confirmación. | CF completeService(citaId) → actualiza cita → CF calculateCommission() → escribe en ganancias/{empleadoId}_{fecha}. |
| RF-40 | Reportar retraso | El empleado reporta un retraso. El sistema notifica automáticamente al cliente con el tiempo estimado. | Botón "Reportar retraso" con selector de minutos (5/10/15/20/30 o personalizado). | CF reportDelay(citaId, minutos) → actualiza cita → FCM push al cliente. |
| RF-41 | Mis ganancias | El empleado consulta ganancia del día, semana y mes con desglose por servicio, comisión de plataforma y total neto. | SE-EARNINGS con chips de período y gráfica de barras (fl_chart). | Consulta: ganancias/ donde empleadoId==uid y fecha en el rango. Índice [empleadoId, fecha]. |
| RF-42 | Gestión de horario propio | El empleado activa/desactiva días laborales y agrega bloqueos de horario para evitar reservas en esos períodos. | SE-SCHEDULE con chips de días (toggles) y lista de bloqueos con date-time picker. | Escritura directa a Firestore. CF getAvailableSlots() consulta los bloqueos activos al calcular slots. |

### Bloque 9 · Panel del administrador

| ID | Nombre | Descripción | FE | BE / DB / CF |
|---|---|---|---|---|
| RF-43 | Dashboard principal | El admin ve KPIs en tiempo real: ingresos del día, citas totales, ocupación y cancelaciones. Cada métrica muestra variación respecto al día anterior. | SA-HOME con StreamBuilder. KPIs calculados en CF para no sobrecargar el cliente. | CF getDashboardKPIs(negocioId, fecha): sum de transacciones, count de citas, cálculo de ocupación. Se refresca cada 5 minutos vía Timer. Índice [negocioId, fecha, estado]. |
| RF-44 | Gestión de citas del día | El admin ve todas las citas del día, puede filtrar por empleado, crear citas manuales y cancelar cualquier cita. | SA-CITAS con calendario strip y lista filtrable con StreamBuilder. FAB para crear cita manual. | Consulta: citas/ donde negocioId==X y fecha==seleccionada. Índice [negocioId, fecha, hora ASC]. |
| RF-45 | Gestión del equipo | El admin ve la lista completa de empleados (activos e inactivos) con citas del día y accede al detalle de cada uno. | SA-TEAM con StreamBuilder. Badge de estado con texto e ícono además de color. Empleados inactivos con Opacity 0.5. | Consulta: negocios/{negocioId}/empleados/ ordenado por activo DESC, nombre ASC. |
| RF-46 | Bandeja de postulaciones recibidas | El admin ve todas las postulaciones de candidatos a empleado con perfil, CV y puede aceptar o rechazar. | SA-APPLICATIONS con lista filtrable por estado (Pendiente/Aceptada/Rechazada). Botón de descarga del CV. | Consulta: postulaciones/ donde negocioId==X, ordenado por fechaPostulacion DESC. Índice [negocioId, estado, fechaPostulacion DESC]. |
| RF-47 | Gestión de clientes del negocio | El admin ve la lista de clientes que han visitado el negocio, identifica inactivos y puede enviarles cupones de retención. | SA-CLIENTS con alerta de clientes inactivos y botón "Enviar cupón". | CF getBusinessClients(negocioId) agrega clientes únicos de las citas. Caché diaria en negocios/{negocioId}/clientesCache/ actualizada por Cloud Scheduler. |

### Bloque 10 · Reportes y finanzas

| ID | Nombre | Descripción | FE | BE / DB / CF |
|---|---|---|---|---|
| RF-48 | Reporte financiero por período | Reportes filtrables por Hoy/Semana/Mes/Año/Personalizado con total de ingresos, ticket promedio, gráfica de barras, desglose por empleado y métodos de pago. | SA-REPORTS con chips de período y gráfica fl_chart. FutureBuilder al cambiar el período. | CF getFinancialReport(negocioId, fechaInicio, fechaFin) con aggregation queries (sum, count). |
| RF-49 | Análisis de horas pico | Gráfica con distribución de citas por hora del día y día de la semana. Identifica automáticamente los momentos de mayor demanda. | Gráfica de barras horizontal en SA-REPORTS con insight textual auto-generado. | CF getPeakHours(negocioId, fechaInicio, fechaFin) agrupa citas por hora. Consulta sobre citas/ donde estado!="cancelada". |
| RF-50 | Cálculo automático de comisiones | El sistema calcula la comisión de cada empleado al completar un servicio, según el porcentaje configurado por el admin. | Comisión visible en SE-EARNINGS del empleado y en el reporte de SA-REPORTS. | CF calculateCommission(citaId) → gananciaEmpleado = total × comision%, comisionPlataforma = total × 10%. DB: ganancias/{empleadoId}_{fecha}. |
| RF-51 | Cierre de caja diario | El admin registra el efectivo contado al cierre del día. El sistema calcula la diferencia respecto a las transacciones registradas y archiva el cierre. | Modal de cierre de caja desde SA-HOME con campo de efectivo contado. El total digital se muestra automáticamente. | CF closeCashRegister(negocioId, fecha, efectivoContado) → suma transacciones digitales → archiva en cierresCaja/{negocioId}_{fecha}. |
| RF-52 | Exportar reporte PDF | El admin exporta cualquier reporte en PDF para compartir con su contador. | Botón "Exportar PDF" en SA-REPORTS. Genera PDF en el dispositivo con la librería pdf de Flutter y comparte con share_plus. | Generación completamente en el dispositivo. No requiere Cloud Function. |

### Bloque 11 · Fidelización

| ID | Nombre | Descripción | FE | BE / DB / CF |
|---|---|---|---|---|
| RF-53 | Acumulación de puntos | El cliente acumula puntos automáticamente al completar una cita pagada. La equivalencia es configurable por el admin. | SC-SUCCESS muestra puntos ganados con animación. SC-LOYALTY con barra de progreso via StreamBuilder. | paymentWebhook() llama a CF addLoyaltyPoints(clienteId, negocioId, monto). DB: fidelizacion/{clienteId}_{negocioId}.puntos con FieldValue.increment(). |
| RF-54 | Sistema de sellos | El admin configura tarjetas de sellos (ej. 6.º corte con descuento). El cliente visualiza su progreso. | SC-LOYALTY con circles de sellos (rellenos/vacíos). Animación al completar la tarjeta. | addLoyaltyPoints() verifica si el nuevo sello completa la tarjeta. Si completa, crea cupón automático. DB: fidelizacion/{clienteId}_{negocioId}.sellosActuales. |
| RF-55 | Canje de recompensas | El cliente canjea puntos por descuentos, servicios gratuitos o productos. El canje se aplica en el próximo pago. | SC-LOYALTY con catálogo de recompensas. Botón "Canjear" activo solo si tiene suficientes puntos. Código de descuento visible en el checkout. | CF redeemReward() valida puntos → FieldValue.increment(-puntos) → crea documento en cupones/. |
| RF-56 | Cupones de retención | El admin envía cupones de descuento a clientes inactivos desde SA-CLIENTS. | Botón "Enviar cupón a inactivos" con campo de porcentaje de descuento configurable. | CF sendRetentionCoupons(negocioId, descuento) → crea cupones/ para cada cliente → FCM push + correo. Expiración de 30 días. |

---

## Requerimientos No Funcionales (RNF)

### Arquitectura

| ID | Nombre | Descripción | Implementación técnica |
|---|---|---|---|
| RNF-01 | Clean Architecture | Capas Domain, Data y Presentation independientes. Domain no conoce Firebase ni Flutter. | `features/{modulo}/domain/` solo Dart puro. `data/` implementa interfaces de Domain. `presentation/` usa Use Cases. Tests unitarios de Domain con MockRepository sin emuladores. |
| RNF-02 | Feature-First Structure | Carpetas organizadas por funcionalidad. Cada módulo es autónomo. | `lib/features/{modulo}/` con domain/, data/, presentation/. `lib/core/` para componentes compartidos. Las features no se importan entre sí; se comunican via Riverpod. |

### Seguridad

| ID | Nombre | Descripción | Implementación técnica |
|---|---|---|---|
| RNF-03 | Aislamiento Multitenant | Security Rules de Firestore garantizan que ningún tenant pueda leer o escribir datos de otro negocio. | Regla base: `allow read, write: if request.auth != null && (resource.data.negocioId == request.auth.token.empleadoEn \|\| request.auth.token.negociosAdmin.hasAny([resource.data.negocioId]));` negocioId se agrega en la CF que crea el documento. Tests con Firebase Emulator. |
| RNF-04 | Custom Claims para detección de rol | Firebase Auth Custom Claims almacenan `{ rol, negociosAdmin[], empleadoEn, activo }` en el token JWT. El sistema detecta el contexto sin consultar Firestore. | `setCustomUserClaims(uid, { rol, negociosAdmin:[], empleadoEn })`. Al crear negocio: push a negociosAdmin[]. Al aceptar empleado: empleadoEn=negocioId. Al desvincular: empleadoEn=null + revokeRefreshTokens(uid). Flutter: getIdToken(forceRefresh:true) antes de operaciones críticas. |
| RNF-05 | Seguridad en pagos (PCI-DSS) | Las transacciones nunca se procesan en el cliente. Cloud Functions recibe y valida webhooks. La API Key de la pasarela vive solo en el servidor. | API Key de MercadoPago en Firebase Secret Manager con defineSecret(). SDK tokeniza la tarjeta en el dispositivo. Webhook: validación HMAC-SHA256. Números de tarjeta nunca en Firestore ni en logs. |
| RNF-06 | HTTPS y API Keys seguras | Toda comunicación usa HTTPS/TLS. Las API Keys viven solo en Cloud Functions, nunca en el código Flutter. | Firebase usa HTTPS por defecto. API Keys en Secret Manager o environment variables de Cloud Functions v2. flutter_security_checker detecta API Keys hardcoded. |

### Rendimiento

| ID | Nombre | Descripción | Implementación técnica |
|---|---|---|---|
| RNF-07 | Tiempo de respuesta ≤ 1.5s | Las consultas de disponibilidad de citas se resuelven en menos de 1.5 segundos en 4G/WiFi. | Firebase Performance Monitoring con trazas personalizadas. Índices compuestos en Firestore. Consultas paralelas con Future.wait(). Caché local de Firestore para datos que cambian poco. |
| RNF-08 | Atomicidad de reservas | Transacciones de Firestore previenen reservas duplicadas aunque dos usuarios confirmen simultáneamente. | runTransaction() en Admin SDK dentro de createBooking(). Rollback automático si el slot ya fue ocupado. Máximo 3 reintentos → SLOT_NOT_AVAILABLE. Documentos de slot con TTL de 24h limpiados por Cloud Scheduler. |
| RNF-09 | Disponibilidad 99.5% mensual | Máximo 3.6 horas de caída al mes. Apoyado en Firebase y Google Cloud. | Firestore y Auth con SLA 99.95%. Cloud Functions 99.9%. Firebase App Check previene abuso. Alertas si tasa de error supera 1% en 5 minutos. Plan de contingencia si la pasarela falla: cita como "pendiente de pago". |
| RNF-10 | Confirmación de pago ≤ 5s | El webhook de pago se procesa y refleja en la app en menos de 5 segundos. | paymentWebhook() con timeout 10s y 256MB. Tiempo esperado: HMAC (50ms) + batch write (200ms) + FCM (300ms) + snapshot listener (500ms) ≈ 1.05s total. |

### UX y Accesibilidad

| ID | Nombre | Descripción | Implementación técnica |
|---|---|---|---|
| RNF-11 | Persistencia offline | La app permite consultar la agenda del día y el historial sin conexión. Se sincroniza al recuperar conexión. | `FirebaseFirestore.instance.settings = Settings(persistenceEnabled:true, cacheSizeBytes:10485760)`. Escrituras offline encoladas y sincronizadas al volver la conexión. Banner "Sin conexión – modo solo lectura" con connectivity_plus. |
| RNF-12 | Interfaz responsiva | El diseño se adapta a móviles (390x844px) y tablets (layout de dos columnas para admin). | LayoutBuilder con breakpoint tablet >768px. Móvil: columna única + BottomNavigation. Tablet: dos columnas + NavigationRail lateral. Golden tests en 375px, 390px, 768px y 1024px. |
| RNF-13 | WCAG 2.2 nivel AA | Todos los textos deben tener ratio de contraste mínimo 4.5:1. Textos críticos 7:1 (AAA). Los estados nunca se diferencian solo por color. | Plugin Stark de Figma verifica el ratio antes de trasladar a código. Design tokens con ratio medido como comentario. Estado activo/error/desactivado usa siempre texto o ícono además del color. Semantics widgets para TalkBack/VoiceOver. |
| RNF-14 | Design Tokens | Todos los colores, tipografías y espaciados se definen como tokens. Ningún valor hardcoded en el código Flutter. | `lib/core/theme/app_tokens.dart` con AppColors, AppTypography, AppSpacing. Lint rule en analysis_options.yaml que falla el build si detecta `Color(0xFF)` fuera de app_tokens.dart. |
| RNF-15 | Áreas de toque mínimas 44x44px | Todos los elementos interactivos tienen área mínima de toque de 44x44px. | Padding interno o GestureDetector con HitTestBehavior.opaque. Material Design aplica minimum touch target automáticamente en botones elevados. |

### Mantenibilidad

| ID | Nombre | Descripción | Implementación técnica |
|---|---|---|---|
| RNF-16 | Cobertura de tests 80% | La capa Domain tiene cobertura mínima del 80% con tests unitarios. La capa Data incluye tests de integración con Firebase Emulator. | `flutter test --coverage` + lcov filtra solo Domain. Tests unitarios con mockito. Tests de integración con Firebase Emulator Suite. CI/CD falla el merge a develop si la cobertura cae por debajo del 80%. |
| RNF-17 | Git Flow y Conventional Commits | El repositorio sigue main → develop → feature/*, fix/*, hotfix/*. Los commits siguen Conventional Commits. | Ramas protegidas: main (solo merge via PR con 1 review + tests verdes). Commits: `feat(social): agregar comentarios en publicaciones`. husky + commitlint valida en pre-commit. release-please genera CHANGELOG.md y semver. |
| RNF-18 | Escalabilidad multitenant y social | La estructura soporta nuevos tenants y crecimiento del feed social sin cambios en reglas ni colecciones. | negocioId es el primer filtro en todas las consultas. Agregar un tenant nuevo es solo crear un documento en negocios/. Índices adicionales para el feed: [activa, likes DESC], [activa, negocioId, fechaCreacion DESC]. |

---

## Cómo usar este contexto

Cuando trabajes en cualquier feature, ten en cuenta:

1. **Rol:** ¿Quién ejecuta esta acción? ¿Qué Custom Claim necesita?
2. **Capa:** ¿Va en Domain (lógica), Data (Firebase) o Presentation (UI)?
3. **Módulo:** ¿A qué carpeta de `features/` pertenece?
4. **Seguridad:** ¿Las Security Rules cubren este caso?
5. **Multitenant:** ¿Toda escritura incluye `negocioId`?