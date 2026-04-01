-- Reporte de impresas de emicartasal2
-- Creado    : 25/10/2017 - Autor: Henry Girón
-- Modificado: 25/08/2017 - Autor: Henry Girón
-- SIS v.2.0 -  - DEIVID, S.A.
-- execute procedure sp_pro4958a('001','2017-12')

drop procedure sp_pro4958a;
create procedure sp_pro4958a(a_cia char(3), a_periodo char(7)) 
returning char(20) as poliza,
          char(100) as cliente,
          char(5) as cod_producto_act,
		  char(5) as cod_producto_ant,
		  varchar(50) as nombre_producto_act,    
		  varchar(50) as nombre_producto_ant,    
          char(5) as cod_agente,
          varchar(50) as nombre_agente,
          date as fecha_aniv,
		  smallint as enviado_email,
          date as fecha_email,	
		  char(50) as descr_cia,
		  dec(16,2) as prima_devengada,
		  dec(16,2) as incurrido_bruto,
		  dec(16,2) as siniestralidad,
		  smallint as sin_asistencia_viaje,
		  char(5) as cod_prod_sav,
		  varchar(50) as nombre_producto_sav,
		  integer as porc_aumento,
		  integer as insuf_prima,
		  integer as cambio_edad_t; 
		  
define _no_documento         char(20);
define _cod_producto_act     char(5);
define _cod_producto_ant     char(5);
define _vigencia_inic        date;
define _vigencia_final       date;
define _cod_agente           char(5);
define _nombre_agente        varchar(50);
define _no_poliza            char(10);
define _nombre_producto_act  varchar(50);
define _nombre_producto_ant  varchar(50);
define _nombre_cliente	     char(100);
define _fecha_aniv           date;
define _descr_cia	         char(50);	
define _enviado_email        smallint;
define _fecha_email	         date;
define _prima_devengada      dec(16,2);
define _incurrido_bruto      dec(16,2);
define _siniestralidad       dec(16,2);
define _sav                  smallint;
define _cod_prod_sav         char(5);
define _nombre_producto_sav  varchar(50);

define _prima			dec(16,2);
define _prima_ant       dec(16,2);
define _cambio_edad_t   dec(5,2);
define _inf_suf_prima   dec(5,2);
define _diferencia      dec(16,2);
define _letra           integer;
define _siniestralidad2 dec(16,2);
define _porc_aumento    dec(16,2);
define _cod_perpago		char(3);
define _porc_impuesto   dec(16,2);
define _fecha_desde     date;

drop table if exists tmp_csalud;
CREATE TEMP TABLE tmp_csalud
   (no_documento         char(20),
    nombre_cliente       char(100),
    cod_producto_act     char(5),
	cod_producto_ant     char(5),
    cod_agente           char(5),
	nombre_agente        varchar(50),
    nombre_producto_act  varchar(50),
	nombre_producto_ant  varchar(50),
	fecha_aniv           date,
	enviado_email        smallint, 
	fecha_email	         date,
	prima_devengada      dec(16,2),
	incurrido_bruto      dec(16,2),
	siniestralidad       dec(16,2),
	sav                  smallint,
	cod_prod_sav         char(5),
	porc_aumento         dec(16,2),
	inf_suf_prima        dec(5,2),
	cambio_edad_t        dec(5,2),
    seleccionado         SMALLINT DEFAULT 1 NOT NULL) 
	WITH NO LOG;		   

--set debug file to "sp_pro4958a.trc";
--trace on;
LET _descr_cia       = NULL;
LET _descr_cia       = sp_sis01(a_cia);
let _fecha_desde = MDY(a_periodo[6,7], 1, a_periodo[1,4]);

set isolation to dirty read;
--  póliza, asegurado, fecha aniversario, producto anterior, producto actual
begin
foreach
	SELECT no_documento,   
	       nombre_cliente,
	       cod_producto,   		   
		   cod_producto_ant,
		   fecha_aniv,
		   enviado_email, 
		   date(fecha_email),
		   prima_devengada,
		   incurrido_bruto,
		   siniestralidad,
		   sav,
		   cod_prod_sav
	  INTO _no_documento,
	       _nombre_cliente,
	       _cod_producto_act,
		   _cod_producto_ant,
		   _fecha_aniv,
		   _enviado_email, 
		   _fecha_email,
           _prima_devengada,
           _incurrido_bruto,
		   _siniestralidad,
           _sav,
           _cod_prod_sav		   
	  FROM emicartasal2 
	 WHERE periodo = a_periodo
  ORDER BY no_documento ASC
	
    LET _no_poliza   = sp_sis21(_no_documento);    	
	
	let _cambio_edad_t = sp_pro576b(_no_documento);
	
    let _prima = sp_pro573(_no_poliza);	   
	
------****
		SELECT cod_perpago
		  INTO _cod_perpago
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;
		 
	  if _cod_perpago = '008' then
	    let _letra = 12;
	  elif _cod_perpago = '001' then
	    let _letra = 1;
	  else
	    select meses 
		  into _letra
		  from cobperpa
		 where cod_perpago = _cod_perpago;
	  end if
	    
	  LET _prima_ant = 0;
	  
	  let _prima_ant = sp_pro580(_no_poliza);	   
		 
	 if _prima_ant is null then
		LET _prima_ant = 0;
	 end if
	
	 LET _prima_ant = _prima_ant / _letra;
	
	 LET _porc_aumento = ((_prima / _prima_ant) - 1) * 100;
	
	-- impuesto	
	select sum(factor_impuesto)
	  into _porc_impuesto
	  from emipolim p, prdimpue i
	 where p.cod_impuesto = i.cod_impuesto
	   and p.no_poliza    = _no_poliza;

	if _porc_impuesto is null then
		let _porc_impuesto = 0;
	end if

	let _prima_ant = _prima_ant * (_porc_impuesto / 100) + _prima_ant; 
	let _prima = _prima * (_porc_impuesto / 100) + _prima; 
		  
				 
		 let _porc_aumento = ((_prima / _prima_ant) - 1) * 100;
		 
		 -- Nuevo cálculo
		 
		 select siniestralidad
		   into _siniestralidad2
		   from emicartasal2
		  where no_documento = _no_documento;
		  
		 if _fecha_desde >= date('01-11-2018') then
			let _siniestralidad2 = 101;
		 end if
		   
		 let _porc_aumento = _porc_aumento;
		 let _cambio_edad_t = _cambio_edad_t;
		 if _cambio_edad_t = 0 then
			let _inf_suf_prima = _porc_aumento;
		 else
			if _siniestralidad2 <= 100 then
				let _inf_suf_prima = 25;
			else
				let _inf_suf_prima = 34;
			end if
			let _cambio_edad_t = _porc_aumento - _inf_suf_prima;
			if _cambio_edad_t < 0 then
				let _cambio_edad_t = 0;
			end if
		 end if	     
------****

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
		exit foreach;
	end foreach
	
	select nombre
	  into _nombre_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select nombre
	  into _nombre_producto_act
	  from prdprod
	 where cod_producto = _cod_producto_act;
	 
	select nombre
	  into _nombre_producto_ant
	  from prdprod
	 where cod_producto = _cod_producto_ant;	 

    insert into tmp_csalud
    values(_no_documento,    
	       _nombre_cliente,
		   _cod_producto_act,
		   _cod_producto_ant,     
		   _cod_agente,      
		   _nombre_agente,
		   _nombre_producto_act, 
		   _nombre_producto_ant,
		   _fecha_aniv,
		   _enviado_email, 
		   _fecha_email,	
           _prima_devengada,
           _incurrido_bruto,
		   _siniestralidad,
           _sav,
           _cod_prod_sav,
           _porc_aumento,
		   _inf_suf_prima,
		   _cambio_edad_t,
		   1);

end foreach

foreach
	select no_documento,     
	       nombre_cliente,
		   cod_producto_act,    
		   cod_producto_ant,      
		   cod_agente,      
		   nombre_agente,   
		   nombre_producto_act,
           nombre_producto_ant,
		   fecha_aniv,
           enviado_email, 
		   fecha_email,
           prima_devengada,
           incurrido_bruto,
		   siniestralidad,
           sav,
           cod_prod_sav,		   
           porc_aumento,
		   inf_suf_prima,
		   cambio_edad_t
	  into _no_documento, 
           _nombre_cliente,	  
		   _cod_producto_act,
		   _cod_producto_ant,
		   _cod_agente,      
           _nombre_agente,
		   _nombre_producto_act,
           _nombre_producto_ant,
		   _fecha_aniv,
           _enviado_email, 
		   _fecha_email,		   
           _prima_devengada,
           _incurrido_bruto,
		   _siniestralidad,
           _sav,
           _cod_prod_sav,		   
           _porc_aumento,
		   _inf_suf_prima,
		   _cambio_edad_t
	  from tmp_csalud
	 where seleccionado = 1					   

	select nombre
	  into _nombre_producto_sav
	  from prdprod
	 where cod_producto = _cod_prod_sav;	 
	 
    return _no_documento,    
	       _nombre_cliente,  
		   _cod_producto_act,
		   _cod_producto_ant,
		   _nombre_producto_act,    
		   _nombre_producto_ant,
		   _cod_agente,      
		   _nombre_agente,
		   _fecha_aniv,
           _enviado_email, 
		   _fecha_email,		   
           _descr_cia,		   
           _prima_devengada,
           _incurrido_bruto,
		   _siniestralidad,
           _sav,
           _cod_prod_sav,
		   _nombre_producto_sav,
           round(_porc_aumento,0),
		   round(_inf_suf_prima,0),
		   round(_cambio_edad_t,0)
		   with resume;   

end foreach

DROP TABLE tmp_csalud;

end

end procedure  