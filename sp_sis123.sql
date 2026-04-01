-- Seleccion del Contrato de Retencion
-- 
-- Creado    : 22/12/2014 - Autor: Armando Moreno
-- Modificado: 22/12/2014 - Autor: Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis123;

CREATE PROCEDURE "informix".sp_sis123(a_no_documento CHAR(20), a_unidad CHAR(5))
RETURNING CHAR(18);

DEFINE _no_unidad CHAR(5);
DEFINE _cnt       smallint;
DEFINE _fecha     date;
DEFINE _numrecla  CHAR(18);
DEFINE _no_poliza char(10);
DEFINE _ramo_sis  smallint;
DEFINE _cod_ramo  char(3);


let _fecha = current;

let _no_poliza = sp_sis21(a_no_documento);

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;

if _ramo_sis = 1 then


	select count(*)
	  into _cnt
	  from recrcmae
	 where actualizado   = 1
	   and no_documento  = a_no_documento
	   and fecha_reclamo = _fecha
	   and no_unidad     = a_unidad;

	let _numrecla = "";

	if _cnt >= 1 then

		select max(numrecla)
		  into _numrecla
		  from recrcmae
		 where actualizado   = 1
		   and no_documento  = a_no_documento
		   and fecha_reclamo = _fecha
		   and no_unidad     = a_unidad;


	end if

else
	let _numrecla = "";
end if

RETURN _numrecla;

END PROCEDURE; 