-- Procedimiento que calcula carnaval y viernes santo
-- Amado Perez M. 30-09-2025

CREATE PROCEDURE sp_par390(a_agno INTEGER)
    RETURNING DATE, DATE;

    DEFINE a, b, c, d, e INTEGER;
    DEFINE pascua DATE;
    DEFINE martes_carnaval DATE;
    DEFINE viernes_santo DATE;

    LET a = MOD(a_agno, 19);
    LET b = MOD(a_agno, 4);
    LET c = MOD(a_agno, 7);
    LET d = MOD((19 * a + 24), 30);
    LET e = MOD((2 * b + 4 * c + 6 * d + 5), 7);

    IF (d + e) < 10 THEN
        LET pascua = MDY(3, d + e + 22, a_agno);
    ELSE
        LET pascua = MDY(4, d + e - 9, a_agno);
    END IF;

    -- Ajustes especiales
    IF pascua = MDY(4, 26, a_agno) THEN
        LET pascua = MDY(4, 19, a_agno);
    END IF;

    IF pascua = MDY(4, 25, a_agno) AND d = 28 AND e = 6 AND a > 10 THEN
        LET pascua = MDY(4, 18, a_agno);
    END IF;

    LET martes_carnaval = pascua - INTERVAL(47) DAY TO DAY;
    LET viernes_santo = pascua - INTERVAL(2) DAY TO DAY;

    RETURN martes_carnaval, viernes_santo;
END PROCEDURE;