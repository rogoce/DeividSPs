drop procedure sp_actuario19b;
-- copia de sp_actuario
create procedure "informix".sp_actuario19b()
	returning integer,varchar(250);

BEGIN
define _error_desc			varchar(250);
define _id_recibo			varchar(25);
define _id_poliza			varchar(25);
define _impuesto			dec(18,2);
define _new_id_mov_tecnico	integer;
define _id_mov_tecnico		integer;
define _cod_ramorea			smallint;
define _error_isam			integer;
define _error				integer;

on exception set _error,_error_isam,_error_desc
	let _error_desc = trim(_error_desc) || 'póliza: ' || _id_poliza || 'factura: ' ||  _id_recibo;
	rollback work;
	return _error,_error_desc;
end exception

--set debug file to "sp_actuario19b.trc";
--trace on;

set isolation to dirty read;

let _cod_ramorea = 100;

select max(id_mov_tecnico)
  into _new_id_mov_tecnico
  from movim_tec_pri_ttco;

foreach with hold
	select min(id_mov_tecnico),                        
		   id_poliza,
		   id_recibo
	  into _id_mov_tecnico,                        
		   _id_poliza,
		   _id_recibo
	  from movim_tec_pri_ttco
	 where cod_ramorea <> 100
	 group by id_poliza,id_recibo

	begin work;

	let _impuesto = 0.00;

	select impuesto
	  into _impuesto
	  from endedmae
	 where no_factura = _id_recibo
	   and no_documento = _id_poliza;

	if _impuesto is null or _impuesto = 0.00 then
		commit work;
		continue foreach;
	end if

	let _new_id_mov_tecnico = _new_id_mov_tecnico + 1;

	select *
	  from movim_tec_pri_ttco
	 where id_mov_tecnico = _id_mov_tecnico
	  into temp tmp_ttco;

	update tmp_ttco
	   set id_mov_tecnico	= _new_id_mov_tecnico,
		   cod_ramorea		= _cod_ramorea,
		   mto_prima		= _impuesto;

	insert into movim_tec_pri_ttco
	select * 
	  from tmp_ttco;

	drop table tmp_ttco;

	commit work;
end foreach

return 0,'Inserción Exitosa';	
end
end procedure;