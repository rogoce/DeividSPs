-- Procedimiento que carga los datos para presupuesto del 2010 por ramo
 
-- 27/11/2009 - Autor: Armando Moreno M.

drop procedure sp_preram10;

create procedure "informix".sp_preram10()
returning integer,
		  char(100);

define _cod_ramo		char(3);
define _tipo_mov		char(2);
define _no_poliza		char(10);
define _periodo			char(7);
define _p_sus_cont      dec(16,2);
define _error_desc		char(100);
define _total_2009 		dec(16,2);

let _tipo_mov   = "8";

foreach

	 SELECT	d.no_poliza,
	        d.prima_neta,
			d.periodo
	   INTO	_no_poliza,
		    _p_sus_cont,
		    _periodo
	   FROM	cobredet d, cobremae m
	  WHERE	d.cod_compania = '001'
	    AND d.actualizado  = 1
		AND d.tipo_mov     IN ('P','N')
		AND d.periodo >= "2008-11"
		AND d.periodo <= "2009-10"
		AND d.no_remesa    = m.no_remesa
		AND m.tipo_remesa  IN ('A', 'M', 'C')
      ORDER BY d.fecha,d.no_recibo,d.no_poliza

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	-- Movimientos Mensuales

	if _periodo[6,7] = "01" then

		update preram2010
		   set ene          = ene + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "02" then

		update preram2010
		   set feb          = feb + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "03" then

		update preram2010
		   set mar          = mar + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "04" then

		update preram2010
		   set abr          = abr + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "05" then

		update preram2010
		   set may          = may + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "06" then

		update preram2010
		   set jun          = jun + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "07" then

		update preram2010
		   set jul          = jul + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "08" then

		update preram2010
		   set ago          = ago + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "09" then

		update preram2010
		   set sep          = sep + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "10" then

		update preram2010
		   set oct          = oct + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "11" then

		update preram2010
		   set nov          = nov + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "12" then

		update preram2010
		   set dic          = dic + _p_sus_cont
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	end if

end foreach

foreach
 select cod_ramo,
		tipo_mov,
		(ene + feb + mar + abr + may + jun + jul + ago + sep + oct + nov + dic)
   into _cod_ramo,
		_tipo_mov,
		_total_2009
   from preram2010
  where tipo_mov = '8'
   order by 1,2

	update preram2010
	   set total_2009   = _total_2009
	 where cod_ramo     = _cod_ramo
	   and tipo_mov     = _tipo_mov;

end foreach	 

return 0, "Actualizacion Exitosa";

end procedure