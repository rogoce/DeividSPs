-- Procedimiento para arreglar recreaco a partir de rectrrea 5/95
-- Creado:     04/10/2024 - Autor Armando Moreno M.

drop procedure sp_arregla_recreaco;
create procedure sp_arregla_recreaco()
returning	integer;

define _error_desc			char(100);
define _error,_no_cambio		        integer;
define _error_isam,_cant_reg	        integer;
define _no_tranrec,_no_reclamo,_no_poliza        char(10); 
define _cod_ruta,_no_unidad           char(5);
define _cantidad,_flag,_flag2,_renglon,_valor            smallint;
define _no_documento char(20);
define _porc_suma  dec(9,6);
define _cod_ramo,_cod_cober_reas  char(3);
define _vigencia_final,_vigencia_inic date;
define _mensaje 			varchar(250);

--set debug file to "sp_reainv_amm1.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

let _cant_reg = 0;
--RECLAMOS
foreach
	select distinct no_reclamo
	  into _no_reclamo
	  from recreaco
     where no_reclamo in(
	select no_reclamo from rectrmae
	 where actualizado = 1
	   and periodo >= '2023-01'
	   and numrecla[1,2] in('02','20','23'))
	   and porc_partic_suma not in(5,95)
	   
    let _flag = 0;
	let _cant_reg = _cant_reg + 1;
	if _cant_reg = 500 then
		exit foreach;
	end if
	foreach
		select no_tranrec
		  into _no_tranrec
		  from rectrmae
		 where no_reclamo = _no_reclamo
		   and actualizado = 1
		   and periodo >= '2023-01'
		   
		foreach
			select porc_partic_suma
			  into _porc_suma
			  from rectrrea
			 where no_tranrec = _no_tranrec
			 
			if _porc_suma in(5,95) then
				let _flag = 1;
				exit foreach;
			else
				continue foreach;
			end if
		end foreach

		if _flag = 1 then
			select * from rectrrea
			where no_tranrec = _no_tranrec into temp prueba_rec;
			
			delete from recreaco
			where no_reclamo = _no_reclamo;
			
			update prueba_rec
			   set no_tranrec = _no_reclamo;
			   
			insert into recreaco(no_reclamo,orden,cod_contrato,porc_partic_suma,porc_partic_prima,subir_bo,cod_cober_reas)
			select no_tranrec,orden,cod_contrato,porc_partic_suma,porc_partic_prima,subir_bo,cod_cober_reas
			  from prueba_rec;
			
			drop table prueba_rec;
			let _valor = sp_arregla_emireaco(_no_reclamo);	--inserta un no_cambio con los contratos y % proveniente de la ruta actica del ramo 2024
			exit foreach;  
		end if
	end foreach
	
	if _flag = 0 then	--ninguna N/T tenia contrato 5/95, procedemos a buscar emireaco
		select no_poliza
		  into _no_poliza
		  from recrcmae
		 where no_reclamo = _no_reclamo;

		select cod_ramo,
		       vigencia_inic,
			   vigencia_final
		  into _cod_ramo,
		       _vigencia_inic,
			   _vigencia_final
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		select cod_ruta
		  into _cod_ruta
		  from rearumae
		 where cod_ramo = _cod_ramo
           and activo = 1
           and serie = '2024';
		
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
				call sp_sis18am(_no_reclamo) returning _error,_mensaje;
				exit foreach;
			end if
		end foreach
		if _flag2 = 0 then	--Emireaco no tiene 5/95, hay que insertarlo.
			let _no_cambio = _no_cambio + 1;
			foreach
				select no_unidad
				  into _no_unidad
				  from emipouni
				 where no_poliza = _no_poliza
				 
				foreach
					select distinct cod_cober_reas
					  into _cod_cober_reas
					  from rearucon
					 where cod_ruta = _cod_ruta

					INSERT INTO emireama(
					no_poliza,
					no_unidad,
					no_cambio,
					cod_cober_reas,
					vigencia_inic,
					vigencia_final
					)
					VALUES(
					_no_poliza, 
					_no_unidad,
					_no_cambio,
					_cod_cober_reas,
					_vigencia_inic,
					_vigencia_final
					);
				end foreach
				
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
				_no_unidad,
				_no_cambio,
				cod_cober_reas,
				orden,
				cod_contrato,
				porc_partic_suma,
				porc_partic_prima
				FROM rearucon
				WHERE cod_ruta = _cod_ruta;
			end foreach
			call sp_sis18am(_no_reclamo) returning _error,_mensaje;
		end if
 	end if
end foreach
return _cant_reg;
end
end procedure;