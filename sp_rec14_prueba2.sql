DROP PROCEDURE sp_rec14_prueba2;
create procedure sp_rec14_prueba2(
a_compania	char(3),
a_agencia	char(3),
a_periodo1	char(7),
a_periodo2	char(7),
a_origen	char(3) default "%"
, a_poliza char(20) default "*" )
returning smallint;

define v_filtros		char(255);
define _doc_poliza		char(20); 
define _no_poliza		char(10); 
define _cod_cliente		char(10); 
define _cod_agente		char(5);
define _cod_grupo		char(5);  
define _cod_subramo		char(3);  
define _cod_sucursal	char(3);  
define _cod_coasegur	char(3);  
define _cod_tipoprod	char(3);
define _cod_origen		char(3);
define _cod_ramo		char(3);  
define _porc_comis_agt	dec(5,2);
define _salv_y_recup	dec(16,2);
define _var_reserva		dec(16,2);
define _pago_y_ded		dec(16,2);
define _porcentaje		dec(16,4);
define _periodot2       char(7);
define _contador		integer;
define _count,_cant_ano,i,_ano	integer;
DEFINE  _cnt INT;
define _periodo1	char(7);
define _periodo2	char(7);
define _periodot	char(7);
define _periodo1r	char(7);
define _periodo2r	char(7);
define _no_remesa    char(10);     
define _prima_pagada dec(16,2);
DEFINE _incurrido_bruto  DECIMAL(16,2);
DEFINE _siniestro_pagado DECIMAL(16,2);
DEFINE _prima_suscrita   DECIMAL(16,2);
define _tipo				char(1);
DEFINE _vigencia_inic    DATE;
DEFINE _vigencia_final    DATE;

set isolation to dirty read;
drop table if exists tmp_codigos;
DROP TABLE if exists  tmp_montos;
DROP TABLE if exists  tmp_vigencia;
DROP TABLE if exists  tmp_siniest;

select par_ase_lider
  into _cod_coasegur
  from parparam
 where cod_compania = a_compania;
   
-- Tabla Temporal
create temp table tmp_siniest(
no_poliza           char(10)  not null,
periodo1       	    char(7),
periodo2       	    char(7),
doc_poliza			char(20)  not null,
cod_ramo            char(3)   not null,
cod_subramo         char(3)   not null,
cod_grupo           char(5)   not null,
prima_suscrita      dec(16,2) not null,
comis_suscrita      dec(16,2) not null,
incurrido_bruto     dec(16,2) not null,
siniestro_pagado    dec(16,2) not null,
prima_pagada		dec(16,2) not null,
comis_pagada        dec(16,2) not null,
fronting            smallint  default 0 not null,
cod_contrato       	char(5),
seleccionado        smallint  default 1 not null,
cod_agente       	char(5),
cod_sucursal        char(3)   not null,
cod_cliente			char(10),
cod_tipoprod		char(3),
salv_y_recup		dec(16,2) default 0 not null,
pago_y_ded			dec(16,2) default 0 not null,
var_reserva			dec(16,2) default 0 not null,
vigencia_inic       date,
vigencia_final      date) with no log;

create index xie01_tmp_siniest on tmp_siniest(no_poliza,periodo1);

create temp table tmp_montos(
no_poliza           char(10)  not null,
periodo1       	    char(7),
periodo2       	    char(7),
prima_suscrita      dec(16,2) default 0 not null,
incurrido_bruto     dec(16,2) default 0 not null,
siniestro_pagado    dec(16,2) default 0 not null,
prima_pagada		dec(16,2) default 0 not null,
pago_y_ded    		dec(16,2) default 0 not null,
salv_y_recup		dec(16,2) default 0 not null,
var_reserva         dec(16,2) default 0 not null,
vigencia_inic       date,
vigencia_final      date) with no log;
create index xie01_tmp_montos on tmp_montos(no_poliza,periodo1);


create temp table tmp_vigencia(
periodo1 char(7),
periodo2 char(7)) with no log;

--SET DEBUG FILE TO "sp_rec14.trc";
--TRACE ON;

begin

let v_filtros = '';
let _cant_ano = a_periodo2[1,4] - a_periodo1[1,4];

let _no_poliza = sp_sis21(a_poliza);

{for i = 1 to _cant_ano + 1
    let _periodot2 = a_periodo1[1,4]||'-'||'12';
	insert into tmp_vigencia(periodo1,periodo2)
	values(a_periodo1,_periodot2);
	let _ano = a_periodo1[1,4];
	let _ano = _ano + 1;
	let a_periodo1 = _ano || '-' || '01';
end for}


 call sp_rec14_vig_real(_no_poliza,a_periodo1,a_periodo2) returning _periodo1r,_periodo2r;	 		  


select count(*) 
  into _cnt 
  from tmp_vigencia2; 

if _cnt = 0 then		
	return 1;
end if	

let _vigencia_inic = '01/01/1900';
let _vigencia_final = '01/01/1900';
foreach 
	select periodo1,
	       periodo2,
		   vigencia_inic,
		   vigencia_final
	  into _periodo1,
	       _periodo2,
		   _vigencia_inic,
		   _vigencia_final
	  from tmp_vigencia2
	  where seleccionado = 1

	foreach 
		select periodo, 
		       prima_suscrita,		
			   no_poliza
		  into _periodot, 
		       _prima_suscrita,
			   _no_poliza
		  from endedmae
		 where cod_compania = a_compania
		   and actualizado  = 1
		   and periodo     >= _periodo1 
		   and periodo     <= _periodo2		   
		   
		insert into tmp_montos(
				no_poliza,
				prima_suscrita,
				periodo1,
				periodo2,
				vigencia_inic,
				vigencia_final)
		values(	_no_poliza,
				_prima_suscrita,
				_periodo1,
				_periodo2,
				_vigencia_inic,
				_vigencia_final);		
	end foreach
	
	foreach
		select no_poliza,
			   prima_neta,
			   periodo
		  into _no_poliza,
			   _prima_pagada,
			   _periodot
		  from cobredet
		 where cod_compania = a_compania
		   and actualizado  = 1
		   and tipo_mov in ('P', 'N')
		   and periodo     >= _periodo1
		   and periodo     <= _periodo2
		   and renglon     <> 0


		SELECT porc_partic_coas
		  INTO _porcentaje
		  FROM emicoama
		 WHERE no_poliza    = _no_poliza
		   AND cod_coasegur = _cod_coasegur;
		   
		IF _porcentaje IS NULL THEN
			LET _porcentaje = 100;
		END IF	    

		LET _prima_pagada = _prima_pagada / 100 * _porcentaje;
		
		INSERT INTO tmp_montos(
		no_poliza,           
		prima_pagada,
		periodo1,
		periodo2,
		vigencia_inic,
		vigencia_final
		)
		VALUES(
		_no_poliza,
		_prima_pagada,
		_periodo1,
		_periodo2,
		_vigencia_inic,
		_vigencia_final	
		);

	END FOREACH
drop table if exists tmp_codigos;

-- Incurrido Bruto y Sinestro Pagado

	LET v_filtros = sp_rec01(a_compania, a_agencia, _periodo1, _periodo2); 
	FOREACH 
	 SELECT	incurrido_bruto,
			pagado_bruto,
			no_poliza,
			salv_y_recup,
			pago_y_ded,
			reserva_bruto,
			periodo
	   INTO	_incurrido_bruto,
			_siniestro_pagado,
			_no_poliza,
			_salv_y_recup,
			_pago_y_ded,
			_var_reserva,
			_periodot
	   FROM	tmp_sinis

		INSERT INTO tmp_montos(
		no_poliza,           
		incurrido_bruto,     
		siniestro_pagado,
		salv_y_recup,
		pago_y_ded,
		var_reserva,
		periodo1,
		periodo2,
		vigencia_inic,
		vigencia_final
		)
		VALUES(
		_no_poliza,
		_incurrido_bruto,     
		_siniestro_pagado,
		_salv_y_recup,
		_pago_y_ded,
		_var_reserva, 
		_periodo1, 
		_periodo2,
		_vigencia_inic,
		_vigencia_final	
		);

	END FOREACH
	drop table if exists tmp_sinis;
	drop table if exists tmp_incurrido;

end foreach

FOREACH 
 SELECT SUM(prima_suscrita),
        SUM(prima_pagada),		
		SUM(incurrido_bruto),
		SUM(siniestro_pagado),
		SUM(salv_y_recup),
		SUM(pago_y_ded),
		SUM(var_reserva),
		periodo1,
		periodo2,
 		no_poliza,
		vigencia_inic,
		vigencia_final
   INTO	_prima_suscrita,
		_prima_pagada,
		_incurrido_bruto,
		_siniestro_pagado,
		_salv_y_recup,
		_pago_y_ded,
		_var_reserva,
		_periodo1r,
		_periodo2r,
		_no_poliza,
		_vigencia_inic,
		_vigencia_final
   FROM tmp_montos
  GROUP BY no_poliza,periodo1,periodo2,vigencia_inic,vigencia_final
  	
	SELECT cod_ramo,
	       cod_subramo,
		   cod_grupo,
		   no_documento,
		   sucursal_origen,
		   cod_contratante,
		   cod_tipoprod,
		   cod_origen
	  INTO _cod_ramo,
	       _cod_subramo,
		   _cod_grupo,
		   _doc_poliza,
		   _cod_sucursal,
		   _cod_cliente,
		   _cod_tipoprod,
		   _cod_origen
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	LET	_cod_agente = NULL;
	LET _contador   = 0;
	LET _porc_comis_agt = 0;

	IF a_origen <> "%" THEN
		IF _cod_origen <> a_origen THEN
			CONTINUE FOREACH;
		END IF
	END IF
	
	FOREACH 
	 SELECT	cod_agente,
	        porc_comis_agt
	   INTO	_cod_agente,
			_porc_comis_agt
	   FROM	emipoagt
	  WHERE	no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

	IF _cod_agente IS NULL THEN
		LET _cod_agente = '';
	END IF

	IF _porc_comis_agt IS NULL THEN
		LET _porc_comis_agt = 0;
	END IF

	INSERT INTO tmp_siniest(
	no_poliza,           
	periodo1,
	periodo2,
	doc_poliza,
	cod_ramo,
	cod_subramo,
	cod_grupo,            
	prima_suscrita,    
	comis_suscrita,  
	incurrido_bruto,     
	siniestro_pagado,    
	prima_pagada,
	comis_pagada,
	cod_agente,
	cod_sucursal,
	cod_cliente,
    cod_tipoprod,
	salv_y_recup,
	pago_y_ded,
	var_reserva,
	vigencia_inic,
	vigencia_final
	)
	VALUES(
	_no_poliza,
	_periodo1r,
	_periodo2r,	
	_doc_poliza,           
	_cod_ramo,            
	_cod_subramo,
	_cod_grupo,            
	_prima_suscrita,      
	_prima_suscrita * _porc_comis_agt / 100, 
	_incurrido_bruto,     
	_siniestro_pagado,    
	_prima_pagada,      
	_prima_pagada * _porc_comis_agt / 100, 
	_cod_agente,
	_cod_sucursal,
	_cod_cliente,        
    _cod_tipoprod,
	_salv_y_recup,
	_pago_y_ded,
	_var_reserva,
	_vigencia_inic,
	_vigencia_final
	);
END FOREACH
return 0;
END 
drop table if exists tmp_codigos;
DROP TABLE if exists  tmp_montos;

END PROCEDURE 
                                                                                                                                                                                                                                                          
