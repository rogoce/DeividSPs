drop procedure sp_rec252;
create procedure sp_rec252(a_periodo char(7),a_diferencia	smallint	default 0)
returning char(20), char(10), dec(16,2), dec(16,2), dec(16,2), dec(16,2), dec(16,2), dec(16,2), dec(16,2), dec(16,2), dec(16,2), char(50),
		  char(7), char(100), date, date, char(10), char(18), char(8);
		  
define _numrecla		char(20);
define _transaccion		char(10);
define _no_tranrec		char(10);
define _anular_nt		char(10);
define _anular_nt2		char(10);
define _no_reclamo		char(10);
define _no_poliza		char(10);
define _cod_tipoprod,_cod_tipopago	char(3);
define _usuario         char(8);
define _fecha_tran		date;
define _fecha_anul		date;
define _no_requis		char(10);
define _cheque_pagado	smallint;
define _cheque_anulado	smallint;
define _cheque_periodo	char(7);
define _monto_tran		dec(16,2);
define _fecha_anulado	date;
define _periodo_anulado	char(7);
define _tran_pagada		smallint;
define _generar_cheque		smallint;

define _por_pagar		dec(16,2);
define _pagado			dec(16,2);
define _anulado			dec(16,2);
define _cheques			dec(16,2);
define _mov_mes			dec(16,2);
define _actual			dec(16,2);
define _anterior		dec(16,2);
define _mov_neto		dec(16,2);
define _mov_dif			dec(16,2);

define _cantidad		smallint;
define _perido_ant		char(7);
define _descrip			char(50);
define _periodo			char(7);
define _cod_cliente     char(10);
define _nombre_clien    char(100);
define _fecha_impresion date;
define _fecha_captura   date;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _n_tipopago      char(18);

let _transaccion = "";
let _fecha_impresion = "";
let _fecha_captura = "";

--set debug file to "sp_rec252.trc";
--trace on;

begin
on exception set _error, _error_isam, _error_desc

	drop table tmp_26612;

	return _error,_transaccion,0,0,0,0,0,0,0,0,0,"",a_periodo,"","","","","","" with resume;

end exception
 
let _perido_ant = sp_sis147(a_periodo);

create temp table tmp_26612(
numrecla			char(20),
transaccion		    char(10),
por_pagar			dec(16,2) default 0,
pagado				dec(16,2) default 0,
anulado				dec(16,2) default 0,
actual				dec(16,2) default 0,
anterior			dec(16,2) default 0
) with no log;

set isolation to dirty read;

-- Por Pagar

foreach
	select numrecla,
		   transaccion,
		   monto,
		   anular_nt,
		   no_reclamo,
		   fecha,
		   no_tranrec,
		   generar_cheque,
		   cod_tipopago,
		   user_added
	  into _numrecla,
		   _transaccion,
		   _por_pagar,
		   _anular_nt,
    	   _no_reclamo,
		   _fecha_tran,
		   _no_tranrec,
		   _generar_cheque,
		   _cod_tipopago,
		   _usuario
	  from rectrmae
	 where (periodo		= a_periodo
	   and actualizado	= 1
	   and cod_tipotran	= "004"
	   and monto		<> 0)
--	   or transaccion = '10-371663'
--	   and numrecla = '18-0819-10915-01'
		 
	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	 
 	select nombre
	  into _n_tipopago
	  from rectipag
	 where cod_tipopago = _cod_tipopago;

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _transaccion not in ("01-1174785", "01-1151748", "01-1066282", "01-1077933", "01-1079128", "01-1080470", "01-1088531", "01-1089805", 
							"01-1095786", "01-1109632", "01-1127556", "01-1127971", "01-1209514", '10-258278', '10-258226', '10-258228',
							'10-258284', '10-258277', '10-258287', '10-258286',	'10-294953', '01-1436052', '01-1438450', '01-1476541',
							'10-320723', '01-1712176','01-1712181', '01-1698292', '01-1715379',	'01-1715835', '01-1715839',	'06-29788',
							'06-07098', '01-1775710', '01-1775715',	'01-1775720', '01-1775721', '01-1775723', '01-1775725', '01-1775726',
							'10-403103', '01-1858697', '10-422248','01-183510','01-183534','01-2225823')
							{,'01-1323577',	'01-1350973'),'01-1358608') } then
		
			if _cod_tipoprod		= "002" 	and 
			   _generar_cheque 	= 0 	then
			
				select count(*)
				  into _cantidad
				  from recasien
				 where no_tranrec = _no_tranrec
				   and cuenta      = "26612";

				if _cantidad <> 0 then
                   
                    if _transaccion not in ('05-20387','01-1865207','01-1865202','01-1890532','10-439034') then --transacciones de coaseguros 
						return _numrecla,
								_transaccion,
								_por_pagar, 
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								0,
								"26612 - Coas",
								a_periodo,
								"",
								"",
								"",
								"",
								_n_tipopago,_usuario
								with resume;
                    else
						return _numrecla,
								_transaccion,
								_por_pagar, 
								0,
								0,
								0,
								_por_pagar,
								0,
								0,
								0,
								0,
								"26612 - Coas",
								a_periodo,
								"",
								"",
								"",
								"",
								_n_tipopago,_usuario
								with resume;
                    end if        
				end if
			
			    if _transaccion not in ('01-1864790','01-1864840') then
					continue foreach;
				end if
			end if
	end if
			
		if _anular_nt is not null then

			select fecha 
			  into _fecha_anul
			  from rectrmae
			 where transaccion = _anular_nt;

			if  _fecha_anul = _fecha_tran then
				if _anular_nt < _transaccion then
					let _transaccion = _anular_nt;
				end if
			elif _fecha_anul < _fecha_tran then
				let _transaccion = _anular_nt;
			end if
			
		end if
		
--		if _anular_nt in ('10-461665','10-463459','01-2082174') then --Transacciones que contabilidad pidió excluir en el cierre de 2025-08 que tenían en una lista de anulacion en lote
--			continue foreach;
--		end if
		
		if _transaccion = '10-348570' then	--se excl. ver con Amado. importador Sabish por error incluyo un reclamo 23-0619-00531-10 que no es de coaseguro.
			continue foreach;
		end if
	--	if _transaccion = '01-1698292' then	--transaccion caso especial de salud 04-05-2020
	--		continue foreach;
	--	end if		
		insert into tmp_26612 (numrecla, transaccion, por_pagar)
		values (_numrecla, _transaccion, _por_pagar);
	 
end foreach

--trace off;
-- Cheques Pagados

foreach
	select r.numrecla,
		   r.transaccion,
	       r.monto
	  into _numrecla,
	       _transaccion,
	       _pagado
	  from chqchmae m, chqchrec r
	 where m.no_requis = r.no_requis 
	   and m.periodo   = a_periodo
	   and m.pagado	   = 1
	   and r.monto	   <> 0
	 --  and r.transaccion = '01-1712176'
	 
	if _transaccion in ('01-2229931','01-2230932','01-2233726','01-2230844')  then
		continue foreach;
	end if	   

	insert into tmp_26612 (numrecla, transaccion, pagado)
	values (_numrecla, _transaccion, _pagado);

end foreach

-- Cheques Anulados

foreach
	select r.numrecla,
	       r.transaccion,
	       r.monto
	  into _numrecla,
	       _transaccion,
	       _anulado
	  from chqchmae m, chqchrec r
	 where m.no_requis = r.no_requis 
	   and year(m.fecha_anulado)	= a_periodo[1,4]
	   and month(m.fecha_anulado)	= a_periodo[6,7]
	   and m.pagado = 1
	   and m.anulado = 1
	   and r.monto <> 0
		--	   and r.transaccion = '01-1712176'

	if _transaccion = '10-503514' and a_periodo = '2025-08' then
		continue foreach;
	end if
	
	if _transaccion in ('01-2229931','01-2230932','01-2233726','01-2230844')  then
		continue foreach;
	end if	   

	insert into tmp_26612 (numrecla, transaccion, anulado)
	values (_numrecla, _transaccion, _anulado);
	 
end foreach

-- Por Pagar Actual

foreach
	select numrecla,	
		   transaccion,
		   monto
	  into _numrecla,
		   _transaccion,
		   _actual
	  from reccietr
	 where periodo = a_periodo
	  --  and transaccion = '01-1712176'


	insert into tmp_26612 (numrecla, transaccion, actual)
	values (_numrecla, _transaccion, _actual);
	 
end foreach

-- Por Pagar Anterior

foreach
	select numrecla,	
	       transaccion,
	       monto
	  into _numrecla,
	       _transaccion,
	       _anterior
	  from reccietr
	 where periodo = _perido_ant
	--   and transaccion = '01-1712176'

	insert into tmp_26612 (numrecla, transaccion, anterior)
	values (_numrecla, _transaccion, _anterior);
	 
end foreach

foreach
	select numrecla,
		   transaccion,
		   sum(por_pagar),
		   sum(pagado),
		   sum(anulado),
		   sum(actual),
		   sum(anterior)
	  into _numrecla,
		   _transaccion,
		   _por_pagar,
		   _pagado,
		   _anulado,
		   _actual,
		   _anterior
	  from tmp_26612
	 group by 1, 2
	 order by 1, 2

	if _transaccion in  ('01-1289504','01-1323577','01-1305177','01-1316833') then --,'01-1864790','01-1864840','10-367793'
		let _actual = _anterior;
		let _por_pagar = 0.00;
	end if

	let _fecha_impresion = "";
    let _fecha_captura = "";

	select no_tranrec,
		   periodo,
		   anular_nt,
		   fecha_anulo,
		   no_requis,
		   monto,
		   pagado,
		   cod_cliente,
		   cod_tipopago,
		   user_added
	 into _no_tranrec,
		  _periodo,
		  _anular_nt2,
		  _fecha_anulado,
		  _no_requis,
		  _monto_tran,
		  _tran_pagada,
		  _cod_cliente,
		  _cod_tipopago,
		  _usuario
	from rectrmae
   where transaccion = _transaccion;
		 
	select nombre
	  into _n_tipopago
	  from rectipag
	 where cod_tipopago = _cod_tipopago;
		 
	select nombre 
	  into _nombre_clien
	  from cliclien
	 where cod_cliente = _cod_cliente;

	let _cheque_pagado	= 0;
	let _cheque_anulado = 0;
		
	if _no_requis is not null then
	
		 select pagado,
				anulado,
				periodo,
				fecha_impresion,
				fecha_captura
		  into _cheque_pagado,
			   _cheque_anulado,
			   _cheque_periodo,
			   _fecha_impresion,
			   _fecha_captura
		  from chqchmae
		 where no_requis = _no_requis; 

	end if

	let _cheques 	= _pagado 		- _anulado;
	let _mov_mes 	= _por_pagar 	- _cheques;
	let _mov_neto	= _actual 		- _anterior;
	let _mov_dif	= _mov_neto 	- _mov_mes;
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Validaciones
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	let _descrip = null;

	if _tran_pagada 	=	1 	and 
	   _anular_nt2		is null	and
	   _no_requis		is null	then	
	   
		let _descrip = "No Pagada";
	end if

	select count(*)
	  into _cantidad
	  from recasien
	 where no_tranrec = _no_tranrec
	   and cuenta      = "14103";

	if _cantidad <> 0 then
		continue foreach;
	end if
		
	if _anular_nt2 is not null then
		let _periodo_anulado = sp_sis39(_fecha_anulado);
		
		if _periodo_anulado < a_periodo then
			if _transaccion not in ("10-249705", "10-249913",'03-23358 ','03-25741','03-25821','06-06456','06-06462') then
				let _descrip = _periodo_anulado || " Anulado";
			end if
		end if
	end if
	
	if _no_requis is not null then

		select count(*)
		  into _cantidad
		  from chqchrec
		 where no_requis 	= _no_requis
		   and transaccion	= _transaccion;
			
		if _cantidad is null then
			let _cantidad = 0;
		end if

		if _cantidad = 0 then

			let _descrip = trim(_no_requis) || "  No Pagado en Requisicion ";
			
		end if
		
	end if
	
	if _anular_nt2		is not null 	and 
	   _no_requis 		is not null 	and 
	   _cheque_pagado 	= 1 			and 
	   _cheque_anulado	= 0 			then
	
		let _descrip = "Se Anulo: " || _anular_nt2 || " Se Pago: " || _no_requis;
	end if

	if _no_requis 		is not null 	and 
	   _cheque_pagado 	= 1 			and 
	   _cheque_anulado	= 0 			and
	   _cheque_periodo	< a_periodo	then

		--if _transaccion not in ("01-156072") then
			let _descrip = trim(_no_requis) || " Pagado en " || _cheque_periodo;
		--end if	
		
		if _anterior	<> 0			and 
		   _actual		= 0 			and
		   _por_pagar 	= 0				and 
		   _pagado 		= 0 			and  
		   _anulado 	= 0 			then

		end if
	end if
	
	select count(*)
	  into _cantidad
	  from chqchrec r, chqchmae m
	 where r.no_requis	= m.no_requis
	   and pagado 		= 1
	   and anulado		= 0
	   and transaccion	= _transaccion;
		
	if _cantidad is null then
		let _cantidad = 0;
	end if

	if _cantidad > 1 then
		--if _transaccion not in ("01-156072") then
			let _descrip = "Pagado mas de un cheque " || _cantidad;
		--end if	
	end if

	-- Return Cuando Hay Error

	if _descrip	is not null	and _mov_dif = 0 then	
		let _mov_dif = _monto_tran;
	end if

	if _transaccion in ('01-1289504','01-1305177','01-1323577','01-1316833','05-11317') then
		let _mov_dif = 0;
		let _descrip = '';
	end if

	if a_diferencia = 1 then
	
		if _mov_dif <> 0 then
		   
			 return _numrecla,
					_transaccion,
					_por_pagar, 
					_pagado,
					_anulado,
					_cheques,
					_mov_mes,
					_anterior,
					_actual,
					_mov_neto,
					_mov_dif,
					_descrip,
					_periodo,
					_nombre_clien,
					_fecha_impresion,
					_fecha_captura,
					_no_requis,
					_n_tipopago,_usuario
					with resume;
					
		end if

	else
		
			 return _numrecla,
					_transaccion,
					_por_pagar, 
					_pagado,
					_anulado,
					_cheques,
					_mov_mes,
					_anterior,
					_actual,
					_mov_neto,
					_mov_dif,
					_descrip,
					_periodo,
					_nombre_clien,
					_fecha_impresion,
				    _fecha_captura,
					_no_requis,
					_n_tipopago,_usuario
					with resume;

		end if				
end foreach
drop table tmp_26612;
end 

return "","",0,0,0,0,0,0,0,0,0,"","9999-99","","","","","","" with resume;
 
end procedure
                                                                                                          
