-- Mayor General

-- Creado    : 13/02/2007 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sac55;

create procedure "informix".sp_sac55(a_ano char(4), a_mes smallint, a_db char(18)) 
returning date,
            char(15),
			integer,
			date,
			date,
			char(50),
			dec(16,2),
			dec(16,2),
			char(12),
			char(50),
			dec(16,2),
			dec(16,2),
			char(50);

define _fechatrx	date;
define _comprobante	char(15);
define _notrx		integer;
define _fechacap	date;
define _fechaact	date;
define _descripcion	char(50);
define _cuenta		char(12);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _nombre		char(50);
define _saldo_ini	dec(16,2);
define _saldo_fin	dec(16,2);

define _nombre_cia	char(50);

create temp table tmp_cglresumen(
res_fechatrx	date,
res_comprobante	char(15),
res_notrx		integer,
res_fechacap	date,
res_fechaact	date,
res_descripcion	char(50),
res_cuenta		char(12),
res_debito		dec(16,2),
res_credito		dec(16,2),
res_nombre		char(50),
res_saldo_ini	dec(16,2),
res_saldo_fin	dec(16,2)
) with no log;

set isolation to dirty read;

select cia_nom
  into _nombre_cia
  from sigman02
 where cia_bda_codigo = a_db;

call sp_sac56(a_ano, a_mes, a_db);

foreach	
 select res_fechatrx,
	    res_comprobante,
	    res_notrx,
	    res_fechacap,
	    res_fechaact,
	    res_descripcion,
	    res_cuenta,
	    res_debito,
	    res_credito,
		res_nombre,
		res_saldo_ini,
		res_saldo_fin
   into _fechatrx,
	    _comprobante,
	    _notrx,
	    _fechacap,
	    _fechaact,
	    _descripcion,
	    _cuenta,
	    _debito,
	    _credito,
		_nombre,
		_saldo_ini,
		_saldo_fin
   from tmp_cglresumen

	return _fechatrx,
		   _comprobante,
	       _notrx,
	       _fechacap,
	       _fechaact,
	       _descripcion,
	       _debito,
	       _credito,
	       _cuenta,
	       _nombre,
	       _saldo_ini,
	       _saldo_fin,
		   _nombre_cia 
		   with resume;	

end foreach

drop table tmp_cglresumen;

end procedure