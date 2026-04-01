-- Procedure que determina los asientos actuales del nuevo contrato mapfre 50/50

-- Cuando se ejecuta en Deivid trae los actuales, cuando se ejecuta en deivid_tmp trae los cambiados

-- Creado    : 28/08/2015 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac244;

create procedure sp_sac244()
returning char(20),
          char(10),
		  date,
		  date,
		  dec(16,2),
		  char(10),
		  dec(16,2),
		  char(7);

define _no_poliza			char(10);
define _no_reclamo			char(10);
define _no_tranrec			char(10);
define _no_remesa			char(10);
define _no_registro			char(10);
define _renglon				integer;
define _no_endoso			char(5);
define _periodo				char(7);
define _periodo1			char(7);
define _periodo2			char(7);

define _no_factura			char(10);
define _no_documento		char(20);
define _prima_suscrita		dec(16,2);
define _vigencia_inic		date;
define _vigencia_final		date;

define v_cuenta				char(25);	
define v_debito     		dec(16,2);
define v_credito    		dec(16,2);
define _diferencia  		dec(16,2);
define v_tipo_comp			smallint;

define _origen      		smallint;

define v_comprobante  		char(50);
define v_nombre_cuenta		char(50);
define _cta_auxiliar		char(1);
define _cod_auxiliar		char(5);
define _nom_auxiliar		char(50);

define _cod_ramo			char(3);


set isolation to dirty read;

let _periodo1 = "2015-08";
let _periodo2 = "2015-08";

-- Produccion

--{
foreach 
 select no_poliza, 
         no_endoso,
		 periodo,
		 no_factura,
		 prima_suscrita,
		 no_documento
   into _no_poliza,
        _no_endoso,
		_periodo,
		_no_factura,
		_prima_suscrita,
		_no_documento
   from endedmae
  where periodo		>= _periodo1
    and periodo		<= _periodo2
	and actualizado	= 1

	select cod_ramo,
	       vigencia_inic,
		   vigencia_final
	  into _cod_ramo,
	       _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza; 
	 
	 if _cod_ramo not in ("002", "020", "023") then
		continue foreach;
	end if

	let _origen = 1;

	{
   foreach
	select debito,
		   credito,
		   cuenta,
		   tipo_comp
	  into v_debito,
		   v_credito,
		   v_cuenta,
		   v_tipo_comp
	  from endasien
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso
	   
		insert into tmp_prod_auto(
		origen,
		tipo_comprobante,
		periodo,
		cuenta,   
		debito,	  
		credito
		)
		values(
		_origen,
		v_tipo_comp,
		_periodo,
		v_cuenta,  
		v_debito,
		v_credito * -1
		);

	end foreach

   foreach
	select debito,
		   credito,
		   cuenta,
		   tipo_comp,
		   cod_auxiliar
	  into v_debito,
		   v_credito,
		   v_cuenta,
		   v_tipo_comp,
		   _cod_auxiliar
	  from endasiau
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso

		insert into tmp_prod_auto2(
		origen,
		tipo_comprobante,
		periodo,
		cuenta,
		cod_auxiliar,   
		debito,	  
		credito
		)
		values(
		_origen,
		v_tipo_comp,
		_periodo,
		v_cuenta,
		_cod_auxiliar,  
		v_debito,
		v_credito * -1
		);
	   
	end foreach
	}
	
	-- Movimientos de Reaseguro
	
	let _origen = 12;
	let _diferencia = 0;

	foreach
	 select no_registro
	   into _no_registro
	   from sac999:reacomp
	  where no_poliza     	= _no_poliza
		and no_endoso     	= _no_endoso
		and tipo_registro 	= 1		
		
		foreach
		 select debito,
				credito,
				cuenta,
				tipo_comp
		   into v_debito,
				v_credito,
				v_cuenta,
				v_tipo_comp
		   from sac999:reacompasie
		  where no_registro = _no_registro
		    and cuenta[1,3] = "511"
			
			let _diferencia = _diferencia + v_debito - v_credito;
			
		end foreach

		{
		foreach
		 select debito,
				credito,
				cuenta,
				tipo_comp,
				cod_auxiliar
		   into v_debito,
				v_credito,
				v_cuenta,
				v_tipo_comp,
				_cod_auxiliar
		   from sac999:reacompasiau
		  where no_registro = _no_registro

			insert into tmp_prod_auto2(
			origen,
			tipo_comprobante,
			periodo,
			cuenta,
			cod_auxiliar,   
			debito,	  
			credito
			)
			values(
			_origen,
			v_tipo_comp,
			_periodo,
			v_cuenta,
			_cod_auxiliar,  
			v_debito,
			v_credito
			);

		end foreach
		}
	
	end foreach

	return _no_documento,
		   _no_factura,
		   _vigencia_inic,
		   _vigencia_final,
		   _prima_suscrita,
		   "511",
		   _diferencia,
		   _periodo
		   with resume;
	
end foreach

end procedure 