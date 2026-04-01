-- Cambio en distribucion de reaseguro, 	PRODUCCION
-- 
-- Creado     : 17/11/2021 - Autor: Amado Perez M
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_reainv6;

create procedure sp_reainv6()
 returning integer,
           char(200);

define _cod_endomov		char(3);
define _cod_tipocan		char(3);
define _cod_tipocalc	char(3);

define _null			char(1);
define _periodo			char(7);
define _no_endoso_int	smallint;
define _no_endoso		char(5);
define _no_endoso_ext	char(5);
define _tiene_impuesto	smallint;
define _cantidad		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _descripcion		char(200);

define _prima_suscrita	dec(16,2);
define _prima_retenida 	dec(16,2);
define _prima 			dec(16,2);
define _descuento		dec(16,2);
define _recargo			dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _prima_bruta		dec(16,2);
define _suma_asegurada	dec(16,2);
define _suma_impuesto	dec(16,2);
define _factor_impuesto	dec(16,2);
define _cod_impuesto	char(3);
define _no_documento    char(20);
define _no_factura      char(10);
define li_return        integer;
define _no_poliza		char(10);
define _vigencia_inic	date;
define _vigencia_final	date;
define _no_unidad       char(5);
define _cnt             smallint;
define _periodo2        char(7);
define _ruta            char(5);
define _cod_ramo        char(3);
define _cod_cober_reas  char(3);
DEFINE _porc_partic_suma, _porc_partic_prima  DECIMAL(10,4);
define _tipo            smallint;
define _cant            integer;
define _cod_ruta        char(5);
define _serie           smallint;
define _suma_asegurada_t dec(16,2);
define _pri_ret_uni     dec(16,2);
define _pri_ret_end     dec(16,2);
define _pri_ret         dec(16,2);
define _no_remesa       char(10);
define _renglon         integer;
define _sac_notrx       integer;


--set debug file to "sp_sis119bk.trc";
--set debug file to "sp_reainv2.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc;
end exception

set isolation to dirty read;

let _suma_asegurada = 0;
let _suma_asegurada_t = 0;

let _cantidad   = 0;
--let _periodo2   = "2014-11";
let _porc_partic_suma  = 0;
let _porc_partic_prima = 0;


-- Pólizas con suma menor o igual a 500,000

foreach WITH HOLD
	select no_poliza,
		   periodo,
	       tipo
	  into _no_poliza,
	       _periodo,
	       _tipo
	  from camrea
	 where actualizado = 0
	--   and no_documento = '0321-00120-01'
	   and tipo = 1
	 order by 1,3,2
  
	select serie,
	  	   cod_ramo
	  into _serie,
	   	   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;
	  
	select cod_ruta
	  into _cod_ruta
	  from rearumae
	 where cod_compania = '001'
	   and cod_ramo = _cod_ramo
	   and serie = _serie
	   and activo = 1;
		   
    let _error = 0;

	begin work;
	
    -- Corrigiendo distribución de reaseguro en endosos	
	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza
	 
	    delete from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;	

        delete from emireama		   
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and no_cambio > 0;	
		   
		insert into emireaco (
		  no_poliza,
		  no_unidad,
		  no_cambio,
		  cod_cober_reas,
		  orden,
		  cod_contrato,
		  porc_partic_suma,
		  porc_partic_prima)
		select _no_poliza,
		       _no_unidad,
			   0,
			   a.cod_cober_reas,
			   a.orden,
			   a.cod_contrato,
			   100.00,
			   100.00
		  from rearucon a, reacomae b
         where a.cod_contrato = b.cod_contrato
           and a.cod_ruta = _cod_ruta
           and b.tipo_contrato = 1;	
		   
		foreach 
		    select no_endoso 
              into _no_endoso
              from endedmae
             where no_poliza = _no_poliza
               and periodo >= '2021-06'
			   and cod_endomov <> '015'

            delete from emigloco
             where no_poliza = _no_poliza
			   and no_endoso = _no_endoso;			

			foreach
				select suma_asegurada
				  into _suma_asegurada
				  from endeduni
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				   and no_endoso = _no_endoso
			  
				let _error = sp_proe04bcam(_no_poliza, _no_unidad, _suma_asegurada, _no_endoso, _cod_ruta); --Procedure que crea el reaseguro emifacon
				
				if _error <> 0 THEN
					rollback work;
					exit foreach;
				end if
				--Actualizando prima retenida unidades
				let _pri_ret_uni = 0.00;
				select sum(r.prima)
				  into _pri_ret_uni
				  from emifacon r, reacomae t
				 where r.cod_contrato = t.cod_contrato
				   and r.no_poliza = _no_poliza
				   and r.no_endoso = _no_endoso
				   and r.no_unidad = _no_unidad
				   and t.tipo_contrato = 1;

				update endeduni
				   set prima_retenida = _pri_ret_uni
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				   and no_unidad = _no_unidad;
			end foreach	
			
			if _error <> 0 THEN
				exit foreach;
			end if
						
			--Verificar esto cuando es en dataserver
--			 FOREACH
--				select distinct sac_notrx 
--				  into _sac_notrx
--				from sac999:reacompasie where no_registro in (
--				select no_registro from sac999:reacomp 
--				 where no_poliza     = _no_poliza
--				   and no_endoso     = _no_endoso
--				   and periodo       = '2021-11'
--				   and tipo_registro = 1)
				   
--				call sp_sac77a(_sac_notrx) returning _error, _error_desc;   
--				if _error <> 0 THEN
--					exit foreach;
--				end if
--			 END FOREACH

			if _error <> 0 THEN
				rollback work;
				continue foreach;
			end if
				   
			--Actualizando prima retenida de endedmae y endedhis
			let _pri_ret_end = 0.00;
			select sum(r.prima)
			  into _pri_ret_end
			  from emifacon r, reacomae t
			 where r.cod_contrato = t.cod_contrato
			   and r.no_poliza = _no_poliza
			   and r.no_endoso = _no_endoso
			   and t.tipo_contrato = 1;
			   
			update endedmae
			   set prima_retenida = _pri_ret_end
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso;
			   
			update endedhis
			   set prima_retenida = _pri_ret_end
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso;
		end foreach
		--Actualizando prima retenida de emipouni
		let _pri_ret_uni = 0.00;
		select sum(r.prima)
		  into _pri_ret_uni
		  from emifacon r, reacomae t
		 where r.cod_contrato = t.cod_contrato
		   and r.no_poliza = _no_poliza
		   and r.no_unidad = _no_unidad
		   and t.tipo_contrato = 1;
		   
		update emipouni
		   set prima_retenida = _pri_ret_uni
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;
    end foreach   		

	if _error <> 0 THEN
		continue foreach;
	end if
	--Actualizando prima retenida de emipomae
	let _pri_ret = 0.00;
	select sum(r.prima)
	  into _pri_ret
	  from emifacon r, reacomae t
	 where r.cod_contrato = t.cod_contrato
	   and r.no_poliza = _no_poliza
	   and t.tipo_contrato = 1;
	   
	update emipomae
	   set prima_retenida = _pri_ret
	 where no_poliza = _no_poliza;
	 
    -- Corrigiendo distribución de reaseguro en remesas	
	foreach
		select no_remesa,
		       renglon
	      into _no_remesa,
               _renglon
          from cobredet
         where no_poliza = _no_poliza
           and tipo_mov   in ('P','N')
           and periodo >= '2021-06'
         order by renglon
	  
	    call sp_sis171bk(_no_remesa, _renglon) returning _error, _error_desc; --Procedure que crea el reaseguro cobreaco
		
--	    if _error = 0 then
--			 FOREACH
--				select distinct sac_notrx 
--				  into _sac_notrx
--				from sac999:reacompasie where no_registro in (
--				select no_registro from sac999:reacomp 
--				 where no_remesa     = _no_remesa
--			       and renglon       = _renglon
--				   and periodo       = '2021-11'
--			       and tipo_registro = 2)
				   
--				call sp_sac77a(_sac_notrx) returning _error, _error_desc;   
--				if _error <> 0 THEN
--					exit foreach;
--				end if
--			 END FOREACH
--        end if		

		if _error <> 0 THEN
			rollback work;
			continue foreach;
		end if
		   
	end foreach
	
	update camrea
	   set actualizado = 1
	 where no_poliza = _no_poliza;

    let _cantidad = _cantidad + 1;

	commit work;

--	if _cantidad >= 1 then
--		exit foreach;
--	end if
end foreach
end

return 0, "Actualizacion Exitosa, " || _cantidad || " Registros Procesados";

end procedure