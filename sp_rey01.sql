-- Procedimiento que Genera la Remesa de los Cobros de Grupo Rey
-- Creado    : 09/07/2015 - Autor: Federico Coronado.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rey01;

create procedure "informix".sp_rey01() 
returning smallint,
            char(100),
            char(10);

define _cod_compania	char(3);
define _cod_sucursal	char(3);

define _flag,_flag2	    integer;
define _renglon      	integer;  
define _saldo        	dec(16,2);
define _monto_total     dec(16,2);
define _monto_total_d   int;
define _no_poliza    	char(10); 
define _no_documento 	char(18);
define _fecha			date;
define _periodo			char(7);
define _tipo_mov        char(1);
define _factor			dec(16,2);
define _prima			dec(16,2);
define _impuesto		dec(16,2);
define _nom_cliente 	char(100);
define _cod_cliente 	char(10);
define _nombre_agente 	char(50);
define _descripcion   	char(100);
define _cod_agente   	char(10);
define _porc_partic		dec(5,2);
define _porc_comis		dec(5,2);
define _null            char(1);
define _cod_banco       char(3);
define a_no_remesa      char(10);
define a_no_recibo      char(10);
define _cod_pagador     char(10);
define _cod_cobrador    char(3);
define _banco           char(3);
define _existe          integer;
define _recibo          char(10);
define _user_added		char(8);
define _registro		integer;
define _no_unico		integer;

define _no_secuencia    char(4);
define _monto_pago		dec(11,2); 
define _monto_pago_d	int;

define _mensaje         char(100);

define _cant_suspe		smallint;
define _cant_tran		smallint;
define _cant_mes		smallint;
define _we_fee			dec(16,2);
define _we_itbms		dec(16,2);

define _error_code      integer;
define _error_isam		integer;
define _error_desc		char(50);
define _opt4            varchar(50);
define _periodo_hoy		char(7);
define _notransaccion   varchar(50);

set isolation to dirty read;

--SET DEBUG FILE TO "sp_rey01.trc";
--TRACE ON ;

begin

on exception set _error_code, _error_isam, _error_desc 
 	return _error_code, _error_desc, _error_desc;
end exception 

select count (*)
  into _registro
  from deivid_cob:gr_transacciones
 where no_remesa is null
   and estado = 0;

if _registro = 0 then
	return 0, 'Actualizacion Exitosa, No Hay Registros de Cobros', "00000"; 
end if

--let _tipo_mov      = 'P';
let _null          = NULL;
let a_no_remesa    = '1';  
let _existe        = 0;
let _periodo       = '';
let _error_code    = 0;
let _cod_banco     = "";
let _cod_sucursal  = '001';
let _cod_compania  = '001';

let _cod_cobrador = "313";         --***************************************************
let _user_added   = "DEIVID";

let a_no_remesa = sp_sis13(_cod_compania, 'COB', '02', 'par_no_remesa');

select fecha
  into _fecha
  from cobremae
 where no_remesa = a_no_remesa;

if _fecha is not null then
	return 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualice Nuevamente ...', '';
end if

let _fecha = today;
/*
if month(_fecha) < 10 then
	let _periodo = year(_fecha) || '-0' || month(_fecha);
else
	let _periodo = year(_fecha) || '-' || month(_fecha);
end if
*/
select cob_periodo
  into _periodo
  from deivid:parparam;
  
  call sp_sis39(_fecha) RETURNING _periodo_hoy;
    --ultimo dia del mes del periodo
  if _periodo <> _periodo_hoy then
		if _periodo < _periodo_hoy then
			CALL sp_sis36(_periodo) RETURNING _fecha;
		else
			CALL sp_sis36bk(_periodo) RETURNING _fecha;
		end if
  end if

--Buscar el banco en parametros   **************************************************************************
SELECT valor_parametro
  INTO _banco
  FROM inspaag
 WHERE codigo_compania  = "001"
   AND codigo_agencia   = "001"
   AND aplicacion       = "COB"
   AND version          = "02"
   AND codigo_parametro = "banco_wun";

-- Insertar el Maestro de Remesas

INSERT INTO cobremae(
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
cod_chequera)
VALUES(
a_no_remesa,
_cod_compania,
_cod_sucursal,
_banco,
_cod_cobrador,
"REY PAGO",
'C',
_fecha,
0,
3,
0.00,
0,
_periodo,
_user_added,
_fecha,
_user_added,
_fecha,
'039'   --********************************************************************************************
);

update deivid_cob:gr_transacciones
   set no_remesa = a_no_remesa
 where no_remesa is null
   and estado = 0;

--ultimo numero de renglon
select max(renglon)
  into _renglon
  from cobredet
 where no_remesa = a_no_remesa;

if _renglon is null then
	let _renglon = 0;
end if

select max(no_unico)
  into _no_unico
  from deivid_cob:gr_transacciones
 where estado = 0;

if _no_unico is null then
	let _no_unico = 0;
end if

foreach
 select cedula,
        cliente,
        montopagado,
        cuenta,
        opt4,
		notransaccion
   into _cod_cliente,
        _nom_cliente,
		_monto_pago,
		_no_documento,
		_opt4,
		_notransaccion
   from deivid_cob:gr_transacciones
  where no_remesa = a_no_remesa
    and estado = 0
  order by cuenta
  
	let _tipo_mov  = 'P';
	
  if _opt4 = 'A' then
     let _tipo_mov = 'N';
  end if

	let _no_unico = _no_unico + 1;
 
	-- Numero de Recibo
	let _recibo     = sp_sis79(_no_unico);
	let a_no_recibo = _cod_cobrador || '-' || _recibo;
  
  	let _saldo    = 0;
  	let _prima    = 0;
  	let _impuesto = 0;
	
	LET _no_poliza = sp_sis21(_no_documento);
	
	
	if _tipo_mov in('P','N') then		--Pago de Prima

		if _no_poliza is null then

			LET _tipo_mov   = 'E';  --Crear prima en suspenso
			LET _nombre_agente  = " ";
	
		else

		    call sp_cob115b(_cod_compania,_cod_sucursal,_no_documento,"") returning _saldo;

			IF _saldo IS NULL THEN
				LET _saldo = 0;
			END IF

			-- Impuestos de la Poliza

			SELECT SUM(i.factor_impuesto)
			  INTO _factor
			  FROM prdimpue i, emipolim p
			 WHERE i.cod_impuesto = p.cod_impuesto
			   AND p.no_poliza    = _no_poliza;

			IF _factor IS NULL THEN
				LET _factor = 0;
			END IF

			LET _factor   = 1 + _factor / 100;
			LET _prima    = _monto_pago / _factor;
			LET _impuesto = _monto_pago - _prima;
			LET _saldo    = _saldo - _monto_pago;

        /* 
		   if _monto_total <= 0 then
				continue foreach;
		   end if
		*/
			-- Descripcion de la Remesa
				
			LET _nombre_agente = " ";

			FOREACH
			 SELECT cod_agente
			   INTO _cod_agente
			   FROM emipoagt
			  WHERE no_poliza = _no_poliza

				SELECT nombre
				  INTO _nombre_agente
				  FROM agtagent
				 WHERE cod_agente = _cod_agente;

				EXIT FOREACH;

			END FOREACH

		end if

	end if

	if _tipo_mov = "E" then -- Crear Prima Suspenso

	   	LET _nombre_agente  = "-";
	   	LET _no_poliza      = null;
	   	LET _no_documento   = a_no_recibo;
	
		select count(*)
		  into _cant_suspe
		  from cobsuspe
		 where doc_suspenso = _no_documento;
		 
		 if _cant_suspe <> 0 then

			update cobsuspe
			   set monto        = monto + _monto_total				  					
			 where doc_suspenso = _no_documento;

		 else

			INSERT INTO cobsuspe(
			doc_suspenso,
			cod_compania,
			cod_sucursal,
			monto,
			fecha,
			coaseguro,
			asegurado,
			poliza,
			ramo,
			actualizado,
			user_added,
			date_added
			)
			VALUES(
			_no_documento,
			_cod_compania,
			_cod_sucursal,
			_monto_pago,
			_fecha,
			"",
			_nom_cliente,
			_no_documento,
			_null,
			0,
			_user_added,
			_fecha
			);
		
		end if

	end if

	  LET _descripcion = TRIM(_nom_cliente) || "/" || TRIM(_nombre_agente);
	 
	  -- Detalle de la Remesa
	  let _renglon = _renglon + 1;

	  INSERT INTO cobredet(
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
	   VALUES(
	   a_no_remesa,
	   _renglon,
	   _cod_compania,
	   _cod_sucursal,
	   a_no_recibo,
	   _no_documento,
	   _tipo_mov,
	   _monto_pago,
	   _prima,
	   _impuesto,
	   0,
	   0,
	   _descripcion,
	   _saldo,
	   _periodo,
	   _fecha,
	   0,
	   _no_poliza
	   );

		update deivid_cob:gr_transacciones
		   set no_renglon    = _renglon,
		       no_unico      = _no_unico
		 where no_remesa     = a_no_remesa
		   and cuenta 		 = _no_documento
		   and notransaccion = _notransaccion
		   and estado 		 = 0;

	  INSERT INTO cobrepag(
	   no_remesa,
	   renglon,
	   tipo_pago,
	   tipo_tarjeta,
	   cod_banco,
	   fecha,
	   no_cheque,
	   girado_por,
	   a_favor_de,
	   importe
	   )
	   VALUES(
	   a_no_remesa,
	   _renglon,
	   '1',
	   '',
	   _cod_banco,
	   _fecha,
	   '',
	   '',
	   "",
	   _monto_pago
	   );
	   
	   foreach
		 SELECT	cod_agente,
				porc_partic_agt,
				porc_comis_agt
		   INTO	_cod_agente,
				_porc_partic,
				_porc_comis
		   FROM	emipoagt
		  WHERE no_poliza = _no_poliza

			INSERT INTO cobreagt(
            no_remesa,
			renglon,
			cod_agente,
			monto_calc,
			monto_man,
			porc_comis_agt,
			porc_partic_agt)
 			VALUES(
			a_no_remesa,
			_renglon,
			_cod_agente,
			0,
			0,
			_porc_comis,
			_porc_partic
			);  
	   end foreach
end foreach

-- Monto total de la remesa

select sum(monto)
  into _saldo
  from cobredet
 where no_remesa = a_no_remesa;
	
if _saldo is null then
	let _saldo = 0.00;
end if

update cobremae
   set monto_chequeo = _saldo
 where no_remesa     = a_no_remesa;

-- Actualizacion de la Remesa

call sp_cob29(a_no_remesa, _user_added) returning _error_code, _error_desc;

if _error_code <> 0 then
	return _error_code, _error_desc || " Remesa # " || a_no_remesa, a_no_remesa;
end if

-- Se coloco el delete a la tabla wun_historico para que cuando se procese el archivo WU solo tome lo que esta en el archivo actual y no procese alguna data basura que quedo si el proceso fallo anteriormente porque se pueden duplicar pagos.
delete from deivid_cob:wun_historico where no_remesa is null;

return 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa; 
		
end 

end procedure;
