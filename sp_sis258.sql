--Creado: 05/05/2022 
--Autor: Román Gordón
--Simulación de Renovación para Pool Automático
--execute procedure sp_sis258() 

drop procedure sp_sis258;

create procedure sp_sis258()
returning	integer			as error_,
			integer			as error_isam,
			varchar(100)	as descripcion;

define _no_documento			char(20);           
define _no_poliza 				char(10);           
define _no_unidad 				char(5);           
define _cod_manzana_aa 			char(15);           
define _cod_manzana_pr 			char(15);           
define _nom_manzana_aa			varchar(100);            
define _nom_manzana_pro			varchar(100);            
define _nom_manzana_pr			varchar(100);            
define _fecha_exp 				char(7);           
define _cod_banco 				char(3);           
define _tipo_tarjeta			char(1);     
define _error                   integer;      
define _error_isam              integer;  
define _error_desc              varchar(100);    

--set debug file to "sp_sis245.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
	--if _no_poliza is null then
	--	let _no_poliza = '';
	--end if
	
	if _no_documento is null then
		let _no_documento = '';
	end if
	
	return	_error,
			_error_isam,
			_no_documento;
end exception


foreach
	select emi.no_documento,
		   uni.no_poliza,
		   uni.no_unidad,
		   uni.cod_manzana,
		   man.referencia,
		   tmp.manzana_aa,
		   tmp.cod_manzana,
		   tmp.nom_manzana
	  into _no_documento,
		   _no_poliza,
		   _no_unidad,
		   _cod_manzana_aa,
		   _nom_manzana_aa,
		   _nom_manzana_pro,
		   _cod_manzana_pr,
		   _nom_manzana_pr
	  from emipomae emi
	 inner join emipouni uni on emi.no_poliza = uni.no_poliza
	 inner join emiman05 man on man.cod_manzana = uni.cod_manzana

	 inner join deivid_tmp:tmp_emiman05 tmp on '0000000000' || trim(tmp.no_poliza) = '0000000000' || trim(uni.no_poliza) and trim(man.referencia) = trim(tmp.manzana_aa)
	 where emi.cod_ramo = '001'
	   and emi.actualizado = 1
	   and emi.vigencia_inic >= '01/01/2023'
	   

	update emipouni
	   set cod_manzana_aux = _cod_manzana_pr
	 where no_poliza in (select no_poliza from emipomae where no_documento = _no_documento)
	   and no_unidad = _no_unidad
	   and cod_manzana_aux is null;
    		
end foreach

return 0,0,'Actualización Exitosa';
end


end procedure;