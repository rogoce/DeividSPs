-- Actualiza la tabla emiletra cuando la póliza recibe un pago
-- Creado    : 13/11/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_pro544c()
drop procedure sp_pro544c;
create procedure sp_pro544c()
returning	int,
			char(50);

define _error_desc			char(50);
define _no_documento			char(20);
define _no_poliza_c			char(10);
define _no_poliza			char(10);
define _monto_pendiente		dec(16,2);
define _letra_residuo		dec(16,2);
define _monto_residuo		dec(16,2);
define _monto_pagado		dec(16,2);
define _total_pen			dec(16,2);
define _monto_pen			dec(16,2);
define _monto_letra			dec(16,2);
define _monto_bruto			dec(16,2);
define _residuo				dec(16,2);
define _resto           	dec(16,2);
define _cnt_no_pagada		smallint;
define _letra_pagada		smallint;
define _no_letra_c			smallint;
define _ult_letra			smallint;
define _no_letra			smallint;
define _pagada				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_venc			date;
define _fecha_vencimiento	date;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_cob346a.trc";
--trace on;
   
foreach
	{select no_documento
	  into _no_documento
	  from (select no_documento,count(distinct no_poliza) cnt_pol
			   from emiletra
			  where monto_pag <> 0
			    and monto_pen <> 0
			  group by no_documento
			) tmp
	 where cnt_pol > 1
	 order by 1}
	select tmp.no_documento
	  into _no_documento
	  from (select emi.no_documento,count(distinct emi.no_poliza) cnt_pol
			   from emiletra emi
			  inner join emipoliza pol
				 on pol.no_documento = emi.no_documento
			    --and pol.cod_status = '1'
			    and pol.saldo >= 0
			  where emi.monto_pag <> 0
			    and emi.monto_pen <> 0
				and emi.no_documento	not in ('0193-0395-01','0193-0534-01','0193-0536-01','0194-0701-01','0194-0715-01','0194-0730-01','0998-00416-02','0999-02914-02')
			  group by no_documento
			) tmp
	  where cnt_pol > 1
	  order by 1

	call sp_pro545(_no_documento) returning _error, _error_desc;
	call sp_cob346a(_no_documento) returning _error, _error_desc;
	call sp_pro544(_no_documento) returning _error, _error_desc;
	
	--return 0,'No_Poliza: ' || _no_poliza_c || '		no_documento: ' || a_no_documento with resume;
end foreach

return 0,'Actualización Exitosa';
end
end procedure;