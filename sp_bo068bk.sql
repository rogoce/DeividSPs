-- Procedimiento que carga los datos para el presupuesto del 2013
 
-- Creado     :	27/10/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo068;		

create procedure "informix".sp_bo068()
returning integer,
		  char(100);

define _cod_vendedor	char(3);
define _cod_ramo		char(3);
define _tipo_mov		char(1);
define _tipo_poliza		char(1);
define _cod_agente		char(5);

define _nueva_renov		char(1);
define _vigencia_inic	date;
define _vigencia_final	date;

define _no_poliza		char(10);
define _no_endoso		char(5);
define _periodo			char(7);
define _prima_suscrita	dec(16,2); 
define _cod_endomov		char(3);
define _cod_contrato	char(5);
define _fronting		smallint;

define _periodo1		char(7);
define _periodo2		char(7);
define _periodo3		char(7);
define _periodo4		char(7);

define _error_desc		char(100);

let _periodo1 = "2014-10";  --"2012-0";   --"2011-11";    --"2013-09";
let _periodo2 = "2015-09";  --"2013-10";   --"2012-10";  --"2014-08";

let _periodo3 = "2013-10";  --"2012-01";  --"2011-01";   --"2013-01";
let _periodo4 = "2014-09";  --"2012-12";  --"2011-12";   --"2013-12";

-- Produccion del Periodo Actual

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
     and periodo      >= _periodo1
	 and periodo      <= _periodo2
	--and no_documento <> '1409-00122-01'

	select nueva_renov,
	       cod_ramo,
		   vigencia_inic,
		   fronting
	  into _nueva_renov,
	       _cod_ramo,
		   _vigencia_inic,
		   _fronting
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo = "008" then
		continue foreach;
	end if

	if _fronting = 1 then
		continue foreach;
	end if

	call sp_bo070(_no_poliza) returning _cod_vendedor, _cod_agente, _error_desc;

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

	-- Unificar las Nuevas y Cancelaciones

	if _tipo_poliza = "1" and _tipo_mov = "2" then
		let _tipo_mov = "1";
	end if

	-- Movimientos Mensuales

	if _periodo[6,7] = "01" then

		update sac999:preven2010
		   set ene          = ene + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza
		   and cod_agente   = _cod_agente;

	elif _periodo[6,7] = "02" then

		update sac999:preven2010
		   set feb          = feb + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza
		   and cod_agente   = _cod_agente;

	elif _periodo[6,7] = "03" then

		update sac999:preven2010
		   set mar          = mar + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza
		   and cod_agente   = _cod_agente;

	elif _periodo[6,7] = "04" then

		update sac999:preven2010
		   set abr          = abr + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza
		   and cod_agente   = _cod_agente;

	elif _periodo[6,7] = "05" then

		update sac999:preven2010
		   set may          = may + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza
		   and cod_agente   = _cod_agente;

	elif _periodo[6,7] = "06" then

		update sac999:preven2010
		   set jun          = jun + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza
		   and cod_agente   = _cod_agente;

	elif _periodo[6,7] = "07" then

		update sac999:preven2010
		   set jul          = jul + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza
		   and cod_agente   = _cod_agente;

	elif _periodo[6,7] = "08" then

		update sac999:preven2010
		   set ago          = ago + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza
		   and cod_agente   = _cod_agente;

	elif _periodo[6,7] = "09" then

		update sac999:preven2010
		   set sep          = sep + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza
		   and cod_agente   = _cod_agente;

	elif _periodo[6,7] = "10" then

		update sac999:preven2010
		   set oct          = oct + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza
		   and cod_agente   = _cod_agente;

	elif _periodo[6,7] = "11" then

		update sac999:preven2010
		   set nov          = nov + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza
		   and cod_agente   = _cod_agente;

	elif _periodo[6,7] = "12" then

		update sac999:preven2010
		   set dic          = dic + _prima_suscrita
		 where cod_vendedor = _cod_vendedor
		   and cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov
		   and tipo_poliza  = _tipo_poliza
		   and cod_agente   = _cod_agente;

	end if

end foreach

-- Produccion del Periodo Anterior

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
     and periodo      >= _periodo3
	 and periodo      <= _periodo4

	select nueva_renov,
	       cod_ramo,
		   vigencia_inic,
		   fronting
	  into _nueva_renov,
	       _cod_ramo,
		   _vigencia_inic,
		   _fronting
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo = "008" then
		continue foreach;
	end if

	if _fronting = 1 then
		continue foreach;
	end if

	call sp_bo070(_no_poliza) returning _cod_vendedor, _cod_agente, _error_desc;

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

	-- Unificar las Nuevas y Cancelaciones

	if _tipo_poliza = "1" and _tipo_mov = "2" then
		let _tipo_mov = "1";
	end if

	-- Movimiento Anual

	update sac999:preven2010
	   set total_2008   = total_2008 + _prima_suscrita
	 where cod_vendedor = _cod_vendedor
	   and cod_ramo     = _cod_ramo
	   and tipo_mov     = _tipo_mov
	   and tipo_poliza  = _tipo_poliza
	   and cod_agente   = _cod_agente;

end foreach

return 0, "Actualizacion Exitosa";

end procedure