
-- Creado: 30/10/2024 - Autor: Armando Moreno M.
--execute procedure sp_tarifas_salud_n2()

drop procedure sp_tarifas_salud_n2;
create procedure sp_tarifas_salud_n2(a_periodo char(7))
returning integer;

define v_filtros			char(255);
define _nom_corredor		varchar(150);
define _nom_zona			varchar(150);
define _error_desc			varchar(50);
define _asegurado			varchar(50);
define _dependiente		varchar(50);
define _recargo_uni		varchar(50);
define _recargo_dep		varchar(50);
define v_desc_nombre		char(35);
define _periodo_pago		char(20);
define _estatus				char(20);
define _no_documento		char(20);
define _cod_dependiente		char(10);
define _no_poliza			char(10);
define _cod_asegurado		char(10);
define v_nopoliza			char(10);
define _periodo_hasta		char(7);
define _periodo_desde		char(7);
define _cod_producto		char(5);
define _no_unidad			char(5);
define _cod_recargo		char(3);
define _cod_perpago		char(3);
define _prima_dependiente	dec(16,2);
define _prima_neta_tot	dec(16,2);
define _prima_neta_pol	dec(16,2);
define _prima_desde_dep	dec(16,2);
define _prima_hasta_dep	dec(16,2);
define _prima_desde		dec(16,2);
define _prima_hasta		dec(16,2);
define _porc_recarg_uni	dec(16,2);
define _porc_recarg_dep	dec(16,2);
define _porc_aum_edad		dec(5,2);
define _fecha_aniv_dep	date;
define _fecha_aniv_uni	date;
define _fecha_desde		date;
define _fecha_hasta		date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _vigencia2022		date;
define _vigencia2023		date;
define _vigencia2024		date;
define _dia_vigencia		smallint;
define _mes_vigencia		smallint;
define _edad_dep_d		smallint;
define _edad_dep_h		smallint;
define _edad_aseg_d		smallint;
define _opcion		    smallint;
define _edad_aseg_22		smallint;
define _edad_aseg_23		smallint;
define _edad_aseg_24		smallint;
define _edad_dep_22		smallint;
define _edad_dep_23		smallint;
define _edad_dep_24		smallint;
define _mes_periodo		smallint;
define _meses				smallint;
define _error_isam,_error   integer;
define _periodo_validar     char(7);

set isolation to dirty read;

--set debug file to "sp_tarifas_salud_n2.trc";
--trace on;
create temp table tmp_tar_salud_n(
no_documento      char(20),
no_unidad		  char(5),
cod_asegurado     char(10),
cod_dependiente   char(10),
opcion            smallint) with no log;
create index tmp_tar_s_ix1 on tmp_tar_salud_n(no_documento);
create index tmp_tar_s_ix2 on tmp_tar_salud_n(opcion);

begin
on exception set _error,_error_isam,_error_desc

	if _no_documento is null then
		let _no_documento = '';
	end if	
	
	return _error;
end exception                                            

let _nom_corredor = '';
let _nom_zona = '';

let _mes_periodo = a_periodo[6,7];
let _fecha_desde = mdy(_mes_periodo,1,a_periodo[1,4]);
let _fecha_hasta = sp_sis36(a_periodo);

foreach                                           
	select no_documento,
	       cod_asegurado,
		   opcion
	  into _no_documento,			
		   _cod_asegurado,
		   _opcion
	  from emicartasal6
     where periodo = a_periodo
  order by opcion
	
	if _opcion = 2 then
		continue foreach;
	end if
	
	--Validacion de exclusion de polizas para insercion del recargo. Caso 14171 Fany 29/06/2025
	let _periodo_validar = null;
	foreach
		select periodo
		  into _periodo_validar
		  from prd_sal_rec_exc
		 where no_documento = _no_documento
		   and activo = 1
		exit foreach;   
	end foreach
	if _periodo_validar is not null then
		if a_periodo < _periodo_validar then
			continue foreach;
		end if
	end if
	
	let _no_poliza = sp_sis21(_no_documento);
	
	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza
		   and activo = 1
		
			insert into tmp_tar_salud_n(
			no_documento,   
			no_unidad,
			cod_asegurado,
			cod_dependiente,
			opcion)
			values(
			_no_documento,
			_no_unidad,
			_cod_asegurado,
			null,
			_opcion);
			
		foreach
			select cod_cliente
			  into _cod_dependiente
			  from emidepen
			 where no_poliza = _no_poliza
               and no_unidad = _no_unidad
               and activo = 1
			   
			insert into tmp_tar_salud_n(
			no_documento,   
			no_unidad,
			cod_asegurado,
			cod_dependiente,
			opcion)
			values(
			_no_documento,
			_no_unidad,
			_cod_asegurado,
			_cod_dependiente,
			_opcion);
		
		end foreach 
	end foreach
end foreach
return 0;
end
end procedure;   