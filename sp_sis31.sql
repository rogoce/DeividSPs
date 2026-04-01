-- Eliminar la informacion del Ach cuando se realiza el cambio de Plan de Pago a una forma de pago que no es Ach.
-- y crear la inf. del Ach cuando la forma de pago sera Ach.

-- Creado : 30/04/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 22/10/2001 - Autor: Armando Moreno M.
-- Modificado: 10/02/2006 - Autor: Armando Moreno. Que no adicione el endoso descriptivo por orden del depto de cobros.
-- Modificado: 17/07/2015 - Autor: Román Gordón. Incluir al procedure sp_cob373 que determina si se debe hacer el endoso de pronto pago electrónico.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis31;
create procedure "informix".sp_sis31(
a_compania	char(3),
a_sucursal	char(3),
a_no_poliza char(10),
a_user		char(8),
a_relac_tar	integer,
a_no_cambio	char(10))
returning	integer,
			char(5),
			char(5);

define _nombre_pagad		varchar(100);
define _error_desc			varchar(100);
define _no_documento		char(20);
define _no_cuenta			char(17);
define _cod_contratante		char(10);
define _cod_pagador			char(10);
define _no_factura			char(10); 
define _periodo				char(7);
define _no_endoso_char		char(5);
define _no_endoso_ext		char(5);
define _no_unidad			char(5);
define _cod_formapag		char(3);
define _cod_endomov			char(3);
define _cod_perpago			char(3);
define _cod_banco			char(3);
define _periodo_tar			char(1);
define _tipo_cuenta			char(1);
define _null				char(1);
define _nuevo_monto_visa	dec(16,2);
define _monto_visa			dec(16,2);
define _saldo_x_unidad		smallint;
define _no_pagos_campl		smallint;
define _letras_extras		smallint;
define _dia					smallint;
define _no_endoso_int		integer;
define _cantidad			integer;
define _no_pagos			integer;
define _error				integer;
define _cnt					integer;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_1_pago		date;

--set debug file to "sp_sis31.trc"; 
--trace on;

let _saldo_x_unidad	= 0;
let _no_endoso_char	= '';
let _no_unidad = '';

begin
on exception set _error 
 	return _error, _no_endoso_char, _no_unidad;         
end exception           

select cod_endomov
  into _cod_endomov
  from endtimov
 where tipo_mov = 18;  --endoso descriptivo

select emi_periodo
  into _periodo
  from parparam
 where cod_compania = a_compania;
 
let _null = null;

select no_documento,
	   vigencia_inic,
	   vigencia_final,
	   cod_formapag,
	   cod_perpago,
	   no_pagos,
	   cod_contratante,
	   saldo_por_unidad
  into _no_documento,
	   _vigencia_inic,
	   _vigencia_final,
	   _cod_formapag,
	   _cod_perpago,
	   _no_pagos,
	   _cod_contratante,
	   _saldo_x_unidad
  from emipomae
 where no_poliza = a_no_poliza;

select no_unidad
  into _no_unidad
  from cobcampl
 where no_documento = _no_documento
   and no_cambio    = a_no_cambio;

if a_relac_tar = 1 then -- eliminacion de los datos del ach
	if _saldo_x_unidad = 1 then

	    let _no_cuenta = null;

		foreach
			select no_cuenta
			   into _no_cuenta
			   from cobcutas
			  where no_documento = _no_documento
			    and no_unidad    = _no_unidad
			exit foreach;
		end foreach

		update emipomae
		   set no_cuenta     = _null,
			   cod_banco     = _null,
			   monto_visa    = 0,
			   tipo_cuenta   = _null
		 where no_documento  = _no_documento;

		update emipouni
		   set no_cuenta     = _null,
			   cod_banco     = _null,
			   monto_visa    = 0,
			   tipo_cuenta   = _null
		 where no_poliza     = a_no_poliza;

		delete from cobcutas
		 where no_documento = _no_documento
		   and no_unidad    = _no_unidad;

		select count(*)
		  into _cantidad
		  from cobcutas
		 where no_cuenta = _no_cuenta;

		if _cantidad is null then
			let _cantidad = 0;
		end if

		if _cantidad = 0 then
			delete from cobcuhab
			 where no_cuenta = _no_cuenta;
		end if
	else
	    let _no_cuenta = null;
		
		foreach
			select no_cuenta
			  into _no_cuenta
			  from cobcutas
			 where no_documento = _no_documento
			exit foreach;
		end foreach

		update emipomae
		   set no_cuenta     = _null,
			   cod_banco     = _null,
			   monto_visa    = 0,
			   tipo_cuenta   = _null
		 where no_documento  = _no_documento;

		delete from cobcutas
		 where no_documento = _no_documento;

		select count(*)
		  into _cantidad
		  from cobcutas
		 where no_cuenta = _no_cuenta;

		if _cantidad is null then
			let _cantidad = 0;
		end if

		if _cantidad = 0 then
			delete from cobcuhab
			 where no_cuenta = _no_cuenta;
		end if
	end if
else
	select cod_pagador,
		   no_cuenta,
		   cod_banco,
		   monto_visa,
		   periodo_tar,
		   tipo_cuenta,
		   cod_perpago,
		   fecha_primer_pago,
		   dia1,
		   no_pagos
	  into _cod_pagador,
		   _no_cuenta,
		   _cod_banco,
		   _monto_visa,
		   _periodo_tar,
		   _tipo_cuenta,
		   _cod_perpago,
		   _fecha_1_pago,
		   _dia,
		   _no_pagos_campl
	  from cobcampl
	 where no_documento = _no_documento
	   and no_cambio    = a_no_cambio; 				

	--call sp_pro545(_no_documento) returning _error,_error_desc;

	--Generacion de Endoso de Descuento de Pronto Pago
	call sp_cob373(a_no_poliza,a_user) returning _error,_error_desc,_nuevo_monto_visa;
	
	if _error = 0 then
		if _nuevo_monto_visa <> 0 then
			let _monto_visa = _nuevo_monto_visa;
			
			update cobcampl
			   set monto_visa = _monto_visa
			 where no_documento = _no_documento
			   and no_cambio    = a_no_cambio;
		end if
	elif _error < 0 then
		return _error,_error_desc,'';
	end if

	if _saldo_x_unidad = 1 then
		update emipouni
		   set no_cuenta     = _no_cuenta,
			   cod_banco     = _cod_banco,
			   monto_visa    = _monto_visa,
			   tipo_cuenta   = _tipo_cuenta,
			   cod_pagador   = _cod_pagador
		 where no_poliza     = a_no_poliza
		   and no_unidad     = _no_unidad;
	else
		if _dia > 0 and _dia <= 31 then
			update emipomae
			   set dia_cobros1   = _dia,
				   dia_cobros2   = _dia
			 where no_documento = _no_documento;

			update emipoliza
			   set dia_cobros1   = _dia,
				   dia_cobros2   = _dia
			 where no_documento  = _no_documento;
		end if

		update emipomae
		   set no_cuenta     = _no_cuenta,
			   cod_banco     = _cod_banco,
			   monto_visa    = _monto_visa,
			   tipo_cuenta   = _tipo_cuenta
		 where no_poliza     = a_no_poliza;		 
	end if

	select nombre
	  into _nombre_pagad
	  from cobcuhab
	 where no_cuenta = _no_cuenta;

	if _nombre_pagad is null then -- crear el maestro de ach

		select nombre
		  into _nombre_pagad
		  from cliclien
		 where cod_cliente = _cod_pagador;

		insert into cobcuhab(
				no_cuenta,
				cod_banco,
				nombre,
				user_added,
				date_added,
				tipo_cuenta,
				tipo_transaccion,
				cod_pagador,
				monto_ach)
		values(	_no_cuenta,
				_cod_banco,
				_nombre_pagad,
				a_user,
				today,
				_tipo_cuenta,
				'D',
				_cod_pagador,
				0.00);
	end if

	select nombre
	  into _nombre_pagad
	  from cobcutas
	 where no_cuenta    = _no_cuenta
	   and no_documento = _no_documento;

	if _nombre_pagad is null then -- crear el detalle del ach
		
		select nombre
		  into _nombre_pagad
		  from cliclien
		 where cod_cliente = _cod_contratante;

		insert into cobcutas(
				no_cuenta,
				no_documento,
				cod_per_pago,
				nombre,
				periodo,
				monto,
				fecha_ult_tran,
				procesar,
				excepcion,
				cargo_especial,
				no_unidad,
				dia)
		values(	_no_cuenta,
				_no_documento,
				_cod_perpago,
				_nombre_pagad,
				_periodo_tar,
				_monto_visa,
				_fecha_1_pago,
				0,
				0,
				0.00,
				_no_unidad,
				_dia);
	else
		if _dia > 0 and _dia <= 31 then
			update cobcutas
			   set dia = _dia,
				   monto = _monto_visa,
				   periodo = _periodo_tar,
				   cod_per_pago = _cod_perpago
			 where no_cuenta = _no_cuenta
			   and no_documento = _no_documento;
			   
			update cobcuhab
			   set tipo_cuenta = _tipo_cuenta,
			       cod_banco = _cod_banco
				   -- monto_ach = _monto_visa
			 where no_cuenta = _no_cuenta;

			update emipomae
			   set dia_cobros1 = _dia,
				   dia_cobros2 = _dia
			 where no_poliza   = a_no_poliza;

			update emipoliza
			   set dia_cobros1   = _dia,
				   dia_cobros2   = _dia
			 where no_documento  = _no_documento;
		end if
	end if
end if

-- Generacion del Endoso para la Constancia del Cambio

{SELECT MAX(no_endoso)
  INTO _no_endoso_int
  FROM endedmae
 WHERE no_poliza = a_no_poliza;

LET _no_endoso_char = sp_set_codigo(5, _no_endoso_int + 1);
LET _no_factura     = sp_sis14(a_compania, a_sucursal, a_no_poliza); 
LET _no_endoso_ext  = sp_sis30(a_no_poliza, _no_endoso_char);

-- Creacion del Endoso

INSERT INTO endedmae(
no_poliza,
no_endoso,
cod_compania,
cod_sucursal,
cod_tipocalc,
cod_formapag,
cod_tipocan,
cod_perpago,
cod_endomov,
no_documento,
vigencia_inic,
vigencia_final,
prima,
descuento,
recargo,
prima_neta,
impuesto,
prima_bruta,
prima_suscrita,
prima_retenida,
tiene_impuesto,
fecha_emision,
fecha_impresion,
fecha_primer_pago,
no_pagos,
actualizado,
no_factura,
fact_reversar,
date_added,
date_changed,
interna,
periodo,
user_added,
factor_vigencia,
suma_asegurada,
posteado,
activa,
vigencia_inic_pol,
vigencia_final_pol,
no_endoso_ext    
)
VALUES(
a_no_poliza,
_no_endoso_char,
a_compania,
a_sucursal,
'007',				--Sin Prima
_cod_formapag,
_null,
_cod_perpago,
_cod_endomov,
_no_documento,
_vigencia_inic,
_vigencia_final,
0,
0,
0,
0,
0,
0,
0,
0,
0,
TODAY,
TODAY,
TODAY,
_no_pagos,
1,
_no_factura,
_null,
TODAY,
TODAY,
1,
_periodo,
a_user,
1,
0,
'1',
1,
_vigencia_inic,
_vigencia_final,
_no_endoso_ext    
);

FOREACH 
 SELECT no_unidad
   INTO _no_unidad
   FROM emipouni
  WHERE no_poliza = a_no_poliza
  ORDER BY no_unidad
	EXIT FOREACH;
END FOREACH

INSERT INTO endeduni(
no_poliza,
no_endoso,
no_unidad,
cod_ruta,
cod_producto,
cod_cliente,
suma_asegurada,
prima,
descuento,
recargo,
prima_neta,
impuesto,
prima_bruta,
reasegurada,
vigencia_inic,
vigencia_final,
beneficio_max,
desc_unidad,
prima_suscrita,
prima_retenida
)
SELECT 
no_poliza,
_no_endoso_char,
no_unidad,
cod_ruta,
cod_producto,
cod_asegurado,
suma_asegurada,
0,
0,
0,
0,
0,
0,
1,
_vigencia_inic,
_vigencia_final,
0,
'',
0,
0
 FROM emipouni
WHERE no_poliza = a_no_poliza
  AND no_unidad = _no_unidad;}

end

return 0, "", "";
--return 0, _no_endoso_char, _no_unidad;

end procedure;