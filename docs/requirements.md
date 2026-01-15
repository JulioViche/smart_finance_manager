## Requerimientos Generales Para TODAS las Aplicaciones

Cada proyecto, sin excepción, debe incluir:

### 1. Arquitectura, Diseño y Calidad
- **Clean Architecture** completa (data, domain, presentation).
- **Atomic Design** aplicado a toda la interfaz.
- Manejo profesional de estado: Riverpod, Bloc o Provider estructurado.
- Temas claro/oscuro opcionales.
- Animaciones básicas en navegación y carga.

### 2. Funcionamiento Offline / Online (OBLIGATORIO)
Cada aplicación debe:
- Funcionar completamente si no hay internet.
- Usar almacenamiento local: Room o SQLite.
- Implementar un sistema de sincronización con la nube al volver la conexión.
- Guardar datos críticos localmente (caché + persistencia).

### 3. Autenticación (OBLIGATORIA, 3 métodos)
Cada app debe incluir:
1. Autenticación mediante API externa (OPCIONAL)
	 - Usuario válido: `admin@admin.com / 123123123`
	 - URL válida: [https://isteremplea.ldcruminahui.com/api/valida/admin@admin.com/123123123](https://isteremplea.ldcruminahui.com/api/valida/admin@admin.com/123123123)
	 - Usuario inválido: [https://isteremplea.ldcruminahui.com/api/valida/demo@ister.edu.ec/12312312](https://isteremplea.ldcruminahui.com/api/valida/demo@ister.edu.ec/12312312)
2. Autenticación con Google
3. Autenticación con Facebook
4. Autenticación con **Firebase** o **MongoDB**

### 4. Sincronización con la Nube
Cada app debe guardar sus datos en:
- Firebase ó Supabase (según elección del equipo).
Debe permitir:
- Subir datos locales cuando regrese el internet.
- Resolver conflictos básicos (último guardado prevalece).

### 5. Notificaciones (OBLIGATORIAS)
- Locales: recordatorios, tareas, alertas.
- Push: enviadas desde Firebase Cloud Messaging.

### 6. Módulos Visuales Obligatorios
Cada aplicación debe incluir:
- Listas dinámicas
- Grids
- Menús (inferior, lateral o ambos)
- Pantallas detalladas (detail view)
- Búsquedas
- Filtros

### 7. Sensores y funcionalidades del dispositivo
Cada proyecto debe usar al menos dos sensores:
- GPS
- Acelerómetro
- Giroscopio
- Cámara
- Brújula
- Sensor de luz

### 8. Manuales Requeridos
Cada equipo debe entregar los siguientes documentos:
1. Manual de Usuario (PDF)
2. Manual de Usuario dentro de la App (pantalla dedicada)
3. Manual de Desarrollo (arquitectura, decisiones técnicas, diseños para Google Play)
4. Manual de Programación (código explicado, diagramas, casos de uso)
5. Código fuente de la app y de los diseños gráficos.
Debe incluir:
- Diagramas de arquitectura
- Diagrama entidad-relación
- Historial de sincronización
- Estructura de paquetes
- Capturas de pantalla

### 9. Publicación Obligatoria
La aplicación debe ser publicada en:
- Google Play Store (Producción o Beta cerrada)
- Con política de privacidad
- Con capturas, descripción, íconos e imágenes necesarias

---

## Proyecto 8: App Financiera Personal con IA Opcional

### Resumen
App completa para control de gastos personales, sincronización y análisis.

### Características mínimas
- Registro de ingresos y egresos
- Dashboard con gráficas
- Exportar a PDF
- Modo offline total
- Sincronización automática
- Notificaciones:
	- gastos elevados
	- pagos próximos
- IA opcional:
	- análisis mensual inteligente
	- recomendaciones de ahorro