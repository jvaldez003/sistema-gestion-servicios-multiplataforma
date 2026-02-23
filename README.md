# Sistema de Gestión de Servicios Multiplataforma

> Plataforma SaaS multitenant para la gestión de citas, recursos y finanzas de cualquier negocio de servicios.

---

## Tabla de Contenidos

- [Descripción General](#-descripción-general)
- [Arquitectura del Proyecto](#-arquitectura-del-proyecto)
- [Stack Tecnológico](#-stack-tecnológico)
- [Estructura de Carpetas](#-estructura-de-carpetas)
- [Flujo de Ramas (Git Flow)](#-flujo-de-ramas-git-flow)
- [Convención de Commits](#-convención-de-commits)
- [Cómo Contribuir](#-cómo-contribuir)
- [Configuración Inicial](#-configuración-inicial)

---

## Descripción General

Este sistema es una plataforma universal de gestión de servicios y citas diseñada bajo el modelo **SaaS multitenant**. Aunque su semilla nació en el sector de barberías y centros de estética, su arquitectura está pensada para adaptarse a **cualquier negocio basado en servicios**: lavaderos de autos, consultorios médicos, canchas deportivas, spas, y más.

### Perfiles de usuario

| Perfil | Plataforma principal | Rol |
|---|---|---|
| **Cliente** | App Móvil | Consulta servicios, agenda citas, recibe notificaciones |
| **Empleado / Profesional** | App Móvil | Ve su hoja de ruta diaria, marca servicios como completados |
| **Dueño / Administrador** | Web + Tablet | Configura el negocio, gestiona finanzas, genera reportes |

### Módulos principales

- **Motor de Configuración Dinámica**: cada negocio configura sus propios recursos, servicios y campos personalizados.
- **Sistema de Citas con Detección de Conflictos**: evita en tiempo real que dos usuarios agenden el mismo recurso.
- **Gestión de Recursos Físicos**: sillas, bahías, cabinas — cada negocio define sus propias unidades.
- **Dashboard Financiero**: cierre de caja diario, comisiones, métodos de pago y análisis de horas pico.
- **Sistema de Fidelización**: historial de clientes y recordatorios inteligentes automáticos.
- **Análisis de Negocio (BI)**: predicción de demanda, tasa de abandono de clientes y KPIs del negocio.

---

## Arquitectura del Proyecto

Se utilizará una arquitectura **Clean Architecture** combinada con el patrón **Feature-First**, lo que permite escalar el proyecto de forma ordenada y mantener cada módulo independiente.

```
Presentation Layer  →  Widgets, Screens, State Management (BLoC / Riverpod)
        ↓
Domain Layer        →  Use Cases, Entities, Repository Interfaces
        ↓
Data Layer          →  Repositories, Data Sources (Firebase / Local)
        ↓
Infrastructure      →  Firebase Firestore, Cloud Functions, FCM, Firebase Auth
```

### ¿Por qué Clean Architecture?

- Facilita las pruebas unitarias por capas.
- Permite cambiar la fuente de datos (Firebase → otro backend) sin tocar la UI.
- Separa claramente responsabilidades entre el equipo.
- Es el estándar que más valoran los evaluadores académicos y técnicos.

### Arquitectura de Datos (Firebase Firestore — NoSQL)

Las colecciones están diseñadas con entidades genéricas para soportar cualquier tipo de negocio:

```
negocios/          → Configuración del tenant (nombre, logo, tipo de industria)
  └── recursos/    → Unidades físicas (silla, bahía, cancha, consultorio)
  └── servicios/   → Catálogo de servicios con duración y precio
  └── colaboradores/ → Perfiles de empleados con horarios y comisiones

usuarios/          → Perfiles de clientes con historial

citas/             → Registro de citas: conecta cliente + colaborador + servicio + horario

transacciones/     → Historial de pagos, métodos, estado y comisiones
```

---

## Stack Tecnológico

| Capa | Tecnología | Justificación |
|---|---|---|
| **Frontend / Mobile** | Flutter (Dart) | Una sola base de código para Android, iOS y Web |
| **Autenticación** | Firebase Auth + OAuth 2.0 | Login con Google/Apple, manejo seguro de sesiones |
| **Base de datos** | Cloud Firestore (NoSQL) | Tiempo real, modo offline, escalable automáticamente |
| **Backend Serverless** | Firebase Cloud Functions | Lógica pesada sin saturar el dispositivo (cierre de caja, triggers) |
| **Notificaciones** | Firebase Cloud Messaging (FCM) | Push notifications automáticas basadas en eventos |
| **Hosting Web** | Firebase Hosting | Despliegue del panel de administración web |
| **Almacenamiento** | Firebase Storage | Fotos de trabajos, logos de negocios |

### Multiplataforma con Flutter

- **Móvil** (Android / iOS): gestos nativos, notificaciones push, acceso a cámara.
- **Web** (Panel Admin): diseño responsivo con menú lateral, tablas de ganancias y reportes.
- Se usa `LayoutBuilder` y `MediaQuery` para adaptar la UI según el ancho de pantalla:
  - `> 600px` → Vista escritorio con sidebar.
  - `< 600px` → Navegación inferior móvil.

---

## 📁 Estructura de Carpetas

> La estructura es una base flexible que evoluciona a medida que avanza el desarrollo.

```
sistema-gestion-servicios-multiplataforma/
│
├── lib/
│   ├── core/                     # Utilidades globales, constantes, temas
│   │   ├── constants/
│   │   ├── theme/
│   │   └── utils/
│   │
│   ├── features/                 # Módulos por funcionalidad (Feature-First)
│   │   ├── auth/                 # Autenticación
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── booking/              # Gestión de citas
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── dashboard/            # Panel financiero
│   │   ├── services/             # Catálogo de servicios
│   │   ├── resources/            # Gestión de recursos físicos
│   │   ├── clients/              # Perfil y fidelización de clientes
│   │   └── settings/             # Configuración dinámica del negocio
│   │
│   └── main.dart
│
├── test/                         # Pruebas unitarias y de integración
├── docs/                         # Diagramas, wireframes y documentación técnica
├── functions/                    # Firebase Cloud Functions (Node.js)
├── .gitignore
├── pubspec.yaml
└── README.md
```

---

## Flujo de Ramas (Git Flow)

El proyecto usa **dos ramas principales** con una estrategia simple y ordenada:

```
main        → Código estable, listo para producción / entrega final
develop     → Integración continua del trabajo del equipo
```

### Reglas de las ramas

| Rama | Propósito | ¿Quién sube aquí? |
|---|---|---|
| `main` | Versión estable y entregable | Solo merges desde `develop` cuando hay un hito listo |
| `develop` | Desarrollo activo e integración | Todo el equipo, desde ramas de features |

### Flujo de trabajo para una nueva funcionalidad

```bash
# 1. Asegurarte de estar actualizado
git checkout develop
git pull origin develop

# 2. Crear tu rama de feature desde develop
git checkout -b feature/nombre-de-la-funcionalidad

# 3. Trabajar, hacer commits...
git add .
git commit -m "feat(booking): agregar validación de conflicto de horarios"

# 4. Subir tu rama al repositorio remoto
git push origin feature/nombre-de-la-funcionalidad

# 5. Crear un Pull Request (PR) hacia develop en GitHub
# → El equipo revisa y aprueba antes de hacer el merge
```

### Tipos de ramas adicionales

```
feature/nombre    → Nueva funcionalidad
fix/nombre        → Corrección de un bug
hotfix/nombre     → Corrección urgente en producción
docs/nombre       → Cambios solo en documentación
refactor/nombre   → Mejora de código sin cambiar funcionalidad
```

---

## Convención de Commits

Se sigue el estándar **Conventional Commits** para que el historial sea claro y legible.

### Formato

```
<tipo>(<módulo>): <descripción corta en presente>
```

### Tipos de commit

| Tipo | Cuándo usarlo |
|---|---|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de un error |
| `docs` | Cambios en documentación |
| `style` | Cambios de formato / estilo visual (sin lógica) |
| `refactor` | Mejora de código existente sin cambiar comportamiento |
| `test` | Agregar o corregir pruebas |
| `chore` | Tareas de mantenimiento (dependencias, configuración) |

### Ejemplos de commits

```bash
feat(auth): implementar login con Google usando Firebase Auth
feat(booking): agregar detección de conflictos de horario en tiempo real
fix(dashboard): corregir cálculo de comisiones en cierre de caja
docs(readme): actualizar estructura de carpetas
style(booking): ajustar espaciado del calendario en vista móvil
refactor(services): separar lógica de catálogo en use cases
test(auth): agregar pruebas unitarias al repositorio de autenticación
chore(deps): actualizar Flutter a versión 3.x.x
```

---

## Cómo Contribuir

1. Clona el repositorio:
   ```bash
   git clone https://github.com/tu-usuario/sistema-gestion-servicios-multiplataforma.git
   ```

2. Entra a la carpeta del proyecto:
   ```bash
   cd sistema-gestion-servicios-multiplataforma
   ```

3. Instala las dependencias:
   ```bash
   flutter pub get
   ```

4. Crea tu rama desde `develop` (nunca desde `main`):
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/tu-funcionalidad
   ```

5. Trabaja, haz commits siguiendo la convención y sube tu rama:
   ```bash
   git push origin feature/tu-funcionalidad
   ```

6. Abre un **Pull Request** en GitHub hacia `develop` y espera revisión del equipo.

---

## Configuración Inicial

> Requisitos previos: Flutter SDK, cuenta de Firebase, Git.

```bash
# Verificar instalación de Flutter
flutter doctor

# Configurar Firebase en el proyecto
flutterfire configure

# Correr la app en modo desarrollo
flutter run
```

---

## Licencia

Este proyecto es de uso académico. Todos los derechos reservados al equipo de desarrollo.

---

> **Repositorio creado con propósito académico — Clase de Computación Móvil**  
> El nombre de la aplicación y el branding final serán definidos por el equipo durante el desarrollo.
