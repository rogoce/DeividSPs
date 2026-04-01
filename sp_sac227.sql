-- Reportes de los asientos por poliza
--
-- Creado el: 06/06/2013 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac227;

create procedure sp_sac227(a_no_documento char(20)) 
returning char(7), date, char(100), char(20), dec(16,2), dec(16,2), char(25), char(100), dec(16,2);

define _no_poliza		char(10);
define _no_endoso		char(5);

define _no_remesa		char(10);
define _no_requis		char(10);
define _renglon			smallint;

define _periodo			char(7);
define _fecha			date;
define _cuenta			char(25);
define _debito			dec(16,2);
define _credito			dec(16,2);
define _suma_dc			dec(16,2);
define _acumulado       dec(16,2);
define _nombre_cta		char(100);

define _documento		char(20);
define _tipo			char(100);
define _no_registro     char(10);
define _tipo_comp       smallint;

define _no_tranrec      char(10);
define _tipo_registro   smallint;

create temp table tmp_asientos (
periodo		char(7),
fecha		date,
tipo		char(100),
documento	char(20),
cuenta		char(25),
debito		dec(16,2),
credito		dec(16,2)
) with no log;

--set debug file to "sp_sac227.trc";
--trace on;

let _tipo = "Produccion - No Factura";

foreach
 select	no_poliza,
        no_endoso,
		no_factura
   into	_no_poliza,
        _no_endoso,
		_documento
   from endedmae
  where no_documento = a_no_documento
    and actualizado  = 1 

	foreach
	 select cuenta,
	        debito,
	        credito,
			periodo,
			fecha
	   into _cuenta,
	        _debito,
	        _credito,
			_periodo,
			_fecha
	   from endasien
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso

		insert into tmp_asientos
		values (_periodo, _fecha, _tipo, _documento, _cuenta, _debito, _credito);	    

	end foreach           	

end foreach

let _tipo = "Cobros - No Recibo";

foreach
 select	no_remesa,
        renglon,
		no_recibo
   into	_no_remesa,
        _renglon,
		_documento
   from cobredet
  where doc_remesa  = a_no_documento
    and actualizado = 1 

	foreach
	 select cuenta,
	        debito,
	        credito,
			periodo,
			fecha
	   into _cuenta,
	        _debito,
	        _credito,
			_periodo,
			_fecha
	   from cobasien
	  where no_remesa = _no_remesa
	    and renglon   = _renglon

		insert into tmp_asientos
		values (_periodo, _fecha, _tipo, _documento, _cuenta, _debito, _credito * -1);	    

	end foreach           	

end foreach

-- Cheques

let _tipo = "Devolucion de Prima";

foreach
 select	p.no_requis,
        p.no_poliza,
		c.no_cheque
   into	_no_requis,
        _no_poliza,
		_documento
   from chqchpol p, chqchmae c
  where c.no_requis    = p.no_requis
    and p.no_documento = a_no_documento
    and c.pagado       = 1 

	foreach
	 select cuenta,
	        debito,
	        credito,
			periodo,
			fecha
	   into _cuenta,
	        _debito,
	        _credito,
			_periodo,
			_fecha
	   from chqchcta
	  where no_requis = _no_requis
	    and no_poliza = _no_poliza

		insert into tmp_asientos
		values (_periodo, _fecha, _tipo, _documento, _cuenta, _debito, _credito * -1);	    

	end foreach           	

end foreach

-- reaseguro

	foreach
		select no_registro,
			   tipo_registro,
			   no_poliza,
			   no_endoso,
			   no_remesa,
			   no_tranrec
		  into _no_registro,
			   _tipo_registro,
			   _no_poliza,
			   _no_endoso,
			   _no_remesa,
			   _no_tranrec
          from sac999:reacomp 
		 where no_documento = a_no_documento
			foreach
			 select cuenta,
					tipo_comp,
					periodo,
					fecha,
					debito,
					credito
			   into _cuenta,
					_tipo_comp,
					_periodo,
					_fecha,
					_debito,
					_credito
			   from sac999:reacompasie
			  where no_registro = _no_registro
			  
					--- Producción
					if _tipo_registro = 1 then
						let _tipo = "Reaseguro - No Factura";
							select no_factura
							  into _documento
							  from endedmae
							 where no_poliza = _no_poliza
							   and no_endoso = _no_endoso
							   and actualizado  = 1;
							   
					--- Cobros
					elif _tipo_registro = 2 then
						let _tipo = "Reaseguro - No Recibo";
							foreach
							 select no_recibo
							   into _documento
							   from cobredet
							  where no_poliza  = _no_poliza
								and no_remesa =  _no_remesa
							 exit foreach;
							end foreach
							
					--- Transacción
					elif _tipo_registro = 3 then
						 let _tipo = "Reaseguro - No Transaccion";
						     select transaccion
							   into _documento
							   from rectrmae
							  where no_tranrec = _no_tranrec;
						
					--- Cheques Pagados --- Cheques Anulados
					elif _tipo_registro = 4 or _tipo_registro = 5 then
						 let _tipo = "Reaseguro - No Requisicion";
						 select no_requis 
						   into _documento
						   from chqchmae
					      where no_requis = _no_remesa; --- _no_remesa cuando es tipo registro 4,5 es no_requis
					end if
					
				insert into tmp_asientos
				values (_periodo, _fecha, _tipo, _documento, _cuenta, _debito, _credito * -1);

            end foreach			 
	end foreach
	
-- nuevo chqcomis chqchcta
let _tipo = "Comis";
	foreach
	
		select no_poliza, 
			   no_requis
	      into _no_poliza,
		       _documento
	      from chqcomis
         where no_documento = a_no_documento
			foreach
			
			   select cuenta, 
					  debito,
					  credito,
					  fecha,
					  periodo
			    into _cuenta,
					 _debito,
					 _credito,
					 _fecha,
					 _periodo
				 from chqchcta
				where no_requis = _documento
				  and no_poliza = _no_poliza 
				  
				insert into tmp_asientos
				values (_periodo, _fecha, _tipo, _documento, _cuenta, _debito, _credito * -1);	
			end foreach
	end foreach	  
		  
		  
		  

	foreach
		select distinct cuenta 
		  into _cuenta
		  from tmp_asientos

	let _acumulado = 0.00;

		foreach

		 select periodo, 
				fecha,
				tipo,
				documento, 
				cuenta, 
				debito, 
				credito
		   into _periodo, 
				_fecha,
				_tipo,
				_documento, 
				_cuenta, 
				_debito, 
				_credito
		   from tmp_asientos
		   where cuenta = _cuenta
		   order by 5,1,2,3
		  --order by cuenta, 1, 2, 3
			
			let _suma_dc = _debito + _credito;
			let _acumulado = _suma_dc + _acumulado;
			
			select cta_nombre
			  into _nombre_cta
			  from cglcuentas
			 where cta_cuenta = _cuenta;

			return _periodo, 
				   _fecha,
				   _tipo,
				   _documento, 
				   _debito, 
				   _credito,
				   _cuenta,
				   _nombre_cta,
				   _acumulado
				with resume;

		end foreach
	end foreach
drop table tmp_asientos;

end procedure