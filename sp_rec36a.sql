-- Reporte de Incurrido Neto por Ramo
-- Creado    : 27/07/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 17/08/2000 - Autor: Demetrio Hurtado Almanza
-- SIS v.2.0 - d_sp_rec01a_dw1 - DEIVID, S.A.

drop procedure sp_rec36a;
create procedure "informix".sp_rec36a(
a_compania	char(3),
a_agencia	char(3),
a_periodo1	char(7),
a_periodo2	char(7),
a_sucursal	char(255)	default "*",
a_ramo		char(255)	default "*") 
returning	char(18),
			char(100),
			char(20),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			char(50),
			char(50),
			char(255),
			char(10);

define v_filtros			char(255);
define v_cliente_nombre 	char(100);
define v_compania_nombre	char(50); 
define v_ramo_nombre		char(50); 
define v_doc_poliza			char(20);
define v_doc_reclamo		char(18);
define v_transaccion		char(10);
define _cod_cliente			char(10);
define _no_reclamo			char(10);
define _no_poliza			char(10); 
define _periodo				char(7);
define _cod_ramo			char(3);
define v_deducible_total	dec(16,2);
define v_incurrido_total	dec(16,2);
define v_deducible_bruto	dec(16,2);
define v_incurrido_bruto	dec(16,2);
define v_deducible_neto		dec(16,2);
define v_salvado_bruto		dec(16,2);
define v_salvado_total		dec(16,2);
define v_salvado_neto		dec(16,2);
define v_incurrido_neto		dec(16,2);

set isolation to dirty read;

-- Nombre de la Compania
let  v_compania_nombre = sp_sis01(a_compania);

-- cargar el incurrido
--drop table tmp_sinis;

let v_filtros = sp_rec36(
a_compania,
a_agencia, 
a_periodo1,
a_periodo2,
a_sucursal,
'*', 
a_ramo,
'*', 
'*', 
'*', 
'*');

foreach
	select no_reclamo,
		   no_poliza,
		   salvado_total*(-1),
		   salvado_bruto*(-1),
		   salvado_neto*(-1), 
		   deducible_total*(-1),
		   deducible_bruto*(-1), 
		   deducible_neto*(-1),
		   incurrido_total*(-1),	
		   incurrido_bruto*(-1),
		   incurrido_neto*(-1),
		   cod_ramo,	
		   periodo,
		   numrecla,
		   transaccion
	  into _no_reclamo,
		   _no_poliza,	
		   v_salvado_total,
		   v_salvado_bruto,
		   v_salvado_neto,
		   v_deducible_total,
		   v_deducible_bruto,
		   v_deducible_neto,
		   v_incurrido_total,
		   v_incurrido_bruto,
		   v_incurrido_neto,
		   _cod_ramo,
		   _periodo,
		   v_doc_reclamo,
		   v_transaccion
	  from tmp_sinis
	 where seleccionado = 1
	 order by numrecla,no_poliza

	select cod_reclamante 
	  into _cod_cliente
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select nombre
	  into v_ramo_nombre
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select no_documento
	  into v_doc_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into v_cliente_nombre
	  from cliclien
	 where cod_cliente = _cod_cliente;

	return v_doc_reclamo,
	 	   v_cliente_nombre,
	 	   v_doc_poliza,
	 	   v_salvado_total, 
		   v_salvado_bruto,
		   v_salvado_neto,
		   v_deducible_total,	
		   v_deducible_bruto,
		   v_deducible_neto,
		   v_incurrido_total,
		   v_incurrido_bruto,	
		   v_incurrido_neto,	
		   v_ramo_nombre,
		   v_compania_nombre,
		   v_filtros,
		   v_transaccion
		   with resume;
end foreach
drop table tmp_sinis;
end procedure;