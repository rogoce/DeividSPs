--procedimiento para eliminar de la tabla salud_ren_rec, registros que no de ben tener el aumento.
--30/07/2024

DROP procedure sp_jean17v3;
CREATE procedure sp_jean17v3(a_periodo char(7),a_renov char(1))
RETURNING char(3),char(5),char(7),char(10),char(20),date;


DEFINE _no_poliza 	CHAR(10);
DEFINE _no_documento        CHAR(20);
define _periodo     char(7);
define _fecha_suscripcion date;
define _cnt,_cnt2,_sac_notrx,_error,_valor,_no_cambio    integer;
define _mensaje      char(50);
define _no_unidad    char(5);
define _cod_cober_reas char(3);
define _suma_asegurada,_prima_ret    dec(16,2);

let _mensaje = "";
let _suma_asegurada = 0.00;

foreach
	select no_poliza,
	       no_documento,
		   fecha_suscripcion,
		   periodo
	  into _no_poliza,
		   _no_documento,
		   _fecha_suscripcion,
		   _periodo
	  from emipomae
	 where actualizado = 1
       and cod_ramo in('023')
       and vigencia_inic >= '01/01/2025'
       and nueva_renov = a_renov
	 order by fecha_suscripcion
	 
	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza;
 
	foreach
		select no_unidad
		  into _no_unidad
		  from endeduni
		 where no_poliza = _no_poliza
           and no_endoso = '00000'
		  order by no_unidad 

		foreach
		
			select distinct cod_cober_reas
			  into _cod_cober_reas
			  from emireaco
			 where no_poliza = _no_poliza
			   and no_cambio = _no_cambio
			   and no_unidad = _no_unidad
			   
			select count(*)
			  into _cnt
			  from  prdcober p, endedcob e
			 where e.cod_cobertura = p.cod_cobertura
			   and e.no_poliza = _no_poliza
			   and e.no_endoso = '00000'
			   and e.no_unidad = _no_unidad
			   and p.cod_cober_reas = _cod_cober_reas;

			if _cnt is null then
				let _cnt = 0;
			end if
			
			if _cnt > 0 then
			else
			
				delete from emireaco
				 where no_poliza = _no_poliza
				   and no_cambio = _no_cambio
				   and no_unidad = _no_unidad
				   and cod_cober_reas = _cod_cober_reas;
				   
				return _cod_cober_reas,_no_unidad,_periodo,_no_poliza,_no_documento,_fecha_suscripcion with resume;
			end if
		end foreach
	end foreach
end foreach
return '','','','','','01/01/1900';
END PROCEDURE;
