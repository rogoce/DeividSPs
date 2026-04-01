-- Procedimiento que carga los datos para el presupuesto del 2010
 
-- Creado     :	27/10/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo065;		

create procedure "informix".sp_bo065()
returning integer,
		  char(100);

define _cod_vendedor	char(3);
define _cod_ramo		char(3);
define _tipo_mov		char(1);
define _tipo_poliza		char(1);

define _nueva_renov		char(1);
define _vigencia_inic	date;
define _vigencia_final	date;

define _no_poliza		char(10);
define _no_endoso		char(5);
define _periodo			char(7);
define _prima_suscrita	dec(16,2); 
define _cod_endomov		char(3);
define _cod_contrato	char(5);
define _tipo_contrato	smallint;
define _fronting		smallint;

define _error_desc		char(100);

-- Produccion del 2009

foreach
  select no_poliza,
         no_endoso,
		 periodo,
         prima_suscrita,
		 cod_endomov,
		 vigencia_final
    into _no_poliza,
	     _no_endoso,
		 _periodo,
         _prima_suscrita,
         _cod_endomov,
         _vigencia_final		
    from endedmae
   where actualizado  = 1
     and periodo      >= "2008-11"
	 and periodo      <= "2009-10"

	foreach
	 select cod_contrato
	   into _cod_contrato
	   from emifacon
	  where no_poliza         = _no_poliza
	    and no_endoso         = _no_endoso
		and porc_partic_prima <> 0.00

		select tipo_contrato
		  into _tipo_contrato
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _tipo_contrato = 3 then
			exit foreach;
		end if

	end foreach

	if _tipo_contrato = 3 then
		continue foreach;
	end if

	select nueva_renov,
	       cod_ramo,
		   vigencia_inic
	  into _nueva_renov,
	       _cod_ramo,
		   _vigencia_inic
	  from emipomae
	 where no_poliza = _no_poliza;

	call sp_bo066(_no_poliza) returning _cod_vendedor, _error_desc;

	if _cod_vendedor = "XXX" then
		return 1, _error_desc;
	end if

	-- Nueva o Renovada

	if _cod_ramo = "018" then

		if (_vigencia_final - _vigencia_inic) > 365 then
			let _tipo_poliza = "2";
		else
			let _tipo_poliza = "1";
		end if
		
	else

		if _nueva_renov = "N" then
			let _tipo_poliza = "1";
		else
			let _tipo_poliza = "2";
		end if

	end if

	-- Poliza o Cancelacion

	if _cod_endomov = "002" then
		let _tipo_mov = "2";
	else
		let _tipo_mov = "1";
	end if

	-- Movimientos Mensuales

	if _periodo[6,7] = "01" then

		update sac999:presup2010
		   set ene          = ene + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza;

	elif _periodo[6,7] = "02" then

		update sac999:presup2010
		   set feb          = feb + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza;

	elif _periodo[6,7] = "03" then

		update sac999:presup2010
		   set mar          = mar + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza;

	elif _periodo[6,7] = "04" then

		update sac999:presup2010
		   set abr          = abr + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza;

	elif _periodo[6,7] = "05" then

		update sac999:presup2010
		   set may          = may + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza;

	elif _periodo[6,7] = "06" then

		update sac999:presup2010
		   set jun          = jun + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza;

	elif _periodo[6,7] = "07" then

		update sac999:presup2010
		   set jul          = jul + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza;

	elif _periodo[6,7] = "08" then

		update sac999:presup2010
		   set ago          = ago + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza;

	elif _periodo[6,7] = "09" then

		update sac999:presup2010
		   set sep          = sep + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza;

	elif _periodo[6,7] = "10" then

		update sac999:presup2010
		   set oct          = oct + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza;

	elif _periodo[6,7] = "11" then

		update sac999:presup2010
		   set nov          = nov + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza;

	elif _periodo[6,7] = "12" then

		update sac999:presup2010
		   set dic          = dic + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza;

	end if

end foreach

-- Produccion del 2008

foreach
  select no_poliza,
         no_endoso,
		 periodo,
         prima_suscrita,
		 cod_endomov,
		 vigencia_final
    into _no_poliza,
	     _no_endoso,
		 _periodo,
         _prima_suscrita,
         _cod_endomov,
         _vigencia_final		
    from endedmae
   where actualizado  = 1
     and periodo      >= "2008-01"
	 and periodo      <= "2008-12"

	foreach
	 select cod_contrato
	   into _cod_contrato
	   from emifacon
	  where no_poliza         = _no_poliza
	    and no_endoso         = _no_endoso
		and porc_partic_prima <> 0.00

		select tipo_contrato
		  into _tipo_contrato
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _tipo_contrato = 3 then
			exit foreach;
		end if

	end foreach

	if _tipo_contrato = 3 then
		continue foreach;
	end if

	select nueva_renov,
	       cod_ramo,
		   vigencia_inic
	  into _nueva_renov,
	       _cod_ramo,
		   _vigencia_inic
	  from emipomae
	 where no_poliza = _no_poliza;

	call sp_bo066(_no_poliza) returning _cod_vendedor, _error_desc;

	if _cod_vendedor = "XXX" then
		return 1, _error_desc;
	end if

	-- Nueva o Renovada

	if _cod_ramo = "018" then

		if (_vigencia_final - _vigencia_inic) > 365 then
			let _tipo_poliza = "2";
		else
			let _tipo_poliza = "1";
		end if
		
	else

		if _nueva_renov = "N" then
			let _tipo_poliza = "1";
		else
			let _tipo_poliza = "2";
		end if

	end if

	-- Poliza o Cancelacion

	if _cod_endomov = "002" then
		let _tipo_mov = "2";
	else
		let _tipo_mov = "1";
	end if

	-- Movimiento Anual

	update sac999:presup2010
	   set total_2008   = total_2008 + _prima_suscrita
	 where cod_vendedor = _cod_vendedor
	   and cod_ramo     = _cod_ramo
	   and tipo_mov     = _tipo_mov
	   and tipo_poliza  = _tipo_poliza;

end foreach

return 0, "Actualizacion Exitosa";

end procedure