--Creado: 05/05/2022 
--Autor: Román Gordón
--Simulación de Renovación para Pool Automático
--execute procedure sp_sis245b('2024-09') 

drop procedure sp_sis257;

create procedure sp_sis257()
returning	integer			as error_isam,
			varchar(100)	as descripcion;

define _no_documento			char(20);           
define _no_poliza 				char(10);           
define _no_trajeta_old 			char(19);           
define _no_trajeta_new			char(19);           
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
	
	return	_error_isam,
			_no_documento;
end exception


foreach
	select pol.no_documento,
		   pol.no_tarjeta,
		   mae.no_tarjeta,
		   mae.fecha_exp,
		   mae.cod_banco,
		   mae.tipo_tarjeta
	  into _no_documento,
		   _no_trajeta_old,
		   _no_trajeta_new,
		   _fecha_exp,
		   _cod_banco,
		   _tipo_tarjeta	   
	  from cobcampl mae
	inner join (
				 select emi.no_documento,max(no_cambio) as cambio
				   from emipomae emi
				  inner join cobcampl cam on cam.no_documento = emi.no_documento
				  where emi.cod_formapag in ('003')

					and emi.estatus_poliza = 1
					and emi.cod_ramo in ('001','003')
				  group by 1
				) tmp on tmp.no_documento = mae.no_documento and tmp.cambio = mae.no_cambio
	inner join emipomae pol on pol.no_documento = mae.no_documento and pol.no_tarjeta <> mae.no_tarjeta and pol.vigencia_final >= '01/01/2025' and pol.actualizado = 1
	--and pol.no_documento = "0120-00335-01"

	let _no_poliza = sp_sis21(_no_documento);
			
	update emipomae
	   set no_tarjeta = _no_trajeta_new,
		   fecha_exp = _fecha_exp,
		   cod_banco = _cod_banco,
		   tipo_tarjeta = _tipo_tarjeta
	 where no_poliza = _no_poliza;
			
	delete from cobtacre
     where no_documento = _no_documento
	   and no_tarjeta = _no_trajeta_old;
	   
	return 0,_no_documento with resume;   
    		
end foreach
end


end procedure;