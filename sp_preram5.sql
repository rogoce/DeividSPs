-- Procedimiento que carga los datos para presupuesto del 2010 por ramo
 
-- 19/11/2009 - Autor: Armando Moreno M.

drop procedure sp_preram5;

create procedure "informix".sp_preram5()
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
define _comision		dec(16,2);
define _mes_char        CHAR(2);
define _ano_char		CHAR(4);
define _fecha_genera    date;

let _tipo_mov = "50";

foreach

  select no_poliza,
         comision,
		 fecha_genera
    into _no_poliza,
	     _comision,
		 _fecha_genera
    from chqcomis
   where fecha_genera between "01/11/2008" and "31/10/2009"
     and no_requis is not null

	IF  MONTH(_fecha_genera) < 10 THEN
		LET _mes_char = '0'|| MONTH(_fecha_genera);
	ELSE
		LET _mes_char = MONTH(_fecha_genera);
	END IF

	LET _ano_char = YEAR(_fecha_genera);
	LET _periodo  = _ano_char || "-" || _mes_char;

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;


	-- Movimientos Mensuales

	if _periodo[6,7] = "01" then

		update preram2010
		   set ene          = ene + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "02" then

		update preram2010
		   set feb          = feb + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "03" then

		update preram2010
		   set mar          = mar + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "04" then

		update preram2010
		   set abr          = abr + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "05" then

		update preram2010
		   set may          = may + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "06" then

		update preram2010
		   set jun          = jun + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "07" then

		update preram2010
		   set jul          = jul + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "08" then

		update preram2010
		   set ago          = ago + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "09" then

		update preram2010
		   set sep          = sep + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "10" then

		update preram2010
		   set oct          = oct + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "11" then

		update preram2010
		   set nov          = nov + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	elif _periodo[6,7] = "12" then

		update preram2010
		   set dic          = dic + _comision
		 where cod_ramo     = _cod_ramo
		   and tipo_mov     = _tipo_mov;

	end if


end foreach

return 0, "Actualizacion Exitosa";

end procedure