--drop procedure sp_rec165;

create procedure sp_rec165(
a_transaccion1	char(10),
a_transaccion2	char(10)
) returning integer,
            char(50);


define _wf_apr_j_fh	datetime year to fraction;

select wf_apr_j_fh
  into _wf_apr_j_fh
  from rectrmae
 where transaccion = a_transaccion1;

update rectrmae
   set wf_apr_j_fh = _wf_apr_j_fh
 where transaccion = a_transaccion2;

return 0, "Actualizacion Exitosa";

end procedure
