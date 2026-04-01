

DROP PROCEDURE act_rem_vida;
CREATE PROCEDURE act_rem_vida(a_no_poliza char(10), a_no_unidad char(5),a_no_remesa char(10), a_renglon integer)
returning char(10),integer;

DEFINE _no_remesa		CHAR(10);
DEFINE _vigencia_inic	DATE;
DEFINE _fecha_hoy 		DATE;
define _valor,_renglon           integer;
define _mensaje         char(250);
define _no_cambio  smallint;

SET ISOLATION TO DIRTY READ;

LET _mensaje = "";

FOREACH
	select no_remesa,
		   renglon
	  into _no_remesa,
		   _renglon
	  from deivid_tmp:rem_vida
	  
	call sp_sis171bk(_no_remesa, _renglon)  returning _valor,_mensaje;

	RETURN _no_remesa,_renglon with resume;
	
END FOREACH
END PROCEDURE

{delete from emireaco
where no_poliza = a_no_poliza
and no_unidad = a_no_unidad
and no_cambio = 0;
		  
let _no_cambio = 0;

INSERT INTO emireaco(
no_poliza,
no_unidad,
no_cambio,
cod_cober_reas,
orden,
cod_contrato,
porc_partic_suma,
porc_partic_prima
)
SELECT 
a_no_poliza, 
no_unidad,
_no_cambio,
cod_cober_reas,
orden,
cod_contrato,
porc_partic_suma,
porc_partic_prima
FROM emifacon
WHERE no_poliza = a_no_poliza
AND no_endoso = '00000';

--call sp_sis171bk(a_no_remesa, a_renglon)  returning _valor,_mensaje;
let _valor = 0;}
--return _valor;


