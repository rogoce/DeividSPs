-- Procedure que determina los asientos actuales del nuevo contrato mapfre 50/50

-- Cuando se ejecuta en Deivid trae los actuales, cuando se ejecuta en deivid_tmp trae los cambiados

-- Creado    : 28/08/2015 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac243;

create procedure sp_sac243()
returning char(25),
          char(50),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(50),
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

define v_cuenta				char(25);	
define v_debito     		dec(16,2);
define v_credito    		dec(16,2);
define _diferencia  		dec(16,2);
define v_tipo_comp			smallint;

define _cantidad			smallint;
define _transaccion			char(10);

define _origen      		smallint;

define v_comprobante  		char(50);
define v_nombre_cuenta		char(50);
define _cta_auxiliar		char(1);
define _cod_auxiliar		char(5);
define _nom_auxiliar		char(50);

define _cod_ramo			char(3);

create temp table tmp_prod_auto(
origen			 	smallint,
tipo_comprobante	smallint,
periodo			 	char(7),
cuenta		   	 	char(25),
debito      	 	decimal(16,2),
credito		     	decimal(16,2)
);

create temp table tmp_prod_auto2(
origen			 	smallint,
tipo_comprobante 	smallint,
periodo			 	char(7),
cuenta		   	 	char(25),
cod_auxiliar	 	char(5),
debito      	 	decimal(16,2),
credito		     	decimal(16,2)
);

set isolation to dirty read;

let _periodo1 = "2015-07";
let _periodo2 = "2015-07";

-- Reclamos

--{
foreach 
 select no_tranrec,
		periodo,
		no_reclamo,
		transaccion
   into _no_tranrec,
		_periodo,
		_no_reclamo,
		_transaccion
   from rectrmae t
  where t.periodo		  >= _periodo1
    and t.periodo		  <= _periodo2
	and t.actualizado	  = 1

	select count(*)
	  into _cantidad
	  from tranpen
	 where transaccion = _transaccion;

	if _cantidad is null then
		let _cantidad = 0;
	end if
	
	if _cantidad <> 0 then
		continue foreach;
	end if
	
	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza; 

	if _cod_ramo not in ("002", "020", "023") then
		continue foreach;
	end if

	let _origen = 2;
	
	foreach
	 select debito,
			credito,
			cuenta,
			tipo_comp
	   into v_debito,
			v_credito,
			v_cuenta,
			v_tipo_comp
	   from recasien
	  where no_tranrec = _no_tranrec

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
	   from sac999:recasiau
	  where no_tranrec = _no_tranrec

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
	
	let _origen = 12;

	foreach
	 select no_registro
	   into _no_registro
	   from sac999:reacomp
	  where no_tranrec    = _no_tranrec
		and tipo_registro = 3		

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
			v_credito
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

	end foreach

end foreach
--}

foreach
 select periodo,
        origen,
        tipo_comprobante,
        cuenta, 
        sum(debito), 
        sum(credito)
   into _periodo,
        _origen,
        v_tipo_comp,
   		v_cuenta, 
        v_debito, 
        v_credito
   from tmp_prod_auto
  group by 1, 2, 3, 4
  order by 1, 2, 3, 4

	let _diferencia = v_debito - v_credito;

	select cta_nombre,
	       cta_auxiliar
	  into v_nombre_cuenta,
	       _cta_auxiliar
	  from cglcuentas
	 where cta_cuenta = v_cuenta;
		
	let v_comprobante = sp_sac11(_origen, v_tipo_comp); 

	return v_cuenta,			
		   v_nombre_cuenta,  
		   v_debito,         
		   v_credito,        
		   _diferencia,
		   null,
		   null,
		   v_comprobante,
		   _periodo
		   with resume;

	foreach
	 select cod_auxiliar,
	        sum(debito),
			sum(credito)
	   into	_cod_auxiliar,
	        v_debito,
			v_credito
	   from tmp_prod_auto2 
	  where	origen			 	= _origen
        and tipo_comprobante	= v_tipo_comp
        and periodo				= _periodo
        and cuenta		   	 	= v_cuenta
	  group by cod_auxiliar

		select ter_descripcion
		  into _nom_auxiliar
		  from cglterceros
		 where ter_codigo = _cod_auxiliar;

		return _cod_auxiliar,			
			   _nom_auxiliar,  
			   null,         
			   null,        
			   null,
			   v_debito,
			   v_credito,
			   v_comprobante,
			   _periodo
			   with resume;

	end foreach

end foreach

drop table tmp_prod_auto;
drop table tmp_prod_auto2;

end procedure 