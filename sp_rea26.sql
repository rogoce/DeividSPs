-- Procedimiento que carga la provisión de Reaseguro.
-- 24/02/2016 - Autor: Román Gordón.
-- execute procedure sp_rea26()

drop procedure sp_rea26;
create procedure 'informix'.sp_rea26()
returning	integer,                  --1
			varchar(100);              --2

define _mensaje				varchar(100);
define _no_documento		char(21);
define _periodo				char(8);
define _cod_ramo			char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _porc_proporcion		dec(9,6);
define _proporcion			dec(9,6);
define _saldo_unidad		dec(16,2);
define _saldo_tot			dec(16,2);
define _saldo_pxc			dec(16,2);
define _cant_unidades		smallint;
define _cnt_contratos		smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _flag                integer;
define _cnt                 integer;

set isolation to dirty read;

--set debug file to "sp_sis188.trc";
--trace on;

begin

on exception set _error,_error_isam,_mensaje
	--rollback work;
 	return _error,_mensaje;
end exception

drop table if exists tmp_cobmoros;

select periodo,
	   no_documento,
	   sum(saldo_pxc) as saldo_pxc
  from deivid_cob:cobmoros2
 where no_documento in ('1610-00462-01')
   and periodo in ('2016-09')
   and saldo_pxc <> 0
 group by 1,2
  into temp tmp_cobmoros;

foreach
	select r.periodo,
		   r.no_documento,
		   t.saldo_pxc,
		   sum(r.saldo_tot),
		   count(distinct r.no_unidad)
	  into _periodo,
		   _no_documento,
		   _saldo_pxc,
		   _saldo_tot,
		   _cant_unidades
	  from rea_saldo2 r, tmp_cobmoros t
	 where r.no_documento = t.no_documento
	   and r.periodo = t.periodo
	   and r.saldo_tot <> 0
	   --and r.no_documento = '0204-02666-01'
	 group by 1,2,3
	 order by 1,2

	foreach
		select no_unidad,
			   count(*),
			   sum(saldo_tot)
		  into _no_unidad,
			   _cnt_contratos,
			   _saldo_unidad
		  from rea_saldo2
		 where periodo = _periodo
		   and no_documento = _no_documento
		 group by 1
		 order by 1

		let _porc_proporcion = _saldo_unidad/_saldo_tot;
		
		update rea_saldo2
		   set saldo_tot = (_saldo_pxc * _porc_proporcion)/_cnt_contratos
		 where periodo = _periodo
		   and no_documento = _no_documento
		   and no_unidad = _no_unidad;		
	end foreach
end foreach

return 0,'Actualización Exitosa';

end
end procedure;