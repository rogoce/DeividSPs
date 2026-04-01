-- Informacion para Credit Search

drop procedure sp_pro119;

create procedure sp_pro119()
returning smallint,
          smallint,
          smallint,
		  smallint,
		  char(20),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  smallint,
		  smallint,
		  char(10),
		  char(10);
          
define _periodo       	smallint;
define _no_poliza     	char(10);
define _no_poliza_nue  	char(10);
define _cod_cliente   	char(10);
define _cedula        	char(30);
define _con_cedula    	smallint;
define _sin_cedula    	smallint;
define _no_documento  	char(20);
define _no_poliza_act 	char(10);
define _estatus_poliza	smallint;
define _cant_aun_canc	smallint;
define _saldo_ant		dec(16,2);
define _saldo_des		dec(16,2);
define _saldo_act		dec(16,2);
define _prima_bruta		dec(16,2);
define _cant_rehab		smallint;
define _cant_emi_nueva	smallint;

define _fecha_emision	date;

define _periodo_hoy		char(7);
define _fecha			date;
define _ano_contable	smallint;
define _mes_contable	smallint;

DEFINE v_por_vencer       DEC(16,2);
DEFINE v_exigible         DEC(16,2);
DEFINE v_corriente        DEC(16,2);
DEFINE v_monto_30         DEC(16,2);
DEFINE v_monto_60         DEC(16,2);
DEFINE v_monto_90         DEC(16,2);

define _cod_endomov		  char(3);
define _no_factura		  char(10);
define _no_motor_ant	char(30);
define _no_motor_nue	char(30);

let _fecha = today;

let _ano_contable = year(_fecha);

if month(_fecha) < 10 then
	let _mes_contable = '0' || month(_fecha);
else
	let _mes_contable = month(_fecha);
end if

let _periodo_hoy = _ano_contable || '-' || _mes_contable;

foreach
 select e.periodo[1,4], 
		e.no_poliza,
		e.fecha_emision,
		e.prima_bruta,
		e.no_factura
   into _periodo,
        _no_poliza,
		_fecha_emision,
		_prima_bruta,
		_no_factura
   from endedmae e, emipomae p
  where e.actualizado = 1
    and e.cod_tipocan = "001"
    and e.no_poliza   = p.no_poliza
    and p.cod_ramo    = "002"
  order by 1

	
	let _cant_rehab = 0;

	foreach
	 select	cod_endomov
	   into _cod_endomov
	   from endedmae
	  where no_poliza      = _no_poliza
	    and fecha_emision >= _fecha_emision
		and actualizado    = 1
		and cod_endomov    = "003"
		and no_factura     > _no_factura

		let _cant_rehab = 1;

	end foreach

	select cod_contratante,
	       no_documento
	  into _cod_cliente,
	       _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	let _saldo_ant = sp_pro120("001", "001", _no_documento, _fecha_emision);
	let _saldo_ant = _saldo_ant - _prima_bruta;
	let _saldo_des = _saldo_ant + _prima_bruta;

	call sp_par78c("001", 
	               "001", 
	               _no_documento, 
	               _periodo_hoy, 
	               _fecha_emision
	               ) returning v_por_vencer,       
    				 		   v_exigible,         
    				           v_corriente,        
    				           v_monto_30,         
    				           v_monto_60,         
    				           v_monto_90,
    				           _saldo_act;    


	let _no_poliza_act = sp_sis21(_no_documento);

	select estatus_poliza
	  into _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza_act;
	
	if _estatus_poliza = 2 then
		let _cant_aun_canc = 1;
	else
		let _cant_aun_canc = 0;
	end if  

	select cedula
	  into _cedula
	  from cliclien
	 where cod_cliente = _cod_cliente;

   let _con_cedula = 0;
   let _sin_cedula = 0;

	if _cedula is null or
	   _cedula = ""    then
	   let _sin_cedula = 1;
	else
	   let _con_cedula = 1;
	end if		

	let _cant_emi_nueva = 0;

   foreach	
	select no_poliza
	  into _no_poliza_nue
	  from emipomae
	 where cod_contratante = _cod_cliente
	   and no_documento    <> _no_documento
	   and cod_ramo        = "002"
	   and actualizado     = 1

		foreach
		 select no_motor
		   into _no_motor_ant
		   from emiauto
		  where no_poliza = _no_poliza

			foreach
			 select no_motor
			   into _no_motor_nue
			   from emiauto
			  where no_poliza = _no_poliza_nue

				if _no_motor_ant = _no_motor_nue then
					let _cant_emi_nueva = 1;
					exit foreach;
				end if					

			end foreach
			
			if 	_cant_emi_nueva = 1 then
				exit foreach;
			end if			

		end foreach

		if 	_cant_emi_nueva = 1 then
			exit foreach;
		end if			

	end foreach

	return _periodo,
	       _con_cedula,
		   _sin_cedula,
		   _cant_aun_canc,
		   _no_documento,
		   _saldo_ant,
		   _saldo_des,
		   _saldo_act,
		   _cant_rehab,
		   _cant_emi_nueva,
		   _no_poliza,
		   _cod_cliente
		   with resume;

end foreach

end procedure
