-- Procedimiento que carga la tabla camrea con registros para realizar cambios referente a reaseguro.
-- 
-- Creado    : 21/11/2022 - Autor: Armando Moreno Montenegro
--se ejecuta traspaso 24/07/2024 patrimoniales de munich a allied

drop procedure sp_reainv_amm;
create procedure sp_reainv_amm()
returning char(10), char(20),char(4);
		  	

define _no_poliza,_no_endoso    char(10);
define _no_documento char(20);
define _cnt 		 integer;
define _serie 		 char(4);
define _no_unidad    char(5);

set isolation to dirty read;

begin 

--set debug file to "sp_reainv.trc";
--trace on;

let _cnt = 0;
let _no_poliza = "";

--NOTA: SE DEBE REVISAR EL PROCEDIMIENTO sp_1reainv_amm PARA BUSCAR RASTROS DE REGISTROS EN EMIREACO CON ESOS CONTRATOS Y CAMBIARLOS.

foreach
	select no_poliza,
	       no_documento,
		   serie
	  into _no_poliza,
           _no_documento,
		   _serie		   
      from emipomae
	 where actualizado = 1
	   and cod_ramo in('001','003','006','010','011','012','013','014','021','022')
	 order by no_poliza

	let _cnt = 0;
	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza
		 
			foreach
				select count(*)
				  into _cnt
				  from emifacon r, reacomae t
				 where r.cod_contrato = t.cod_contrato
				   and r.no_poliza = _no_poliza
				   and r.no_unidad = _no_unidad
				   and t.tipo_contrato <> 1
				   and r.cod_contrato in('00750','00755','00751','00756','00752','00757','00753','00758','00754','00759','00746','00745') --contratos viejos
				   
				if _cnt is null then
					let _cnt = 0;
				end if
				if _cnt > 0 then
					return  _no_poliza,_no_documento,_serie with resume;
					
					select count(*)
					  into _cnt
					  from camrea
					 where no_poliza = _no_poliza
					   and no_unidad = _no_unidad;
					 
					if _cnt is null THEN
						let _cnt = 0;
					end if	
					
					if _cnt = 0 then 
						insert into camrea(
						no_poliza,no_unidad,actualizado,no_endoso,periodo,no_documento,tipo,fecha)
						values(_no_poliza,_no_unidad,0,'',_serie,_no_documento,1,today);
					end if
				end if
			end foreach
	end foreach
	--***************VERIFICACION DE ENDOSOS DE ELIMINACION DE UNIDADES
	select count(*)
	  into _cnt
	  from endedmae
	 where no_poliza   = _no_poliza
	   and actualizado = 1
	   and periodo = '2024-07'	--periodo actual
	   and cod_endomov = '005';
	
	if _cnt is null then
		let _cnt = 0;
	end if
	
	if _cnt > 0 then
		foreach
			select no_endoso
			  into _no_endoso
			  from endedmae
			 where no_poliza   = _no_poliza
			   and actualizado = 1
			   and periodo = '2024-07'
			   and cod_endomov = '005'
			   
			foreach
				select no_unidad
				  into _no_unidad
				  from endeduni
				 where no_poliza = _no_poliza
                   and no_endoso = _no_endoso
				   
				select count(*)
				  into _cnt
				  from emifacon r, reacomae t
				 where r.cod_contrato = t.cod_contrato
				   and r.no_poliza = _no_poliza
				   and r.no_unidad = _no_unidad
				   and r.no_endoso = _no_endoso
				   and t.tipo_contrato <> 1
				   and r.cod_contrato in('00750','00755','00751','00756','00752','00757','00753','00758','00754','00759','00746','00745'); --contratos viejos
				   
				if _cnt is null then
					let _cnt = 0;
				end if
				if _cnt > 0 then
					select count(*)
					  into _cnt
					  from camrea
					 where no_poliza = _no_poliza
					   and no_unidad = _no_unidad;
					 
					if _cnt is null THEN
						let _cnt = 0;
					end if	
					
					if _cnt = 0 then 
						insert into camrea(
						         no_poliza,no_unidad,actualizado,no_endoso,periodo,no_documento,tipo,fecha)
						values(_no_poliza,_no_unidad,0,_no_endoso,_serie,_no_documento,1,today);
					end if
				end if   
			end foreach
		end foreach
	end if
end foreach
end 
end procedure;
