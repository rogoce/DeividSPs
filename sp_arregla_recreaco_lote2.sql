-- Procedimiento para arreglar recreaco a partir de rectrrea 5/95
-- Creado:     04/10/2024 - Autor Armando Moreno M.

drop procedure sp_arregla_recreaco_lote2;
create procedure sp_arregla_recreaco_lote2()
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

let _cnt = 0;
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
		
		   
	let _cnt = _cnt + 1;
	if _cnt = 1000 then
		exit foreach;
	end if
	
	let _valor = sp_arregla_recreaco_ind(_no_reclamo);
		
	return _cnt,0,'',_no_reclamo,'' with resume;
end foreach

return 0,0,'Fin','','' with resume;
end
end procedure;