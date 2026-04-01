drop procedure sp_actuario19bb;
-- copia de sp_actuario
create procedure "informix".sp_actuario19bb()
	returning integer,varchar(250);

BEGIN
define _error_desc			varchar(250);
define _no_remesa			varchar(25);
define _renglon				integer;
define _impuesto			dec(18,2);
define _new_id_mov_tecnico	integer;
define _id_mov_tecnico		integer;
define _cod_ramorea			smallint;
define _error_isam			integer;
define _error				integer;

on exception set _error,_error_isam,_error_desc
	let _error_desc = trim(_error_desc) || 'póliza: ' || _no_remesa || 'factura: ' ||  _no_remesa;
	rollback work;
	return _error,_error_desc;
end exception

--set debug file to "sp_actuario19b.trc";
--trace on;

set isolation to dirty read;

let _cod_ramorea = 100;

select max(id_mov_tecnico)
  into _new_id_mov_tecnico
  from movim_tec_pri_tt;

foreach with hold
	select min(id_mov_tecnico),                        
		   no_remesa,
		   renglon
	  into _id_mov_tecnico,                        
		   _no_remesa,
		   _renglon
	  from movim_tec_pri_tt
	 where no_remesa <> '452855'
	 group by no_remesa,renglon

	begin work;

	let _impuesto = 0.00;

	select impuesto
	  into _impuesto
	  from cobredet
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;

	if _impuesto is null or _impuesto = 0 then
		commit work;
		continue foreach;
	end if

	let _new_id_mov_tecnico = _new_id_mov_tecnico + 1;

	select *
	  from movim_tec_pri_tt
	 where id_mov_tecnico = _id_mov_tecnico
	  into temp tmp_ttco1;

	update tmp_ttco1
	   set id_mov_tecnico	= _new_id_mov_tecnico,
		   cod_ramorea		= _cod_ramorea,
		   mto_prima		= _impuesto;

	insert into movim_tec_pri_tt
	select * 
	  from tmp_ttco1;

	drop table tmp_ttco1;

	commit work;
end foreach

return 0,'Inserción Exitosa';	
end
end procedure;