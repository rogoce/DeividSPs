-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada - RENOVACION DE POLIZAS

-- Creado:	23/07/2014 - Autor: Amado Perez M

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe74b1;
 
create procedure sp_proe74b1(a_poliza CHAR(10), a_unidad CHAR(5), a_producto CHAR(5), a_cobertura CHAR(5), a_opc smallint)
returning DECIMAL(5,2), dec(16,2), dec(16,2), dec(16,2);


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
define _grupo               char(5);
define _descuento_edad      dec(16,2);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_proe74b.trc"; 
--trace on;

LET _descuento_max = 0;
LET _tipo_descuento = 0;
LET _descuento_modelo = 0;
LET _descuento_sini = 0;
let _descuento_max = 0;

SELECT no_documento, 
       cod_ramo, 
	   cod_subramo
  INTO _no_documento, 
       _cod_ramo,
	   _cod_subramo
  FROM emipomae
 WHERE no_poliza = a_poliza;

IF _cod_ramo not in("002","023") THEN
   Return 0.00, 0.00, 0.00,0.00;
END IF 

SELECT cod_tipo_tar
  INTO _cod_tipo_tar
  FROM emipouni
 WHERE no_poliza = a_poliza
   AND no_unidad = a_unidad;

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

select cod_tipoauto, cod_marca, grupo
  into _cod_tipo, _cod_marca, _grupo
  from emimodel
 where cod_modelo = _cod_modelo;

select tipo_auto
  into _tipo_auto
  from emitiaut
 where cod_tipoauto = _cod_tipo;

if _tipo_auto = 0 then
   Return 0.00, 0.00, 0.00,0.00;
end if
   
-- Busqueda de los descuentos 
SELECT descuento_max, 
	   tipo_descuento
  INTO _descuento_max, 
       _tipo_descuento 
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
ELIF _cod_ramo = '023' THEN
	IF _tipo_descuento IN (1,2) THEN
		select descuento_be,
			   descuento_fl
		  into _descuento_be,
			   _descuento_fl
		  from prdprod
		 where cod_producto = a_producto;
		 
		if a_opc in(1,5) then
			delete from emirede0
			 where no_poliza = a_poliza
			   and no_unidad = a_unidad
			   and cod_descuen in ('001','002');	
			   
            if _descuento_be > 0 then
				insert into emirede0 (no_poliza, no_unidad, cod_descuen, porc_descuento) 
				values (a_poliza, a_unidad, '001', _descuento_be );
			end if
			
            if _descuento_fl > 0 then
				insert into emirede0 (no_poliza, no_unidad, cod_descuen, porc_descuento) 
				values (a_poliza, a_unidad, '002', _descuento_fl );
			end if						   
		elif a_opc = 2 then
			delete from emirede1
			 where no_poliza = a_poliza
			   and no_unidad = a_unidad
			   and cod_descuen in ('001','002');
			   
            if _descuento_be > 0 then
				insert into emirede1 (no_poliza, no_unidad, cod_descuen, porc_descuento) 
				values (a_poliza, a_unidad, '001', _descuento_be );
			end if
			
            if _descuento_fl > 0 then
				insert into emirede1 (no_poliza, no_unidad, cod_descuen, porc_descuento) 
				values (a_poliza, a_unidad, '002', _descuento_fl );
			end if
		elif a_opc = 3 then
			delete from emirede2
			 where no_poliza = a_poliza
			   and no_unidad = a_unidad
			   and cod_descuen in ('001','002');
			   
            if _descuento_be > 0 then
				insert into emirede2 (no_poliza, no_unidad, cod_descuen, porc_descuento) 
				values (a_poliza, a_unidad, '001', _descuento_be );
			end if
			
            if _descuento_fl > 0 then
				insert into emirede2 (no_poliza, no_unidad, cod_descuen, porc_descuento) 
				values (a_poliza, a_unidad, '002', _descuento_fl );
			end if
		end if
	END IF 

END IF

let _fecha_envio = null;
{select max(fecha_envio),periodo[6,7]
  into _fecha_envio,_mes
  from emirenduc
 where no_documento = _no_documento
 group by 2;}
 
if _tipo_descuento = 1 then	--> Descuento RC igual para Sedan, Suv, Pick Up
elif _tipo_descuento = 2 then --> Descuento Combinado Casco

	if _grupo is null or trim(_grupo) = '' then
			let _descuento_modelo = sp_proe72a(a_poliza,a_unidad);

		{if (_fecha_envio >= '09/09/2015' ) or _fecha_envio is null then
			let _descuento_modelo = sp_proe81(_cod_marca, _cod_modelo);
		end if}

			--if _mes not in('08','09','10') or _fecha_envio is null then
				--let _descuento_modelo = sp_proe81(_cod_marca, _cod_modelo);
			--end if
	else
		let _descuento_max = sp_proe85d(a_poliza,a_unidad);
	end if
	--Buscando siniestros de la ultima vigencia
	call sp_pro550(_no_documento) returning _no_documento, _no_sinis_ult, _no_sinis_his, _no_vigencias, _no_sinis_pro, _incurrido_bruto, _prima_devengada, _siniestralidad,	_descuento_sini, _condicion;
--	let _descuento_sini = 0.00;
	if (_tipo_auto = 1 and _cod_tipo_tar in ('001','006','007','008','002') and _no_sinis_ult = 0) or (_tipo_auto = 1 and _cod_ramo = '023' and _cod_tipo_tar in ('001','006','007','008','002') and _no_sinis_ult = 0) then	--'002'
	--	let	_descuento_max = 50;
	else
		if _cod_ramo = '002' AND _cod_subramo = '001' then
			call sp_pro550(_no_documento) returning _no_documento, _no_sinis_ult, _no_sinis_his, _no_vigencias, _no_sinis_pro, _incurrido_bruto, _prima_devengada, _siniestralidad,	_descuento_sini, _condicion;
			if _condicion = 1 then -- Recargo
				let _descuento_max = _descuento_max - _descuento_max * _descuento_sini / 100;
				let _descuento_sini = 0.00;
			end if
	   end if
	end if
else
	let _descuento_max = 0;
end if

if _cod_ramo = '002' and _cod_subramo = '001' then
	let _descuento_edad = sp_proe86a(a_poliza,a_unidad); --> Descuento por edad
end if
{if _mes not in('08','09','10') or _fecha_envio is null then
else}
	--let _descuento_sini = 0;
--end if
return _descuento_max,
       _descuento_modelo,
	   _descuento_sini,
	   _descuento_edad;

end procedure
