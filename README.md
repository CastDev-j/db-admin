# SQL Server Docker

Levantamiento de SQL Server 2022 mediante Docker Compose.

## Inicio rápido

```bash
docker-compose up -d
```

## Credenciales

| Campo      | Valor                    |
| ---------- | ------------------------ |
| Usuario    | `sa`                     |
| Contraseña | `YourStrong@Password123` |
| Puerto     | `1433`                   |
| PID        | Developer                |

## Conexión

```
Server: localhost,1433
User: sa
Password: YourStrong@Password123
```

### Cadena de conexión (ADO.NET)

```
Server=localhost,1433;Database=master;User Id=sa;Password=YourStrong@Password123;Persist Security Info=False;Pooling=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Application Name="SQL Server Management Studio";Command Timeout=0
```

```
Server=10.1.2.218,1433;Database=master;User Id=sa;Password=YourStrong@Password123;Persist Security Info=False;Pooling=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Application Name="SQL Server Management Studio";Command Timeout=0
```

## Comandos útiles

```bash
# Detener
docker-compose down

# Detener y eliminar volúmenes
docker-compose down -v

# Ver logs
docker-compose logs -f
```

## Notas

- Cambia la contraseña en producción.
- Los datos se persisten en el volumen `sqlserver_data`.
