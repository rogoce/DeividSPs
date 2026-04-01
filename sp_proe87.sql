-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada - RENOVACION DE POLIZAS

-- Creado:	23/07/2014 - Autor: Amado Perez M

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe87;
 
create procedure sp_proe87(a_poliza CHAR(10), a_unidad CHAR(5), a_producto CHAR(5), a_cobertura CHAR(5), a_opc smallint)
returning DECIMAL(5,2), dec(16,2), dec(16,2);


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
DEFINE _cant_x_def          SMALLINT;
DEFINE _cod_marca           CHAR(5);

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
define _descuento_modelo    decimal(16,2);
DEFINE _cod_tipo_tar        CHAR(3);
define _fecha_envio         date;
define _mes                 char(2);
DEFINE _descuento_be, _descuento_fl DECIMAL(5,2);
define _descuento_edad      DECIMAL(16,2);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_proe74b.trc"; 
--trace on;

LET _descuento_max = 0;
LET _tipo_descuento = 0;
LET _descuento_modelo = 0;
LET _descuento_sini = 0;
let _fecha_envio = null;

SELECT no_documento, 
       cod_ramo, 
	   cod_subramo
  INTO _no_documento, 
       _cod_ramo,
	   _cod_subramo
  FROM emipomae
 WHERE no_poliza = a_poliza;
 
{select max(fecha_envio) --Renovación de Ducruet pantalla emision electronica
  into _fecha_envio
  from emirenduc
 where no_documento = _no_documento;
 
if (_fecha_envio >= '01/01/2017' and _fecha_envio <= '02/03/2017' ) and _fecha_envio is not null then
	Return 0.00, 0.00, 0.00;
end if}


IF _cod_ramo <> "002" OR _cod_subramo <> '001' THEN
   Return 0.00, 0.00, 0.00;
END IF 


-- Buscando informacion del tipo de vehiculo 1 Sedan, 2 Suv, 3 Pick Up
select no_motor
  into _no_motor
  from emiauto
 where no_poliza = a_poliza 
   and no_unidad = a_unidad;

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
   Return 0.00, 0.00, 0.00;
end if
   
-- Busqueda de los descuentos 
SELECT tipo_descuento
  INTO _tipo_descuento 
  FROM prdcobpd
 WHERE prdcobpd.cod_producto  = a_producto
   AND prdcobpd.cod_cobertura = a_cobertura;

-- Eliminando descuento de buena experiencia

IF _cod_ramo = '002' THEN
	IF _tipo_descuento IN (1,2) THEN
		if a_opc in(1,5) then

			delete from emirede0
			 where no_poliza = a_poliza
			   and no_unidad = a_unidad
			   and cod_descuen = "001";

		elif a_opc = 2 then
			delete from emirede1
			 where no_poliza = a_poliza
			   and no_unidad = a_unidad
			   and cod_descuen = "001";

		elif a_opc = 3 then
			delete from emirede2
			 where no_poliza = a_poliza
			   and no_unidad = a_unidad
			   and cod_descuen = "001";

		end if
	END IF 

END IF

 
if _tipo_descuento = 1 then	--> Descuento RC igual para Sedan, Suv, Pick Up
elif _tipo_descuento = 2 then --> Descuento Combinado Casco
    let _descuento_max = 0;
	let _descuento_max = sp_proe85a(a_poliza,a_unidad);
		
	--Buscando siniestros de la ultima vigencia
	call sp_pro550(_no_documento) returning _no_documento, _no_sinis_ult, _no_sinis_his, _no_vigencias, _no_sinis_pro, _incurrido_bruto, _prima_devengada, _siniestralidad,	_descuento_sini, _condicion;
	let _descuento_sini = 0.00;
		if _cod_ramo = '002' AND _cod_subramo = '001' and _descuento_max > 0.00 then
			let _descuento_edad = sp_proe86a(a_poliza,a_unidad); --> Descuento por edad

			call sp_pro550(_no_documento) returning _no_documento, _no_sinis_ult, _no_sinis_his, _no_vigencias, _no_sinis_pro, _incurrido_bruto, _prima_devengada, _siniestralidad,	_descuento_sini, _condicion;
			if _condicion = 1 then -- Recargo
				let _descuento_max = _descuento_max - _descuento_max * _descuento_sini / 100;
				let _descuento_sini = 0.00;
			end if
	   end if
else
	let _descuento_max = 0;
end if

return _descuento_max,
       _descuento_edad,
	   _descuento_sini;

end procedure
