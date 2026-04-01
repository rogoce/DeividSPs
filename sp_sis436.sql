----------------------------------------------------------
--Procedure que retorna el cod_cliente de cliclien en base del id_relac_cliente de ttcorp
--Creado    : 04/09/2015 - Autor: Román Gordón
----------------------------------------------------------

drop procedure sp_sis436;
create procedure sp_sis436(a_no_poliza char(10), a_fecha_hasta date)
returning	integer,
			varchar(255);

define _error_desc			varchar(255);
define _cod_cliente			char(10);
define _cod_cober_reas		char(3);
define _cod_cobertura		char(5);
define _no_unidad			char(5);
define _prima_neta_tot		dec(16,2);
define _prima_anual			dec(16,2);
define _prima_neta			dec(16,2);
define _descuento			dec(16,2);
define _recargo				dec(16,2);
define _prima				dec(16,2);
define _porc_proporcion		dec(9,6);
define _error				integer;
define _error_isam			integer;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	return _error,_error_desc;
end exception

--set debug file to "sp_sis436.trc";
--trace on;

drop table if exists tmp_emipocob;

create temp table tmp_emipocob(
no_poliza		char(10),
no_unidad		char(5),
cod_cobertura	char(5),
cod_cober_reas	char(3),
porc_proporcion	dec(9,6),
prima_anual		dec(16,2),
prima			dec(16,2),
descuento		dec(16,2),
recargo			dec(16,2),
prima_neta		dec(16,2),
primary key(no_poliza,no_unidad,cod_cobertura,cod_cober_reas)) with no log;

foreach
	select c.no_unidad,
		   c.cod_cobertura,
		   p.cod_cober_reas,
		   c.prima_anual,
		   c.prima,
		   c.descuento,
		   c.recargo,
		   c.prima_neta
	  into _no_unidad,
		   _cod_cobertura,
		   _cod_cober_reas,
		   _prima_anual,
		   _prima,
		   _descuento,
		   _recargo,
		   _prima_neta
	  from endedmae e, endedcob c, prdcober p  
	 where e.no_poliza = c.no_poliza
	   and e.no_endoso = c.no_endoso
	   and c.cod_cobertura = p.cod_cobertura
	   and e.no_poliza = a_no_poliza
	   and e.fecha_emision <= a_fecha_hasta
	   and e.vigencia_inic <= a_fecha_hasta
	   and e.actualizado = 1

	begin
		on exception in(-268,-239)
			update tmp_emipocob
			   set prima_anual = prima_anual + _prima_anual,
				   prima = prima + _prima,
				   descuento = descuento + _descuento,
				   recargo = recargo + _recargo,
				   prima_neta = prima_neta + _prima_neta
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad
			   and cod_cobertura = _cod_cobertura
			   and cod_cober_reas = _cod_cober_reas;
		end exception

		insert into tmp_emipocob(
				no_poliza,
				no_unidad,
				cod_cobertura,
				cod_cober_reas,
				prima_anual,
				prima,
				descuento,
				recargo,
				prima_neta,
				porc_proporcion)
		values(	a_no_poliza,
				_no_unidad,
				_cod_cobertura,
				_cod_cober_reas,
				_prima_anual,
				_prima,
				_descuento,
				_recargo,
				_prima_neta,
				0);
	end
end foreach

select sum(prima_neta)
  into _prima_neta_tot
  from tmp_emipocob;

if _prima_neta_tot is null then
	let _prima_neta_tot = 0;
end if 

foreach
	select c.cod_cober_reas,
		   sum(t.prima_neta/_prima_neta_tot) * 100
	  into _cod_cober_reas,
		   _porc_proporcion
	  from tmp_emipocob t, prdcober c
	 where t.cod_cobertura = c.cod_cobertura
	 group by cod_cober_reas

	update tmp_emipocob
	   set porc_proporcion = _porc_proporcion
	 where cod_cober_reas = _cod_cober_reas;
end foreach

return 0,'Actualización Exitosa';

end
end procedure;