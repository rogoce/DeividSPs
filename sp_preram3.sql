-- Procedimiento que carga los datos para presupuesto del 2010 por ramo
 
-- 18/11/2009 - Autor: Armando Moreno M.

drop procedure sp_preram3;

create procedure "informix".sp_preram3()
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
define _incurrido_bruto dec(16,2);
define _incurrido_neto  dec(16,2);
define v_filtros        char(255);

-- Incurrido Neto y bruto

let _incurrido_bruto = 0;
let _incurrido_neto  = 0;


	CALL sp_preram4('001', '001', "2008-11", "2009-10") RETURNING v_filtros;

	foreach

		SELECT (pagado_bruto + reserva_bruto),
			   (pagado_neto  + reserva_neto),
			   periodo,
			   cod_ramo
		  INTO _incurrido_bruto,
		       _incurrido_neto,
			   _periodo,
			   _cod_ramo
		  FROM tmp_incurrid
	     where periodo     >= "2008-11"
		   and periodo     <= "2009-10"

		-- Movimientos Mensuales

		if _periodo[6,7] = "01" then

			update preram2010
			   set ene         = ene + _incurrido_bruto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '40';

			update preram2010
			   set ene         = ene + _incurrido_neto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '42';

		elif _periodo[6,7] = "02" then

			update preram2010
			   set feb         = feb + _incurrido_bruto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '40';

			update preram2010
			   set feb         = feb + _incurrido_neto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '42';



		elif _periodo[6,7] = "03" then

			update preram2010
			   set mar         = mar + _incurrido_bruto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '40';

			update preram2010
			   set mar         = mar + _incurrido_neto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '42';


		elif _periodo[6,7] = "04" then

			update preram2010
			   set abr         = abr + _incurrido_bruto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '40';

			update preram2010
			   set abr         = abr + _incurrido_neto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '42';


		elif _periodo[6,7] = "05" then

			update preram2010
			   set may         = may + _incurrido_bruto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '40';

			update preram2010
			   set may         = may + _incurrido_neto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '42';


		elif _periodo[6,7] = "06" then

			update preram2010
			   set jun         = jun + _incurrido_bruto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '40';

			update preram2010
			   set jun         = jun + _incurrido_neto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '42';


		elif _periodo[6,7] = "07" then

			update preram2010
			   set jul         = jul + _incurrido_bruto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '40';

			update preram2010
			   set jul         = jul + _incurrido_neto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '42';


		elif _periodo[6,7] = "08" then

			update preram2010
			   set ago         = ago + _incurrido_bruto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '40';

			update preram2010
			   set ago         = ago + _incurrido_neto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '42';


		elif _periodo[6,7] = "09" then

			update preram2010
			   set sep         = sep + _incurrido_bruto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '40';

			update preram2010
			   set sep         = sep + _incurrido_neto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '42';


		elif _periodo[6,7] = "10" then

			update preram2010
			   set oct         = oct + _incurrido_bruto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '40';

			update preram2010
			   set oct         = oct + _incurrido_neto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '42';


		elif _periodo[6,7] = "11" then

			update preram2010
			   set nov         = nov + _incurrido_bruto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '40';

			update preram2010
			   set nov         = nov + _incurrido_neto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '42';


		elif _periodo[6,7] = "12" then

			update preram2010
			   set dic         = dic + _incurrido_bruto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '40';

			update preram2010
			   set dic         = dic + _incurrido_neto
			 where cod_ramo    = _cod_ramo
			   and tipo_mov    = '42';

		end if


	end foreach

	DROP TABLE tmp_incurrid;

return 0, "Actualizacion Exitosa";

end procedure