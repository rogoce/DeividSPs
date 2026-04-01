-- Procedimiento para arreglar recreaco a partir de rectrrea 5/95
-- Creado:     04/10/2024 - Autor Armando Moreno M.

drop procedure sp_arregla_recreaco_lote;
create procedure sp_arregla_recreaco_lote(a_no_documento char(20))
returning	integer,integer,char(100),char(10),char(3);

define _error_desc			char(100);
define _error,_no_cambio,_no_cambio_e		        integer;
define _error_isam	        integer;
define _no_tranrec,_no_reclamo,_no_poliza        char(10); 
define _cod_ruta,_no_unidad           char(5);
define _cantidad,_flag,_flag2,_renglon,_valor,_flag3,_seguir      smallint;
define _no_documento char(20);
define _porc_suma  dec(9,6);
define _cod_ramo,_cod_cober_reas  char(3);
define _vigencia_final,_vigencia_inic date;
define _mensaje 			varchar(250);

--set debug file to "sp_arregla_recreaco_lote.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error,_error_isam,_error_desc,'','';
end exception

set isolation to dirty read;

--RECLAMOS
let _seguir = 0;
foreach
	select no_poliza,
	       cod_ramo,
		   vigencia_inic,
		   vigencia_final
      into _no_poliza,
		   _cod_ramo,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
     where actualizado = 1
	   and no_documento = a_no_documento
	   --and year(vigencia_final) in(2022)
	   
	let _seguir = 1;

	let _no_cambio = 0;
	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza;
		
	let _flag2 = 0;
	let _flag3 = 0;
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
		foreach
			select no_unidad,
			       max(no_cambio)
			  into _no_unidad,
                   _no_cambio_e			  
			  from emireaco
		     where no_poliza = _no_poliza
		     group by no_unidad
		     order by no_unidad
		   
		    if _no_cambio <> _no_cambio_e then
				let _flag3 = 1;
				exit foreach;
		    end if
		
		end foreach
	end if
	if _flag3 = 1 then		--Se crea Emireaco usando el maximo no_cambio que tiene 5/95 para el resto de las unidades.
		select cod_ruta
		  into _cod_ruta
		  from rearumae
		 where cod_ramo = _cod_ramo
           and activo = 1
           and serie = '2024';
		   
		foreach
			select no_unidad,
				   max(no_cambio)
			  into _no_unidad,
				   _no_cambio_e				  
			  from emireaco
			 where no_poliza = _no_poliza
			 group by no_unidad
			having max(no_cambio) < _no_cambio
		 
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
	end if
	
	if _flag2 = 0 then	--Emireaco no tiene 5/95, Se crea un nuevo no_cambio para todas las unidades.

		let _no_cambio = _no_cambio + 1;
		
		select cod_ruta
		  into _cod_ruta
		  from rearumae
		 where cod_ramo = _cod_ramo
           and activo = 1
           and serie = '2024';
		   
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
	end if
end foreach
return _seguir,_flag3,'','','';
end
end procedure;