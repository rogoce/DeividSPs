-- Creado:     24/02/2026 - Autor Armando Moreno M.

drop procedure sp_arregla_emifacon_salud;
create procedure sp_arregla_emifacon_salud(a_periodo char(7))
returning integer;

define _error_desc			char(100);
define _error,_no_cambio,_valor,_error_isam		        integer;
define _no_tranrec,_no_reclamo,_no_poliza        char(10); 
define _cod_ruta,_no_unidad, _no_endoso           char(5);
define _cantidad,_renglon,_cant_ruta            smallint;
define _porc_suma,_porcentaje  dec(9,6);
define _cod_ramo,_cod_cober_reas  char(3);
define _vigencia_final,_vigencia_inic,_fecha_actual date;
define _mensaje 			varchar(250);
define _suma_asegurada,_prima_suscrita, _prima_retenida      dec(16,2);

--set debug file to "sp_arregla_emifacon_salud";
--trace on;

begin work;
begin
on exception set _error,_error_isam,_error_desc 
    rollback work;
 	return _error;
end exception

set isolation to dirty read;

foreach
	select e.vigencia_inic,
	       e.suma_asegurada,
           e.no_poliza,
           e.no_endoso,
           t.no_unidad
	  into _vigencia_inic,
	       _suma_asegurada,
		   _no_poliza,
		   _no_endoso,
		   _no_unidad
	  from endedmae e, emifacon t
     where e.no_poliza = t.no_poliza
       and e.no_endoso = t.no_endoso
       and e.actualizado = 1
       and e.periodo = a_periodo
       and e.no_documento[1,2] = '18'
       and t.porc_partic_prima not in(30,70)
	   
	let _valor = sp_arregla_emireaco_salud_1(_no_poliza, _no_endoso, _no_unidad);
	
	delete from emigloco
	 where no_poliza = _no_poliza
       and no_endoso = _no_endoso;
	  
	let _valor = sp_proe04b(_no_poliza, _no_unidad , _suma_asegurada, _no_endoso);
	
    if _valor = 0 then
		select sum(r.prima)
		  into _prima_retenida
		  from emifacon r, reacomae t
	  	 where r.cod_contrato = t.cod_contrato
		   and r.no_poliza = _no_poliza
		   and r.no_endoso = _no_endoso
		   and t.tipo_contrato = 1;  
			 
		update endedmae
		   set prima_retenida = _prima_retenida
		 where no_poliza    = _no_poliza
		   and no_endoso    = _no_endoso;  
		 
		update endedhis
		   set prima_retenida = _prima_retenida
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;  
		   
		update sac999:reacomp
		   set sac_asientos = 0
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and tipo_registro = 1;
	end if
 
end foreach
commit work;
return 0;
end
end procedure;