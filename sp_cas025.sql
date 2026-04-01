-- Incluye un pago al Rutero por fuera del Call Center

-- Creado    : 08/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/05/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - w_m_detalle_detalle - DEIVID, S.A.

drop procedure sp_cas025;	  

create procedure sp_cas025(
a_cod_cliente	char(10),
a_dia			smallint
) returning char(100);

define _code_pais		    char(3);
define _code_provincia	    char(2);
define _code_ciudad  	    char(2);
define _code_distrito	    char(2);
define _code_correg  	    char(5);
define _contacto			CHAR(50);
define _cod_cobrador_cl		char(3);
define _cod_pagador		    char(10);
define _cod_motiv   		char(3);
define _code_agente  	    char(5);

define v_por_vencer			dec(16,2);
define v_apagar				dec(16,2);
define v_saldo 				dec(16,2);
define v_exigible 			dec(16,2);
define v_corriente 			dec(16,2);
define v_monto_30 			dec(16,2);
define v_monto_60 			dec(16,2);
define v_monto_90 			dec(16,2);

define _fecha_hora		    datetime year to fraction(5);

define v_documento    		char(20);
define v_doc    			char(20);

define _fecha_hoy			date;
define _periodo			    char(7);
define _mes_char            CHAR(2);
define _ano_char		    CHAR(4);

let _fecha_hoy   = today;

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF

LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;

let _fecha_hora  = current;

delete from cobcapen
 where cod_cliente = a_cod_cliente;

select code_pais,
	   code_provincia,
	   code_ciudad,
	   code_distrito,
	   code_correg,
	   contacto
  into _code_pais,
	   _code_provincia,
	   _code_ciudad,
	   _code_distrito,
	   _code_correg,
	   _contacto
  from cliclien
 where cod_cliente = a_cod_cliente;

select cod_cobrador
  into _cod_cobrador_cl
  from gencorr
 where code_pais      =	_code_pais
   and code_provincia =	_code_provincia
   and code_ciudad	  =	_code_ciudad
   and code_distrito  =	_code_distrito
   and code_correg	  =	_code_correg;

if _cod_cobrador_cl is null then
	return "Cobrador de Calle Null ...";
end if

if _contacto is null then
	let _contacto = "";
end if

select cod_pagador
  into _cod_pagador
  from cobruter1
 where cod_pagador = a_cod_cliente;

let _cod_motiv   = null;
let _code_agente = null;

if _cod_pagador is null then --crear el pagador

	INSERT INTO cobruter1(
	cod_cobrador,   	
	cod_motiv,
	a_pagar,      
	saldo,       
	por_vencer,  
	exigible,    
	corriente,   
	monto_30,    
	monto_60,    
	monto_90,
	dia_cobros1,	
	dia_cobros2,
	fecha,
	cod_agente,
	cod_pagador,
	code_pais,     
	code_provincia,
	code_ciudad,	 
	code_distrito,
	code_correg,
	descripcion
	)
	VALUES(
	_cod_cobrador_cl,
	_cod_motiv,    
	0.00,
	0.00,     
	0.00,
	0.00,  
	0.00,	
	0.00,	
	0.00,	
	0.00,	
    a_dia,
	a_dia,
	_fecha_hora,
	_code_agente,
	a_cod_cliente,
	_code_pais,
	_code_provincia,
	_code_ciudad,
	_code_distrito,
	_code_correg,
	_contacto
    );

else

    update cobruter1
       set cod_cobrador   = _cod_cobrador_cl,
		   cod_motiv	  = _cod_motiv,    
		   a_pagar        = 0.00,
		   saldo       	  = 0.00,     
		   por_vencer	  = 0.00,
		   exigible		  = 0.00,  
		   corriente	  = 0.00,	
		   monto_30		  = 0.00,	
		   monto_60		  = 0.00,	
		   monto_90		  = 0.00,	
		   dia_cobros1	  = a_dia,
		   dia_cobros2	  = a_dia,
		   fecha		  = _fecha_hora,
		   cod_agente	  = _code_agente,
		   cod_pagador	  = a_cod_cliente,
		   code_pais	  = _code_pais,
		   code_provincia = _code_provincia,
		   code_ciudad	  = _code_ciudad,
		   code_distrito  = _code_distrito,
		   code_correg	  = _code_correg,
		   descripcion    = _contacto
     where cod_pagador    = a_cod_cliente;

end if

foreach
 select	no_documento
   into	v_documento
   from	caspoliza
  where	cod_cliente  = a_cod_cliente

	CALL sp_cob33(
	'*',
	'*',
	v_documento,
	_periodo,
	_fecha_hoy
	) RETURNING v_por_vencer,
			    v_exigible,  
			    v_corriente, 
			    v_monto_30,  
			    v_monto_60,  
			    v_monto_90,
			    v_saldo
			    ;

	 let v_apagar = v_exigible;
	 let v_doc    = null;

--	 if v_apagar  <= 0.00 then
--	 	continue foreach;
--	 end if

	 select	no_documento
	   into	v_doc
	   from	cobruter2
	  where	no_documento = v_documento;

	 if v_doc is null then	--crear la poliza en cobruter2

		LET _fecha_hora = _fecha_hora + 1 UNITS SECOND;

		INSERT INTO cobruter2(
		no_documento,
		cod_cobrador,   	
		cod_motiv,
		a_pagar,      
		saldo,       
		por_vencer,  
		exigible,    
		corriente,   
		monto_30,    
		monto_60,    
		monto_90,
		dia_cobros1,	
		dia_cobros2,
		fecha,
		cod_agente,
		cod_pagador,
		code_pais,     
		code_provincia,
		code_ciudad,	 
		code_distrito,
		code_correg
		)
		VALUES(
		v_documento,
		_cod_cobrador_cl,
		_cod_motiv,    
		v_apagar,
		v_saldo,     
		v_por_vencer,
		v_exigible,  
		v_corriente,	
		v_monto_30,	
		v_monto_60,	
		v_monto_90,	
	    a_dia,
		a_dia,
		_fecha_hora,
		_code_agente,
		a_cod_cliente,
		_code_pais,
		_code_provincia,
		_code_ciudad,
		_code_distrito,
		_code_correg
	    );

	 else

	    update cobruter2
	       set cod_cobrador = _cod_cobrador_cl,
			   cod_motiv	=  _cod_motiv,    
			   a_pagar      =  v_exigible,
			   saldo       	=  v_saldo,     
			   por_vencer	=  v_por_vencer,
			   exigible		=  v_exigible,  
			   corriente	=  v_corriente,	
			   monto_30		=  v_monto_30,	
			   monto_60		=  v_monto_60,	
			   monto_90		=  v_monto_90,	
			   dia_cobros1	=  a_dia,
			   dia_cobros2	=  a_dia,
			   fecha		=  _fecha_hora,
			   cod_agente	=  _code_agente,
			   cod_pagador	=  a_cod_cliente,
			   code_pais	  = _code_pais,
			   code_provincia = _code_provincia,
			   code_ciudad	  = _code_ciudad,
			   code_distrito  =_code_distrito,
			   code_correg	  = _code_correg
	     where no_documento   = v_documento;

	 end if

end foreach

select sum(a_pagar),      
	   sum(saldo),       
	   sum(por_vencer),  
	   sum(exigible),    
	   sum(corriente),   
	   sum(monto_30),    
	   sum(monto_60),    
	   sum(monto_90)
  into v_apagar,
	   v_saldo,     
	   v_por_vencer,
	   v_exigible,  
	   v_corriente,	
	   v_monto_30,	
	   v_monto_60,	
	   v_monto_90
  from cobruter2
 where cod_pagador = a_cod_cliente;

update cobruter1
   set a_pagar      =  v_exigible,
	   saldo       	=  v_saldo,     
	   por_vencer	=  v_por_vencer,
	   exigible		=  v_exigible,  
	   corriente	=  v_corriente,	
	   monto_30		=  v_monto_30,	
	   monto_60		=  v_monto_60,	
	   monto_90		=  v_monto_90
 where cod_pagador  = a_cod_cliente;


return "Proceso Satisfactorio ...";

end procedure