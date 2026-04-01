-- Busca polizas con un valor errado en el limite2 de las coberturas de comprensivo y colision.
-- dado el Numero de Documento
--Armando Moreno M. 25/04/2018


DROP PROCEDURE sp_sis21f;
CREATE PROCEDURE "informix".sp_sis21f() 
RETURNING CHAR(20),char(10),date,date;

DEFINE _no_poliza		CHAR(10);
DEFINE _vigencia_inic,_vig_fin	DATE;
define _no_documento char(20);
define _cnt smallint;

SET ISOLATION TO DIRTY READ;

LET _no_poliza = NULL;

FOREACH
	select no_documento,no_poliza,vigencia_inic,vigencia_final
	  into _no_documento,_no_poliza,_vigencia_inic,_vig_fin
	  from emipomae
	 where actualizado = 1
	   and cod_grupo = '1090'
	 order by vigencia_final desc

    select count(*)
	  into _cnt
	  from emipocob
	 where no_poliza = _no_poliza
	   and limite_2  = 15000
	   and cod_cobertura in('00118','00119');
	   
	if _cnt is null then
		let _cnt = 0;
	end if
	
	if _cnt > 0 then
		return _no_documento,_no_poliza,_vigencia_inic,_vig_fin with resume;
	end if
END FOREACH

END PROCEDURE;