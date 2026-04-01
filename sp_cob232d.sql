-- Reporte del Cierre de Caja - Detallado
-- Creado    : 01/02/2010 - Autor: Demetrio Hurtado Almanza 
-- SIS v.2.0 - d_cobr_cierre_caja_automatico_reporte - DEIVID, S.A.

drop procedure sp_cob232d;

create procedure "informix".sp_cob232d(a_no_caja char(10))
returning integer,
		  varchar(50),
		  date,
		  dec(10,2),
		  varchar(50),
		  varchar(30);  --21


define _girado_por		char(50);
define _no_remesa		char(10);
define _importe			dec(16,2);
define _fecha 			date;
define _no_cheque       integer;
define _cod_banco       char(3);
define _nombre_banco    varchar(50);
define _tipo_cheque     smallint;
define _stipo_cheque    varchar(30);

set isolation to dirty read;

--SET DEBUG FILE TO "sp_cob232d.trc";
--trace on;

let _tipo_cheque = 0;
let _stipo_cheque = "";

foreach
	select no_remesa
	  into _no_remesa
	  from tmp_caja
	 where tipo_pago = 2
	 
	foreach 
		select no_cheque,
			   cod_banco,
			   fecha,
			   importe,
			   girado_por,
			   tipo_cheque
		  into _no_cheque,
			   _cod_banco,
			   _fecha,
			   _importe,
			   _girado_por,
			   _tipo_cheque
		  from cobrepag 
		 where no_remesa = _no_remesa 
		 
		 select nombre
		   into _nombre_banco
		   from chqbanco 
		  where cod_banco = _cod_banco;
		  
			if _tipo_cheque = 1 then
				let _stipo_cheque = "Cheque Gerencia";
			elif _tipo_cheque = 2 then
				let _stipo_cheque = "Cheque Local";
			elif _tipo_cheque = 3 then
				let _stipo_cheque = "Cheque Extranjero";
			else
				let _stipo_cheque = "Cheque Sin Especificar";
			end if

		return _no_cheque,
			   _nombre_banco,
			   _fecha,
			   _importe,
			   _girado_por,
			   _stipo_cheque
			   with resume;
	end foreach
end foreach

--drop table tmp_caja;
end procedure