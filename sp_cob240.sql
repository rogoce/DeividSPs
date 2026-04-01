-- insercion en tabla de recibos anulados cobrecan

-- Creado    : 10/02/2010 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_cob240;

create procedure sp_cob240(a_no_remesa char(10))
returning integer,
          char(100);

define _cod_chequera 	char(3); 
define _no_remesa		char(10);
define _no_recibo    	char(10);
define _cod_cobrador    char(3);
define _cod_libreta  	char(5);
define _ult_no_recibo   char(10);
define _user_added      char(8);
define _cantidad        integer;
define _error			integer;
define _error_desc		char(100);
define _error_isam		integer;

on exception set _error, _error_isam, _error_desc
   return _error, _error_desc;
end exception


SET ISOLATION TO DIRTY READ;

begin

let _no_remesa = sp_sis13("001", 'COB', '02', 'par_no_remesa');

select count(*)
  into _cantidad
  from cobremae
 where no_remesa = _no_remesa;

if _cantidad <> 0 then
	return 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...';
end if

select cod_chequera,
       cod_cobrador,
	   user_added
  into _cod_chequera,
       _cod_cobrador,
	   _user_added
  from cobremae
 where no_remesa = a_no_remesa;

select cod_libreta
  into _cod_libreta
  from cobcobra
 where cod_cobrador = _cod_cobrador;

select ult_no_recibo
  into _ult_no_recibo
  from coblibre
 where cod_libreta = _cod_libreta;

foreach
	select no_recibo
	  into _no_recibo
	  from cobredet
	 where no_remesa = a_no_remesa

	exit foreach;
end foreach

select * 
  from cobremae
 where no_remesa = a_no_remesa
  into temp prueba;

update prueba
   set monto_chequeo = 0,
       no_remesa     = _no_remesa
 where no_remesa     = a_no_remesa;

insert into cobremae
select * from prueba
 where no_remesa = _no_remesa;

drop table prueba;

select * 
  from cobredet
 where no_remesa = a_no_remesa
  into temp prueba;

update prueba
   set monto            = 0,
       prima_neta       = 0,
	   impuesto		    = 0,
	   monto_descontado = 0,
	   desc_remesa      = "Anula Recibo " || _no_recibo,
	   saldo            = 0,
	   tipo_mov         = "B",
	   no_recibo        = _no_recibo,
       no_remesa        = _no_remesa
 where no_remesa = a_no_remesa;

insert into cobredet
select * from prueba
 where no_remesa = _no_remesa;

drop table prueba;

let _no_recibo = _ult_no_recibo;

update cobredet
   set no_recibo = _no_recibo
 where no_remesa = a_no_remesa;

call sp_cob29(_no_remesa, _user_added) returning _error, _error_desc; 

if _error <> 0 then
	return _error, _error_desc;
end if

return 0, _no_recibo;

end
end procedure 