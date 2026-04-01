
drop procedure sp_par217;

create procedure "informix".sp_par217()
returning integer,
          char(50);

define _cod_contrato	char(5);
define _serie 			smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin work;

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc;
end exception

for _serie = 1997 to 2005

	let _cod_contrato = sp_sis13("001", "PAR", "02", "par_cont_reas");

	select *
	  from reacomae
	 where cod_contrato = "00549"
	  into temp tmp_reacomae;

	update tmp_reacomae
	   set cod_contrato   = _cod_contrato,
                  serie = _serie,  
	       vigencia_inic  = mdy(1,  1,  _serie),
		   vigencia_final = mdy(12, 31, _serie);

	insert into reacomae
    select * 
      from tmp_reacomae;

	drop table tmp_reacomae;

	select *
	  from reacocob
	 where cod_contrato = "00549"
	  into temp tmp_reacomae;

	update tmp_reacomae
	   set cod_contrato = _cod_contrato;
	   
	insert into reacocob
	select *
	  from tmp_reacomae;
	  	
	drop table tmp_reacomae;

end for

end

commit work;
--rollback work;

return 0, "Actualizacion Exitosa";

end procedure