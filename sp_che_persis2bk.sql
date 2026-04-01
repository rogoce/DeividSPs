--******************************************************
-- Reporte Totales bono de persistencia para corredores
--******************************************************

-- Creado    : 14/02/2022 - Autor: Armando Moreno M.

DROP PROCEDURE sp_che_persis2;
CREATE PROCEDURE sp_che_persis2()
RETURNING char(10),varchar(50),integer,integer,integer,smallint,char(3),char(50);


DEFINE _cod_agente      CHAR(5);
define _cnt             integer;
define _cant_pol         integer;
define _error,_persis			integer;
define _error_isam,_no_pol_ren_aa_per		integer;
define _error_desc		char(50);
define _bono            smallint;
define _n_corredor,_n_zona varchar(50);
define _cod_vendedor char(3);

let _error    = 0;
let _cant_pol = 0;
let _bono     = 0;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_bonoccp01.trc";
--TRACE ON;

let _persis = 0;

foreach
	select cod_agente,
		   cant_pol 
	  into _cod_agente,
		   _cant_pol  
	  from chepersisapt
	 where cant_pol >= 120
	   --and cod_agente not in ('01315','01834')
	 order by cod_agente
 
    select sum(no_pol_ren_aa_per)
	  into _no_pol_ren_aa_per
	  from chepersisaa
	 where cod_agente = _cod_agente
	   and no_documento in (select no_documento  from chepersisap where cod_agente = _cod_agente);
	 
	let _persis = (_no_pol_ren_aa_per / _cant_pol) * 100;
	let _bono = 0;

	if _persis >= 75 and _persis < 80 then
		let _bono = 500;
	elif _persis >= 80 and _persis < 90 then
		let _bono = 750;
	elif _persis >= 90 and _persis < 100 then
		let _bono = 1000;
    end if
			
	select nombre,
           cod_vendedor
	  into _n_corredor,
	       _cod_vendedor
	  from agtagent
     where cod_agente = _cod_agente;
	
	select nombre into _n_zona from agtvende
    where cod_vendedor = _cod_vendedor;
	
	return _cod_agente,	_n_corredor, _cant_pol, _no_pol_ren_aa_per, _persis, _bono,_cod_vendedor,_n_zona with resume;
	
end foreach
END PROCEDURE;