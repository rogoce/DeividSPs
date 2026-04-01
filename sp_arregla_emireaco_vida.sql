-- Creado:     04/10/2024 - Autor Armando Moreno M.

drop procedure sp_arregla_emireaco_vida;
create procedure sp_arregla_emireaco_vida(a_no_poliza char(10))
returning	integer;

define _error_desc			char(100);
define _error,_no_cambio,_cnt		        integer;
define _error_isam,_cant_reg	        integer;
define _no_tranrec,_no_reclamo,_no_poliza        char(10); 
define _cod_ruta,_no_unidad           char(5);
define _cantidad,_flag,_flag2,_renglon,_valor            smallint;
define _no_documento char(20);
define _porc_suma  dec(9,6);
define _cod_ramo,_cod_cober_reas  char(3);
define _vigencia_final,_vigencia_inic date;
define _mensaje 			varchar(250);
define _suma_aseg,_prima_ret dec(16,2);

--set debug file to "sp_reainv_amm1.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

let _cant_reg = 0;
let _suma_aseg = 0.00;
let _cnt = 0;

foreach
    --Esto es para un solo mes
	select distinct no_poliza
	  into _no_poliza
	  from emireaco
	 where no_poliza in(
	select no_poliza from emipomae
	 where actualizado = 1
	   and no_poliza = a_no_poliza
	   and cod_ramo = '019')

	--
	
	{select distinct no_poliza
	  into _no_poliza
	  from emireaco
	 where no_poliza in(
	select no_poliza from endedmae
	 where actualizado = 1
	   and no_poliza = a_no_poliza
	   and periodo >= '2024-07'
       and periodo <= '2024-12'
       and no_endoso = '00000'
	   and no_documento[1,2] = '19')
	   and porc_partic_suma in(50)
	   and porc_partic_prima in(50)}
	   
    let _flag = 0;
	let _cant_reg = _cant_reg + 1;
	if _cant_reg = 10 then
		exit foreach;
	end if
	
	foreach
		select no_unidad,
		       suma_asegurada
		  into _no_unidad,
		       _suma_aseg
		  from emipouni
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach
	
	let _valor = sp_proe04_vida1(_no_poliza,_no_unidad,'00858',_suma_aseg,'001');
	let _prima_ret = 0.00;
	
	if _valor = 0 then
	
		delete from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and no_cambio = 0;
		  
	    let _no_cambio = 0;
	
		INSERT INTO emireaco(
		no_poliza,
		no_unidad,
		no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima
		)
		SELECT 
		_no_poliza, 
		no_unidad,
		_no_cambio,
		cod_cober_reas,
		orden,
		cod_contrato,
		porc_partic_suma,
		porc_partic_prima
		FROM emifacon
		WHERE no_poliza = _no_poliza
		  AND no_endoso = '00000';
		  
		select sum(r.prima)
		  into _prima_ret
		  from emifacon r, reacomae t
		 where r.cod_contrato = t.cod_contrato
		   and r.no_poliza = _no_poliza
		   and r.no_endoso = '00000'
		   and t.tipo_contrato = 1;  
		  
		update emipomae
           set prima_retenida = _prima_ret
		 where no_poliza = _no_poliza;
		 
		update endedmae
           set prima_retenida = _prima_ret
		 where no_poliza = _no_poliza
		   and no_endoso = '00000';
		   
		update endedhis
           set prima_retenida = _prima_ret
		 where no_poliza = _no_poliza
		   and no_endoso = '00000';
	else
		select count(*)
		  into _cnt
		  from emifacon
		 where no_poliza = _no_poliza
           and no_endoso = '00000';

		if _cnt = 0 then
			insert into emifacon
			select * from temp_emifacon;
			let _cant_reg = _valor;
		end if
	end if
	drop table temp_emifacon;
end foreach
return _cant_reg;
end
end procedure;