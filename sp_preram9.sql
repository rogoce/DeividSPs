-- Procedimiento que carga los datos para presupuesto del 2010 por ramo
 
-- 24/11/2009 - Autor: Armando Moreno M.

drop procedure sp_preram9;

create procedure "informix".sp_preram9()
returning integer,
		  char(100);

define _cod_ramo		char(3);
define _tipo_mov		char(2);

define _nueva_renov		char(1);
define _vigencia_inic	date;
define _vigencia_final	date;

define _no_poliza		char(10);
define _no_endoso		char(5);
define _periodo			char(7);
define _prima_suscrita	dec(16,2);
define _p_sus_cont      dec(16,2);
define _p_sus           dec(16,2);
define _prima_retenida  dec(16,2);
define _cod_endomov		char(3);
define _cod_contrato	char(5);
define _fronting		smallint;
define _tipo_contrato   smallint;
define _error_desc		char(100);
define _p_ced_tot		dec(16,2);
define _p_ced 			dec(16,2);
define _monto_comision	dec(16,2);
define _total_2009      dec(16,2);
define _porc_ene		dec(16,5);
define _porc_feb		dec(16,5);
define _porc_mar		dec(16,5);
define _porc_abr		dec(16,5);
define _porc_may		dec(16,5);
define _porc_jun		dec(16,5);
define _porc_jul		dec(16,5);
define _porc_ago		dec(16,5);
define _porc_sep		dec(16,5);
define _porc_oct		dec(16,5);
define _porc_nov		dec(16,5);
define _porc_dic		dec(16,5);
define _ene2			dec(16,2);
define _feb2			dec(16,2);
define _mar2			dec(16,2);
define _abr2			dec(16,2);
define _may2			dec(16,2);
define _jun2			dec(16,2);
define _jul2			dec(16,2);
define _ago2			dec(16,2);
define _sep2			dec(16,2);
define _oct2			dec(16,2);
define _nov2			dec(16,2);
define _dic2			dec(16,2);
define _ene			    dec(16,2);
define _feb				dec(16,2);
define _mar				dec(16,2);
define _abr				dec(16,2);
define _may				dec(16,2);
define _jun				dec(16,2);
define _jul				dec(16,2);
define _ago				dec(16,2);
define _sep				dec(16,2);
define _oct				dec(16,2);
define _nov				dec(16,2);
define _dic				dec(16,2);
define _cod_cober_reas  char(3);
define _tiene_com		smallint;
define _porc_comision	decimal(5,2);
define _monto_contrato  dec(16,2);
define _porc_cont_partic decimal(9,6);
define _monto_comision_fin dec(16,2);
define _valor,_valor2   dec(16,2);
define _tipo_movi       char(1);
define v_doc_reclamo    char(30);
define v_no_remesa      char(10);
define _no_reclamo      char(10);
define _cod_tipotran    char(3);

FOREACH
 
	 SELECT monto,
	        no_reclamo,
			cod_tipotran,
			periodo
	   INTO _monto_comision,
	        _no_reclamo,
			_cod_tipotran,
			_periodo
	   FROM rectrmae
	  WHERE cod_compania = '001'
	    AND actualizado  = 1
		AND cod_tipotran IN ('005','006')
		AND periodo      >= '2008-11'
		AND periodo      <= '2009-10'
	    AND monto        <> 0

	 select no_poliza
	   into _no_poliza
	   from recrcmae
	  where no_reclamo = _no_reclamo;

		IF _cod_tipotran = '005' THEN --Salvamento;
			let _tipo_mov = "70";
		ELSE
			 --Recupero;
			let _tipo_mov = "72";
		END IF

	select cod_ramo,
		   vigencia_inic
	  into _cod_ramo,
		   _vigencia_inic
	  from emipomae
	 where no_poliza = _no_poliza;

	let _monto_comision = _monto_comision * -1;

	-- Movimientos Mensuales

	if _periodo[6,7] = "01" then

		update preram2010
		   set ene          = ene + _monto_comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "02" then

		update preram2010
		   set feb          = feb + _monto_comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "03" then

		update preram2010
		   set mar          = mar + _monto_comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "04" then

		update preram2010
		   set abr          = abr + _monto_comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "05" then

		update preram2010
		   set may          = may + _monto_comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "06" then

		update preram2010
		   set jun          = jun + _monto_comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "07" then

		update preram2010
		   set jul          = jul + _monto_comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "08" then

		update preram2010
		   set ago          = ago + _monto_comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "09" then

		update preram2010
		   set sep          = sep + _monto_comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "10" then

		update preram2010
		   set oct          = oct + _monto_comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "11" then

		update preram2010
		   set nov          = nov + _monto_comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "12" then

		update preram2010
		   set dic          = dic + _monto_comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	end if

end foreach

-- Totales Horizontales

foreach
 select cod_ramo,
		tipo_mov,
		(ene + feb + mar + abr + may + jun + jul + ago + sep + oct + nov + dic)
   into _cod_ramo,
		_tipo_mov,
		_total_2009
   from preram2010
  where tipo_mov = '70'
   order by 1,2

 update preram2010
    set total_2009   = _total_2009
  where cod_ramo     = _cod_ramo
    and tipo_mov     = _tipo_mov;

end foreach

foreach
 select cod_ramo,
		tipo_mov,
		(ene + feb + mar + abr + may + jun + jul + ago + sep + oct + nov + dic)
   into _cod_ramo,
		_tipo_mov,
		_total_2009
   from preram2010
  where tipo_mov = '72'
   order by 1,2

 update preram2010
    set total_2009   = _total_2009
  where cod_ramo     = _cod_ramo
    and tipo_mov     = _tipo_mov;

end foreach

return 0, "Actualizacion Exitosa";

end procedure