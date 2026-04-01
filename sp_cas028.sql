drop procedure sp_cas028;

create procedure sp_cas028(
a_no_documento	char(20),
a_cod_cliente	char(10)
) returning     integer,
                char(100);

define _cantidad	smallint;
define _cliente_ant	char(10);
define _no_poliza	char(10);

--SET DEBUG FILE TO "sp_cas028.trc"; 
--trace on;

SET ISOLATION TO DIRTY READ;

select count(*)
  into _cantidad
  from cascliente
 where cod_cliente = a_cod_cliente;

if _cantidad = 0 then

	let _cantidad = sp_cas027(a_cod_cliente,a_no_documento);

	if _cantidad <> 0 then
		return 1, "No se pudo cambiar el Pagador.";
	end if

end if

select count(*)
  into _cantidad
  from caspoliza
 where no_documento = a_no_documento;

let _no_poliza = sp_sis21(a_no_documento);

if _cantidad = 0 then

	insert into caspoliza(
	no_documento,
	cod_cliente,
	dia_cobros1,
	dia_cobros2,
	a_pagar,
	cod_campana
	)
	values(
	a_no_documento,
	a_cod_cliente,
	0,
	0,
	0.00,
	'00000'
	);
	
else
	foreach
		select cod_cliente
		  into _cliente_ant
		  from caspoliza
		 where no_documento =  a_no_documento
		exit foreach;
	end foreach

	update caspoliza
	   set cod_cliente  = a_cod_cliente
	 where no_documento =  a_no_documento;

	select count(*)
	  into _cantidad
	  from caspoliza
	 where cod_cliente = _cliente_ant;

	if _cantidad = 0 then

		delete from cascliente
		 where cod_cliente = _cliente_ant;

		delete from cobcapen
		 where cod_cliente = _cliente_ant;

	end if

end if

return 0, "Actualizacion Exitosa ...";

end procedure                                                 
