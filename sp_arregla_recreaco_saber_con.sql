-- Procedimiento para arreglar recreaco a partir de rectrrea 5/95
-- Creado:     04/10/2024 - Autor Armando Moreno M.

drop procedure sp_arregla_recreaco_saber_con;
create procedure sp_arregla_recreaco_saber_con(a_cod_ramo char(3))
returning	integer,integer,char(100),char(10),char(3);

define _error_desc			char(100);
define _error,_no_cambio,_no_cambio_e,_valor1,_valor2,_cnt    integer;
define _error_isam	        integer;
define _no_tranrec,_no_reclamo,_no_poliza        char(10);
define _no_documento		char(20);
define _no_unidad           char(5);
define _flag2      smallint;
define _porc_suma  dec(9,6);
define _cod_ramo  char(3);
define _vigencia_final,_vigencia_inic date;
define _mensaje 			varchar(250);
define _valor_10 			  char(10);
define _valor_3  			  char(3);


--set debug file to "sp_arregla_recreaco_lote.trc";
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
	   and no_documento[1,4] = '0224'
	   --and year(vigencia_final) = 2022
	   and cod_ramo = a_cod_ramo
	   and estatus_poliza in(1,3)
	 group by no_documento
	 order by no_documento
	 
	foreach
		select no_poliza,
			   cod_ramo,
			   vigencia_final
		  into _no_poliza,
			   _cod_ramo,
			   _vigencia_final
		  from emipomae
		 where actualizado = 1
		   and no_documento = _no_documento
		   and estatus_poliza in(1,3)
		   --and year(vigencia_final) in(2022)
		   order by no_poliza
		   
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
			--call sp_arregla_recreaco_lote(_no_documento) returning _valor1,_valor2,_error_desc,_valor_10,_valor_3;
			let _cnt = _cnt + 1;
		end if
		return _cnt,_flag2,_no_documento,_no_poliza,a_cod_ramo with resume;

	end foreach

end foreach
end
end procedure;