-- Realiza cambios de Enmoaut a Emiauto
-- Creado    : 06/04/2016 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_pro4955('877853','00004')
  
drop procedure sp_che233;
create procedure sp_che233()
returning	DATETIME YEAR TO MONTH,
			DATETIME YEAR TO MONTH,
			CHAR(80),
			SMALLINT;

define _error_desc,_mensaje		CHAR(100);
DEFINE _no_unidad       CHAR(5);
DEFINE _cod_tipoveh     CHAR(3);
DEFINE _uso_auto        CHAR(1);
define _error_isam		integer;
define _error			integer;
define _no_documento    char(20);
define a_no_poliza      char(10);
define _no_poliza       char(10);
define _no_endoso       char(5);
define _vigencia_inic   date;
define _fecha1          date;
define _fecha2          date;
	DEFINE _anos         SMALLINT;
	DEFINE _periodo1     DATETIME YEAR TO MONTH;
	DEFINE _periodo2     DATETIME YEAR TO MONTH;
	DEFINE _periodo_char CHAR(80);
	DEFINE _mes          CHAR(2);
set isolation to dirty read;


set debug file to "sp_che233.trc";
trace on;
--return _error, _error_desc;

BEGIN


	
	let _vigencia_inic = '01/07/2016';
	let _fecha2        = '01/09/2016';

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

{	foreach
		select distinct no_documento
		  into _no_documento
		  from aa
		  
		let a_no_poliza = sp_sis21(_no_documento);
		foreach
			select no_endoso
			  into _no_endoso
			  from endedmae
			 where no_poliza = a_no_poliza
			   and actualizado = 1
			   and cod_endomov = '026'
			   
			SELECT no_unidad,
				   cod_tipoveh,
                   uso_auto			   
			  INTO _no_unidad,
				   _cod_tipoveh,
				   _uso_auto
			  FROM endmoaut
			 WHERE no_poliza = a_no_poliza
			   AND no_endoso = _no_endoso;
			   
			foreach
				select no_poliza
				  into _no_poliza
				  from emipomae
				 where actualizado  = 1
				   and no_documento = _no_documento
				   and no_poliza    <> a_no_poliza
				   
				UPDATE emiauto
				   SET cod_tipoveh = _cod_tipoveh,
   				       uso_auto    = _uso_auto
				 WHERE no_poliza   = _no_poliza
				   AND no_unidad   = _no_unidad;   
				 
			end foreach
			
	    end foreach
	end foreach
	END}
	
end
--trace off;

return _periodo1,_periodo2,_periodo_char,_anos;
end procedure;