-- Procedimiento que Genera el Reporte Detallado del proceso de carga detalle de provision de corredor
-- Creado    : 28/10/2016 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.   -- execute procedure sp_pro560('2016-01');
drop procedure sp_pro560;
create procedure sp_pro560(a_periodo varchar(7))
returning	char(7),	--	1	periodo
			varchar(50),--	2	nombre_ramo
			dec(16,2),	--	3	saldo_tot
			dec(16,2);	--	4	comision			
			
define _periodo				char(7);
define _nombre_ramo	        varchar(50);
define _saldo_tot	        dec(16,2);
define _comision	        dec(16,2);

set isolation to dirty read;
-- set debug file to "sp_pro560.trc";   -- Ramo, Saldo, Monto, Provisión 
-- trace on; 

foreach 
	select b.nombre,
		   sum(a.saldo_tot),
		   sum(a.comision) 
	  into _nombre_ramo, 
		   _saldo_tot,
		   _comision 
	  from prov_agt a, prdramo b
	 where a.cod_ramo = b.cod_ramo 
	   and a.periodo =  a_periodo
	 group by b.nombre
	 order by b.nombre  

return	a_periodo,
		_nombre_ramo,
		_saldo_tot,
		_comision with resume;			
end foreach
end procedure;