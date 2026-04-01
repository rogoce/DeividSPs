-- Verificacion de Distribucion de Contratos de Salud

DROP PROCEDURE sp_par19;

CREATE PROCEDURE "informix".sp_par19(
a_periodo1	char(7),
a_periodo2	char(7))
returning char(20),
          date,
		  date,
		  date,
		  dec(16,2),
		  smallint,
		  dec(16,2),
		  smallint,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(3),
		  char(50),
		  smallint,
		  dec(16,2),
		  smallint;

define _no_poliza         char(10); 
define _no_documento      char(20); 
define _vigencia_inic     date;     
define _vigencia_final    date;     
define _fecha_cancelacion date;     
define _prima_suscrita    dec(16,2);
define _prima_retenida    dec(16,2);
define _prima_contrato    dec(16,2);
define _mes               smallint;
define _meses_repo        smallint;
define _meses_no_repo     smallint;
define _prima_repo		  dec(16,2);
define _prima_no_repo	  dec(16,2);
define _monto			  dec(16,2);
define _porcentaje        dec(16,2);
define _prima_cancel	  dec(16,2);
define _cod_subramo		  char(3);
define _prima_xl          dec(16,2);
define _prima_xl_no       dec(16,2);
define _nombre_subramo	  CHAR(50);	
define _fecha_emision     date;
define _monto_xl          dec(16,2);
define _order             smallint;
			
foreach
 select p.no_poliza,
        p.no_documento,
		p.vigencia_inic,
		p.vigencia_final,
		p.fecha_cancelacion,
		p.cod_subramo,
		e.prima_suscrita,
		e.prima_retenida,
		e.periodo[6,7],
		e.fecha_emision
   into _no_poliza,
        _no_documento,
		_vigencia_inic,
		_vigencia_final,
		_fecha_cancelacion,
		_cod_subramo,
		_prima_suscrita,
	    _prima_retenida,
		_mes,
		_fecha_emision
   from emipomae p, endedmae e
  where p.cod_ramo      = '018'
    and e.actualizado   = 1 
	and p.no_poliza     = e.no_poliza
--    and vigencia_inic >= '01/06/2000'
--    and vigencia_inic <= '30/06/2000'
--    and p.vigencia_inic >= '01/05/1999'
--    and p.vigencia_inic <= '30/04/2000'
      and e.periodo     >= a_periodo1
      and e.periodo     <= a_periodo2 
--	  and cod_endomov   <> '002'
  order by  vigencia_inic, no_documento

	if _mes >= 5  and 
	   _mes <= 12 then
		let _order = _mes - 4;
	else
		let _order = _mes + 8;
	end if

{
	select prima_suscrita,
	       prima_retenida
	  into _prima_suscrita,
	       _prima_retenida
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = '00000';
}

	let _prima_xl = 0;

	if   _cod_subramo = '001' then
		let _prima_contrato = 0;
	elif _cod_subramo = '005' then
		let _prima_contrato = 0;
	elif _cod_subramo = '009' then
		let _prima_xl = _prima_suscrita * (4.9 / 100);
		if _fecha_emision >= '01/05/2000' then
			let _prima_contrato =  (_prima_suscrita - _prima_xl) * (60 / 100);
		else
			let _prima_contrato =  (_prima_suscrita - _prima_xl) * (85 / 100);
		end if
	elif _cod_subramo = '007' then
		let _prima_xl = _prima_suscrita * (4.9 / 100);
		if _fecha_emision >= '01/05/2000' then
			let _prima_contrato =  (_prima_suscrita - _prima_xl) * (60 / 100);
		else
			let _prima_contrato =  (_prima_suscrita - _prima_xl) * (85 / 100);
		end if
	elif _cod_subramo = '008' then
		let _prima_xl = _prima_suscrita * (4.9 / 100);
		if _fecha_emision >= '01/05/2000' then
			let _prima_contrato =  (_prima_suscrita - _prima_xl) * (60 / 100);
		else
			let _prima_contrato =  (_prima_suscrita - _prima_xl) * (85 / 100);
		end if
	elif _cod_subramo = '003' then
		let _prima_xl = _prima_suscrita * (19 / 100);
		let _prima_contrato = (_prima_suscrita - _prima_xl) * (50 / 100);
	elif _cod_subramo = '004' then
		let _prima_xl = _prima_suscrita * (27.3 / 100);
		let _prima_contrato = (_prima_suscrita - _prima_xl) * (50 / 100);
	elif _cod_subramo = '006' then
		let _prima_xl = _prima_suscrita * (4.9 / 100);
		if _fecha_emision >= '01/05/2000' then
			let _prima_contrato =  (_prima_suscrita - _prima_xl) * (60 / 100);
		else
			let _prima_contrato =  (_prima_suscrita - _prima_xl) * (85 / 100);
		end if
	else
		let _prima_contrato = _prima_suscrita - _prima_retenida;
	end if

--	let _prima_contrato = _prima_suscrita - _prima_retenida;
--	let _mes = month(_vigencia_inic);

	if _prima_suscrita = 0 then
		let _porcentaje = 0;
	else
		let _porcentaje = _prima_contrato / (_prima_suscrita - _prima_xl) * 100;
	end if

	if _fecha_cancelacion is null then
		let _prima_cancel = 0;
	else
		let _prima_cancel = _prima_contrato;
	end if

	if _fecha_emision < '07/08/2000' then

		if   _mes = 5 then 
			let _meses_repo = 12;
		elif _mes = 6 then
			let _meses_repo = 11;
		elif _mes = 7 then
			let _meses_repo = 10;
		elif _mes = 8 then
			let _meses_repo = 9;
		elif _mes = 9 then
			let _meses_repo = 8;
		elif _mes = 10 then
			let _meses_repo = 7;
		elif _mes = 11 then
			let _meses_repo = 6;
		elif _mes = 12 then
			let _meses_repo = 5;
		elif _mes = 1 then
			let _meses_repo = 4;
		elif _mes = 2 then
			let _meses_repo = 3;
		elif _mes = 3 then
			let _meses_repo = 2;
		elif _mes = 4 then
			let _meses_repo = 1;
		end if

		let _meses_no_repo = 12 - _meses_repo;
		let _monto         = _prima_contrato / 12;
		let _monto_xl      = _prima_xl / 12;

	else

		let _meses_repo    = 1;
		let _meses_no_repo = 0;
		let _monto         = _prima_contrato;
		let _monto_xl      = _prima_xl;

	end if

	let _prima_repo    = _monto * _meses_repo;
	let _prima_no_repo = _monto * _meses_no_repo;
	let _prima_xl      = _monto_xl * _meses_repo;
	let _prima_xl_no   = _monto_xl * _meses_no_repo;

	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo    = '018'
	   and cod_subramo = _cod_subramo;

	RETURN _no_documento,
	       _vigencia_inic,
		   _vigencia_final,
		   _fecha_emision,
		   _prima_contrato,
		   _meses_repo,
		   _prima_repo,
		   _meses_no_repo,
		   _prima_no_repo,
		   _prima_suscrita,
		   _porcentaje,
		   _prima_xl,
		   _cod_subramo,
		   _nombre_subramo,
		   _mes,
		   _prima_xl_no,
		   _order
		   with resume;

end foreach

END PROCEDURE;
