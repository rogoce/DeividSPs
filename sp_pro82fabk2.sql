
drop procedure sp_pro82fabk2;
CREATE PROCEDURE "informix".sp_pro82fabk2()
			RETURNING   INTEGER   -- _error


DEFINE _error				INTEGER;
DEFINE _no_poliza			char(10);
DEFINE _no_unidad			char(5);
DEFINE _vig_ini				date;
DEFINE _suma_asegurada		DECIMAL(16,2);
DEFINE _cod_ramo			char(3);
define _cod_ruta            char(5);
define _opcion_final		smallint;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET ISOLATION TO DIRTY READ;


foreach

	select e.no_poliza,
	       e.no_unidad,
		   e.vigencia_inic,
		   e.suma_aseg,
		   e.opcion_final,
		   i.cod_ramo
	  into _no_poliza,
	       _no_unidad,
		   _vig_ini,
		   _suma_asegurada,
		   _opcion_final,
		   _cod_ramo
	  from emireaut e, emipomae i
	 where e.no_poliza = i.no_poliza
	   and i.cod_ramo  = '002'
       and e.vigencia_inic >= '01/07/2013'

	select cod_ruta
	  into _cod_ruta
	  from rearumae
	 where cod_ramo = _cod_ramo
	   and activo   = 1
	   and _vig_ini between vig_inic and vig_final;


	delete from emireglo
  	 where no_poliza = _no_poliza;


	select * 
	  from rearucon
	 where cod_ruta = _cod_ruta
	  into temp prueba;

	insert into emireglo(
	no_poliza,
	no_endoso,
	orden,
	cod_contrato,
	cod_ruta,
	porc_partic_prima,
	porc_partic_suma,
	suma_asegurada,
	prima)
	select _no_poliza,
	       '00000',
			orden,
			cod_contrato,
	        cod_ruta,
			porc_partic_prima,
			porc_partic_suma,
	       	0,0
	  from prueba;

	drop table prueba;

    call sp_pro82fa(_no_poliza,_no_unidad, _suma_asegurada, '001',_opcion_final) returning _error;

end foreach

END
END PROCEDURE                                                                                                                                                                                                 
