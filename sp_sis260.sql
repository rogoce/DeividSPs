--Creado: 05/05/2022 
--Autor: Román Gordón
--Simulación de Renovación para Pool Automático
--execute procedure sp_sis258() 

drop procedure sp_sis260;

create procedure sp_sis260()
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
	
	if _no_documento is null then
		let _no_documento = '';
	end if
	
	return	_error,
			_error_isam,
			_no_documento;
end exception


delete from tbl_SiniestrosBitacora;
return 0,0,'Actualización Exitosa';
end


end procedure;