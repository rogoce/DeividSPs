--procedimiento para eliminar de la tabla salud_ren_rec, registros que no de ben tener el aumento.
--30/07/2024

DROP procedure sp_jean17v2;
CREATE procedure sp_jean17v2(a_periodo char(7),a_renov char(1))
RETURNING char(7),char(10),char(20),date;


DEFINE _no_poliza 	CHAR(10);
DEFINE _no_documento        CHAR(20);
define _fecha_suscripcion date;
define _cnt,_cnt2,_sac_notrx,_error,_valor    integer;
define _mensaje      char(50);
define _no_unidad   char(5);
define _suma_asegurada,_prima_ret    dec(16,2);

let _mensaje = "";
let _suma_asegurada = 0.00;

foreach
	select no_poliza,
	       no_documento,
		   fecha_suscripcion
	  into _no_poliza,
		   _no_documento,
		   _fecha_suscripcion
	  from emipomae
	 where actualizado = 1
       and cod_ramo in('023')
       and periodo = a_periodo
       and nueva_renov = a_renov
	   and no_documento in ('2325-00003-01','2325-00004-01','2325-00001-01')
	 order by fecha_suscripcion
	 
	let _valor = 0;

		foreach
			select no_unidad,
			       suma_asegurada
			  into _no_unidad,
			       _suma_asegurada
			  from endeduni
			 where no_poliza = _no_poliza
			   and no_endoso = '00000'
			   
			select count(*)
			  into _cnt
			  from  prdcober p, emipocob e
			 where e.cod_cobertura = p.cod_cobertura
			   and e.no_poliza = _no_poliza
			   and e.no_unidad = _no_unidad
			   and p.cod_cober_reas = '047';
			   
			if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt > 0 then
				let _valor = sp_proe04v2(_no_poliza,_no_unidad,_suma_asegurada,'001');
				return a_periodo,_no_poliza,_no_documento,_fecha_suscripcion with resume;
			end if	
		end foreach
		
{		select det.sac_notrx
		  into _sac_notrx
		  from sac999:reacomp mae
		 inner join sac999:reacompasie det on det.no_registro = mae.no_registro
		 inner join sac999:reacompasiau aux on aux.no_registro = det.no_registro and aux.cuenta = det.cuenta
		 where mae.periodo = a_periodo
		   and mae.no_poliza = _no_poliza
		   and mae.no_endoso = '00000';
			   
		if _sac_notrx is not null then
			call sp_sac77(_sac_notrx) returning _error, _mensaje;
		end if
}		
		let _prima_ret = 0.00;
		if _valor = 0 then
			select sum(r.prima)
			  into _prima_ret
			  from emifacon r, reacomae t
			 where r.cod_contrato = t.cod_contrato
			   and r.no_poliza = _no_poliza
			   and r.no_endoso = '00000'
			   and t.tipo_contrato = 1;
			
			update endedmae
			   set prima_retenida = _prima_ret
			 where no_poliza = _no_poliza
			   and no_endoso = '00000';
			   
			update endedhis
			   set prima_retenida = _prima_ret
			 where no_poliza = _no_poliza
			   and no_endoso = '00000';
		end if
end foreach
return '','','','01/01/1900';
END PROCEDURE;
