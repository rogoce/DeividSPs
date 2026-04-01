DROP PROCEDURE convertir_cpu_time;
CREATE PROCEDURE convertir_cpu_time(cpu_cent DEC(20,10))
    RETURNING VARCHAR(50);

    DEFINE total_seconds DEC(20,10);
    DEFINE horas INTEGER;
    DEFINE minutos INTEGER;
    DEFINE segundos INTEGER;
    DEFINE resultado VARCHAR(50);

    LET total_seconds = cpu_cent * 2; -- / 100;
    LET horas = TRUNC(total_seconds / 3600);
    LET minutos = TRUNC(MOD(total_seconds, 3600) / 60);
    LET segundos = MOD(total_seconds, 60);

    LET resultado = horas || 'h ' || minutos || 'm ' || segundos || 's';

    RETURN resultado;
END PROCEDURE;
