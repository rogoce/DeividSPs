-- Creacion de la remesa de Cierre de Caja

-- Creado    : 01/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_cob231;
create procedure sp_cob231(a_no_caja char(10))
returning	integer,
			char(100);

define _observacion    	varchar(100);
define _error_desc		char(100);
define _descripcion		char(50);
define _cuenta			char(25);
define _no_recibo,_no_rem    	char(10);
define _no_remesa		char(10);
define _user_cierre		char(8);
define _user_caja		char(8);
define _periodo			char(7);
define _cod_chequera 	char(3);
define _cod_compania	char(3);
define _cod_sucursal	char(3);
define _cod_banco		char(3);
define _tipo_mov		char(1);
define _total_caja		dec(16,2);
define _monto,_mto_rem	dec(16,2);
define _cantidad		smallint;
define _contador		smallint;
define _renglon			smallint;
define _error_isam		integer;
define _diferencia   	integer;
define _recibo1      	integer;
define _recibo2      	integer;
define _error			integer;
define _fecha_cierre	date;
define _fecha,_fecha2 	date;


begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _fecha2 = current;
let _mto_rem = 0;
-- Validaciones para que esten todas las cuentas

foreach
	select renglon
	  into _renglon
	  from cobcieca2
	 where no_caja = a_no_caja
	   and cuenta  is null

	return 1, 'No Existe Cuenta para Renglon ' || _renglon;

end foreach

-- Verificacion para la Secuencia de Recibos

select fecha,
       cod_chequera,
	   total_caja,
	   user_cierre,
	   fecha_cierre,
	   user_caja
  into _fecha,
       _cod_chequera,
	   _total_caja,
	   _user_cierre,
	   _fecha_cierre,
	   _user_caja
  from cobcieca
 where no_caja = a_no_caja;

let _contador = 0;
--VALIDACION PARA EVITAR DUPLICODAD DE ACTUALIZACION DE REMESA DE CIERRE, ARMANDO 07/05/2020
let _cantidad = 0;
foreach
	select count(*),no_remesa,sum(monto_chequeo)
	  into _cantidad,_no_rem,_mto_rem
	  from cobremae
	 where fecha        = _fecha2
	   and tipo_remesa  = 'F'
	   and cod_chequera = _cod_chequera
	 group by no_remesa
	 order by no_remesa
	 
	exit foreach;
 end foreach
 
 if _cantidad is null then
	let _cantidad = 0;
 end if
 
 if _cantidad > 0 then
	if abs(_mto_rem) = abs(_total_caja) then
		return 1, 'Ya existe la Remesa de Cierre ' || _no_rem || ', Por Favor verifique ...';	
	end if
 end if
 --*****TERMINA VALIDACION DE DUPLICIDAD
{
foreach
 select	d.no_recibo
   into	_no_recibo
   from	cobredet d, cobremae m
  where m.no_remesa    = d.no_remesa
    and m.fecha        = _fecha
	and m.cod_chequera = _cod_chequera
	and m.actualizado  = 1
  group by no_recibo 
  order by no_recibo 

	let _contador = _contador + 1;

	if _contador = 1 then

		if _no_recibo[4,4] = "-" then
			let _recibo1 = _no_recibo[5,10];
		else 
			let _recibo1 = _no_recibo;
		end if

	end if				

	if _no_recibo[4,4] = "-" then
		let _recibo2 = _no_recibo[5,10];
	else
		let _recibo2 = _no_recibo;
	end if

	if _recibo1 <> _recibo2 then

		let _diferencia = _recibo2 - _recibo1;

		if _diferencia <> 1 then

			return 1, "El Recibo #: " || _recibo1 + 1 || " No Ha Sido Capturado ...";

		end if

		if _no_recibo[4,4] = "-" then
			let _recibo1 = _no_recibo[5,10];
		else 
			let _recibo1 = _no_recibo;
		end if

	end if

end foreach
}

-- Validaciones Iniciales para la Remesa

let _no_remesa = sp_sis13("001", 'COB', '02', 'par_no_remesa');

select count(*)
  into _cantidad
  from cobremae
 where no_remesa = _no_remesa;

if _cantidad <> 0 then
	return 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualize Nuevamente ...';
end if

let _cod_banco = "146";

let _periodo = sp_sis39(_fecha);

select cod_compania,
       cod_sucursal
  into _cod_compania,
       _cod_sucursal
  from chqchequ
 where cod_banco    = _cod_banco
   and cod_chequera = _cod_chequera;

insert into cobremae(
no_remesa,   
cod_compania,   
cod_sucursal,   
cod_banco,   
cod_cobrador,   
recibi_de,   
tipo_remesa,   
fecha,   
comis_desc,   
contar_recibos,   
monto_chequeo,   
actualizado,   
periodo,   
user_added,   
date_added,   
user_posteo,   
date_posteo,
cod_chequera
)
values(
_no_remesa,
_cod_compania,
_cod_sucursal,
_cod_banco,
null,
"REMESA DE CIERRE DE CAJA " || _fecha,
'F',
_fecha,
0,
2,
_total_caja * -1,
0,
_periodo,
_user_caja,
_fecha_cierre,
_user_cierre,
_fecha_cierre,
_cod_chequera
);

let _tipo_mov = 'M';

foreach
	select renglon,
		   cuenta,
		   monto,
		   observacion
	  into _renglon,
		   _cuenta,
		   _monto,
		   _observacion
	  from cobcieca2
	 where no_caja = a_no_caja
	
	if _observacion is not null then
		let _descripcion = _observacion;
	else
		select cta_nombre
		  into _descripcion
		  from cglcuentas
		 where cta_cuenta = _cuenta;
	end if

	insert into cobredet(
	no_remesa,
	renglon,
	cod_compania,
	cod_sucursal,
	no_recibo,
	doc_remesa,
	tipo_mov,
	monto,
	prima_neta,
	impuesto,
	monto_descontado,
	comis_desc,
	desc_remesa,
	saldo,
	periodo,
	fecha,
	actualizado,
	no_poliza
	)
	values(
	_no_remesa,
	_renglon,
	_cod_compania,
	_cod_sucursal,
	_renglon,
	_cuenta,
	_tipo_mov,
	_monto * -1,
	0.00,
	0.00,
	0.00,
	0,
	_descripcion,
	0.00,
	_periodo,
	_fecha,
	0,
	null);
end foreach

call sp_cob29(_no_remesa, _user_cierre) returning _error, _error_desc; 

if _error <> 0 then
	return _error, _error_desc;
end if

return 0, "Actualizacion Exitosa, Remesa: " || _no_remesa;
end
end procedure 