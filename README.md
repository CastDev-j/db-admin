# SQL Server Docker

Levantamiento de SQL Server 2022 mediante Docker Compose.

## Inicio rápido

```bash
docker-compose up -d
```

## Credenciales

| Campo | Valor |
|-------|-------|
| Usuario | `sa` |
| Contraseña | `YourStrong@Password123` |
| Puerto | `1433` |
| PID | Developer |

## Conexión

```
Server: localhost,1433
User: sa
Password: YourStrong@Password123
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
