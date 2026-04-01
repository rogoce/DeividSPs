-- Recibos por cuenta 26612 perdida total -- 
-- Creado    : 12/02/2020 - Autor: Henry Giron
-- SIS v.2.0 d_- DEIVID, S.A.
drop procedure sp_rec252a;
create procedure sp_rec252a(
a_periodo 		char(7),
a_diferencia	smallint	default 0)
returning integer, char(50);
		   
define _numrecla		char(20);
define _transaccion		char(10);
define _no_tranrec		char(10);
define _anular_nt		char(10);
define _anular_nt2		char(10);
define _no_reclamo		char(10);
define _no_poliza		char(10);
define _cod_tipoprod	char(3);
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

define _perd_total      smallint;

let _transaccion = "";

let _fecha_impresion = "";
let _fecha_captura = "";
let _perd_total = 0;


--set debug file to "sp_rec252.trc";
--trace on;
drop table if exists tmp_26612;
begin
on exception set _error, _error_isam, _error_desc

	--drop table tmp_26612;

			return _error,
					_error_desc
					with resume;

end exception
 
let _perido_ant = sp_sis147(a_periodo);

create temp table tmp_26612(
numrecla			char(20),
transaccion		char(10),
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
		   generar_cheque
	  into _numrecla,
		   _transaccion,
		   _por_pagar,
		   _anular_nt,
    	   _no_reclamo,
		   _fecha_tran,
		   _no_tranrec,
		   _generar_cheque
	  from rectrmae
	 where periodo		= a_periodo
	   and actualizado	= 1
	   and cod_tipotran	= "004"
	   and monto		<> 0
		 
	select no_poliza, perd_total
	  into _no_poliza, _perd_total
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	 
	 if _perd_total <> 1 then
		continue foreach;
	 end if	   
	 
	 let _cantidad = 0;
	 
		select count(*)
		  into _cantidad
		  from recasien
		 where no_tranrec = _no_tranrec
           and cuenta      = "14103";

		if _cantidad <> 0 then
			continue foreach;
		end if	 

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _transaccion not in (
									"01-1174785", 
									"01-1151748", 
									"01-1066282", 
									"01-1077933", 
									"01-1079128", 
									"01-1080470", 
									"01-1088531", 
									"01-1089805", 
									"01-1095786", 
									"01-1109632", 
									"01-1127556", 
									"01-1127971",
									"01-1209514",
									'10-258278',
									'10-258226',
									'10-258228',
									'10-258284',
									'10-258277',
									'10-258287',
									'10-258286',
									'10-294953',
									'01-1436052',
									'01-1438450',
									'01-1476541',
									'10-320723'){,
									'01-1323577',
									'01-1350973'),
									'01-1358608') }
									then
		
			if _cod_tipoprod		= "002" 	and 
			   _generar_cheque 	= 0 	then
			
				select count(*)
				  into _cantidad
				  from recasien
				 where no_tranrec = _no_tranrec
				   and cuenta      = "26612";

				if _cantidad <> 0 then

					{return _numrecla,
							"26612 - Coas"							
							with resume;}
							continue foreach;
				
				end if
			
				continue foreach;
				
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
		if _transaccion = '10-348570' then	--se excl. ver con Amado. importador Sabish por error incluyo un reclamo 23-0619-00531-10 que no es de coaseguro.
			continue foreach;
		end if
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
	   
		select perd_total
		  into _perd_total
		  from recrcmae
		 where numrecla = _numrecla;
		 
		 if _perd_total <> 1 then
			continue foreach;
		 end if	   	   

		 select no_tranrec
		  into _no_tranrec
		  from rectrmae
		 where transaccion = _transaccion;		 		 

	 let _cantidad = 0;
	 
		select count(*)
		  into _cantidad
		  from recasien
		 where no_tranrec = _no_tranrec
           and cuenta      = "14103";

		if _cantidad <> 0 then
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
	
		select perd_total
		  into _perd_total
		  from recrcmae
		 where numrecla = _numrecla;
		 
		 if _perd_total <> 1 then
			continue foreach;
		 end if	   
		 
		 select no_tranrec
		  into _no_tranrec
		  from rectrmae
		 where transaccion = _transaccion;		 		 

	 let _cantidad = 0;
	 
		select count(*)
		  into _cantidad
		  from recasien
		 where no_tranrec = _no_tranrec
           and cuenta      = "14103";

		if _cantidad <> 0 then
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
  
  		select perd_total
		  into _perd_total
		  from recrcmae
		 where numrecla = _numrecla;
		 
		 if _perd_total <> 1 then
			continue foreach;
		 end if	  
		 
		 select no_tranrec
		  into _no_tranrec
		  from rectrmae
		 where transaccion = _transaccion;		 		 

	 let _cantidad = 0;
	 
		select count(*)
		  into _cantidad
		  from recasien
		 where no_tranrec = _no_tranrec
           and cuenta      = "14103";

		if _cantidad <> 0 then
			continue foreach;
		end if	 		 		 

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
  
  		select perd_total
		  into _perd_total
		  from recrcmae
		 where numrecla = _numrecla;
		 
		 if _perd_total <> 1 then
			continue foreach;
		 end if	  
		 
		 select no_tranrec
		  into _no_tranrec
		  from rectrmae
		 where transaccion = _transaccion;		 		 

	 let _cantidad = 0;
	 
		select count(*)
		  into _cantidad
		  from recasien
		 where no_tranrec = _no_tranrec
           and cuenta      = "14103";

		if _cantidad <> 0 then
			continue foreach;
		end if	 		 		 

		insert into tmp_26612 (numrecla, transaccion, anterior)
		values (_numrecla, _transaccion, _anterior);
	 
end foreach



--drop table tmp_26612;

end 

return 0,'Actualizacion Exitosa';
 
end procedure
                                                                                                          
