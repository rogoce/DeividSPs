-- Procedimiento para arreglar recreaco a partir de rectrrea 5/95
-- Creado:     04/10/2024 - Autor Armando Moreno M.

drop procedure sp_arregla_emireaco_lote;
create procedure sp_arregla_emireaco_lote(a_cod_ramo char(3))
returning	integer,integer,char(100),char(10),char(3);

define _error_desc			  char(100);
define _error,_error_isam,_valor1   integer;
define _no_reclamo,_no_poliza char(10); 
define _valor,_cnt            smallint;
define _mensaje 			  varchar(250);
define _valor_10 			  char(10);
define _no_documento 		  char(20);
define _valor_3  			  char(3);


--set debug file to "sp_arregla_recreaco_lote1.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error,_error_isam,_error_desc,'','';
end exception

set isolation to dirty read;

--RECLAMOS
let _cnt = 0;
foreach
	select no_documento
	  into _no_documento
	  from emipomae
	 where actualizado = 1
	   and year(vigencia_final) >= 2024
	   and cod_ramo = a_cod_ramo
	   and estatus_poliza in(1,3)
	 group by no_documento
	   
	let _cnt = _cnt + 1;
	if _cnt = 150 then
		exit foreach;
	end if
	
	call sp_arregla_recreaco_lote(_no_documento) returning _valor1,_valor1,_error_desc,_valor_10,_valor_3;
	
	return _cnt,0,_no_documento,'','' with resume;
end foreach
return 0,0,'Fin','','' with resume;
end
end procedure;