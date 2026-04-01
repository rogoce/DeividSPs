-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada - RENOVACION DE POLIZAS

-- Creado:	23/07/2014 - Autor: Amado Perez M

-- SIS v.2.0 - DEIVID, S.A.

drop procedure ap_proe74;
 
create procedure ap_proe74(a_poliza CHAR(10), a_unidad CHAR(5), a_producto CHAR(5), a_cobertura CHAR(5)) 
                 returning CHAR(5) as unidad,
				           CHAR(5) as producto,
						   CHAR(5) as cod_cobertura,
						   VARCHAR(50) as cobertura,
				           DECIMAL(5,2) as descuento_max,
				           DECIMAL(5,2) as descunto_modelo,
						   DECIMAL(5,2) as descuento_sini,
						   DECIMAL(5,2) as descuento_vehic,
						   DECIMAL(5,2) as descuento_edad,
						   DECIMAL(5,2) as descuento_tv_x_pr,
						   SMALLINT as tipo_descuento,
						   CHAR(3) as tipo_tar,
						   smallint as ano_tarifa;


DEFINE _no_documento        CHAR(20); 
DEFINE _cod_ramo          	CHAR(3);
DEFINE _descuento_max		DECIMAL(5,2);
DEFINE _tipo_descuento      SMALLINT;
DEFINE _cant_g              SMALLINT;
DEFINE _cant_p              SMALLINT;
DEFINE _cant_s 				SMALLINT;
DEFINE _no_motor	        CHAR(50);
DEFINE _cod_modelo			CHAR(5);
DEFINE _cod_tipo			CHAR(3);
DEFINE _tipo_auto			SMALLINT;
DEFINE _no_poliza			CHAR(10);
DEFINE _cant_x_def          SMALLINT;
DEFINE _cod_marca           CHAR(5);
DEFINE _cod_tipo_tar        CHAR(3);
DEFINE _descuento_be, _descuento_fl DECIMAL(5,2);
DEFINE _descuento_modelo    DEC(16,2);

define _no_sinis_ult		smallint;
define _no_sinis_his		smallint;
define _no_vigencias		smallint;
define _no_sinis_pro		dec(16,2);
define _incurrido_bruto		dec(16,2);
define _prima_devengada		dec(16,2);
define _siniestralidad		dec(16,2);
define _descuento_sini		dec(16,2);
define _cod_subramo         CHAR(3);
define _condicion           smallint;
DEFINE _valor				smallint;
define _descuento_vehic     dec(16,2);
define _descuento_edad      dec(16,2);
DEFINE _descuento_tv_x_pr   DECIMAL(16,2);
define _cobertura           varchar(50);
define _vigencia_final      DATE;

define _opcion, _ano_tarifa              smallint;

SET ISOLATION TO DIRTY READ;

SET DEBUG FILE TO "ap_proe74.trc"; 
trace on;

LET _descuento_max = 0;
LET _tipo_descuento = 0;
LET _tipo_descuento = 0;
LET _descuento_modelo = 0;
LET _descuento_sini = 0;
LET _opcion = 0;
LET _descuento_vehic = 0;
let _descuento_edad = 0;
let _descuento_tv_x_pr = 0;

SELECT no_documento, 
       cod_ramo,
	   cod_subramo,
	   vigencia_final
  INTO _no_documento, 
       _cod_ramo,
	   _cod_subramo,
	   _vigencia_final
  FROM emipomae
 WHERE no_poliza = a_poliza;

IF _cod_ramo not in ("002", "023") THEN
   Return null, null, null, null, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, null,0;
END IF 

foreach
SELECT cod_tipo_tar,
       no_unidad,
	   cod_producto
  INTO _cod_tipo_tar,
       a_unidad,
	   a_producto
  FROM emipouni
 WHERE no_poliza = a_poliza
   AND no_unidad = a_unidad
 

-- Buscando informacion del tipo de vehiculo 1 Sedan, 2 Suv, 3 Pick Up
select no_motor, ano_tarifa
  into _no_motor, _ano_tarifa
  from emiauto
 where no_poliza = a_poliza
   and no_unidad = a_unidad;
   
let _ano_tarifa = _ano_tarifa + 1;

if _ano_tarifa = 0 then
	let _ano_tarifa = 1;
end if	

select cod_modelo
  into _cod_modelo
  from emivehic
 where no_motor = _no_motor;

select cod_tipoauto, cod_marca
  into _cod_tipo, _cod_marca
  from emimodel
 where cod_modelo = _cod_modelo;

select tipo_auto
  into _tipo_auto
  from emitiaut
 where cod_tipoauto = _cod_tipo;

if _tipo_auto = 0 then
   Return null, null, null, null, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, null,0;
end if
foreach
select cod_cobertura
  into a_cobertura
  from emipocob
 where no_poliza = a_poliza
   and no_unidad = a_unidad
 
LET _descuento_max = 0;
LET _tipo_descuento = 0;
LET _tipo_descuento = 0;
LET _descuento_modelo = 0;
LET _descuento_sini = 0;
LET _opcion = 0;
LET _descuento_vehic = 0;
let _descuento_edad = 0;
let _descuento_tv_x_pr = 0;

 
-- Busqueda de los descuentos 
SELECT descuento_max, 
	   tipo_descuento
  INTO _descuento_max, 
       _tipo_descuento 
  FROM prdcobpd
 WHERE prdcobpd.cod_producto  = a_producto
   AND prdcobpd.cod_cobertura = a_cobertura;


if _tipo_descuento = 1 then	--> Descuento RC igual para Sedan, Suv, Pick Up
	let _descuento_tv_x_pr = sp_proe89(a_poliza, a_unidad); --> Descuento por tipo de vehiculo por Producto (Ducruet)
elif _tipo_descuento = 2 then --> Descuento Combinado Casco
    let _descuento_max = 0.00;
	let _descuento_tv_x_pr = sp_proe89(a_poliza, a_unidad); --> Descuento por tipo de vehiculo por Producto (Ducruet)
	--Modificacion para comparar y escoger la mejor tarifa
    if _cod_ramo = '002' and _cod_subramo = '001' then
		call sp_pro550(_no_documento) returning _no_documento, _no_sinis_ult, _no_sinis_his, _no_vigencias, _no_sinis_pro, _incurrido_bruto, _prima_devengada, _siniestralidad,	_descuento_sini, _condicion;
		if _condicion = 1 then --Condicion de recargo sobre el descuento
		else
			let _descuento_vehic = ap_proe85a(a_poliza,a_unidad);
			let _descuento_max = sp_proe72(a_poliza,a_unidad);
			if _tipo_auto = 1 and _cod_tipo_tar in ('001','002','006','008') and _no_sinis_ult = 0 then	-- Tarifas Normales y Sedan sin sinietro
				let	_descuento_max = 50;
			end if
			if _vigencia_final >= "01/04/2021" then
				if _descuento_vehic = 0 then
					let _opcion = 1;
				else
					let _opcion = 0;
				end if				
			else
				if _descuento_max > _descuento_vehic then
					let _opcion = 1;
				else
					let _opcion = 0;
				end if
			end if
			let _descuento_max = 0.00;
			let _descuento_vehic = 0.00;
		end if
	end if	
	--
    if _cod_ramo = '002' and _cod_subramo = '001' and _opcion = 0 then
		let _descuento_vehic = ap_proe85a(a_poliza,a_unidad);
	end if
	if _descuento_vehic > 0.00 then
		let _descuento_edad = sp_proe86a(a_poliza,a_unidad); --> Descuento por edad
		call sp_pro550(_no_documento) returning _no_documento, _no_sinis_ult, _no_sinis_his, _no_vigencias, _no_sinis_pro, _incurrido_bruto, _prima_devengada, _siniestralidad,	_descuento_sini, _condicion;
		if _condicion = 1 then	--Condicion de recargo sobre el descuento
			let _descuento_vehic = _descuento_vehic - _descuento_vehic * _descuento_sini / 100;
			let _descuento_sini = 0.00;
		end if
	else
		let _descuento_max = sp_proe72(a_poliza,a_unidad);

		let _descuento_modelo = 0.00;
		let _descuento_modelo = sp_proe81(_cod_marca, _cod_modelo);
		
		if  _descuento_modelo is null then
			let _descuento_modelo = 0.00;
		end if
		if _cod_ramo = '002' and _cod_subramo = '001' then
			let _descuento_edad = sp_proe86a(a_poliza,a_unidad); --> Descuento por edad
		end if
				
		--Buscando siniestros de la ultima vigencia
		call sp_pro550(_no_documento) returning _no_documento, _no_sinis_ult, _no_sinis_his, _no_vigencias, _no_sinis_pro, _incurrido_bruto, _prima_devengada, _siniestralidad,	_descuento_sini, _condicion;
		let _descuento_sini = 0.00;
		if (_tipo_auto = 1 and _cod_tipo_tar in ('001','002','006','007','008') and _no_sinis_ult = 0) or (_tipo_auto = 1 and _cod_ramo = '023' and _cod_tipo_tar in ('001', '002', '006','007','008') and _no_sinis_ult = 0) then	--'002'
			let	_descuento_max = 50;
		else
			if _cod_ramo = '002' AND _cod_subramo = '001' then
				call sp_pro550(_no_documento) returning _no_documento, _no_sinis_ult, _no_sinis_his, _no_vigencias, _no_sinis_pro, _incurrido_bruto, _prima_devengada, _siniestralidad,	_descuento_sini, _condicion;
				if _condicion = 1 then -- Recargo
					let _descuento_max = _descuento_max - _descuento_max * _descuento_sini / 100;
					let _descuento_sini = 0.00;
				end if
		   end if
		end if
	end if
else
	let _descuento_max = 0;
end if

let _descuento_max = _descuento_max + _descuento_modelo + _descuento_sini + _descuento_vehic + _descuento_edad + _descuento_tv_x_pr;

select nombre
  into _cobertura
  from prdcober
 where cod_cobertura = a_cobertura;

return a_unidad,
       a_producto,
	   a_cobertura,
	   _cobertura,
       _descuento_max, 
       _descuento_modelo, 
	   _descuento_sini, 
	   _descuento_vehic, 
	   _descuento_edad, 
	   _descuento_tv_x_pr,
	   _tipo_descuento,
	   _cod_tipo_tar,
	   _ano_tarifa
	   with resume;
end foreach
end foreach

end procedure
