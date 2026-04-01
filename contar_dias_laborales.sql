CREATE PROCEDURE contar_dias_laborales(fecha_inicio DATE, fecha_fin DATE)
    RETURNING INTEGER;

    DEFINE contador INTEGER;
    DEFINE fecha_actual DATE;
    DEFINE dia_semana INTEGER;

    LET contador = 0;
    LET fecha_actual = fecha_inicio;

    WHILE fecha_actual <= fecha_fin
    LOOP
        LET dia_semana = WEEKDAY(fecha_actual); -- 0 = domingo, 6 = sábado

        IF dia_semana BETWEEN 1 AND 5 THEN
            IF NOT EXISTS (
                SELECT 1 FROM feriados WHERE fecha = fecha_actual
            ) THEN
                LET contador = contador + 1;
            END IF;
        END IF;

        LET fecha_actual = fecha_actual + 1 UNITS DAY;
    END LOOP;

    RETURN contador;
END PROCEDURE;
