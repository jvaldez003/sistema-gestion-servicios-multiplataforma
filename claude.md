# CLAUDE.md — Instrucciones para el Agente Claude Code

## Contexto del proyecto

Este es **FlowServ**, una app móvil Flutter + Firebase para gestión de citas y servicios.
Lee el archivo `CONTEXT.md` en la raíz del proyecto para entender la arquitectura, el sistema de roles, la estructura de datos y todos los requerimientos funcionales y no funcionales.

---

## Reglas absolutas — NUNCA violes estas reglas

### 🔴 DISEÑO VISUAL — NO TOCAR
- **No modifiques ningún archivo de UI** a menos que se te pida explícitamente
- No cambies colores, tipografías, espaciados ni layouts
- No reorganices widgets ni pantallas
- No reemplaces componentes visuales existentes
- No cambies nombres de rutas que ya funcionan visualmente
- Si necesitas agregar UI nueva, imita exactamente el estilo de lo que ya existe

### 🔴 ANTES DE HACER CUALQUIER COSA
- Lee `CONTEXT.md` completo
- Revisa el código existente del módulo que vas a tocar
- **No hagas nada sin que se te pida explícitamente**
- Si tienes dudas entre dos enfoques, pregunta antes de implementar

### 🔴 NO HAGAS CAMBIOS EN CADENA
- Toca solo el archivo(s) mencionado(s) en la instrucción
- No "aproveches" para refactorizar código cercano
- No renombres variables ni métodos que ya funcionan
- No muevas archivos de lugar

---

## Cómo trabajar en este proyecto

### Flujo de trabajo estándar

```
1. Lee CONTEXT.md
2. Lee el código existente del módulo relevante
3. Identifica exactamente qué falta o qué está roto
4. Reporta ANTES de tocar nada (a menos que se indique lo contrario)
5. Implementa solo lo que se pidió
6. Verifica que el diseño visual no cambió
```

### Cuando te pidan un reporte

Sigue este formato exacto:

```
## Estado actual
[Qué funciona hoy]

## Qué falta para que sea funcional
[Lista priorizada — solo lo crítico]

## Qué se puede omitir para el MVP
[Lo que no bloquea el funcionamiento básico]

## Archivos que habría que tocar
[Ruta exacta de cada archivo, con una línea explicando qué cambiaría]

## Estimación
[Honesta — qué se puede terminar hoy]
```

### Cuando te pidan implementar algo

- Implementa una cosa a la vez
- Confirma después de cada cambio
- Si algo falla, revierte y reporta antes de intentar otra solución
- Nunca dejes el proyecto en un estado que no compile

---

## Stack y convenciones

- **Flutter** con Riverpod para estado y GoRouter para navegación
- **Clean Architecture**: Domain → Data → Presentation. Domain no importa Firebase ni Flutter
- **Feature-First**: `lib/features/{modulo}/domain/`, `data/`, `presentation/`
- **Firebase**: Auth con Custom Claims, Firestore, Cloud Functions, FCM, Storage
- **Pagos**: MercadoPago (principal), PayU (alternativa)
- **Tokens**: Usar siempre `AppColors.X`, `AppSpacing.X`. Nunca valores hardcoded

## Roles del sistema

Un solo login. El sistema detecta el rol por Custom Claims del token JWT:
- `negociosAdmin: []` → puede ser admin de esos negocios
- `empleadoEn: "negocioId"` → es empleado de ese negocio
- Sin ninguno → es cliente

Un usuario puede tener todos los roles al mismo tiempo y cambiar de contexto desde el perfil.

---

## Prioridad para MVP funcional

Si hay que omitir algo para presentar hoy, omitir en este orden (de menos a más crítico):

1. Fidelización (puntos, sellos, canjes)
2. Reportes avanzados (horas pico, exportar PDF)
3. Cierre de caja
4. Modo multisede
5. Galería de trabajos (puede mostrar solo las publicaciones)
6. Feed social (comentarios y reacciones)
7. Postulación de empleados (puede ser invitación directa solamente)
8. Pago anticipado parcial (depósito)

**Nunca omitir:**
- Login y detección de rol
- Flujo completo de reserva (buscar → seleccionar → confirmar)
- Panel del empleado (agenda del día + completar servicio)
- Dashboard básico del admin (KPIs + citas del día)
- Catálogo de servicios
- Notificaciones push básicas

---

## Archivos clave del proyecto

```
CONTEXT.md              ← Contexto completo del proyecto
CLAUDE.md               ← Este archivo
lib/
  core/
    theme/              ← Design tokens (NO modificar sin permiso)
    router/             ← GoRouter y guards de rol
  features/
    auth/               ← Login, registro, detección de rol
    booking/            ← Reservas, motor de conflictos
    social/             ← Feed, publicaciones, reacciones
    payments/           ← MercadoPago, webhooks
    employees/          ← Postulaciones, invitaciones
    dashboard/          ← Panel admin
    catalog/            ← Catálogo de servicios
    loyalty/            ← Fidelización
functions/              ← Cloud Functions (TypeScript)
firestore.rules         ← Security Rules
```