-- Procedure que ajusta la reserva de acuerdo a parametros

-- Creado    : 29/12/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec242;

create procedure sp_rec242()
returning char(3),
		  char(20),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);


define _periodo			char(7);
define v_filtros		char(255);

define _reserva_tot		dec(16,2);
define _reserva_bru		dec(16,2);
define _reserva_aju		dec(16,2);
define _reserva_fin		dec(16,2);

define _porc_ajust		dec(16,2);

define _no_reclamo		char(10);
define _no_poliza		char(10);
define _cod_ramo		char(3);
define _numrecla		char(20);

define _cant			smallint;
define _cod_cobertura	char(5);
define _perd_total		smallint;

define _id				integer;
define _ajustado    	smallint;

define _error			integer;
define _error_desc		char(50);

let _periodo = "2014-12";

{
call sp_rec02(
"001", 
"001", 
_periodo,
'*',
'*',
'*',
'002,020;',
'*'
) returning v_filtros; 

foreach 
 select no_reclamo,		
 		no_poliza,			
	    reserva_total, 	
	    reserva_bruto, 	
		cod_ramo,		
		numrecla
   into	_no_reclamo, 		
   		_no_poliza,	   	
	    _reserva_tot,		
	    _reserva_bru,		
		_cod_ramo,			
		_numrecla
   from tmp_sinis 
  where seleccionado = 1
  order by cod_ramo, numrecla

	select perd_total
	  into _perd_total
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	-- No incluye las perdidas totales

	if _perd_total = 1 then
		continue foreach;
	end if

	call sp_rec723(_numrecla) returning _error, _error_desc;

--	if _error = 1 and _reserva_tot > 200 then
--		let _error = 0;
--	end if

	-- Proceso de Ajuste

	if _cod_ramo = "002" then
		
		let _porc_ajust = 10;

	elif _cod_ramo = "020" then

		let _porc_ajust = 50;

	end if

	if _reserva_tot <= 10 then

		let _reserva_aju = _reserva_tot; 

	else

		let _reserva_aju = _reserva_tot * _porc_ajust / 100; 

	end if

	let _reserva_fin = _reserva_tot - _reserva_aju;
}

--begin work;

let _cant = 0;

foreach 
 select id,
		reclamo,
		ramo,		
	    total, 	
		ajuste,
		final,
		ajustado
   into	_id,
		_numrecla,
		_cod_ramo,			
        _reserva_tot,
        _reserva_aju,		
	    _reserva_fin,
	    _ajustado		
   from deivid_tmp:tmp_reservas2014
--  where ajustado = 0
--    and id       = 2
  order by id

	{
	let _cant = _cant + 1;

	select no_reclamo
	  into _no_reclamo
	  from recrcmae
	 where numrecla = _numrecla;

	select sum(variacion)
	  into _reserva_bru
	  from rectrmae
	 where no_reclamo  = _no_reclamo
	   and actualizado = 1;

	-- Proceso para determinar la cobertura

	let _cod_cobertura = null;

	foreach
	 select cod_cobertura	    
	   into _cod_cobertura	    
	   from recrccob
	  where no_reclamo      = _no_reclamo 
	    and reserva_actual >= _reserva_aju

		exit foreach;

	end foreach

	if _reserva_aju > _reserva_bru then

		let _ajustado = 2;

	else

		call sp_rec223(_no_reclamo, _reserva_aju, _cod_cobertura) returning _error, _error_desc;  

		if _error = 0 then

			let _ajustado = 1;

		else

			let _ajustado = 3;

		end if

	end if

	update deivid_tmp:tmp_reservas2014
	   set ajustado = _ajustado
	 where id       = _id;
	}

	return _ajustado,
	       _numrecla,
		   _reserva_tot,
		   _id,
		   _reserva_aju,
		   _reserva_fin
		   with resume;

--	if _cant > 100 then
--		exit foreach;
--	end if

end foreach

--commit work;

end procedure
