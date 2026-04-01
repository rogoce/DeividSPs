-- Numero Interno de Poliza de la ultima Vigencia dado el Numero de Documento

-- Creado    : 02/03/2001 - Autor: Demetrio Hurtado Almanza
-- Modificado: 02/03/2001 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis21aa;
CREATE PROCEDURE sp_sis21aa()
RETURNING CHAR(10),char(20),dec(16,2),dec(16,2);

DEFINE _no_poliza      CHAR(10);
DEFINE _no_documento char(20);
define _prima_bruta,_saldo dec(16,2);
define _no_unidad char(5);
define _cod_cobertura char(10);

SET ISOLATION TO DIRTY READ;

LET _no_poliza = NULL;
let _prima_bruta = 0;
let _saldo = 0;
FOREACH
	select poliza,prima_bruta,saldo
	  into _no_documento,_prima_bruta,_saldo
	  from deivid_tmp:temp_venc2021mares
     where cancelada = 0
	 
	let _no_poliza = sp_sis21(_no_documento);
	foreach
		select no_unidad, cod_cobertura
		  into _no_unidad, _cod_cobertura
		  from emipocob
		 where no_poliza = _no_poliza
		 order by no_unidad,orden
		 exit foreach;
	end foreach
	update emipocob
	   set prima_neta = _saldo
	 where no_poliza = _no_poliza
       and no_unidad = _no_unidad
       and cod_cobertura = _cod_cobertura;
	
    return _no_poliza,_no_documento,_prima_bruta,_saldo with resume;	 
END FOREACH

END PROCEDURE;