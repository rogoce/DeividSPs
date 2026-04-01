-- Procedimiento que Carga la Siniestralidad Por Poliza en un Periodo 
-- 
-- Creado    : 25/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 12/09/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 06/08/2002 - Autor: Amado Perez Mendoza -- Se agrega la comision de corredor
--                                                        para la prima suscrita y la prima pagada
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec14_uni;
create procedure sp_rec14_uni(a_compania	char(3),a_agencia	char(3),a_periodo1	char(7),a_periodo2	char(7),a_origen	char(3) default "%")
--returning smallint;


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
define _contador		integer;
define _count			integer;
define _nom_sucursal	char(50);
define _suc_prom        char(3);
define _cod_vendedor	char(3);
define _nombre_vendedor	char(50);
define _cnt_incurrido   integer;
define _no_reclamo      char(10);


set isolation to dirty read;

select par_ase_lider
  into _cod_coasegur
  from parparam
 where cod_compania = a_compania;
   
-- Tabla Temporal
create temp table tmp_siniest_uni(
no_poliza           char(10)  not null,
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
cod_vendedor	    CHAR(3),                    -- cod_vendedor
nombre_vendedor     CHAR(50),                    -- nombre_vendedor
cnt_incurrido       int,                          -- casos de incurridos Amado 28-05-2021
no_reclamo          CHAR(10)
) with no log;

create index xie01_tmp_siniest_uni on tmp_siniest_uni(no_poliza,no_reclamo);

create temp table tmp_montos_uni(
no_poliza           char(10)  not null,
prima_suscrita      dec(16,2) default 0 not null,
incurrido_bruto     dec(16,2) default 0 not null,
siniestro_pagado    dec(16,2) default 0 not null,
prima_pagada		dec(16,2) default 0 not null,
pago_y_ded    		dec(16,2) default 0 not null,
salv_y_recup		dec(16,2) default 0 not null,
var_reserva         dec(16,2) default 0 not null,
cnt_incurrido       int       default 0,
no_reclamo          CHAR(10)) with no log;
create index xie01_tmp_montos_uni on tmp_montos_uni(no_poliza);



-- Primas Suscritas
-- Nombre de la Compania
{begin

define _prima_suscrita decimal(16,2);

foreach 
	select prima_suscrita,		
		   no_poliza
	  into _prima_suscrita,
		   _no_poliza
	  from endedmae
	 where cod_compania = a_compania
	   and actualizado  = 1
	   and periodo     >= a_periodo1 
	   and periodo     <= a_periodo2

	insert into tmp_montos(
			no_poliza,
			prima_suscrita)
	values(	_no_poliza,
			_prima_suscrita);
end foreach
end
}
-- Primas Pagadas

{begin

define _no_remesa    char(10);     
define _prima_pagada dec(16,2);

foreach
	select no_poliza,
		   prima_neta
	  into _no_poliza,
		   _prima_pagada
	  from cobredet
	 where cod_compania = a_compania
	   and actualizado  = 1
	   and tipo_mov in ('P', 'N')
	   and periodo     >= a_periodo1
	   and periodo     <= a_periodo2
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
	prima_pagada
	)
	VALUES(
	_no_poliza,
	_prima_pagada
	);

END FOREACH

END
}
-- Incurrido Bruto y Sinestro Pagado

BEGIN
DEFINE _incurrido_bruto  DECIMAL(16,2);
DEFINE _siniestro_pagado DECIMAL(16,2);

LET v_filtros = sp_rec01(a_compania, a_agencia, a_periodo1, a_periodo2); 

FOREACH 
 SELECT	incurrido_bruto,
        pagado_bruto,
		no_poliza,
		salv_y_recup,
		pago_y_ded,
		reserva_bruto,
		no_reclamo
   INTO	_incurrido_bruto,
        _siniestro_pagado,
		_no_poliza,
		_salv_y_recup,
		_pago_y_ded,
		_var_reserva,
		_no_reclamo
   FROM	tmp_sinis
   
    LET _cnt_incurrido = 0;
   
	IF _incurrido_bruto <> 0 THEN -- casos de incurridos Amado 28-05-2021
		LET _cnt_incurrido = 1;
	END IF   

	INSERT INTO tmp_montos_uni(
	no_poliza,           
	incurrido_bruto,     
	siniestro_pagado,
	salv_y_recup,
	pago_y_ded,
	var_reserva,
	cnt_incurrido,
	no_reclamo
	)
	VALUES(
	_no_poliza,
	_incurrido_bruto,     
	_siniestro_pagado,
	_salv_y_recup,
	_pago_y_ded,
	_var_reserva,
	_cnt_incurrido,
	_no_reclamo
	);

END FOREACH

DROP TABLE tmp_sinis;

END

BEGIN

DEFINE _incurrido_bruto  DECIMAL(16,2);
DEFINE _siniestro_pagado DECIMAL(16,2);
DEFINE _prima_suscrita   DECIMAL(16,2);
DEFINE _prima_pagada     DECIMAL(16,2);

--SET DEBUG FILE TO "\\nemesis\ancon\Store Procedures\Debug\sp_rec14.trc";-- Nombre de la Compania
--TRACE ON;

FOREACH 
 SELECT SUM(prima_suscrita),
        SUM(prima_pagada),		
		SUM(incurrido_bruto),
		SUM(siniestro_pagado),
		SUM(salv_y_recup),
		SUM(pago_y_ded),
		SUM(var_reserva),
		SUM(cnt_incurrido),
 		no_poliza,
		no_reclamo
   INTO	_prima_suscrita,
		_prima_pagada,
		_incurrido_bruto,
		_siniestro_pagado,
		_salv_y_recup,
		_pago_y_ded,
		_var_reserva,
		_cnt_incurrido,
		_no_poliza,
		_no_reclamo
   FROM tmp_montos_uni
  GROUP BY no_poliza,no_reclamo
  	
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
	
	-- F9: 32147 USER:DALBA 
	select sucursal_promotoria,trim(descripcion)
	  into _suc_prom,_nom_sucursal
	  from insagen
	 where codigo_agencia  = _cod_sucursal
	   and codigo_compania = '001';

   select cod_vendedor
     into _cod_vendedor
     from parpromo
    where cod_agente  = _cod_agente
      and cod_agencia = _suc_prom
      and cod_ramo	   = _cod_ramo;
	
	select nombre
	  into _nombre_vendedor
	  from agtvende
	 where cod_vendedor = _cod_vendedor;	 
	-- F9: 32147 USER:DALBA 	
	

	INSERT INTO tmp_siniest_uni(
	no_poliza,           
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
	cod_vendedor,	
	nombre_vendedor,
    cnt_incurrido,
    no_reclamo	
	)
	VALUES(
	_no_poliza,
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
	_cod_vendedor,			  
	_nombre_vendedor,
    _cnt_incurrido,
    _no_reclamo    
	);
END FOREACH
END 

DROP TABLE tmp_montos_uni;
--return 0;
END PROCEDURE;
