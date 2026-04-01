-- Procedimiento que carga los datos para presupuesto del 2010 por ramo
 
-- 17/11/2009 - Autor: Armando Moreno M.

drop procedure sp_preram1;

create procedure "informix".sp_preram1()
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


foreach
  select no_poliza,
         no_endoso,
		 periodo,
         prima_suscrita,
		 cod_endomov,
		 vigencia_final,
		 prima_retenida
    into _no_poliza,
	     _no_endoso,
		 _periodo,
         _prima_suscrita,
         _cod_endomov,
         _vigencia_final,
         _prima_retenida
    from endedmae
   where actualizado  = 1
     and periodo      >= "2008-11"
	 and periodo      <= "2009-10"

	let _tipo_mov   = "";
	let _p_sus_cont = 0;
	let _p_ced      = 0;
	let _p_ced_tot  = 0;

	foreach
	 select cod_contrato,
	        prima
	   into _cod_contrato,
	        _p_sus
	   from emifacon
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso

		select fronting,
		       tipo_contrato
		  into _fronting,
		       _tipo_contrato
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _tipo_contrato = 1 then --retencion
			continue foreach;
		else

			if _tipo_contrato = 3 then --facultativo
				let _tipo_mov = "3";
				let _p_sus_cont = _p_sus_cont + _p_sus;
				if _fronting = 1 then
					let _tipo_mov = "4";
				end if
			else
				let _p_ced = _p_ced + _p_sus;
			end if

		end if

	end foreach

	let _p_ced_tot = _p_ced + _p_sus_cont;

	select nueva_renov,
	       cod_ramo,
		   vigencia_inic
	  into _nueva_renov,
	       _cod_ramo,
		   _vigencia_inic
	  from emipomae
	 where no_poliza = _no_poliza;


	-- Movimientos Mensuales

	if _periodo[6,7] = "01" then

		update preram2010
		   set ene          = ene + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

		update preram2010
		   set ene          = ene + _prima_suscrita
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '1';

		update preram2010
		   set ene          = ene + _prima_retenida
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '2';

		update preram2010
		   set ene          = ene + _p_ced_tot
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '5';


	elif _periodo[6,7] = "02" then

		update preram2010
		   set feb          = feb + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

		update preram2010
		   set feb          = feb + _prima_suscrita
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '1';

		update preram2010
		   set feb          = feb + _prima_retenida
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '2';

		update preram2010
		   set feb          = feb + _p_ced_tot
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '5';



	elif _periodo[6,7] = "03" then

		update preram2010
		   set mar          = mar + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

		update preram2010
		   set mar          = mar + _prima_suscrita
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '1';

		update preram2010
		   set mar          = mar + _prima_retenida
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '2';

		update preram2010
		   set mar          = mar + _p_ced_tot
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '5';

	elif _periodo[6,7] = "04" then

		update preram2010
		   set abr          = abr + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

		update preram2010
		   set abr          = abr + _prima_suscrita
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '1';

		update preram2010
		   set abr          = abr + _prima_retenida
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '2';

		update preram2010
		   set abr          = abr + _p_ced_tot
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '5';

	elif _periodo[6,7] = "05" then

		update preram2010
		   set may          = may + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

		update preram2010
		   set may          = may + _prima_suscrita
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '1';

		update preram2010
		   set may          = may + _prima_retenida
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '2';

		update preram2010
		   set may          = may + _p_ced_tot
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '5';

	elif _periodo[6,7] = "06" then

		update preram2010
		   set jun          = jun + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

		update preram2010
		   set jun          = jun + _prima_suscrita
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '1';

		update preram2010
		   set jun          = jun + _prima_retenida
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '2';

		update preram2010
		   set jun          = jun + _p_ced_tot
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '5';

	elif _periodo[6,7] = "07" then

		update preram2010
		   set jul          = jul + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

		update preram2010
		   set jul          = jul + _prima_suscrita
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '1';

		update preram2010
		   set jul          = jul + _prima_retenida
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '2';

		update preram2010
		   set jul          = jul + _p_ced_tot
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '5';

	elif _periodo[6,7] = "08" then

		update preram2010
		   set ago          = ago + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

		update preram2010
		   set ago          = ago + _prima_suscrita
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '1';

		update preram2010
		   set ago          = ago + _prima_retenida
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '2';

		update preram2010
		   set ago          = ago + _p_ced_tot
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '5';

	elif _periodo[6,7] = "09" then

		update preram2010
		   set sep          = sep + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

		update preram2010
		   set sep          = sep + _prima_suscrita
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '1';

		update preram2010
		   set sep          = sep + _prima_retenida
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '2';

		update preram2010
		   set sep          = sep + _p_ced_tot
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '5';

	elif _periodo[6,7] = "10" then

		update preram2010
		   set oct          = oct + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

		update preram2010
		   set oct          = oct + _prima_suscrita
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '1';

		update preram2010
		   set oct          = oct + _prima_retenida
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '2';

		update preram2010
		   set oct          = oct + _p_ced_tot
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '5';

	elif _periodo[6,7] = "11" then

		update preram2010
		   set nov          = nov + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

		update preram2010
		   set nov          = nov + _prima_suscrita
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '1';

		update preram2010
		   set nov          = nov + _prima_retenida
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '2';

		update preram2010
		   set nov          = nov + _p_ced_tot
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '5';


	elif _periodo[6,7] = "12" then

		update preram2010
		   set dic          = dic + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

		update preram2010
		   set dic          = dic + _prima_suscrita
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '1';

		update preram2010
		   set dic          = dic + _prima_retenida
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '2';

		update preram2010
		   set dic          = dic + _p_ced_tot
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = '5';

	end if


end foreach

return 0, "Actualizacion Exitosa";

end procedure