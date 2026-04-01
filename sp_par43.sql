-- Informe para IMCS

-- Creado    : 04/09/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 31/10/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_prod_sp_par43_dw1 - DEIVID, S.A.

drop procedure sp_par43;

create procedure sp_par43(a_compania char(3),a_periodo  char(7))
returning char(20),		-- Poliza
		  char(5),		-- Unidad
		  char(7),
		  date,
		  integer,
		  char(7),
		  date,
		  char(1),
		  char(10);

define v_no_documento		char(20);
define v_no_unidad			char(5);
define v_nombre_subramo		char(50);
define v_fecha_efectiva		date;
define v_nombre_asegurado	char(100);
define v_principal			char(1);
define v_conyugue			char(1);
define v_hijo				char(1);
define v_cedula				char(30);
define v_fecha_nac			date;
define v_tipo				char(1);
define v_nombre_cia   		char(50);
		  	
define _cod_ramo			char(3);
define _cod_subramo			char(3);
define _no_poliza			char(10);
define _fecha_emi_pol		date;
define _fecha_emi_uni		date;
define _cod_asegurado		char(10);
define _mes_espera          smallint;
define _cod_parentesco		char(3);
define _tipo_parentesco		smallint;
define _fecha_cancelacion 	date;
define _no_endoso			char(5);
define _cod_endomov			char(3);
define _periodo             char(7);
define _estatus_poliza		smallint;
define _cod_procedimiento	char(5);
define v_pre_existen		smallint;
define v_pre_exis_desc		char(50);
define v_fecha_revision		date;
define _leer_aseg			char(10);
define v_monto				dec(16,2);
define _tar_periodo			char(7);
define v_tar_tarifa			dec(16,2);
define _cant_certificados	integer;
define _periodo_vigente     char(7);
define _vigencia_vigente	date;
define _emision_actual		date;
define _no_activo_desde		date;
define _cant_unidades   	integer;

define _periodo_canc		char(7);
define _tar_canc_tar		dec(16,2);
define _tar_canc_acu		dec(16,2);
	
set isolation to dirty read;

--set debug file to "sp_pro74.trc";
--trace on;

let v_nombre_cia    = sp_sis01(a_compania); 

select cod_ramo
  into _cod_ramo
  from prdramo
 where ramo_sis = 5;

select cod_endomov
  into _cod_endomov
  from endtimov
 where tipo_mov = 2;

-- Polizas y Certificados Vigentes
--{
let v_tipo = 1;
let _cant_certificados    = 0;
let _periodo_vigente[5,5] = "-";

if a_periodo[6,7] = 1 then
	let _periodo_vigente[1,4] = a_periodo[1,4] - 1;
	let _periodo_vigente[6,7] = "12";
else

	let _periodo_vigente[1,4] = a_periodo[1,4];

	if (a_periodo[6,7] - 1 ) < 10 then 
		let _periodo_vigente[6,7] = "0" || (a_periodo[6,7] - 1 );
	else
		let _periodo_vigente[6,7] = (a_periodo[6,7] - 1 );
	end if	
end if

let _periodo_vigente  = _periodo_vigente;
let _vigencia_vigente = MDY(_periodo_vigente[6,7], 1, _periodo_vigente[1,4]);
let _vigencia_vigente = _vigencia_vigente;
let _emision_actual   = MDY(a_periodo[6,7], 1, a_periodo[1,4]);
let _emision_actual   = _emision_actual;

foreach
 select p.no_poliza,
        p.estatus_poliza,
		u.no_activo_desde,
		u.fecha_emision,
		p.periodo,
		p.no_documento,
		no_unidad
   into _no_poliza,
        _estatus_poliza,
		_no_activo_desde,
		_fecha_emi_uni,
		_periodo,
		v_no_documento,
		v_no_unidad
   from emipouni u, emipomae p
  where u.no_poliza            = p.no_poliza
	and	p.cod_ramo             = _cod_ramo
    and p.cod_subramo          in ("007", "008", "009")
    and p.actualizado          = 1
	and p.vigencia_final       >= _vigencia_vigente
--	and u.fecha_emision        < _emision_actual
--	and p.periodo              < a_periodo
--	and p.no_documento         = "1899-00209-01"

	-- Verificaciones de Cuando se Cancelo la Poliza

	let _periodo_canc = "";

	if _estatus_poliza in (2, 4) then

		select max(no_endoso)
		  into _no_endoso
		  from endedmae
		 where no_poliza   = _no_poliza
		   and actualizado = 1
		   and cod_endomov = _cod_endomov
		   and periodo    <= a_periodo;

		select periodo
		  into _periodo_canc
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso; 	

		if _periodo_canc < a_periodo then
			continue foreach;
		end if

	end if

	-- Certificados Eliminados
	
	if _no_activo_desde is not null then
		if _no_activo_desde < _emision_actual then
			continue foreach;
		end if
	end if

	select count(*)
	  into _cant_unidades
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cant_unidades = 1 then
		if _periodo >= a_periodo then
			continue foreach;
		end if
	else
		if _fecha_emi_uni >= _emision_actual then
			continue foreach;
		end if
	end if

{
	select cantidad
	  into _cant_certificados
	  from tmp_vigen
	 where no_poliza = _no_poliza
	   and no_unidad = v_no_unidad;

	if _cant_certificados is null then
		let v_tipo = "";
	else
		let v_tipo = "*";
	end if
}
	begin
	on exception in(-268)
		update tmp_vigen
		   set cantidad  = cantidad + 1
		 where no_poliza = _no_poliza
		   and no_unidad = v_no_unidad;
	end exception
		insert into tmp_vigen
		values(_no_poliza, v_no_unidad, 1);
	end

	let v_tipo = "";

	 return v_no_documento,
	        v_no_unidad,
			_periodo_canc,
			_no_activo_desde,
			_cant_unidades,
			_periodo,
			_fecha_emi_uni,
			v_tipo,
			_no_poliza
			with resume;

end foreach

end procedure