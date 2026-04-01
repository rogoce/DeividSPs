-- Procedimiento para arreglar recreaco a partir de rectrrea 5/95
-- Creado:     04/10/2024 - Autor Armando Moreno M.

drop procedure sp_arregla_recreaco_lote1;
create procedure sp_arregla_recreaco_lote1(a_no_reclamo char(10), a_no_documento char(20))
returning integer,integer,char(100),char(10),char(3);

define _error_desc			  char(100);
define _error,_error_isam,_valor1,_valor2,_no_cambio   integer;
define _no_reclamo,_no_poliza char(10); 
define _valor,_cnt,_flag2            smallint;
define _mensaje 			  varchar(250);
define _valor_10 			  char(10);
define _no_documento 		  char(20);
define _valor_3,_cod_ramo	  char(3);
define _vigencia_final        date;
define _porc_suma  			  dec(9,6);


--set debug file to "sp_arregla_recreaco_lote1.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error,_error_isam,_error_desc,'','';
end exception

set isolation to dirty read;

--RECLAMOS
if a_no_reclamo <> "" then
	let _cnt = 0;
	foreach
		--Individual
		{select distinct no_reclamo
		  into _no_reclamo
		  from recreaco
		 where no_reclamo in(
		select no_reclamo from recrcmae
		 where actualizado = 1
		   and no_reclamo = a_no_reclamo)
		   and porc_partic_suma not in(5,95)}
		
		--Lote
		select distinct no_reclamo
		  into _no_reclamo
		  from recreaco
		 where no_reclamo in(
		select no_reclamo from rectrmae
		 where actualizado = 1
		   and periodo >= '2023-01'
		   and numrecla[1,2] in('02','20','23'))
		   and porc_partic_suma not in(5,95)
		   
		let _cnt = _cnt + 1;
		if _cnt = 100 then
			exit foreach;
		end if
		
		select no_documento into _no_documento from recrcmae
		where no_reclamo = _no_reclamo
		  and actualizado = 1;
		
		call sp_arregla_recreaco_lote(_no_documento) returning _valor1,_valor2,_error_desc,_valor_10,_valor_3;
		if _valor1 = 1 then
			let _valor = sp_arregla_recreaco_ind(_no_reclamo);
		else
			continue foreach;
		end if
		
		return _cnt,0,'',_no_reclamo,'' with resume;
	end foreach

else

	{foreach
			select no_poliza,
				   cod_ramo,
				   vigencia_final
			  into _no_poliza,
				   _cod_ramo,
				   _vigencia_final
			  from emipomae
			 where actualizado = 1
			   and no_documento = a_no_documento
			   and year(vigencia_final) >= 2024
			   and estatus_poliza in(1,3)
			   order by no_poliza
			   
			if year(_vigencia_final) > 2025 then
				continue foreach;
			end if

			let _no_cambio = 0;
			select max(no_cambio)
			  into _no_cambio
			  from emireaco
			 where no_poliza = _no_poliza;
				
			let _flag2 = 0;
			foreach
				select porc_partic_suma
				  into _porc_suma
				  from emireaco
				 where no_poliza = _no_poliza
				   and no_cambio = _no_cambio
				
				if _porc_suma in(5,95) then
					let _flag2 = 1;
					exit foreach;
				end if
			end foreach
			
		if _flag2 = 1 then	--Al menos 1 unidad tiene 5/95
			continue foreach;
		elif _flag2 = 0 then
			call sp_arregla_recreaco_lote(_no_documento) returning _valor1,_valor2,_error_desc,_valor_10,_valor_3;
			if _valor1 = 1 then
				let _no_reclamo = null;
				select distinct no_reclamo
				  into _no_reclamo
				  from recreaco
				 where no_reclamo in(
				select no_reclamo from recrcmae
				 where actualizado = 1
				   and no_reclamo = _no_reclamo)
				   and porc_partic_suma not in(5,95);
				
				if _no_reclamo is not null then
					let _valor = sp_arregla_recreaco_ind(_no_reclamo);
				end if	
			end if	
		else
			continue foreach;
		end if
	end foreach}
end if
return 0,0,'Fin','','' with resume;
end
end procedure;