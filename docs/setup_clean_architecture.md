# Script para Crear Estructura de Clean Architecture

Este script crea automáticamente toda la estructura de carpetas necesaria para implementar Clean Architecture en el proyecto Smart Finance Manager.

## Instrucciones de Uso

### En Windows (PowerShell):

```powershell
# Navegar al directorio lib
cd d:\julio\Android\AndoridStudioProjects\smart_finance_manager\lib

# Crear estructura de Core
New-Item -ItemType Directory -Force -Path "core\constants"
New-Item -ItemType Directory -Force -Path "core\errors"
New-Item -ItemType Directory -Force -Path "core\network"
New-Item -ItemType Directory -Force -Path "core\theme"
New-Item -ItemType Directory -Force -Path "core\utils"
New-Item -ItemType Directory -Force -Path "core\widgets"

# Crear estructura de Authentication
New-Item -ItemType Directory -Force -Path "features\authentication\data\datasources"
New-Item -ItemType Directory -Force -Path "features\authentication\data\models"
New-Item -ItemType Directory -Force -Path "features\authentication\data\repositories"
New-Item -ItemType Directory -Force -Path "features\authentication\domain\entities"
New-Item -ItemType Directory -Force -Path "features\authentication\domain\repositories"
New-Item -ItemType Directory -Force -Path "features\authentication\domain\usecases"
New-Item -ItemType Directory -Force -Path "features\authentication\presentation\bloc"
New-Item -ItemType Directory -Force -Path "features\authentication\presentation\pages"
New-Item -ItemType Directory -Force -Path "features\authentication\presentation\widgets"

# Crear estructura de Transactions
New-Item -ItemType Directory -Force -Path "features\transactions\data\datasources"
New-Item -ItemType Directory -Force -Path "features\transactions\data\models"
New-Item -ItemType Directory -Force -Path "features\transactions\data\repositories"
New-Item -ItemType Directory -Force -Path "features\transactions\domain\entities"
New-Item -ItemType Directory -Force -Path "features\transactions\domain\repositories"
New-Item -ItemType Directory -Force -Path "features\transactions\domain\usecases"
New-Item -ItemType Directory -Force -Path "features\transactions\presentation\bloc"
New-Item -ItemType Directory -Force -Path "features\transactions\presentation\pages"
New-Item -ItemType Directory -Force -Path "features\transactions\presentation\widgets"

# Crear estructura de Categories
New-Item -ItemType Directory -Force -Path "features\categories\data\datasources"
New-Item -ItemType Directory -Force -Path "features\categories\data\models"
New-Item -ItemType Directory -Force -Path "features\categories\data\repositories"
New-Item -ItemType Directory -Force -Path "features\categories\domain\entities"
New-Item -ItemType Directory -Force -Path "features\categories\domain\repositories"
New-Item -ItemType Directory -Force -Path "features\categories\domain\usecases"
New-Item -ItemType Directory -Force -Path "features\categories\presentation\bloc"
New-Item -ItemType Directory -Force -Path "features\categories\presentation\pages"
New-Item -ItemType Directory -Force -Path "features\categories\presentation\widgets"

# Crear estructura de Budgets
New-Item -ItemType Directory -Force -Path "features\budgets\data\datasources"
New-Item -ItemType Directory -Force -Path "features\budgets\data\models"
New-Item -ItemType Directory -Force -Path "features\budgets\data\repositories"
New-Item -ItemType Directory -Force -Path "features\budgets\domain\entities"
New-Item -ItemType Directory -Force -Path "features\budgets\domain\repositories"
New-Item -ItemType Directory -Force -Path "features\budgets\domain\usecases"
New-Item -ItemType Directory -Force -Path "features\budgets\presentation\bloc"
New-Item -ItemType Directory -Force -Path "features\budgets\presentation\pages"
New-Item -ItemType Directory -Force -Path "features\budgets\presentation\widgets"

Write-Host "✅ Estructura de carpetas creada exitosamente!" -ForegroundColor Green
```

### En Linux/Mac (Bash):

```bash
#!/bin/bash

# Navegar al directorio lib
cd /path/to/smart_finance_manager/lib

# Crear estructura de Core
mkdir -p core/{constants,errors,network,theme,utils,widgets}

# Crear estructura de Authentication
mkdir -p features/authentication/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}

# Crear estructura de Transactions
mkdir -p features/transactions/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}

# Crear estructura de Categories
mkdir -p features/categories/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}

# Crear estructura de Budgets
mkdir -p features/budgets/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}

echo "✅ Estructura de carpetas creada exitosamente!"
```

## Estructura Resultante

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── transactions/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── categories/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   └── budgets/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
├── injection_container.dart
└── main.dart
```

## Próximos Pasos

Después de crear la estructura:

1. **Crear archivos Core**:
   - `core/errors/failures.dart`
   - `core/errors/exceptions.dart`

2. **Implementar una feature completa** (recomendado: Transactions):
   - Domain layer (entities, repositories, use cases)
   - Data layer (models, data sources, repository impl)
   - Presentation layer (bloc, pages, widgets)

3. **Configurar Dependency Injection**:
   - Crear `injection_container.dart`

4. **Actualizar main.dart**:
   - Inicializar dependency injection
   - Configurar BlocProviders

5. **Agregar dependencias al pubspec.yaml**

6. **Escribir tests**
