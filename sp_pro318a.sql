--Procedure que Crea los Registros en la Estructura del Pool de Renovación Manual y en la Estructura de Opciones de Renovación
-- Creado    : 25/06/2013 - Autor: Román Gordón
-- sis v.2.0 - deivid, s.a. 

drop procedure sp_pro318a;
create procedure "informix".sp_pro318a(a_no_poliza char(10))
returning integer,varchar(100);

define _error_desc			varchar(100);
define _desc_limite1		varchar(50);
define _desc_limite2		varchar(50);
define _no_documento		char(21);
define _no_factura			char(10);
define _no_poliza			char(10);
define _usuario				char(8);
define _cod_cobertura		char(5);
define _cod_producto		char(5);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_ruta			char(5);
define _cod_tipotran		char(3);
define _sucursal_origen		char(3);
define _cod_no_renov		char(3);
define _cod_compania		char(3);
define _centro_costo		char(3);
define _cod_agente			char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6);
define _porc_partic_suma	dec(9,6);
define _suma_asegurada		dec(16,2);
define _prima_anual			dec(16,2);
define _suma_deprec			dec(16,2);
define _prima_neta			dec(16,2);
define _deducible			dec(16,2);
define _descuento			dec(16,2);
define _incurrido			dec(16,2);
define _limite1				dec(16,2);
define _limite2				dec(16,2);
define _recargo				dec(16,2);
define _saldo				dec(16,2);
define _pagos				dec(16,2);
define _prima				dec(16,2);
define _cant_reclamos		smallint;
define _no_renovar			smallint;
define _tot_pagos			smallint;
define _cnt_reglo			smallint;
define _renovada			smallint;
define _cantidad			smallint;
define _orden				smallint;
define _serie				smallint;
define _cnt					smallint;
define _error				integer;
define _vigencia_final		date;
define _vigencia_inic		date;

begin

let _cod_compania = '001';
let _no_unidad = '00001';
let _cod_ruta = '';

--set debug file to "sp_pro318a.trc";
--trace on;


select no_documento,
	   vigencia_inic,
	   vigencia_final,
	   no_factura,
	   renovada,
	   no_renovar,
	   cod_no_renov,
	   sucursal_origen,
	   cod_ramo
  into _no_documento,
	   _vigencia_inic,
	   _vigencia_final,
	   _no_factura,
	   _renovada,
	   _no_renovar,
	   _cod_no_renov,
	   _sucursal_origen,
	   _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

if _sucursal_origen = '047' then
	let _sucursal_origen = '001';
end if

select centro_costo
  into _centro_costo
  from insagen
 where codigo_agencia  = _sucursal_origen
   and codigo_compania = _cod_compania;

--Busca el usuario al que se le asignará la Renovación
call sp_pro332(_centro_costo,"5") returning _usuario;
 
foreach
	select cod_agente
	  into _cod_agente
	  from emipoagt
	 where no_poliza = a_no_poliza
	exit foreach;
end foreach;

update emirepo
   set estatus = 4,--Pool de Renovación Manual.
	   user_added = _usuario
 where no_poliza  = a_no_poliza;

select count(*) 
  into _cnt
  from emirepol
 where no_poliza = a_no_poliza;
 
--Si ya existe en la tabla del Pool Manual no es necesario seguir con el proceso
if _cnt > 0 then
	return 0,'Ya existe el registro en el Set de Renovación';
end if

call sp_sis61d(a_no_poliza) returning _error;

if _error > 0 then
	return _error,'Error al Eliminar la información de Renovación';
end if

let _saldo = sp_cob115b('001','001',_no_documento,'');
if _saldo is null then
	let _saldo = 0;
end if

select count(*) 
  into _cant_reclamos
  from recrcmae
 where no_poliza   = a_no_poliza
   and actualizado = 1;

if _cant_reclamos is null then
	let _cant_reclamos = 0;
end if

let _tot_pagos = 0;
foreach
	select cod_tipotran 
	  into _cod_tipotran
	  from rectitra
	 where tipo_transaccion in (4,5,6,7)

	select sum(x.monto) 
	  into _pagos
	  from rectrmae x, recrcmae y
	 where y.no_poliza     = a_no_poliza
	   and y.actualizado   = 1
	   and x.no_reclamo    = y.no_reclamo
	   and x.actualizado   = 1
	   and x.cod_tipotran  = _cod_tipotran;

	if _pagos is null then
		let _pagos = 0;
	end if

	let _tot_pagos = _tot_pagos + _pagos;
end foreach

-- Variacion de Reserva
select sum(x.variacion) 
  into _incurrido
  from rectrmae x, recrcmae y
 where y.no_poliza   = a_no_poliza
   and y.actualizado = 1
   and x.no_reclamo  = y.no_reclamo
   and x.actualizado = 1;

if _incurrido is null then
	let _incurrido = 0;
end if

-- Incurrido
let _incurrido = _incurrido + _tot_pagos;

insert into emirepol(
		no_poliza,
		user_added,
		cod_no_renov,
		no_documento,
		renovar,
		no_renovar,
		fecha_selec,
		vigencia_inic,
		vigencia_final,
		saldo,
		cant_reclamos,
		no_factura,
		incurrido,
		pagos,
		porc_depreciacion,
		cod_agente,
		estatus
		)
values( a_no_poliza,
		_usuario,
		_cod_no_renov,
		_no_documento,
		_renovada,
		_no_renovar,
		today,
		_vigencia_inic,
		_vigencia_final,
		_saldo,
		_cant_reclamos,
		_no_factura,
		_incurrido,
		_tot_pagos,
		0.00,
		_cod_agente,
		4);

--Procedure que inserta la información de Emision en la Estructura de Opciones de Renovación.
foreach
	select cod_cobertura,
		   limite_1,
		   limite_2,
		   prima_anual,
		   prima,
		   deducible,
		   descuento,
		   recargo,
		   prima_neta,
		   orden,
		   desc_limite1,
		   desc_limite2
	  into _cod_cobertura,
		   _limite1,
		   _limite2,
		   _prima_anual,
		   _prima,
		   _deducible,
		   _descuento,
		   _recargo,
		   _prima_neta,
		   _orden,
		   _desc_limite1,
		   _desc_limite2
	  from emipocob
	 where no_poliza     = a_no_poliza
	   and no_unidad     = _no_unidad

	insert into emireau1(
			no_poliza,
			no_unidad,
			cod_cobertura,
			orden,
			chek_o,
			deducible_o,
			limite_1_o,
			limite_2_o,
			prima_anual_o,
			prima_o,
			descuento_o,
			recargo_o,
			prima_neta_o,
			chek_1,
			deducible_1,
			limite_1_1,
			limite_2_1,
			prima_anual_1,
			prima_1,
			descuento_1,
			recargo_1,
			prima_neta_1,
			chek_2,
			deducible_2,
			limite_1_2,
			limite_2_2,
			prima_anual_2,
			prima_2,
			descuento_2,
			recargo_2,
			prima_neta_2,
			deducible_3,
			limite_1_3,
			limite_2_3,
			prima_anual_3,
			prima_3,
			descuento_3,
			recargo_3,
			prima_neta_3,
			factor_vigencia,
			desc_limite1,
			desc_limite2)
	values(	a_no_poliza,
			_no_unidad,
			_cod_cobertura,
			_orden,
			1,
			_deducible,
			_limite1,
			_limite2,
			_prima_anual,
			_prima,
			_descuento,
			_recargo,
			_prima_neta,
			1,
			_deducible,
			_limite1,
			_limite2,
			_prima_anual,
			_prima,
			_descuento,
			_recargo,
			_prima_neta,
			1,
			_deducible,
			_limite1,
			_limite2,
			_prima_anual,
			_prima,
			_descuento,
			_recargo,
			_prima_neta,
			1,
			_deducible,
			_limite1,
			_limite2,
			_prima_anual,
			_prima,
			_descuento,
			_recargo,
			_prima_neta,
			_desc_limite1,
			_desc_limite2);
end foreach
call sp_pro82e(_usuario,a_no_poliza,_no_documento,_vigencia_final,0.00) returning _cod_producto,_no_poliza,_no_unidad,_suma_deprec,_cantidad;

--Procedure de Cambio de Productos Comerciales
call sp_pro561(a_no_poliza,_no_unidad) returning _error;

if _error not in (0,1) then
	return _error,'Error al Realizar el cambio de Productos Comerciales.';
end if

--Carga de Reaseguro Global de la Póliza en caso de que no exista
let _cnt_reglo = 0;

select count(*)
  into _cnt_reglo
  from emireglo
 where no_poliza = a_no_poliza;

if _cnt_reglo = 0 then
	select suma_aseg,
		   year(vigencia_inic),
		   vigencia_inic
	  into _suma_asegurada,
		   _serie,
		   _vigencia_inic
	  from emireaut
	 where no_poliza = _no_poliza
	   and no_unidad = '00001';

	foreach
		select cod_ruta
		  into _cod_ruta
		  from rearumae  
		 where cod_compania = '001'
		   and cod_ramo = _cod_ramo
		   and _vigencia_inic between vig_inic and vig_final
		   and activo = 1
		 order by cod_ruta asc
		exit foreach;
	end foreach

	if _cod_ruta is null or _cod_ruta = '' then
		select descripcion
		  into _error_desc
		  from inserror
		 where tipo_error = 2
		   and code_error = 291;
		
		return -1,_error_desc;
	end if
	
	foreach
		select orden,
			   cod_contrato,
			   porc_partic_prima,
			   porc_partic_suma
		  into _orden,
			   _cod_contrato,
			   _porc_partic_prima,
			   _porc_partic_suma
		  from rearucon
		 where cod_ruta = _cod_ruta

		insert into emireglo (
				no_poliza,
				no_endoso,
				orden,
				cod_contrato,
				porc_partic_prima,
				porc_partic_suma,
				suma_asegurada,
				prima,
				cod_ruta)
		values	(_no_poliza,
				"00000",
				_orden,
				_cod_contrato,
				_porc_partic_prima,
				_porc_partic_suma,
				0.00,
				0.00,
				_cod_ruta);
	end foreach
end if

call sp_pro82f(a_no_poliza,_no_unidad,0.00, _cod_compania,0) returning _error;
if _error <> 0 then
	return _error,'Error al Verificar el Reaseguro Global de la Póliza';
end if

for _cnt = 1 to 8
	call sp_pro82h(a_no_poliza,_cnt);
end for

update emireaut
   set opcion_final = 0
 where no_poliza = a_no_poliza;
 
--Crea las coberturas con la opcion de renovacion			
call sp_pro82c(a_no_poliza,0) returning _error,_error_desc; --0 es la opcion de renovacion

if _error <> 0 then
	return _error,'Error al Crear las coberturas de la póliza.';
end if

select suma_asegurada
  into _suma_asegurada
  from emiporen
 where no_poliza = a_no_poliza;
 
call sp_pro82fa(a_no_poliza,_no_unidad, _suma_asegurada, '001',0) returning _error;

if _error <> 0 then
	return _error,'Error al Crear el Reaseguro de la Unidad';
end if

end 
return 0,'Insercion Exitosa';
end procedure