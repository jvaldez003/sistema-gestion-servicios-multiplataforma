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

## Cómo usar este contexto

Cuando trabajes en cualquier feature, ten en cuenta:

1. **Rol:** ¿Quién ejecuta esta acción? ¿Qué Custom Claim necesita?
2. **Capa:** ¿Va en Domain (lógica), Data (Firebase) o Presentation (UI)?
3. **Módulo:** ¿A qué carpeta de `features/` pertenece?
4. **Seguridad:** ¿Las Security Rules cubren este caso?
5. **Multitenant:** ¿Toda escritura incluye `negocioId`?
