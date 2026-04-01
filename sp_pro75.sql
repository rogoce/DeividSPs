-- Verificacion de Distribucion de Contratos de Salud

DROP PROCEDURE sp_pro75;

CREATE PROCEDURE "informix".sp_pro75(
a_compania char(3),
a_periodo1 char(7), 
a_periodo2 char(7))
returning smallint,
		  char(50),
          dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(50),
		  char(7);
		  
define _cod_ramo		  char(3);
define _cod_subramo		  char(3);
define _prima_suscrita    dec(16,2);
define _prima_retenida    dec(16,2);
define _mes               smallint;
define _fecha_emision     date;
define _prima_contrato    dec(16,2);
define _prima_xl          dec(16,2);
define _nombre_subramo	  char(50);	
define v_nombre_cia		  char(50);
define _periodo			  char(7);

define _fecha1			  date;
define _fecha2			  date;

set isolation to dirty read;

let _fecha1 = "01/05/2000";
let _fecha2 = "01/05/2002";

let v_nombre_cia = sp_sis01(a_compania); 

select cod_ramo
  into _cod_ramo
  from prdramo
 where ramo_sis = 5;
  				
foreach
 select p.cod_subramo,
		e.prima_suscrita,
		e.prima_retenida,
		e.periodo[6,7],
		e.fecha_emision,
		e.periodo
   into _cod_subramo,
		_prima_suscrita,
	    _prima_retenida,
		_mes,
		_fecha_emision,
		_periodo
   from emipomae p, endedmae e
  where p.cod_ramo      = _cod_ramo
    and e.actualizado   = 1 
	and p.no_poliza     = e.no_poliza
    and e.periodo       >= a_periodo1
    and e.periodo       <= a_periodo2 

	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	let _prima_xl = 0;

	if   _cod_subramo = '001' then -- HEA

		let _prima_contrato = 0;

	elif _cod_subramo = '005' then -- CUI

		let _prima_contrato = 0;

	elif _cod_subramo = '009' then -- GLO

		let _prima_xl = _prima_suscrita * (4.9 / 100);

		if _fecha_emision < _fecha1 then
			let _prima_contrato = (_prima_suscrita - _prima_xl) * (85 / 100);
		elif _fecha_emision >= _fecha1 and 
		     _fecha_emision <  _fecha2 then
			let _prima_contrato =  (_prima_suscrita - _prima_xl) * (60 / 100);
		else
			let _prima_contrato =  0;
		end if

	elif _cod_subramo = '007' then -- PA1

		let _prima_xl = _prima_suscrita * (4.9 / 100);

		
		if _fecha_emision < _fecha1 then
			let _prima_contrato =  (_prima_suscrita - _prima_xl) * (85 / 100);
		elif _fecha_emision >= _fecha1 and 
		     _fecha_emision <  _fecha2 then
			let _prima_contrato =  (_prima_suscrita - _prima_xl) * (60 / 100);
		else
			let _prima_contrato =  0;
		end if

	elif _cod_subramo = '008' then -- PA2

		let _prima_xl = _prima_suscrita * (4.9 / 100);

		if _fecha_emision < _fecha1 then
			let _prima_contrato =  (_prima_suscrita - _prima_xl) * (85 / 100);
		elif _fecha_emision >= _fecha1 and 
		     _fecha_emision <  _fecha2 then
			let _prima_contrato =  (_prima_suscrita - _prima_xl) * (60 / 100);
		else
			let _prima_contrato =  0;
		end if

	elif _cod_subramo = '003' then -- CAN

		let _prima_xl = _prima_suscrita * (19 / 100);

		if _fecha_emision < _fecha2 then
			let _prima_contrato = (_prima_suscrita - _prima_xl) * (50 / 100);
		else
			let _prima_contrato =  0;
		end if

	elif _cod_subramo = '004' then -- TRO

		let _prima_xl = _prima_suscrita * (27.3 / 100);

		if _fecha_emision < _fecha2 then
			let _prima_contrato = (_prima_suscrita - _prima_xl) * (50 / 100);
		else
			let _prima_contrato =  0;
		end if

	elif _cod_subramo = '006' then -- Coaseguro

		let _prima_xl = _prima_suscrita * (4.9 / 100);

		if _fecha_emision < _fecha1 then
			let _prima_contrato =  (_prima_suscrita - _prima_xl) * (85 / 100);
		elif _fecha_emision >= _fecha1 and 
		     _fecha_emision <  _fecha2 then
			let _prima_contrato =  (_prima_suscrita - _prima_xl) * (60 / 100);
		else
			let _prima_contrato =  0;
		end if

	else

		let _prima_contrato = _prima_suscrita - _prima_retenida;

	end if

	RETURN _mes,
		   _nombre_subramo,
		   _prima_suscrita,
		   _prima_xl,
		   (_prima_suscrita - _prima_xl),
		   _prima_contrato,
		   v_nombre_cia,
		   _periodo
		   with resume;

end foreach

END PROCEDURE;
