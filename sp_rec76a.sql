-- (Proceso diario) para buscar las requisiciones de firma electronica
-- Para poder agregar mas transacciones de reclamos a una misma
-- Modificado: 14/06/2006 - Autor: Armando Moreno Montenegro

drop procedure sp_rec76a;

create procedure "informix".sp_rec76a()
 returning	char(10),	--no_requis
			dec(16,2),	--monto
			char(100),	--a nombre de
			date,		--fecha captura
			char(8),	--user_added
			char(3),
			char(3);

define _nombre_tipo_pago	varchar(50);
define _descripcion			varchar(50);
define _wf_incidente_str	varchar(10);
define _nombre				char(100);
define _numrecla			char(20);
define _no_reclamo			char(10);
define _no_requis			char(10);
define _user_added			char(8);
define _cod_chequera		char(3);
define _cod_banco			char(3);
define _origen_cheque		char(1);
define _monto				dec(16,2);
define _firma_electronica	smallint;
define _periodo_pago		smallint;
define _error				integer;
define _dias				integer;
define _cnt, _cnt_ajust		integer;
define _fecha_captura		date;
define _fecha_time			datetime year to fraction(5);
define _fecha_rec			datetime year to fraction(5);

--set debug file to "sp_rec76a.trc";
--trace on;

set isolation to dirty read;

let _fecha_time 	= current;
let _fecha_rec 	    = current;

update wf_firmas set orden = 0;
--update recajust set orden = 0, ord_tercero = 0;

foreach
	select cod_banco,
	       cod_chequera
	  into _cod_banco,
		   _cod_chequera
	  from chqbanch
	 where cod_ramo <> '*' -- Se modifico ya que tambien hay de autos
	 group by 1,2
--	 where cod_ramo = '018'

	select firma_electronica
	  into _firma_electronica
	  from chqchequ
	 where cod_banco    = _cod_banco
	   and cod_chequera	= _cod_chequera;

	if _firma_electronica = 1 then	--es chequera de firma electronica
	else
		continue foreach;	
	end if
   
    update chqchmae
	   set autorizado    = 1
	 where autorizado    = 0
	   and pagado        = 0
	   and anulado       = 0
 	   and origen_cheque = "S"
	   and cod_banco     = _cod_banco
	   and cod_chequera  = _cod_chequera
	   and en_firma	  in (0, 4)
	   and monto         > 0.00;
	
	foreach
		select no_requis,
			   monto,
			   a_nombre_de,
			   periodo_pago,
			   user_added,
			   fecha_captura,
			   origen_cheque
		  into _no_requis,
			   _monto,
			   _nombre,
			   _periodo_pago,
			   _user_added,
			   _fecha_captura,
			   _origen_cheque
		  from chqchmae
		 where autorizado		= 1
		   and pagado			= 0
		   and anulado			= 0
		   and origen_cheque	in ("3","G","S","M") --,"K" Por este lado no se irá a firma la devolucion por poliza cancelada -- ahora es desde cobros que se pasa -- Se agregó "M" reclamo accidentes personales Amado 26-06-2025
		   and cod_banco		= _cod_banco
		   and cod_chequera		= _cod_chequera
		   and en_firma			in (0, 4)
		   and monto			> 0.00
		  
 --		and fecha_captura < date(current) --> Para volver a generar cuando el servidor de error. Amado 27/02/2012
 --		and origen_cheque in ("3","G")
 --		and no_requis = '821545'

       if _periodo_pago is null then
		let _periodo_pago = 0;
	   end if

		select count(*)
		  into _cnt
		  from chqchrec
		 where no_requis = _no_requis;
	    
		if _cnt > 0  then
		else
			if _origen_cheque = "3"	then
				continue foreach;
			end if
		end if  	

        -- No pasar yoseguro
		let _cnt_ajust = 0;
		
		select count(*)
		  into _cnt_ajust
		  from recordam
		 where no_requis = _no_requis;	

        if _cnt_ajust is null then
			let _cnt_ajust = 0;
        end if		
		
		select count(*)
		  into _cnt		
		  from chqchrec a, rectrmae b
		 where a.no_requis = b.no_requis
		   and b.yoseguro = 1
		   and a.no_requis = _no_requis;

		if _cnt > 0 and _cnt_ajust = 0 then
			continue foreach;
		end if  	

		if _origen_cheque in ("3","M") then  -- Caso 09862 USER: CMARIN 
			let _cnt = 0;
			select count(*)
			  into _cnt
			  from chqchrec
			 where no_requis = _no_requis
			   and numrecla[1,2] in ('02','20','18','04','23','16','19');

			if _cnt = 0 then
				continue foreach;
			end if   
		end if

		let _dias = today - _fecha_captura;

		set lock mode to wait;

		if _origen_cheque = 'G' then
			if _dias = 0 then
				update chqchmae
				   set en_firma         = 1,
					   fecha_paso_firma = _fecha_time
				 where no_requis        = _no_requis;
	  
				return _no_requis,
					   _monto,
					   _nombre,
					   _fecha_time,
					   _user_added,
					   _cod_banco,
					   _cod_chequera
				with resume;
			end if
		elif _origen_cheque = 'S' then
			update chqchmae
			   set en_firma         = 1,
				   fecha_paso_firma = _fecha_time
			 where no_requis        = _no_requis;
		
			return _no_requis,
				   _monto,
				   _nombre,
				   _fecha_time,
				   _user_added,
				   _cod_banco,
				   _cod_chequera
			with resume;
		else
			if _periodo_pago = 0 then    --diario
				if _dias >= 1 then			   
					update chqchmae
					   set en_firma         = 1,
						   fecha_paso_firma = _fecha_time
					 where no_requis        = _no_requis;
				
                -- Insertando en RECNOTAS
					foreach
						select numrecla
						  into _numrecla
						  from chqchrec
						 where no_requis = _no_requis
						   and numrecla[1,2] in ('02','20','04','23','16','19')

						let _fecha_rec = _fecha_rec + 1 units second;

						select no_reclamo
						  into _no_reclamo
						  from recrcmae 
						 where numrecla = _numrecla;

						call sp_rwf104(_no_reclamo,_fecha_rec,"La requisicion # " || trim(_no_requis) || " subio a firma electronica",_user_added) returning _error, _descripcion;
					end foreach				 

					return _no_requis,
						   _monto,
						   _nombre,
						   _fecha_time,
						   _user_added,
						   _cod_banco,
						   _cod_chequera
					with resume;
				end if
			elif _periodo_pago = 1 then  --semanal
				if _dias > 7 then
					update chqchmae
					   set en_firma         = 1,
						   fecha_paso_firma = _fecha_time
					 where no_requis        = _no_requis;

					-- Insertando en RECNOTAS
					foreach
						select numrecla
						  into _numrecla
						  from chqchrec
						 where no_requis = _no_requis
						   and numrecla[1,2] in ('02','20','04','23','16','19')

						let _fecha_rec = _fecha_rec + 1 units second;

						select no_reclamo
						  into _no_reclamo
						  from recrcmae 
						 where numrecla = _numrecla;

						call sp_rwf104(_no_reclamo,_fecha_rec,"La requisicion # " || trim(_no_requis) || " subio a firma electronica",_user_added) returning _error, _descripcion;
					end foreach
					
					return _no_requis,
						   _monto,
						   _nombre,
						   _fecha_time,
						   _user_added,
						   _cod_banco,   
						   _cod_chequera
						   with resume;
				end if
			else	--mensual
				if _dias > 30 then
					update chqchmae
					   set en_firma         = 1,
						   fecha_paso_firma = _fecha_time
					 where no_requis        = _no_requis;

					-- Insertando en RECNOTAS
					foreach
						select numrecla
						  into _numrecla
						  from chqchrec
						 where no_requis = _no_requis
						   and numrecla[1,2] in ('02','20','04','23','16','19')

						let _fecha_rec = _fecha_rec + 1 units second;

						select no_reclamo
						  into _no_reclamo
						  from recrcmae 
						 where numrecla = _numrecla;

						call sp_rwf104(_no_reclamo,_fecha_rec,"La requisicion # " || trim(_no_requis) || " subio a firma electronica",_user_added) returning _error, _descripcion;
					end foreach
				
					return _no_requis,
						   _monto,
						   _nombre,
						   _fecha_time,
						   _user_added,
						   _cod_banco,
						   _cod_chequera
					with resume;
				end if
			end if
		end if
		set isolation to dirty read;
	end foreach
end foreach
end procedure
