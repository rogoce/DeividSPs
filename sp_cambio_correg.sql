-- Proceso que modifica el codigo de corregimiento de las polizas con codigo de corregimiento por definir
-- 
-- Creado    : 20/01/2012 - Autor: Roman Gordon
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cambio_correg;

create procedure sp_cambio_correg()
returning smallint;

define _cod_cliente  	char(10);
define _fecha_gestion 	datetime year to second;
define _descripcion   	char(512);
define _cod_correg	  	char(5);
define _cod_gestion	  	char(3);
define _nombre_gestion	char(50);
define _cont			integer;

set isolation to dirty read;

--set debug file to "sp_cambio_correg.trc";
--trace on;


foreach
	select cod_cliente
	  into _cod_cliente
	  from tmp_clientes

	select code_correg
	  into _cod_correg
	  from cliclien
	 where cod_cliente = _cod_cliente;

	if _cod_correg is not null and _cod_correg <> '01' then
		continue foreach;
	else
		update cliclien
		   set code_correg = '00089',
			   dia_cobros1 = 2,
			   dia_cobros2 = 2
		 where cod_cliente = _cod_cliente;

		update cascliente
		   set dia_cobros1 = 2,
			   dia_cobros2 = 2
		 where cod_cliente = _cod_cliente;
	end if
end foreach

return 0;
end procedure