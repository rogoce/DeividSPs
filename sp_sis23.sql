-- eliminar la informacion de la tarjeta de credito cuando se realiza
-- el cambio de plan de pago a una forma que no es tarjeta

-- creado    : 30/04/2001 - autor: demetrio hurtado almanza 
-- modificado: 30/04/2001 - autor: demetrio hurtado almanza
-- modificado: 10/02/2006 - autor: armando moreno. que no adicione el endoso descriptivo por orden del depto de cobros.

-- sis v.2.0 - deivid, s.a.

drop procedure sp_sis23;
create procedure sp_sis23(
a_compania	char(3),
a_sucursal	char(3),
a_no_poliza	char(10),
a_user		char(8),
a_relac_tar	integer,
a_no_cambio	char(10))

returning	integer,
			char(5),
			char(5); 

define _motivo_rechazo	varchar(50);
define _error_desc		varchar(50);
define _nombre_pagad	char(100);
define _no_documento	char(20);
define _no_tarjeta		char(19);
define _cod_contratante	char(10);
define _cod_pagador		char(10);
define _no_factura		char(10);
define _fecha_exp		char(7);
define _periodo			char(7);
define _no_endoso_char	char(5);
define _no_endoso_ext	char(5);
define _no_unidad		char(5);
define _cod_formapag	char(3);
define _cod_endomov		char(3);
define _cod_perpago		char(3);
define _cod_banco		char(3);
define _periodo_tar		char(1);
define _tipo_tarjeta	char(1);
define _null			char(1);
define _nuevo_monto_visa	dec(16,2);
define _monto_visa		dec(16,2);
define _saldo_x_unidad	smallint;
define _no_pagos_campl	smallint;
define _letras_extras	smallint;
define _dia				smallint;
define _no_endoso_int	integer;
define _secuencia		integer;
define _cantidad		integer;
define _no_pagos		integer;
define _error			integer;
define _vigencia_final	date;
define _vigencia_inic	date;
define _fecha_1_pago	date;
define _cnt             integer;

--set debug file to "sp_sis23.trc"; 
--trace on;
if a_no_poliza = '2895052' then
	set debug file to "sp_sis23.trc"; 
	trace on;
end if	
set isolation to dirty read;

let _no_endoso_char = '';
let _no_tarjeta = '';
let _no_unidad = '';
let _saldo_x_unidad = 0;
let _dia = 0;

begin
on exception set _error 
 	return _error, _no_endoso_char, _no_unidad;         
end exception           

select cod_endomov
  into _cod_endomov
  from endtimov
 where tipo_mov = 18;
-- and cod_endomov = '015';  --SD#6865 Mariluz

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

if a_relac_tar = 1 then -- eliminacion de los datos de la tarjeta
	if _saldo_x_unidad = 1 then
		foreach
			select no_tarjeta
			  into _no_tarjeta
			  from cobtacre
			 where no_documento = _no_documento
			   and no_unidad    = _no_unidad
			exit foreach;
		end foreach

		update emipomae
		   set no_tarjeta    = _null,
		       fecha_exp     = _null,
			   cod_banco     = _null,
			   monto_visa    = 0,
			   tipo_tarjeta  = _null
		 where no_poliza     = a_no_poliza;

		update emipouni
		   set no_tarjeta    = _null,
		       fecha_exp     = _null,
			   cod_banco     = _null,
			   monto_visa    = 0,
			   tipo_tarjeta  = _null
		 where no_poliza     = a_no_poliza
           and no_unidad     = _no_unidad;

		delete from cobtacre
		 where no_documento = _no_documento
		   and no_unidad    = _no_unidad;

		if _no_tarjeta is not null then
			select count(*)
			  into _cantidad
			  from cobtacre
			 where no_tarjeta = _no_tarjeta;

			if _cantidad is null then
				let _cantidad = 0;
			end if

			if _cantidad = 0 then
				delete from cobtahab
				 where no_tarjeta = _no_tarjeta;
			end if
		end if
    else
		foreach
			select no_tarjeta
			  into _no_tarjeta
			  from cobtacre
			 where no_documento = _no_documento
			exit foreach;
		end foreach

		update emipomae
		   set no_tarjeta    = _null,
		       fecha_exp     = _null,
			   cod_banco     = _null,
			   monto_visa    = 0,
			   tipo_tarjeta  = _null
		 where no_poliza     = a_no_poliza;

		delete from cobtacre
		 where no_documento = _no_documento;

		if _no_tarjeta is not null then
			select count(*)
			  into _cantidad
			  from cobtacre
			 where no_tarjeta = _no_tarjeta;

			if _cantidad is null then
				let _cantidad = 0;
			end if

			if _cantidad = 0 then
				delete from cobtahab
				 where no_tarjeta = _no_tarjeta;
			end if
		end if
	end if
else
	select cod_pagador,
		   no_tarjeta,
		   fecha_exp,
		   cod_banco,
		   monto_visa,
		   periodo_tar,
		   tipo_tarjeta,
		   cod_perpago,
		   fecha_primer_pago,
		   dia1,
		   no_pagos
	  into _cod_pagador,
		   _no_tarjeta,
		   _fecha_exp,
		   _cod_banco,
		   _monto_visa,
		   _periodo_tar,
		   _tipo_tarjeta,
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

	{if _no_pagos_campl <> _no_pagos then
		let _letras_extras = _no_pagos_campl - _no_pagos;
		
		call sp_pro541c(a_no_poliza,_letras_extras) returning _error,_error_desc;
	end if}

	if _saldo_x_unidad = 1 then
		update emipouni
		   set no_tarjeta    = _no_tarjeta,
		       fecha_exp     = _fecha_exp,
			   cod_banco     = _cod_banco,
			   monto_visa    = _monto_visa,
			   tipo_tarjeta  = _tipo_tarjeta,
			   cod_pagador   = _cod_pagador
		 where no_poliza     = a_no_poliza
		   and no_unidad     = _no_unidad;
	else
		update emipomae
		   set no_tarjeta    = _no_tarjeta,
		       fecha_exp     = _fecha_exp,
			   cod_banco     = _cod_banco,
			   monto_visa    = _monto_visa,
			   tipo_tarjeta  = _tipo_tarjeta
		 where no_poliza     = a_no_poliza;

		if _dia > 0 and _dia <= 31 then
			update emipomae
			   set dia_cobros1   = _dia,
				   dia_cobros2   = _dia
			 where no_poliza     = a_no_poliza;

			update emipoliza
			   set dia_cobros1   = _dia,
				   dia_cobros2   = _dia
			 where no_documento  = _no_documento;
		end if
	end if

	select nombre
	  into _nombre_pagad
	  from cobtahab
	 where no_tarjeta = _no_tarjeta;
	
	if _nombre_pagad is null then -- crear el maestro de tarjetas
		select nombre
		  into _nombre_pagad
		  from cliclien
		 where cod_cliente = _cod_pagador;

		insert into cobtahab(
				no_tarjeta,
				cod_banco,
				nombre,
				fecha_exp,
				user_added,
				date_added,
				tipo_tarjeta)
		values(	_no_tarjeta,
				_cod_banco,
				_nombre_pagad,
				_fecha_exp,
				a_user,
				today,
				_tipo_tarjeta);
	else
		
		select trim(motivo_rechazo)
		  into _motivo_rechazo
		  from cobtatra
		 where no_documento = _no_documento
		   and no_tarjeta = _no_tarjeta;

		if upper(_motivo_rechazo) = 'INVALID DATE' or _motivo_rechazo[1,2] = '54' then
			
		end if

		update cobtahab
	       set fecha_exp    = _fecha_exp,
	           cod_banco    = _cod_banco,
		       tipo_tarjeta = _tipo_tarjeta
	     where no_tarjeta   = _no_tarjeta;
	end if

	select nombre
	  into _nombre_pagad
	  from cobtacre
	 where no_tarjeta   = _no_tarjeta
	   and no_documento = _no_documento;

	if _nombre_pagad is null then -- crear el detalle de la tarjeta

		select nombre
		  into _nombre_pagad
		  from cliclien
		 where cod_cliente = _cod_contratante;

		insert into cobtacre(
				no_tarjeta,
				no_documento,
				cod_perpago,
				nombre,
				periodo,
				monto,
				fecha_ult_tran,
				procesar,
				excepcion,
				cargo_especial,
				no_unidad,
				dia)
		values(	_no_tarjeta,
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
			update cobtacre
			   set dia			 = _dia,
				   monto 		 = _monto_visa,
				   cod_perpago	 = _cod_perpago
			 where no_tarjeta  	 = _no_tarjeta
			   and no_documento  = _no_documento;

			update emipomae
			   set dia_cobros1   = _dia,
				   dia_cobros2   = _dia
			 where no_poliza     = a_no_poliza;

			update emipoliza
			   set dia_cobros1   = _dia,
				   dia_cobros2   = _dia
			 where no_documento  = _no_documento;

			foreach
				select mail_secuencia
				  into _secuencia
				  from parmailcomp
				 where asegurado = _no_tarjeta
				   and no_documento = _no_documento

				delete from parmailsend
				 where secuencia = _secuencia;
			end foreach
			
			delete from parmailcomp
			 where asegurado = _no_tarjeta
			   and no_documento = _no_documento;
		end if
	end if
end if

-- generacion del endoso para la constancia del cambio

{select max(no_endoso)
  into _no_endoso_int
  from endedmae
 where no_poliza = a_no_poliza;

let _no_endoso_char = sp_set_codigo(5, _no_endoso_int + 1);
let _no_factura     = sp_sis14(a_compania, a_sucursal, a_no_poliza); 
let _no_endoso_ext  = sp_sis30(a_no_poliza, _no_endoso_char);

-- creacion del endoso

insert into endedmae(
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
values(
a_no_poliza,
_no_endoso_char,
a_compania,
a_sucursal,
'007',
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
today,
today,
today,
_no_pagos,
1,
_no_factura,
_null,
today,
today,
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

foreach 
 select no_unidad
   into _no_unidad
   from emipouni
  where no_poliza = a_no_poliza
  order by no_unidad
	exit foreach;
end foreach

insert into endeduni(
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
select 
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
 from emipouni
where no_poliza = a_no_poliza
  and no_unidad = _no_unidad;}
end

return 0, "", "";
--return 0, _no_endoso_char, _no_unidad;

end procedure;
