-- Reporte para las requisiciones de Reclamos

-- Creado    : 26/05/2017 - Autor: Amado Perez
-- Copia del sp_che113

drop procedure sp_che159;

create procedure sp_che159(a_periodo CHAR(7))
 returning smallint   	as dia, 
           varchar(10)   	as mes1_auto, 
		   dec(16,2) 	as monto_mes1_auto,
		   varchar(10)		as mes2_auto,
		   dec(16,2)	as monto_mes2_auto,
		   varchar(10)		as mes3_auto,
		   dec(16,2)	as monto_mes3_auto,
		   varchar(10)		as mes1_salud,
		   dec(16,2)	as monto_mes1_salud,
		   varchar(10)		as mes2_salud,
		   dec(16,2)	as monto_mes2_salud,
		   varchar(10)		as mes3_salud,
		   dec(16,2)	as monto_mes3_salud,
		   varchar(10)		as mes1,
		   dec(16,2)	as monto_mes1,
		   varchar(10)		as mes2,
		   dec(16,2)	as monto_mes2,
		   varchar(10)		as mes3,
		   dec(16,2)	as monto_mes3;

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
define _reclamo			char(20);
define _no_cheque		integer;
define _cuenta          varchar(25);
define _mes1, _mes2,_mes,_ano2, _ano1,_orden, _meses   SMALLINT;
define _fecha2, _fecha1, _fecha_p     	      DATE;
define _fecha_impresion date;
define _contador, _contador2, _contador3         integer;  
define _mes11, _mes12, _mes13, _mes21, _mes22, _mes23 smallint;
define _monto11, _monto12, _monto13, _monto21, _monto22, _monto23 dec(16,2);  
define _cod_ramo char(3);
define _mes111, _mes122, _mes133 varchar(10);

CREATE TEMP TABLE temp_presu(
		  tipo_ramo       SMALLINT,
		  fecha_impresion DATE,
		  monto           dec(16,2),
		  dia             smallint,
		  mes             smallint,
		  ano             smallint,
		  PRIMARY KEY(tipo_ramo, fecha_impresion)) WITH NO LOG;

CREATE TEMP TABLE temp_presu_sal(
         dia		smallint,
         mes11      smallint,
		 monto11    dec(16,2),
		 mes12		smallint,
		 monto12	dec(16,2),
		 mes13		smallint,
		 monto13	dec(16,2),
		 mes21		smallint,
		 monto21	dec(16,2),
		 mes22		smallint,
		 monto22	dec(16,2),
		 mes23		smallint,
		 monto23	dec(16,2))
		 WITH NO LOG;

SET ISOLATION TO DIRTY READ;

LET _ano1 = a_periodo[1,4];
LET _mes1 = a_periodo[6,7];

LET _fecha_p = MDY(_mes1,1,_ano1);
LET _fecha1 = _fecha_p - 2 UNITS MONTH;
LET _fecha2 = _fecha_p + 1 UNITS MONTH;
LET _fecha2 = _fecha2 - 1;

foreach
select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = '002' 

foreach
 select	no_requis,
		cod_cliente,
		monto,
		a_nombre_de,
		periodo_pago,
		firma1,
		firma2,
		no_cheque,
		fecha_impresion
   into	_no_requis,
		_cod_cliente,
		_monto,
		_a_nombre_de,
		_periodo_pago,
		_firma1,
		_firma2,
		_no_cheque,
		_fecha_impresion
   from	chqchmae
  where anulado         = 0
  --  and autorizado      = 1
	and pagado			= 1
	and origen_cheque   = '3'
	and fecha_impresion >= _fecha1 
	and fecha_impresion <= _fecha2
	and cod_banco       = _cod_banco
	and cod_chequera    = _cod_chequera
	and en_firma        = 2
	
   foreach
	select numrecla
	  into _reclamo
	  from chqchrec
	 where no_requis = _no_requis
	exit foreach;
   end foreach   
   
   if _reclamo[1,2] not in ('02','20','23') then
	continue foreach;
   end if

	   BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_presu
                SET monto = monto + _monto
               WHERE tipo_ramo     = 1
                 AND fecha_impresion  = _fecha_impresion;

          END EXCEPTION
          INSERT INTO temp_presu
              VALUES(1,
                     _fecha_impresion,
                     _monto,
					 day(_fecha_impresion),
					 month(_fecha_impresion),
					 year(_fecha_impresion)
                     );
       END
   
end foreach
end foreach

foreach
	select cod_banco,
		   cod_chequera
	  into _cod_banco,
		   _cod_chequera
	  from chqbanch
	 where cod_ramo = '018'

	foreach
	 select	no_requis,
			cod_cliente,
			monto,
			a_nombre_de,
			periodo_pago,
			firma1,
			firma2,
			no_cheque,
			fecha_impresion
	   into	_no_requis,
			_cod_cliente,
			_monto,
			_a_nombre_de,
			_periodo_pago,
			_firma1,
			_firma2,
			_no_cheque,
			_fecha_impresion
	   from	chqchmae
	  where anulado         = 0
--		and autorizado      = 1
		and cod_banco       = _cod_banco
		and cod_chequera    = _cod_chequera
		and pagado			= 1
		and en_firma        = 2
		and fecha_impresion between _fecha1 and _fecha2

	   BEGIN
          ON EXCEPTION IN(-239)
             UPDATE temp_presu
                SET monto = monto + _monto
               WHERE tipo_ramo     = 2
                 AND fecha_impresion  = _fecha_impresion;

          END EXCEPTION
          INSERT INTO temp_presu
              VALUES(2,
                     _fecha_impresion,
                     _monto,
					 day(_fecha_impresion),
					 month(_fecha_impresion),
					 year(_fecha_impresion)
                     );
       END
	   
	end foreach
end foreach

foreach
	select cod_banco,
		   cod_chequera,
		   cod_ramo
	  into _cod_banco,
		   _cod_chequera,
		   _cod_ramo
	  from chqbanch
	 where cod_ramo in ('016','019') 

	foreach
	 select	no_requis,
			cod_cliente,
			monto,
			a_nombre_de,
			periodo_pago,
			firma1,
			firma2,
			no_cheque,
			fecha_impresion
	   into	_no_requis,
			_cod_cliente,
			_monto,
			_a_nombre_de,
			_periodo_pago,
			_firma1,
			_firma2,
			_no_cheque,
			_fecha_impresion
	   from	chqchmae
	  where anulado         = 0
	 --   and autorizado      = 1
		and pagado			= 1
		and origen_cheque   = '3'
		and fecha_impresion >= _fecha1 
		and fecha_impresion <= _fecha2
		and cod_banco       = _cod_banco
		and cod_chequera    = _cod_chequera
		and en_firma        = 2
				
	   foreach
		select numrecla, transaccion
		  into _reclamo, _transaccion
		  from chqchrec
		 where no_requis = _no_requis
		exit foreach;
	   end foreach   
	   
	   if _reclamo[1,2] <> _cod_ramo[2,3] then
		continue foreach;
	   end if

		   BEGIN
			  ON EXCEPTION IN(-239)
				 UPDATE temp_presu
					SET monto = monto + _monto
				   WHERE tipo_ramo     = 2
					 AND fecha_impresion  = _fecha_impresion;

			  END EXCEPTION
			  INSERT INTO temp_presu
				  VALUES(2,
						 _fecha_impresion,
						 _monto,
						 day(_fecha_impresion),
						 month(_fecha_impresion),
						 year(_fecha_impresion)
						 );
		   END
	   
	end foreach
end foreach

for _contador = 1 to 31
	let _monto = 0.00;
	let _monto11 = 0.00;
	let _monto12 = 0.00;
	let _monto13 = 0.00;
	let _monto21 = 0.00;
	let _monto22 = 0.00;
	let _monto23 = 0.00;
 for _contador2 = 1 to 2
	let _mes1 = month(_fecha2);
	let _ano1 = year(_fecha2);
	
	for _contador3 = 1 to 3
		select monto
		  into _monto
		  from temp_presu
		 where tipo_ramo = _contador2
		   and dia = _contador
		   and mes = _mes1
		   and ano = _ano1;
		   
		if _monto is null then
			let _monto = 0.00;
		end if
		  
		if _contador2 = 1 then
			if _contador3 = 1 then
				let _monto11 = _monto;
				let _mes11 = _mes1;
			elif _contador3 = 2 then
				let _monto12 = _monto;
				let _mes12 = _mes1;
		    else
				let _monto13 = _monto;
				let _mes13 = _mes1;
		    end if
		else
			if _contador3 = 1 then
				let _monto21 = _monto;
				let _mes21 = _mes1;
			elif _contador3 = 2 then
				let _monto22 = _monto;
				let _mes22 = _mes1;
		    else
				let _monto23 = _monto;
				let _mes23 = _mes1;
		    end if
		end if
		
		let _mes1 = _mes1 - 1;
	    if _mes1 = 0 then
			let _mes1 = 12;
			let _ano1 = _ano1 - 1;
		end if
	end for
  end for
  insert into temp_presu_sal values(
         _contador,
         _mes11,
		 _monto11,
		 _mes12,
		 _monto12,
		 _mes13,
		 _monto13,
		 _mes21,
		 _monto21,
		 _mes22,
		 _monto22,
		 _mes23,
		 _monto23);
         
end for

foreach with hold
	select dia,
           mes11,
		   monto11,
		   mes12,
		   monto12,
		   mes13,
		   monto13,
		   mes21,
		   monto21,
		   mes22,
		   monto22,
		   mes23,
		   monto23
	  into _contador,
         _mes11,
		 _monto11,
		 _mes12,
		 _monto12,
		 _mes13,
		 _monto13,
		 _mes21,
		 _monto21,
		 _mes22,
		 _monto22,
		 _mes23,
		 _monto23
	 from temp_presu_sal

	 if _mes11 = 1 then
		let _mes111 = "ENERO";
	 ELIF _mes11 = 2 then
		let _mes111 = "FEBRERO";
	 ELIF _mes11 = 3 then
		let _mes111 = "MARZO";
	 ELIF _mes11 = 4 then
		let _mes111 = "ABRIL";
	 ELIF _mes11 = 5 then
		let _mes111 = "MAYO";
	 ELIF _mes11 = 6 then
		let _mes111 = "JUNIO";
	 ELIF _mes11 = 7 then
		let _mes111 = "JULIO";
	 ELIF _mes11 = 8 then
		let _mes111 = "AGOSTO";
	 ELIF _mes11 = 9 then
		let _mes111 = "SEPTIEMBRE";
	 ELIF _mes11 = 10 then
		let _mes111 = "OCTUBRE";
	 ELIF _mes11 = 11 then
		let _mes111 = "NOVIEMBRE";
	 ELSE
		let _mes111 = "DICIEMBRE";	 
	 END IF

	 if _mes12 = 1 then
		let _mes122 = "ENERO";
	 ELIF _mes12 = 2 then
		let _mes122 = "FEBRERO";
	 ELIF _mes12 = 3 then
		let _mes122 = "MARZO";
	 ELIF _mes12 = 4 then
		let _mes122 = "ABRIL";
	 ELIF _mes12 = 5 then
		let _mes122 = "MAYO";
	 ELIF _mes12 = 6 then
		let _mes122 = "JUNIO";
	 ELIF _mes12 = 7 then
		let _mes122 = "JULIO";
	 ELIF _mes12 = 8 then
		let _mes122 = "AGOSTO";
	 ELIF _mes12 = 9 then
		let _mes122 = "SEPTIEMBRE";
	 ELIF _mes12 = 10 then
		let _mes122 = "OCTUBRE";
	 ELIF _mes12 = 11 then
		let _mes122 = "NOVIEMBRE";
	 ELSE
		let _mes122 = "DICIEMBRE";	 
	 END IF

	 if _mes13 = 1 then
		let _mes133 = "ENERO";
	 ELIF _mes13 = 2 then
		let _mes133 = "FEBRERO";
	 ELIF _mes13 = 3 then
		let _mes133 = "MARZO";
	 ELIF _mes13 = 4 then
		let _mes133 = "ABRIL";
	 ELIF _mes13 = 5 then
		let _mes133 = "MAYO";
	 ELIF _mes13 = 6 then
		let _mes133 = "JUNIO";
	 ELIF _mes13 = 7 then
		let _mes133 = "JULIO";
	 ELIF _mes13 = 8 then
		let _mes133 = "AGOSTO";
	 ELIF _mes13 = 9 then
		let _mes133 = "SEPTIEMBRE";
	 ELIF _mes13 = 10 then
		let _mes133 = "OCTUBRE";
	 ELIF _mes13 = 11 then
		let _mes133 = "NOVIEMBRE";
	 ELSE
		let _mes133 = "DICIEMBRE";	 
	 END IF
	 
	 return _contador,
         trim(_mes111),
		 _monto11,
		 trim(_mes122),
		 _monto12,
		 trim(_mes133),
		 _monto13,
		 trim(_mes111),
		 _monto21,
		 trim(_mes122),
		 _monto22,
		 trim(_mes133),
		 _monto23,
		 trim(_mes111),
		 _monto11 + _monto21,
		 trim(_mes122),
		 _monto12 + _monto22,
		 trim(_mes133),
		 _monto13 + _monto23 with resume;
	
end foreach

DROP TABLE temp_presu;
DROP TABLE temp_presu_sal;
end procedure
