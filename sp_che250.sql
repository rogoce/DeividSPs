-- Reporte Bono de Persistencia
-- Creado    : 02/03/2023 - Autor: Henry Giron
-- SIS v.2.0 - d_cheq_sp_che250_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che250;
CREATE PROCEDURE sp_che250(a_compania CHAR(3), a_cod_agente CHAR(5) default '*', a_periodo char(7)) 
  RETURNING  CHAR(15),	 --cod_agente
			 CHAR(50),	 --n_corredor
			 SMALLINT,	 --tot_pol_ap
			 SMALLINT,	 --tot_pol_ren_aa
			 SMALLINT,	 --persis
			 DECIMAL(16,2),	 --monto_bono
			 CHAR(3),	 --cod_vendedor
			 CHAR(50),	 --n_vendedor
			 CHAR(50);    --CIA

DEFINE _cod_agente      CHAR(5);
define _cant_pol         integer;
define _no_pol_ren_aa_per		integer;
define _bono, _persis            smallint;
define _n_corredor,_n_zona , v_nombre_cia varchar(50);
define _cod_vendedor char(3);


let _cant_pol = 0;
let _bono     = 0;


--SET DEBUG FILE TO "\\sp_che83.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 



FOREACH
  SELECT cod_agente,
		n_corredor,
		tot_pol_ap,
		tot_pol_ren_aa,
		persis,
		monto_bono,
		cod_vendedor,
		n_vendedor		
   INTO	_cod_agente,
		_n_corredor, 
		_cant_pol, 
		_no_pol_ren_aa_per, 
		_persis, 
		_bono,
		_cod_vendedor,
		_n_zona 
   FROM	chqbopersis
  WHERE cod_agente matches a_cod_agente
    and nvl(seleccionado,0) = 0
	and periodo  = a_periodo			
			
	return _cod_agente,	
			_n_corredor, 
			_cant_pol,
			_no_pol_ren_aa_per, 
			_persis, 
			_bono,
			_cod_vendedor,
			_n_zona,
            v_nombre_cia			
	with resume;
	
END FOREACH

UPDATE chqbopersis
   SET seleccionado = 1
 WHERE cod_agente = a_cod_agente
   and periodo  = a_periodo;


END PROCEDURE;