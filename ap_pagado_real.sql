-- Reporte para las requisiciones Anuladas de Cheques por banco y chequera

-- Creado    : 26/07/2012 - Autor: Armando Moreno

drop procedure ap_pagado_real;

create procedure ap_pagado_real(a_fecha date, a_fecha2 date)
 returning smallint as cod_area,
		   varchar(20) as area,
		   integer as anio,
		   smallint as mes,
		   dec(16,2) as pagado_real;

define _no_requis		char(10);
define _cod_cliente		char(10);
define _nom_tipopago	char(50);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _nom_recla		char(100);
define _nom_aseg		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _cod_asegurado	char(10);
define _cod_reclamante	char(10);
define _no_reclamo		char(10);
define _monto_tran		dec(16,2);
define _fecha			date;
define _transaccion		char(10);
define _reclamo			char(18);
define _no_cheque		integer;
define _anulado_por     char(8);
define _fecha_anulado   date;
define _hora_anulado    datetime hour to fraction(5);
define _n_banco         char(50);
define _n_chequera      char(50);
define _fecha_impresion date;  
define _area            varchar(20);
define _numrecla        char(20);
define _cod_area        smallint;
define _anio            integer;
define _mes             smallint;

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_arreglo(
		cod_area     smallint, 
		anio         integer,
		mes          smallint,
		monto	  	 DEC(16,2),
		PRIMARY KEY (cod_area, anio, mes)) WITH NO LOG;

		--/*CATEGORIZAR*/
		--A-AUTOMOVIL                   ="002","020"
		--B-SALUD y HOSPITALIZACION     ="018"
		--C-PATRIMONIALES               ="001","003","005","006","015","011","013","010","009","017","014","021","012","007"
		--D-PERSONAS    				="019","004","016"
		--E-FIANZAS                     ="008","080"
		
foreach
	 select	no_requis,
			cod_cliente,
			monto,
			a_nombre_de,
			periodo_pago,
			firma1,
			firma2,
			no_cheque,
			fecha_anulado,
			hora_anulado,
			anulado_por,
			fecha_impresion,
			cod_banco,
			cod_chequera
	   into	_no_requis,
			_cod_cliente,
			_monto,
			_a_nombre_de,
			_periodo_pago,
			_firma1,
			_firma2,
			_no_cheque,
			_fecha_anulado,
			_hora_anulado,
			_anulado_por,
			_fecha_impresion,
			_cod_banco,
			_cod_chequera
	   from	chqchmae
	  where origen_cheque = '3'
	    and pagado = 1
		and fecha_impresion >= a_fecha 
		and fecha_impresion <= a_fecha2
		
	foreach
		select numrecla
		  into _numrecla
		  from chqchrec
		 where no_requis = _no_requis
		 
		exit foreach;
	end foreach
	
	let _anio = year(_fecha_impresion);
	let _mes  = month(_fecha_impresion);
	
	if _numrecla[1,2] in ('02','20') then
		let _cod_area = 1;
	elif _numrecla[1,2] = '23' then
		let _cod_area = 11;
	elif _numrecla[1,2] in ('04','16','18','19') then
		let _cod_area = 2;
	elif _numrecla[1,2] in ('08','80') then
		let _cod_area = 3;
	elif _numrecla[1,2] in ('01','03','05','06','15','11','13','10','09','14','17','21','12','07') then
		let _cod_area = 4;	
	else
		continue foreach;
	end if
	
   BEGIN
	  ON EXCEPTION IN(-239)
		 UPDATE tmp_arreglo
			SET monto = monto + _monto
		   WHERE cod_area = _cod_area
		     and anio = _anio
			 and mes = _mes;

	  END EXCEPTION
	  	  
	  INSERT INTO tmp_arreglo
		  VALUES(_cod_area,	
                 _anio,
                 _mes,				 
				 _monto
				 );
   END
	
	   
end foreach

foreach
	 select	no_requis,
			cod_cliente,
			monto * (-1),
			a_nombre_de,
			periodo_pago,
			firma1,
			firma2,
			no_cheque,
			fecha_anulado,
			hora_anulado,
			anulado_por,
			fecha_impresion,
			cod_banco,
			cod_chequera
	   into	_no_requis,
			_cod_cliente,
			_monto,
			_a_nombre_de,
			_periodo_pago,
			_firma1,
			_firma2,
			_no_cheque,
			_fecha_anulado,
			_hora_anulado,
			_anulado_por,
			_fecha_impresion,
			_cod_banco,
			_cod_chequera
	   from	chqchmae
	  where origen_cheque = '3'
	    and pagado = 1
		and fecha_anulado >= a_fecha 
		and fecha_anulado <= a_fecha2
		
	foreach
		select numrecla
		  into _numrecla
		  from chqchrec
		 where no_requis = _no_requis
		 
		exit foreach;
	end foreach
	
	let _anio = year(_fecha_anulado);
	let _mes  = month(_fecha_anulado);
	
	if _numrecla[1,2] in ('02','20') then
		let _cod_area = 1;
	elif _numrecla[1,2] = '23' then
		let _cod_area = 11;
	elif _numrecla[1,2] in ('04','16','18','19') then
		let _cod_area = 2;
	elif _numrecla[1,2] in ('08','80') then
		let _cod_area = 3;
	elif _numrecla[1,2] in ('01','03','05','06','15','11','13','10','09','14','17','21','12','07') then
		let _cod_area = 4;	
	else
		continue foreach;
	end if
	
   BEGIN
	  ON EXCEPTION IN(-239)
		 UPDATE tmp_arreglo
			SET monto = monto + _monto
		   WHERE cod_area = _cod_area
		     and anio = _anio
			 and mes = _mes;

	  END EXCEPTION
	  	  
	  INSERT INTO tmp_arreglo
		  VALUES(_cod_area,	
                 _anio,
                 _mes,				 
				 _monto
				 );
   END
	
	
   
end foreach

foreach with hold
   select cod_area,
          anio,
		  mes,
          monto
	 into _cod_area,
	      _anio,
		  _mes,
	      _monto
	 from tmp_arreglo
	 
	if _cod_area = 1 then
		let _area = 'AUTOMOVIL';
	elif _cod_area = 11 then
		let _area = 'AUTOMOVIL FLOTA';
	elif _cod_area = 2 then
		let _area = 'PERSONAS';
	elif _cod_area = 3 then
		let _area = 'FIANZAS';
	elif _cod_area = 4 then
		let _area = 'PATRIMONIALES';
	else
		let _area = 'OTRO';
	end if
   
	return _cod_area,
	       _area,
		   _anio,
		   _mes,
	       _monto
		   with resume;
end foreach

drop table tmp_arreglo;

end procedure
