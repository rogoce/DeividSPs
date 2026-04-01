-- Creado    : 10/12/2010 - Autor: Roman Gordon
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_cob257;

create procedure "informix".sp_cob257(
a_datos			char(512),
a_cod_agente	char(5),
a_tipo_md		char(3),
a_tipo_formato	smallint) 
returning	char(10),	-- _no_remesa,
			char(10),	-- _no_cheque,        
			char(10),	-- _fecha_remesa,		
			char(10),	-- _fecha_desde,		
			char(10),	-- _fecha_hasta,		
			dec(16,2),	-- _monto_total,		
			dec(16,2),	-- _monto_comis,		
			dec(16,2),	-- _monto_comis_cobro,
			dec(16,2),	-- _monto_comis_visa,	
			dec(16,2),	-- _monto_comis_clave,
			dec(16,2),	-- _monto_bruto,
			char(20),	-- _no_documento,		  
			char(5),	-- _secuencia,
			dec(16,2),	-- _porc_comis,
			dec(16,2),	-- _neto_pagado,
			dec(16,2),	-- _comis_desc,
			char(10),	-- _no_recibo,
			char(50),	-- _cliente,
			char(10),	-- _fecha_pago,
			dec(16,2);	-- _monto_cobrado		  

					   
define _char_1				char(1);
define _tipo_separador		char(1);
define _signo				char(1);
define _cod_corredor		char(5);
define _secuencia			char(5);
define _dato_dec			char(10);
define _fecha_desde			char(10);  
define _fecha_hasta			char(10);
define _fecha_remesa		char(10);
define _no_remesa	     	char(10);  
define _no_cheque        	char(10);
define _no_recibo			char(10);
define _fecha_pago			char(10);
define _no_documento		char(20);
define _campo				char(30);
define _dato				char(50);
define _cliente				char(50);
define _monto_total			dec(16,2);
define _monto_cobrado		dec(16,2); 
define _monto_comis			dec(16,2); 
define _monto_comis_cobro	dec(16,2); 
define _monto_comis_visa	dec(16,2); 
define _monto_comis_clave	dec(16,2); 
define _monto_bruto			dec(16,2); 
define _porc_comis			dec(16,2);
define _neto_pagado			dec(16,2);
define _comis_desc			dec(16,2);
define _cantidad_archivos	smallint;
define _separador_archivo	smallint;
define _desde				smallint;
define _hasta				smallint;
define _contador			smallint;
define _inicio				smallint;
define _final				smallint;

set isolation to dirty read;
--set debug file to "sp_cob257.trc";
--trace on;

let _char_1			 	= '';	
let	_tipo_separador	   	= '';	
let	_no_documento	   	= '';	
let	_cod_corredor	   	= '';	
let	_secuencia			= '';	
let	_no_remesa	       	= '';	
let	_no_cheque         	= '';	
let	_no_recibo		   	= '';	
let	_dato_dec			= '';	
let	_signo			   	= '';	
let	_campo				= '';	
let	_dato				= '';	
let	_cliente			= '';		
let	_fecha_remesa		= '01/01/1900';
let	_fecha_desde	   	= '01/01/1900';		
let	_fecha_hasta	   	= '01/01/1900';
let	_fecha_pago			= '01/01/1900';
let	_monto_comis_cobro	= 0.00;	
let	_monto_comis_clave	= 0.00;
let	_monto_comis_visa	= 0.00;
let _monto_cobrado		= 0.00;
let	_monto_total		= 0.00;	
let	_monto_comis		= 0.00;	
let	_monto_bruto		= 0.00;	
let	_neto_pagado		= 0.00;	
let	_porc_comis			= 0.00;
let	_comis_desc			= 0.00;
let	_cantidad_archivos	= 0;
let	_separador_archivo	= 0;
let	_desde				= 0;
let	_hasta				= 0;
let	_contador			= 0;
let	_inicio				= 0;
let	_final				= 0;

--------------------------------************* Selecciona la informacion del agente en la tabla cobforpaexm ************************------------------------
select cod_corredor,
	   cantidad_archivos,
	   separador_archivo,
	   tipo_separador
  into _cod_corredor,
	   _cantidad_archivos,
	   _separador_archivo,
	   _tipo_separador
  from cobforpaexm
 where cod_agente = a_cod_agente
   and tipo_formato = a_tipo_formato;

--------------------------------************* En caso de que el archivo sea el archivo control *******************--------------------------------------------

if a_tipo_md = 'con' then 
	if _separador_archivo = 1 then ------------------------***** En caso que la separacion sea por longitud (Archivo Control)*****---------------------------
		foreach
			select campo,
				   desde,
			   	   hasta
		  	  into _campo,
		  	  	   _desde,
		  	   	   _hasta
		  	  from cobforpaexd0
			 where cod_corredor = _cod_corredor
			 order by desde

			let _final = _hasta - _desde + 1;
			let _dato = '';
			let _signo = '';
			
			for _contador = 1 to 512

				let _char_1	= a_datos[1, 1];
				let a_datos	= a_datos[2, 512];
				let _dato	= trim(_dato) || trim(_char_1);
				
				if _contador = _final then
					exit for;
				end if				
			end for

			if _campo = 'no_remesa' then
				let _no_remesa = _dato;
			end if

			if _campo = 'no_cheque' then
				let _no_cheque = _dato;
			end if

			if _campo = 'fecha_remesa' then
				let _fecha_remesa = _dato;
			end if

			if _campo = 'periodo_desde' then
				let _fecha_desde = _dato;
			end if

			if _campo = 'periodo_hasta' then
				let _fecha_hasta = _dato;
			end if

			if _campo = 'monto_total' then
				for _contador = 1 to 50
					let _char_1		= _dato[1, 1];
					
					if _char_1 = '0' then
						let _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							let _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							let _dato = _dato[2, 50];
						else
							exit for;
						end if
				   end if
				end for
				
				if _dato <> '' then
					let _monto_total = _signo || _dato;
				end if
			end if

			if _campo = 'monto_comis' then
				for _contador = 1 to 50
				
					let _char_1		= _dato[1, 1];
					
					if _char_1 = '0' then
						let _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							let _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							let _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				end for
				if _dato <> '' then
					let _monto_comis = _signo || _dato;
				end if
			end if

			if _campo = 'monto_comis_cobro' then
				for _contador = 1 to 50
					let _char_1		= _dato[1, 1];
					
					if _char_1 = '0' then
						let _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							let _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							let _dato = _dato[2, 50];
						else
							exit for;
						end if
					end if
				end for

				if _dato <> '' then
					let _monto_comis_cobro = _signo || _dato;
				end if
			end if

			if _campo = 'monto_comis_visa' then
				for _contador = 1 to 50
					let _char_1		= _dato[1, 1];

					if _char_1 = '0' then
						let _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							let _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							let _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				end for
				
				if _dato <> '' then
					let _monto_comis_visa = _signo || _dato;
				end if
			end if

			if _campo = 'monto_comis_clave' then
				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				END FOR
				if _dato <> '' then
					let _monto_comis_clave = _signo || _dato;
				end if

			end if

			if _campo = 'monto_bruto' then
				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				END FOR
				if _dato <> '' then
					let _monto_bruto = _signo || _dato;
				end if

			end if

		end foreach

	  	  
	else ---------------------------***** En caso que la separacion sea por Tipo de Caracter o por tabulacion (Archivo Control)*****---------------------------
		if _separador_archivo = 3 then
			CALL sp_sis115(a_datos, _tipo_separador);
		else
			let _tipo_separador = '\t';
			CALL sp_sis115(a_datos, _tipo_separador);
		end if
		
		foreach
			select dato,
				   inicio
			  into _dato,
				   _inicio
		  	  from tmp_datos

			Select campo
			  into _campo
			  from cobforpaexd0
			 where cod_corredor = _cod_corredor
			   and desde = _inicio;

			let _signo = '';
			if _campo = 'no_remesa' then
				let _no_remesa = _dato;
			end if

			if _campo = 'no_cheque' then
				let _no_cheque = _dato;
			end if

			if _campo = 'fecha_remesa' then
				let _fecha_remesa = _dato;
			end if

			if _campo = 'periodo_desde' then
				let _fecha_desde = _dato;
			end if	
			if _campo = 'periodo_hasta' then
				let _fecha_hasta = _dato;
			end if

			if _campo = 'monto_cobrado' then
				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				END FOR
				if _dato <> '' then
					let _monto_cobrado = _signo || _dato;
				end if
			end if
			if _campo = 'monto_total' then			

				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if
				   end if
				END FOR
				if _dato <> '' then
							let _monto_total = _signo || _dato;
				end if
			end if

			if _campo = 'monto_comis' then
				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				END FOR
				if _dato <> '' then
					let _monto_comis = _signo || _dato;
				end if
			end if

			if _campo = 'monto_comis_cobro' then
				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if
					end if
				END FOR

				if _dato <> '' then
					let _monto_comis_cobro = _signo || _dato;
				end if

			end if

			if _campo = 'monto_comis_visa' then
				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				END FOR
				if _dato <> '' then
					let _monto_comis_visa = _signo || _dato;
				end if

			end if

			if _campo = 'monto_comis_clave' then
			   FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				END FOR
				if _dato <> '' then
					let _monto_comis_clave = _signo || _dato;
				end if

			end if

			if _campo = 'monto_bruto' then
				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				END FOR
				if _dato <> '' then
					let _monto_bruto = _signo || _dato;
				end if

			end if

		end foreach
				
	end if

------------------------------------------------********************* En caso de que el archivo sea el archivo detalle *******************------------------

elif a_tipo_md = 'det' then	  

	if _separador_archivo = 1 then	------------********************* En caso que la separacion sea por Longitud (Archivo Detalle)********------------------
	foreach
		select campo,
			   desde,
		   	   hasta
	  	  into _campo,
	  	  	   _desde,
	  	   	   _hasta
	  	  from cobforpaexd1
		 where cod_corredor = _cod_corredor
		 order by desde

		let _final = _hasta - _desde + 1;
		let _dato = '';
		let _signo = '';
		FOR _contador = 1 TO 512

			LET _char_1	= a_datos[1, 1];
			LET a_datos	= a_datos[2, 512];

			LET _dato	= TRIM(_dato) || TRIM(_char_1);
			if _contador = _final then
				exit for;
			end if	
			
		END FOR
		
		if _campo = 'secuencia' then
			let _secuencia = _dato;
		end if
		
		if _campo = 'no_remesa' then
			let _no_remesa = _dato;
		end if

		if _campo = 'no_documento' then
			let _no_documento = _dato;
		end if

		if _campo = 'no_recibo' then
			let _no_recibo = _dato;
		end if

		if _campo = 'cliente' then
			let _cliente = _dato;
		end if

		if _campo = 'fecha_pago' then
			let _fecha_pago = _dato;
		end if
		
		if _campo = 'monto_cobrado' then
			FOR _contador = 1 TO 50

				LET _char_1		= _dato[1, 1];
				if _char_1 = '0' then
					LET _dato = _dato[2, 50];
				else				
					if _char_1 = '-' or _char_1 = '+' then
						let _signo = _char_1;
						LET _dato = _dato[2, 50];
					elif _char_1 = ' ' then
						LET _dato = _dato[2, 50];
					else
						exit for;
					end if					
				end if
			END FOR
			if _dato <> '' then
				let _monto_cobrado = _signo || _dato;
			end if
		end if		
				
		if _campo = 'comis_desc' then			

			FOR _contador = 1 TO 50

				LET _char_1		= _dato[1, 1];
				if _char_1 = '0' then
					LET _dato = _dato[2, 50];
				else				
					if _char_1 = '-' or _char_1 = '+' then
						let _signo = _char_1;
						LET _dato = _dato[2, 50];
					elif _char_1 = ' ' then
						LET _dato = _dato[2, 50];
					else
						exit for;
					end if
			   end if
			END FOR
			if _dato <> '' then
				let _monto_total = _signo || _dato;
			end if
		end if

		if _campo = 'monto_comis' then
			FOR _contador = 1 TO 50

				LET _char_1		= _dato[1, 1];
				if _char_1 = '0' then
					LET _dato = _dato[2, 50];
				else				
					if _char_1 = '-' or _char_1 = '+' then
						let _signo = _char_1;
						LET _dato = _dato[2, 50];
					elif _char_1 = ' ' then
						LET _dato = _dato[2, 50];
					else
						exit for;
					end if					
				end if
			END FOR
			if _dato <> '' then
				let _monto_comis = _signo || _dato;
			end if
		end if

		if _campo = 'comis_cobro' then
			FOR _contador = 1 TO 50

				LET _char_1		= _dato[1, 1];
				if _char_1 = '0' then
					LET _dato = _dato[2, 50];
				else				
					if _char_1 = '-' or _char_1 = '+' then
						let _signo = _char_1;
						LET _dato = _dato[2, 50];
					elif _char_1 = ' ' then
						LET _dato = _dato[2, 50];
					else
						exit for;
					end if
				end if
			END FOR

			if _dato <> '' then
				let _monto_comis_cobro = _signo || _dato;
			end if

		end if

		if _campo = 'comis_visa' then
			FOR _contador = 1 TO 50

				LET _char_1		= _dato[1, 1];
				if _char_1 = '0' then
					LET _dato = _dato[2, 50];
				else				
					if _char_1 = '-' or _char_1 = '+' then
						let _signo = _char_1;
						LET _dato = _dato[2, 50];
					elif _char_1 = ' ' then
						LET _dato = _dato[2, 50];
					else
						exit for;
					end if					
				end if
			END FOR
			if _dato <> '' then
				let _monto_comis_visa = _signo || _dato;
			end if

		end if

		if _campo = 'comis_clave' then
		   FOR _contador = 1 TO 50

				LET _char_1		= _dato[1, 1];
				if _char_1 = '0' then
					LET _dato = _dato[2, 50];
				else				
					if _char_1 = '-' or _char_1 = '+' then
						let _signo = _char_1;
						LET _dato = _dato[2, 50];
					elif _char_1 = ' ' then
						LET _dato = _dato[2, 50];
					else
						exit for;
					end if					
				end if
			END FOR
			if _dato <> '' then
				let _monto_comis_clave = _signo || _dato;
			end if

		end if

		if _campo = 'monto_bruto' then
			FOR _contador = 1 TO 50

				LET _char_1		= _dato[1, 1];
				if _char_1 = '0' then
					LET _dato = _dato[2, 50];
				else				
					if _char_1 = '-' or _char_1 = '+' then
						let _signo = _char_1;
						LET _dato = _dato[2, 50];
					elif _char_1 = ' ' then
						LET _dato = _dato[2, 50];
					else
						exit for;
					end if					
				end if
			END FOR
			if _dato <> '' then
				let _monto_bruto = _signo || _dato;
			end if

		end if

		if _campo = 'neto_pagado' then
			FOR _contador = 1 TO 50

				LET _char_1		= _dato[1, 1];
				if _char_1 = '0' then
					LET _dato = _dato[2, 50];
				else				
					if _char_1 = '-' or _char_1 = '+' then
						let _signo = _char_1;
						LET _dato = _dato[2, 50];
					elif _char_1 = ' ' then
						LET _dato = _dato[2, 50];
					else
						exit for;
					end if					
				end if
			END FOR
			if _dato <> '' then
				let _neto_pagado = _signo || _dato;
			end if

		end if

		if _campo = 'porc_comis' then
			FOR _contador = 1 TO 50

				LET _char_1		= _dato[1, 1];
				if _char_1 = '0' then
					LET _dato = _dato[2, 50];
				else				
					if _char_1 = '-' or _char_1 = '+' then
						let _signo = _char_1;
						LET _dato = _dato[2, 50];
					elif _char_1 = ' ' then
						LET _dato = _dato[2, 50];
					else
						exit for;
					end if					
				end if
			END FOR
			if _dato <> '' then
				let _porc_comis = _signo || _dato;
			end if

		end if


	end foreach

  	  
	else  ---------------------------***** En caso que la separacion sea por Tipo de Caracter o por tabulacion (Archivo Detalle)*****---------------------------
		if _separador_archivo = 3 then
			CALL sp_sis115(a_datos, _tipo_separador);
		else
			let _tipo_separador = '\t';
			CALL sp_sis115(a_datos, _tipo_separador);
		end if
		
		foreach
			select dato,
				   inicio
			  into _dato,
				   _inicio
		  	  from tmp_datos

			Select campo
			  into _campo
			  from cobforpaexd1
			 where cod_corredor = _cod_corredor
			   and desde = _inicio;

			let _signo = '';

			if _campo = 'secuencia' then
				let _secuencia = _dato;
			end if
			
			if _campo = 'no_remesa' then
				let _no_remesa = _dato;
			end if

			if _campo = 'no_documento' then
				let _no_documento = _dato;
			end if

			if _campo = 'no_recibo' then
				let _no_recibo = _dato;
			end if

			if _campo = 'cliente' then
				let _cliente = _dato;
			end if

			if _campo = 'fecha_pago' then
				let _fecha_pago = _dato;
			end if

			if _campo = 'comis_desc' then			

				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if
				   end if
				END FOR
				if _dato <> '' then
							let _monto_total = _signo || _dato;
				end if
			end if

			if _campo = 'monto_comis' then
				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				END FOR
				if _dato <> '' then
					let _monto_comis = _signo || _dato;
				end if
			end if

			if _campo = 'monto_cobrado' then
				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				END FOR
				if _dato <> '' then
					let _monto_cobrado = _signo || _dato;
				end if
			end if

			if _campo = 'comis_cobro' then
				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if
					end if
				END FOR

				if _dato <> '' then
					let _monto_comis_cobro = _signo || _dato;
				end if

			end if

			if _campo = 'comis_visa' then
				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				END FOR
				if _dato <> '' then
					let _monto_comis_visa = _signo || _dato;
				end if

			end if

			if _campo = 'comis_clave' then
			   FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				END FOR
				if _dato <> '' then
					let _monto_comis_clave = _signo || _dato;
				end if

			end if

			if _campo = 'monto_bruto' then
				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				END FOR
				if _dato <> '' then
					let _monto_bruto = _signo || _dato;
				end if

			end if

			if _campo = 'neto_pagado' then
				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				END FOR
				if _dato <> '' then
					let _neto_pagado = _signo || _dato;
				end if

			end if

			if _campo = 'porc_comis' then
				FOR _contador = 1 TO 50

					LET _char_1		= _dato[1, 1];
					if _char_1 = '0' then
						LET _dato = _dato[2, 50];
					else				
						if _char_1 = '-' or _char_1 = '+' then
							let _signo = _char_1;
							LET _dato = _dato[2, 50];
						elif _char_1 = ' ' then
							LET _dato = _dato[2, 50];
						else
							exit for;
						end if					
					end if
				END FOR
				if _dato <> '' then
					let _porc_comis = _signo || _dato;
				end if
			end if
		end foreach				
	end if
end if

RETURN _no_remesa,			  
	   _no_cheque,        	  
	   _fecha_remesa,		  
	   _fecha_desde,		  
	   _fecha_hasta,		  
	   _monto_total,		  
	   _monto_comis,		  
	   _monto_comis_cobro,	  
	   _monto_comis_visa,	  
	   _monto_comis_clave,	  
	   _monto_bruto,		  
	   _no_documento,		  
	   _secuencia,			  
	   _porc_comis,			  
	   _neto_pagado,		  
	   _comis_desc,			  
	   _no_recibo,			  
	   _cliente,			  
	   _fecha_pago,			  
	   _monto_cobrado;		  	
END PROCEDURE
