-- creado: 19/05/2017 - Autor: Federico Coronado

drop procedure sp_end13;

create procedure "informix".sp_end13()
returning integer,
          char(1),
          char(30);  --21

define v_no_poliza          char(10);
define v_fecha_registro		date; 
define v_no_factura         varchar(15);
define v_vig_ini    		date;
define v_vig_fin    		date;
define v_cnt                integer;
define v_no_documento       varchar(20);
define v_count              smallint;
define v_sum_prima_neta     dec(16,2);
set isolation to dirty read;

--set debug file to "sp_end13.trc";
--trace on;

foreach
	select no_poliza,
		   no_documento,
		   fecha_registro,
		   vigencia_inic, 
		   vigencia_final,
		   sum(prima_neta)
      INTO v_no_poliza,
	       v_no_documento,
	       v_fecha_registro,
		   v_vig_ini,
		   v_vig_fin,
		   v_sum_prima_neta
	  from prdemielctdet
	 where cod_agente = '00180'
	   and fecha_registro = '22/05/2017'
	   and no_factura = ''
	   and actualizado <> 2
  group by 1,2,3,4,5
	   
	let v_cnt = 1;
	let v_no_factura = '';
	
		select count(*)
		  into v_count
		  from endedmae
		where no_poliza 	= v_no_poliza
		 and fecha_emision 	= '23/05/2017'
		 and no_documento   = v_no_documento
		 and cod_endomov in('006')
		 and user_added in('DEIVID','informix')
		 and prima_neta = v_sum_prima_neta;
		 
	if v_count is null then
		let v_count = 0;
	end if
	
	if v_count > 0 then
		foreach
			select no_factura
			  into v_no_factura
			  from endedmae
			where no_poliza 	= v_no_poliza
			 and fecha_emision 	= '23/05/2017'
			 and no_documento   = v_no_documento
			 and prima_neta 	= v_sum_prima_neta
			-- and vigencia_inic_pol = v_vig_ini
			-- and vigencia_final_pol = v_vig_fin
			 and cod_endomov in('006')
			 and user_added in('DEIVID','informix')	 
			 
			if v_cnt > 1 then
				let v_no_factura = '';
			end if
			
			let v_cnt = v_cnt + 1;	
			
		end foreach
	end if
	--if v_no_factura is null then
		--let v_no_factura = '';
	--end if
	
	update prdemielctdet
	   set no_factura 		= v_no_factura
	 where cod_agente 		= '00180'
	   and no_poliza  		= v_no_poliza
	   and no_documento     = v_no_documento
	   and fecha_registro 	= v_fecha_registro
	   and no_factura 		= '';
	   --and sum(prima_neta) 		= v_sum_prima_neta;

end foreach
end procedure