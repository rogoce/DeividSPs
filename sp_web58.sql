-- Obtener la fecha del reclamo.

-- Creado    : 01/10/2019 - Autor: Federico Coronado

-- SIS - Pagina Web

drop procedure sp_web58;

create procedure "informix".sp_web58()
returning char(7),
		  date;


DEFINE _fecha_recl_default	CHAR(20);
DEFINE _fecha_recl_valor	CHAR(20);
DEFINE _mes_char			CHAR(2);
DEFINE _ano_char			CHAR(4);
DEFINE _periodo			    CHAR(7);
DEFINE _cod_compania        CHAR(3);

let _cod_compania	= '001';

SELECT valor_parametro 
INTO _fecha_recl_default 
FROM inspaag
WHERE codigo_compania  = _cod_compania
AND aplicacion       = "REC"
AND version          = "02"
AND codigo_parametro = "fecha_recl_default";

IF TRIM(_fecha_recl_default) = "1" THEN
IF  MONTH(current) < 10 THEN
	LET _mes_char = '0'|| MONTH(current);
ELSE
	LET _mes_char = MONTH(current);
END IF

LET _ano_char = YEAR(current);
LET _periodo  = _ano_char || "-" || _mes_char;
LET _fecha_recl_valor = date(current);
ELSE
SELECT valor_parametro 
  INTO _fecha_recl_valor 
  FROM inspaag
 WHERE codigo_compania  = _cod_compania
   AND aplicacion       = "REC"
   AND version          = "02"
   AND codigo_parametro = "fecha_recl_valor";

LET _fecha_recl_valor = trim(_fecha_recl_valor);
LET _periodo = trim(_fecha_recl_valor[7,10]) || "-" || trim(_fecha_recl_valor[4,5]);
END IF
return _periodo,
	   _fecha_recl_valor;
end procedure