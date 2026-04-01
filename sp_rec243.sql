-- Procedure que Depura las TRansacciones de Pago de la cuenta 26612
-- Inctrucciones Leyri Moreno, Correo del 11/06/2015

drop procedure sp_rec243;

create procedure sp_rec243()
returning char(10),
          char(10),
		  char(10),
		  char(20);


define _transaccion	char(10);
define _pagado		smallint;
define _no_requis	char(10);
define _anular_nt	char(10);
define _numrecla	char(20);

define _id			integer;
define _no_tranrec	char(10);
define _no_tranrec2	char(10);
define _cantidad	integer;
define _cant_sec	integer;

define _compania   	char(3); 
define _sucursal   	char(3); 
define _no_reclamo 	char(10);
define _valor_nvo	char(10);
define _user		char(10);

define _error		integer;

let _user     = "GERENCIA";
let _error    = 0;
let _cant_sec = 0;

--set debug file to "sp_rec243.trc";
--trace on;

set isolation to dirty read;

begin work;

--update deivid_tmp:tmp_depurar26612
--   set procesado         = 0,
--	   pagado            = 0,
--	   transaccion_anula = null;  

foreach
 /*select transaccion,
        id
   into _transaccion,
        _id
   from deivid_tmp:tmp_depurar26612
  where procesado    = 0
	and transaccion  not in ("10-128475", "01-979339", "01-976012", "01-975998")
--	and transaccion  = "01-1032996"
--    and saldo        > 0
--    and reclamo[1,2] not in ("02")
  order by reclamo*/

	

	select pagado,
	       no_requis,
		   anular_nt,
		   numrecla,
		   no_tranrec,
		   no_reclamo,
		   cod_compania,
		   cod_sucursal,
		   transaccion
	  into _pagado,
	       _no_requis,
		   _anular_nt,
		   _numrecla,
		   _no_tranrec,
		   _no_reclamo,
		   _compania,
		   _sucursal,
		   _transaccion
	  from rectrmae
	 where anular_nt is null
	   and transaccion in ('06-06462',
'01-1271616',
'01-1289504',
'01-1305177',
'01-1316833',
'01-1323577',
'05-08545',
'01-1733603',
'01-1792699',
'01-1792700',
'01-1792703',
'01-1832932',
'01-1832939',
'01-1877692',
'01-1877690',
'01-1898300',
'01-1898292',
'01-1917300',
'01-1951929',
'90-04277',
'90-04276',
'01-1957902',
'10-449481',
'01-1962241',
'01-1965266',
'01-1961860',
'01-1961847',
'01-1961883',
'01-1965346',
'90-04400',
'01-1974794',
'90-04550',
'01-1991720',
'01-1988663',
'01-1988671',
'01-1988665',
'01-1988669',
'01-1988689',
'01-1988719',
'01-1988744',
'01-1988746',
'01-1997601',
'10-458559',
'10-456740',
'10-456741',
'10-456569',
'03-67417',
'01-1998645',
'01-1998647',
'01-1998643',
'01-1998636',
'01-1998633',
'01-2016134',
'10-459261',
'10-459780',
'10-460116',
'10-460891',
'10-459969',
'01-2014373',
'01-2008132',
'01-2008903',
'01-2012332',
'01-2012331',
'01-2012334',
'01-2012349',
'01-2012350',
'01-2006707',
'10-461217',
'10-461021',
'01-2017798',
'10-461665',
'01-2017724',
'10-462982',
'01-2018076',
'01-2018034',
'01-2018080',
'01-2023045',
'01-2023046',
'10-465078',
'10-463378',
'10-463459',
'10-463710',
'10-463383',
'10-463927',
'06-36688',
'10-464063',
'01-2030798',
'01-2030377',
'01-2027983',
'01-2031393',
'01-2031392',
'01-2031390',
'01-2031388',
'01-2031387',
'10-463669',
'07-38644',
'07-39018',
'10-466341',
'10-466387',
'10-466364',
'01-2042865',
'10-465474',
'10-466400',
'01-2036797',
'10-466374',
'01-2042101',
'01-2045683',
'01-2051369',
'10-468000',
'10-468668',
'07-39614',
'01-2050963',
'01-2050960',
'10-467930',
'10-469147',
'10-470427',
'10-470648',
'03-70886',
'10-469484',
'01-2061420',
'02-25941',
'02-25940',
'03-70712',
'01-2071042',
'10-471613',
'10-472090',
'01-2070940',
'01-2071327',
'01-2071329',
'10-472415',
'01-2065145',
'03-71900',
'10-476829',
'10-474763',
'01-2082174',
'10-476123',
'10-476586',
'03-71773',
'10-475990',
'01-2083410',
'01-2091874',
'10-479905',
'10-479430',
'10-479202',
'10-478963',
'10-479800',
'10-479801',
'01-2100092',
'10-481626',
'01-2097648',
'01-2099948',
'01-2099947',
'10-481228',
'01-2097372',
'01-2098312',
'01-2098316',
'01-2098318',
'01-2103050',
'01-2103712')

	-- Proceso de Actualizacion Inicial antes de la reversion
	
	if _pagado = 1 then

		if _anular_nt is not null then

			update deivid_tmp:tmp_depurar26612
			   set procesado         = 1,
				   pagado            = 2,
				   transaccion_anula = _anular_nt
			 where id                = _id;  
			 
			continue foreach; 
		
		else
		
			select count(*)
			  into _cantidad
			  from chqchrec
			 where no_requis   = _no_requis
			   and transaccion = _transaccion;
			   
			if _cantidad is null then
				let _cantidad = 0;
			end if
			
			if _cantidad <> 0 then

				update deivid_tmp:tmp_depurar26612
				   set procesado         = 1,
					   pagado            = 1,
				       transaccion_anula = _no_requis
				 where id                = _id;  

				continue foreach; 
				 
			end if
			
		end if
		
	else
	
		if _no_requis is not null then

			select count(*)
			  into _cantidad
			  from chqchrec
			 where no_requis   = _no_requis
               and transaccion = _transaccion;
			   
			if _cantidad is null then
				let _cantidad = 0;
			end if
			
			if _cantidad = 0 then
		
				update rectrmae
				   set no_requis  = null
				 where no_tranrec = _no_tranrec;   
		  
			else
			
				update deivid_tmp:tmp_depurar26612
				   set procesado         = 1,
					   pagado            = 3,
				       transaccion_anula = _no_requis
				 where id                = _id;  

			end if

			continue foreach; 
		
		elif _anular_nt is not null then
		
			update deivid_tmp:tmp_depurar26612
			   set procesado         = 1,
				   pagado            = 2,
				   transaccion_anula = _anular_nt
			 where id                = _id;  
			 
			return _transaccion,
				   _error,
				   _anular_nt,
				   _numrecla
			  with resume;
		
			continue foreach; 

		end if
				 
	end if

--	continue foreach; 

	let _cant_sec = _cant_sec + 1;

	-- Proceso de Reversion
	
	 select count(*)
	   into _cantidad
	   from rectrrea
	  where no_tranrec = _no_tranrec;

	if _cantidad is null then
		let _cantidad = 0;
	end if

	-- No tiene contratos de reaseguros (Error)
	
	if _cantidad = 0 then

		return _transaccion,
			   "0",
			   "",
			   _numrecla
		  with resume;
		  
	else

		 select count(*)
		   into _cantidad
		   from rectrrea
		  where no_tranrec    = _no_tranrec
			and tipo_contrato <> 1;

		-- Solo tiene contrato de retencion
		
		if _cantidad = 0 then

			--{
			let _valor_nvo = sp_sis13(_compania, "REC", "02", "par_tran_genera");

			call sp_rec127(_compania, _sucursal, _no_reclamo, _no_tranrec, _valor_nvo, _user) returning _error, _anular_nt;

			if _error <> 0 then
			
				rollback work;
				
				return _transaccion,
					   _error,
					   _anular_nt,
					   _numrecla;
					   
			end if
				
			update deivid_tmp:tmp_depurar26612
			   set procesado         = 1,
				   pagado            = 4,
				   transaccion_anula = _anular_nt
			 where id                = _id;  
			--}
			
			return _transaccion,
				   _error,
				   _anular_nt,
				   _numrecla
			  with resume;
			  
		else

			let _valor_nvo = sp_sis13(_compania, "REC", "02", "par_tran_genera");

			call sp_rec127(_compania, _sucursal, _no_reclamo, _no_tranrec, _valor_nvo, _user) returning _error, _anular_nt;

			if _error <> 0 then
			
				rollback work;
				
				return _transaccion,
					   _error,
					   _anular_nt,
					   _numrecla;
					   
			end if
				
			update deivid_tmp:tmp_depurar26612
			   set procesado         = 1,
				   pagado            = 5,
				   transaccion_anula = _anular_nt
			 where id                = _id;  

			select no_tranrec 
			  into _no_tranrec2
			  from rectrmae
			 where transaccion = _anular_nt;
			 
			delete from rectrrea
			 where no_tranrec    = _no_tranrec2
			   and tipo_contrato <> 1;
			   
			update rectrrea
               set porc_partic_suma  = 100,
                   porc_partic_prima = 100
			 where no_tranrec    = _no_tranrec2;
			 
			return _transaccion,
		    _cantidad,
		    _anular_nt,
		    _numrecla
			with resume;

		end if
		
	end if
	
	if _cant_sec >= 25 then
		exit foreach;
	end if
	
end foreach
 
--rollback work;
commit work;
 
return "", "", "", "";
 
end procedure