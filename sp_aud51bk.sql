-- Procedure para sacar informacion de cglresumen / cglresumen1 para TTCORP 
-- Creado    :04/04/2014 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud51bk;
create procedure "informix".sp_aud51bk()
 returning integer,  varchar(100); 

define _error_cod  			integer;
define _error_desc          varchar(50);
define _error_isam	        integer;
define _transaccion			char(50);

set isolation to dirty read;

begin

on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, trim(_error_desc) || " " || _transaccion;
end exception

SET DEBUG FILE TO "sp_aud51.trc";
trace on;

delete from deivid_ttcorp:tmp_cglresumen;
delete from deivid_ttcorp:tmp_cglresumen1;

let _transaccion = "";
{select *
  from cglresumen
 where res_comprobante in ('12-00276','12-00277','12-00278','12-00279','12-00280','12-00281')
   and year(res_fechatrx) = 2017
   and res_tipcomp <> '016'
  into temp prueba;}

select *
  from cglresumen
 where res_fechatrx >= '01/02/2020'
   and res_fechatrx <= '29/02/2020'
   and res_tipcomp <> '016'
   and res_notrx in(select res_notrx from deivid_tmp:notrx_faltante)
   into temp prueba;

insert into deivid_ttcorp:tmp_cglresumen
select * from prueba;

drop table prueba;

{select t.*
  from cglresumen c, cglresumen1 t
 where c.res_noregistro = t.res1_noregistro
   and c.res_comprobante in ('12-00276','12-00277','12-00278','12-00279','12-00280','12-00281')
   and year(c.res_fechatrx) = 2017
   and c.res_tipcomp <> '016'}
select t.*
  from cglresumen c, cglresumen1 t
 where c.res_noregistro = t.res1_noregistro
   and c.res_fechatrx >= '01/02/2020'
   and c.res_fechatrx <= '29/02/2020'
   and c.res_tipcomp <> '016'
   and c.res_notrx in(select res_notrx from deivid_tmp:notrx_faltante)
  into temp prueba;

insert into deivid_ttcorp:tmp_cglresumen1
select * from prueba;

drop table prueba;

---******Carga de comprobantes de cobasien

--call sp_sac152a(a_fecha_desde, a_fecha_hasta) returning _error_cod,_error_desc;

return 0,  "Exitoso";

end

end procedure








