-- Procedure que Genera el Reporte de Transacciones de Pagos
-- Creado    : 10/06/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec732;

create procedure "informix".sp_rec732(a_compania char(3),a_periodo char(7), a_periodo2 char(7))
returning	char(10), char(20), varchar(50), varchar(100), date, dec(16,2), char(50);

define	_no_tranrec			char(10);
define	_numrecla			char(20);
define	_no_reclamo			char(10);
define	_fecha				date;
define	_fecha2				date;
define	_monto				dec(16,2);
define	_cod_cliente		char(10);
define	_cod_tipopago   	char(3);
define 	_dias				smallint;
define  _transaccion		char(10);
define	_nom_tipopago   	varchar(50);
define	_nom_cliente    	varchar(100);
define  _compania_nombre	char(50);


--set debug file to "sp_pro397.trc";
--trace on;

set isolation to dirty read;

begin
{on exception set _error,_error_isam,_desc_error
	--return _error,_error_isam,_desc_error;
	drop table tmp_cufian;
end exception}

{create temp table tmp_cufian
   (no_documento		char(21),
	cod_subramo			char(3),
	cod_cliente			char(10),
	proyecto			byte,
	valor_contrato		dec(16,2),
	monto_afianzado		dec(16,2),
	contrato_retencion	dec(16,2),
	contrato_cesion		dec(16,2),
	fecha_emision		date,
	vigencia_inic		date,
	vigencia_final		date)
--primary key(no_aviso,no_poliza,no_documento)) 
with no log;}


let _compania_nombre = sp_sis01(a_compania);

foreach
	select no_tranrec,
	       numrecla,
		   no_reclamo,
		   fecha,
		   monto,
		   cod_cliente,
		   cod_tipopago,
		   transaccion
	  into _no_tranrec,
	       _numrecla,
		   _no_reclamo,
		   _fecha,
		   _monto,
		   _cod_cliente,
		   _cod_tipopago,
		   _transaccion
	  from rectrmae
	 where numrecla[1,2]  in  ('02','20','23')
	   and cod_tipotran = '004'
	   and periodo >= a_periodo
	   and periodo <= a_periodo2
	   and actualizado = 1
	
	let _fecha2 = null;
	
	foreach
		select fecha
		  into _fecha2		 
		  from rectrmae
		 where no_reclamo = _no_reclamo
		   and no_tranrec <  _no_tranrec
		   and cod_tipotran = '002'
		   and actualizado = 1
		  order by fecha desc
		
		exit foreach;
	end foreach
		
	let _dias = _fecha - _fecha2;
	
	if _dias = 0  then
	    select nombre
		  into _nom_cliente
		  from cliclien
		 where cod_cliente = _cod_cliente;
		 
		select nombre 
          into _nom_tipopago
          from rectipag
         where cod_tipopago = _cod_tipopago;		  
	
		return 	_transaccion,
				_numrecla,
				_nom_tipopago,
				_nom_cliente,
				_fecha,
				_monto,
				_compania_nombre
				with resume;
	
	end if
end foreach

	 
--drop table tmp_cufian;
end
end procedure
