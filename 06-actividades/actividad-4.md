# Actividad 4 — Bitácora sobre la tabla de rentas (BD Video)

## Objetivo

Crear una **bitácora** (tabla de auditoría) para la tabla **`itc_Renta`** de la base de
datos **Video** usando **queries**. La bitácora debe registrar automáticamente, en cada
`INSERT`, `UPDATE` y `DELETE` sobre `itc_Renta`:
quién lo hizo, cuándo, qué operación y qué datos se vieron afectados.

Se implementa con un **TRIGGER (`AFTER`)**: cuando el usuario inserta/modifica/elimina
una renta, el disparador escribe la novedad en la tabla `BitacoraRenta` sin que el
usuario tenga que hacer nada extra.

![[Pasted image 20261007221155.png]]

## Paso a paso

1. Revisar la **estructura actual** de `itc_Renta` con `EXEC sp_help itc_Renta`.
![[Pasted image 20261007221307.png]]
2. Crear la tabla `BitacoraRenta` (dónde se guardan los eventos).
![[Pasted image 20261007221333.png]]
3. Crear el `trigger trg_BitacoraRenta` sobre `itc_Renta`.
![[Pasted image 20261007221406.png]]
4. Ejecutar un `INSERT`, un `UPDATE` y un `DELETE` de prueba.
![[Pasted image 20261007221427.png]]
5. **Consultar la bitácora** para ver el resultado paso a paso.
![[Pasted image 20261007221442.png]]
6. (Opcional) Eliminar trigger y tabla al terminar para dejar la BD limpia.
![[Pasted image 20261007221458.png]]

## Queries aplicadas (documentadas)

```sql
-- ============================================================
-- ACTIVIDAD 4: Bitácora para itc_Renta en BD_VIDEOS
-- ============================================================
USE BD_VIDEOS;
GO

-- PASO 1: Ver la estructura actual de la tabla de rentas
EXEC sp_help itc_Renta;
GO

-- PASO 2: Crear la tabla bitácora
CREATE TABLE dbo.BitacoraRenta (
    id_bitacora INT IDENTITY(1,1) CONSTRAINT PK_bitacora PRIMARY KEY, -- folio del evento
    fecha       DATETIME     NOT NULL DEFAULT GETDATE(),              -- cuándo ocurrió
    usuario     VARCHAR(60)  NOT NULL DEFAULT SUSER_SNAME(),          -- quién lo hizo
    operacion   VARCHAR(10)  NOT NULL,                                -- INSERT / UPDATE / DELETE
    folio       INT          NULL,                                    -- renta afectada
    detalle     VARCHAR(400) NULL                                     -- datos relevantes del cambio
);
GO

-- PASO 3: Crear el trigger de auditoría (se dispara después de las 3 operaciones)
CREATE TRIGGER dbo.trg_BitacoraRenta
ON dbo.itc_Renta
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Registra INSERT: fila solo existe en inserted
    INSERT INTO dbo.BitacoraRenta (operacion, folio, detalle)
    SELECT 'INSERT', i.folio,
           'Pelicula=' + ISNULL(CAST(i.cve_p AS VARCHAR(10)),'-') +
           ', Cliente=' + ISNULL(CAST(i.cve_c AS VARCHAR(10)),'-') +
           ', Dias=' + ISNULL(CAST(i.dias AS VARCHAR(10)),'-')
    FROM inserted i
    WHERE NOT EXISTS (SELECT 1 FROM deleted d WHERE d.folio = i.folio);

    -- Registra UPDATE: fila existe en inserted y en deleted
    INSERT INTO dbo.BitacoraRenta (operacion, folio, detalle)
    SELECT 'UPDATE', i.folio,
           'Dias: ' + ISNULL(CAST(d.dias AS VARCHAR(10)),'-') +
           ' -> ' + ISNULL(CAST(i.dias AS VARCHAR(10)),'-')
    FROM inserted i
    JOIN deleted d ON d.folio = i.folio;

    -- Registra DELETE: fila solo existe en deleted
    INSERT INTO dbo.BitacoraRenta (operacion, folio, detalle)
    SELECT 'DELETE', d.folio,
           'Pelicula=' + ISNULL(CAST(d.cve_p AS VARCHAR(10)),'-') +
           ', Cliente=' + ISNULL(CAST(d.cve_c AS VARCHAR(10)),'-')
    FROM deleted d
    WHERE NOT EXISTS (SELECT 1 FROM inserted i WHERE i.folio = d.folio);
END
GO

-- PASO 4: Probar la bitácora con DML de ejemplo
SELECT 'filas antes de la prueba' AS etapa, COUNT(*) AS filas FROM dbo.itc_Renta;
GO

INSERT INTO itc_Renta (cve_p, cve_c, cve_devol, fecha_prestamo, dias, costoXdia)
VALUES (1, 1, 1, CAST(GETDATE() AS DATE), 3, '50');   -- nueva renta
UPDATE itc_Renta SET dias = 5 WHERE folio = SCOPE_IDENTITY(); -- se modifica
DELETE FROM itc_Renta WHERE folio = SCOPE_IDENTITY();          -- se elimina
GO

-- PASO 5: VER EL RESULTADO DE LA BITÁCORA paso a paso
SELECT id_bitacora, CONVERT(VARCHAR(16), fecha, 120) AS fecha, usuario,
       operacion, folio, detalle
FROM dbo.BitacoraRenta
ORDER BY id_bitacora;
GO

-- Resumen por tipo de operación
SELECT operacion, COUNT(*) AS eventos FROM dbo.BitacoraRenta GROUP BY operacion;
GO

-- PASO 6 (opcional): dejar la BD como estaba, eliminando el trigger y la tabla
-- DROP TRIGGER dbo.trg_BitacoraRenta;
-- DROP TABLE dbo.BitacoraRenta;
```
