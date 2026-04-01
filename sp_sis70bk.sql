-- Procedure que crea el Historico de Corredores para las facturas

-- Creado    : 11/12/2004 - Autor: Demetrio Hurtado Almanza
--			   
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis70bk;		

create procedure sp_sis70bk()
returning DATETIME YEAR TO MONTH,DATETIME YEAR TO MONTH,char(80),smallint;

	define _cantidad	smallint;
	DEFINE _cod_producto CHAR(5);
	DEFINE _anos         SMALLINT;
	DEFINE _porc_comis   DEC(5,2);
	DEFINE _periodo1     DATETIME YEAR TO MONTH;
	DEFINE _periodo2     DATETIME YEAR TO MONTH;
	DEFINE _periodo_char CHAR(80);
	DEFINE _mes          CHAR(2);
	define _vigencia_inic,_fecha2 date;
	
	let _vigencia_inic = '27/04/2015';
	let _fecha2        = '27/05/2015';

	IF MONTH(_vigencia_inic) < 10 THEN
		LET _periodo1 = YEAR(_vigencia_inic)  || "-0" || MONTH(_vigencia_inic);
	ELSE
		LET _periodo1 = YEAR(_vigencia_inic)  || "-" || MONTH(_vigencia_inic);
	END IF

	IF MONTH(_fecha2) < 10 THEN
		LET _periodo2 = YEAR(_fecha2) || "-0" || MONTH(_fecha2);
	ELSE
		LET _periodo2 = YEAR(_fecha2) || "-" || MONTH(_fecha2);
	END IF

	LET _periodo_char = _periodo2 - _periodo1;
	LET _anos         = _periodo_char[1,5];

	IF _periodo_char[7,8] <> '00' THEN
		LET _anos = _anos + 1;
	END IF

return _periodo1,_periodo2,_periodo_char,_anos;
end procedure 
