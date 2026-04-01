-- MODIFICAR ACREEDORES A REQUERIMIENTO
--LLENAR TABLA deivid_tmp:cambio_acr

DROP procedure sp_jean07;
CREATE procedure sp_jean07()
RETURNING char(10),char(20),char(10),char(5);

DEFINE _no_poliza,_cod_acreedor,_no_notas	 	CHAR(10);
DEFINE _no_documento    CHAR(20);
DEFINE _cod_acr         char(10);
DEFINE _cnt  			integer;
DEFINE _observacion varchar(255);
define _no_unidad       char(5);


foreach
	select no_documento,
		   no_unidad,
		   cod_acreedor
	  into _no_documento,
		   _no_unidad,
		   _cod_acreedor
	  from deivid_tmp:cambio_acr
	 order by cod_acreedor

	let _no_poliza = sp_sis21(_no_documento);
	
	select cod_acreedor
	  into _cod_acr
	  from emipoacr
	 where no_poliza = _no_poliza
       and no_unidad = _no_unidad;
	   
	if _cod_acr = '02395' then
		--Insertar la nota en table eminotas
		select count(*)
		  into _cnt
		  from eminotas
		 where no_poliza = _no_poliza
		   and date_added = today
		   and user_added = 'DEIVID';
		   
		if _cnt is null then
			let _cnt = 0;
		end if
	
		if _cnt = 0 then
		
			LET _no_notas = sp_sis158("001", 'PRO', '02', 'par_notas');
			
			if _cod_acreedor = '01229' then --acreedor multibank
				let _observacion = 'POR INDICACION DE ACREEDOR SAR, SE PROCEDE CON CAMBIO DE ACREEDOR A ENTIDAD BANCARIA MULTIBANK INC.';
			elif _cod_acreedor = '02412' then --acreedor banisi
				let _observacion = 'POR INDICACION DE ACREEDOR SAR, SE PROCEDE CON CAMBIO DE ACREEDOR A ENTIDAD BANCARIA BANISI, S.A.';
			elif _cod_acreedor = '02039' then --acreedor delta
				let _observacion = 'POR INDICACION DE ACREEDOR SAR, SE PROCEDE CON CAMBIO DE ACREEDOR A ENTIDAD BANCARIA BANCO DELTA, S.A.';
			else --bac
				let _observacion = 'POR INDICACION DE ACREEDOR SAR, SE PROCEDE CON CAMBIO DE ACREEDOR A ENTIDAD BANCARIA BAC INTERNATIONAL BANK.';
			end if
				
			 insert into eminotas(
			 no_notas,
			 no_documento,
			 no_poliza,
			 date_added,
			 user_added,
			 descripcion,
			 procesado,
			 user_proceso,
			 date_proceso
			 )	
			 values (
			 _no_notas,
			 _no_documento,
			 _no_poliza,		
			 current,       		
			 'DEIVID',
			 _observacion,
			 1,
			 'DEIVID',
			 current
			 );
		end if
		--actualizar el codigo de acreedor solamente a emipoacr
		update emipoacr
		   set cod_acreedor = _cod_acreedor
		 where no_poliza = _no_poliza
           and no_unidad = _no_unidad;		 
	
		return _cod_acreedor,_no_documento, _cod_acr,_no_unidad with resume;
	end if
	 
end foreach
END PROCEDURE;