-- Procedimiento que Genera el Reporte Detallado del proceso de carga detalle de provision de corredor 
-- Creado    : 28/10/2016 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.   -- execute procedure sp_pro559('2016-01'); 
drop procedure sp_pro559; 
create procedure sp_pro559(a_periodo varchar(7))
returning	char(7),	--	1	periodo
			char(20),	--	2	no_documento
			date,		--	3	vigencia_inic
			date,		--	4	vigencia_final
			char(3),	--	5	cod_ramo
			varchar(50),--	6	nombre_ramo
			char(5),	--	7	cod_agente
			varchar(50),--	8	nombre_agente
			char(10),	--	9	cod_contratante
			varchar(100),	--	10	nombre_contratante
			dec(16,2),	--	11	saldo_tot
			dec(5,2),	--	12	porc_partic_agt
			dec(5,2),	--	13	porc_comis_agt
			dec(16,2);	--	14	provision  
			
define _periodo					char(7);
define _no_documento			char(20);
define _vigencia_inic 			date;
define _vigencia_final 			date;
define _cod_ramo				char(3);
define _nombre_ramo	            varchar(50);
define _cod_agente				char(5);
define _nombre_agente	        varchar(50);
define _cod_contratante         char(10);
define _nombre_contratante	    varchar(100);
define _saldo_tot	            dec(16,2);
define _porc_partic_agt	        dec(5,2);
define _porc_comis_agt	        dec(5,2);
define _provision	            dec(16,2);

set isolation to dirty read;
--set debug file to "sp_pro559.trc"; 
--trace on;

foreach
select 	a.periodo,
		e.no_documento,
		a.vigencia_inic,
		a.vigencia_final,
		a.cod_ramo,
		b.nombre,
		a.cod_agente,
		c.nombre,
		a.cod_contratante,
		d.nombre,
		a.saldo_tot,
		a.porc_partic_agt,
		a.porc_comis_agt,
		a.comision
  into  _periodo	,
		_no_documento	,
		_vigencia_inic	,
		_vigencia_final	,
		_cod_ramo	,
		_nombre_ramo	,
		_cod_agente	,
		_nombre_agente	,
		_cod_contratante	,
		_nombre_contratante	,
		_saldo_tot	,
		_porc_partic_agt	,
		_porc_comis_agt	,
		_provision	  
  from prov_agt a, prdramo b, agtagent c, cliclien d, emipomae e
  where a.periodo =  a_periodo
    and a.cod_ramo = b.cod_ramo
    and a.cod_agente = c.cod_agente
    and a.cod_contratante = d.cod_cliente
    and a.no_poliza = e.no_poliza  

	return	_periodo	,
			_no_documento	,
			_vigencia_inic	,
			_vigencia_final	,
			_cod_ramo	,
			_nombre_ramo	,
			_cod_agente	,
			_nombre_agente	,
			_cod_contratante	,
			_nombre_contratante	,
			_saldo_tot	,
			_porc_partic_agt	,
			_porc_comis_agt	,
			_provision	
			with resume;
end foreach

end procedure