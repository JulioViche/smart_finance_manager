# Smart Finance Manager - Data Model Documentation

## Overview
Este documento describe el modelo de datos de la aplicación Smart Finance Manager, que utiliza Firebase Firestore como base de datos NoSQL.

## Collections

### 1. Users Collection (`users`)

Almacena la información de los usuarios de la aplicación.

#### Fields:
| Campo                               | Tipo      | Descripción                                    |
| ----------------------------------- | --------- | ---------------------------------------------- |
| `auth_provider`                     | String    | Proveedor de autenticación (ej: "google")      |
| `created_at`                        | Timestamp | Fecha y hora de creación del usuario           |
| `display_name`                      | String    | Nombre para mostrar del usuario                |
| `email`                             | String    | Correo electrónico del usuario                 |
| `photo_url`                         | String    | URL de la foto de perfil del usuario           |
| `preferences`                       | Object    | Objeto con las preferencias del usuario        |
| `preferences.currency`              | String    | Moneda preferida (ej: "USD")                   |
| `preferences.notifications_enabled` | Boolean   | Indica si las notificaciones están habilitadas |
| `preferences.theme`                 | String    | Tema de la aplicación (ej: "dark")             |

#### Example Document:
```json
{
  "auth_provider": "google",
  "created_at": "14 de enero de 2026 a las 8:25:39 p.m. UTC-5",
  "display_name": "Denise Rea",
  "email": "denisenoemi277@gmail.com",
  "photo_url": "https://plus.unsplash.com/premium/photo-1667030474693-6d0632f970299...",
  "preferences": {
    "currency": "USD",
    "notifications_enabled": true,
    "theme": "dark"
  }
}
```

---

### 2. Categories Collection (`categories`)

Almacena las categorías de transacciones (ingresos y gastos).

#### Fields:
| Campo       | Tipo    | Descripción                                  |
| ----------- | ------- | -------------------------------------------- |
| `color_hex` | String  | Color en formato hexadecimal (ej: "#F00000") |
| `icon_code` | String  | Código del ícono a mostrar (ej: "food")      |
| `is_active` | Boolean | Indica si la categoría está activa           |
| `name`      | String  | Nombre de la categoría                       |
| `type`      | String  | Tipo de categoría: "expense" o "income"      |

#### Example Document:
```json
{
  "color_hex": "#F00000",
  "icon_code": "food",
  "is_active": true,
  "name": "comida",
  "type": "expense"
}
```

---

### 3. Budgets Collection (`budgets`)

Almacena los presupuestos configurados por los usuarios para diferentes categorías.

#### Fields:
| Campo             | Tipo   | Descripción                             |
| ----------------- | ------ | --------------------------------------- |
| `alert_threshold` | Number | Umbral de alerta (0-1, donde 0.3 = 30%) |
| `category_id`     | String | Referencia al ID de la categoría        |
| `limit_amount`    | Number | Monto límite del presupuesto            |
| `period`          | String | Período del presupuesto (ej: "mensual") |
| `user_id`         | String | Referencia al ID del usuario            |

#### Example Document:
```json
{
  "alert_threshold": 0.3,
  "category_id": "/categories/fo9CPqY4b3541Ppdivk3",
  "limit_amount": 300,
  "period": "mensual",
  "user_id": "/users/aP8CIMEGo5YzMCnss660"
}
```

---

### 4. Transactions Collection (`transactions`)

Almacena todas las transacciones (ingresos y gastos) de los usuarios.

#### Fields:
| Campo                | Tipo      | Descripción                                           |
| -------------------- | --------- | ----------------------------------------------------- |
| `amount`             | Number    | Monto de la transacción                               |
| `category_id`        | String    | Referencia al ID de la categoría                      |
| `created_at`         | Timestamp | Fecha y hora de creación del registro                 |
| `date`               | Timestamp | Fecha y hora de la transacción                        |
| `is_deleted`         | Boolean   | Indica si la transacción está eliminada (soft delete) |
| `location`           | GeoPoint  | Ubicación geográfica [latitud, longitud]              |
| `receipt_image_path` | String    | Ruta de la imagen del recibo (puede ser "none")       |
| `type`               | String    | Tipo de transacción: "income" o "expense"             |
| `updated_at`         | Timestamp | Fecha y hora de última actualización                  |
| `user_id`            | String    | Referencia al ID del usuario                          |

#### Example Document:
```json
{
  "amount": 200,
  "category_id": "/categories/fo9CPqY4b3541Ppdivk3",
  "created_at": "14 de enero de 2026 a las 8:33:33 p.m. UTC-5",
  "date": "14 de enero de 2026 a las 8:32:07 p.m. UTC-5",
  "is_deleted": false,
  "location": [0°N, 0°E],
  "receipt_image_path": "none",
  "type": "income",
  "updated_at": "14 de enero de 2026 a las 8:33:45 p.m. UTC-5",
  "user_id": "/users/aP8CIMEGo5YzMCnss660"
}
```

---

## Relationships

### Entity Relationship Diagram

```
Users (1) ----< (N) Transactions
Users (1) ----< (N) Budgets
Categories (1) ----< (N) Transactions
Categories (1) ----< (N) Budgets
```

### Relationship Details:

1. **Users → Transactions**: Un usuario puede tener múltiples transacciones
   - Campo de relación: `transactions.user_id` → `users.{id}`

2. **Users → Budgets**: Un usuario puede tener múltiples presupuestos
   - Campo de relación: `budgets.user_id` → `users.{id}`

3. **Categories → Transactions**: Una categoría puede estar asociada a múltiples transacciones
   - Campo de relación: `transactions.category_id` → `categories.{id}`

4. **Categories → Budgets**: Una categoría puede tener múltiples presupuestos
   - Campo de relación: `budgets.category_id` → `categories.{id}`

---

## Data Types Reference

| Firestore Type | Descripción                                 |
| -------------- | ------------------------------------------- |
| String         | Cadena de texto                             |
| Number         | Número (entero o decimal)                   |
| Boolean        | Valor booleano (true/false)                 |
| Timestamp      | Fecha y hora                                |
| GeoPoint       | Coordenadas geográficas [latitud, longitud] |
| Object         | Objeto anidado con campos                   |

---

## Business Rules

1. **Soft Delete**: Las transacciones utilizan el campo `is_deleted` para eliminación lógica
2. **Timestamps**: Todas las colecciones principales mantienen registros de `created_at` y `updated_at`
3. **References**: Las relaciones se almacenan como strings con la ruta completa (ej: `/users/aP8CIMEGo5YzMCnss660`)
4. **Alert Threshold**: Los presupuestos tienen un umbral de alerta expresado como decimal (0.3 = 30%)
5. **Location Tracking**: Las transacciones pueden incluir ubicación geográfica opcional
6. **Receipt Storage**: Las transacciones pueden tener imágenes de recibos asociadas

---

## Screenshots Reference

Las siguientes capturas de pantalla muestran ejemplos reales de documentos en cada colección:

1. **Budgets Collection**: Muestra la configuración de presupuestos con umbrales de alerta
2. **Categories Collection**: Muestra categorías con colores e íconos personalizados
3. **Transactions Collection**: Muestra transacciones con ubicación y timestamps
4. **Users Collection**: Muestra perfiles de usuario con preferencias anidadas

---

*Última actualización: 14 de enero de 2026*
